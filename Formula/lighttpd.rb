class Lighttpd < Formula
  desc "Small memory footprint, flexible web-server"
  homepage "https://www.lighttpd.net/"
  url "https://download.lighttpd.net/lighttpd/releases-1.4.x/lighttpd-1.4.63.tar.xz"
  sha256 "2aef7f0102ebf54a1241a1c3ea8976892f8684bfb21697c9fffb8de0e2d6eab9"
  license "BSD-3-Clause"
  revision 1

  livecheck do
    url "https://download.lighttpd.net/lighttpd/releases-1.4.x/"
    regex(/href=.*?lighttpd[._-]v?(\d+(?:\.\d+)+)\.t/i)
  end

  bottle do
    sha256 arm64_monterey: "febd63ab82f4b96ee6b1b6b7e4e658202aa1f87af58b8a2f635d27da50c82137"
    sha256 arm64_big_sur:  "1f2b0fa8fc1fa2e6bf4717da8a2b770ceaf3e028f60a54d4556991ef4170e887"
    sha256 monterey:       "6f2557e86538603fc34fefc4e33e35abd50962bc021e548877dad2877413fcbc"
    sha256 big_sur:        "67edde9ec018c162d4188619e4840a6fdbea2f5418bb8c1d30d48a1438fba1b1"
    sha256 catalina:       "30b655e43f0f325eab7157986e7832e85c37bc22686b259d6626a103af608794"
    sha256 x86_64_linux:   "62a9f6a041bc72126cddf1fad869b4c33470ce9f4f1852b7c351f73163728610"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "openldap"
  depends_on "openssl@1.1"
  depends_on "pcre2"

  # default max. file descriptors; this option will be ignored if the server is not started as root
  MAX_FDS = 512

  def config_path
    etc/"lighttpd"
  end

  def log_path
    var/"log/lighttpd"
  end

  def www_path
    var/"www"
  end

  def run_path
    var/"lighttpd"
  end

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --sbindir=#{bin}
      --with-bzip2
      --with-ldap
      --with-openssl
      --without-pcre
      --with-pcre2
      --with-zlib
    ]

    # autogen must be run, otherwise prebuilt configure may complain
    # about a version mismatch between included automake and Homebrew's
    system "./autogen.sh"
    system "./configure", *args
    system "make", "install"

    unless File.exist? config_path
      config_path.install "doc/config/lighttpd.conf", "doc/config/modules.conf"
      (config_path/"conf.d/").install Dir["doc/config/conf.d/*.conf"]
      inreplace config_path+"lighttpd.conf" do |s|
        s.sub!(/^var\.log_root\s*=\s*".+"$/, "var.log_root    = \"#{log_path}\"")
        s.sub!(/^var\.server_root\s*=\s*".+"$/, "var.server_root = \"#{www_path}\"")
        s.sub!(/^var\.state_dir\s*=\s*".+"$/, "var.state_dir   = \"#{run_path}\"")
        s.sub!(/^var\.home_dir\s*=\s*".+"$/, "var.home_dir    = \"#{run_path}\"")
        s.sub!(/^var\.conf_dir\s*=\s*".+"$/, "var.conf_dir    = \"#{config_path}\"")
        s.sub!(/^server\.port\s*=\s*80$/, "server.port = 8080")
        s.sub!(%r{^server\.document-root\s*=\s*server_root \+ "/htdocs"$}, "server.document-root = server_root")

        # get rid of "warning: please use server.use-ipv6 only for hostnames, not
        # without server.bind / empty address; your config will break if the kernel
        # default for IPV6_V6ONLY changes"
        s.sub!(/^server.use-ipv6\s*=\s*"enable"$/, 'server.use-ipv6 = "disable"')

        s.sub!(/^server\.username\s*=\s*".+"$/, 'server.username  = "_www"')
        s.sub!(/^server\.groupname\s*=\s*".+"$/, 'server.groupname = "_www"')
        s.sub!(/^#server\.network-backend\s*=\s*"sendfile"$/, 'server.network-backend = "writev"')

        # "max-connections == max-fds/2",
        # https://redmine.lighttpd.net/projects/1/wiki/Server_max-connectionsDetails
        s.sub!(/^#server\.max-connections = .+$/, "server.max-connections = " + (MAX_FDS / 2).to_s)
      end
    end

    log_path.mkpath
    (www_path/"htdocs").mkpath
    run_path.mkpath
  end

  def caveats
    <<~EOS
      Docroot is: #{www_path}

      The default port has been set in #{config_path}/lighttpd.conf to 8080 so that
      lighttpd can run without sudo.
    EOS
  end

  plist_options manual: "lighttpd -f #{HOMEBREW_PREFIX}/etc/lighttpd/lighttpd.conf"

  def plist
    <<~EOS
      <?xml version="1.0" encoding="UTF-8"?>
      <!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
      <plist version="1.0">
      <dict>
        <key>Label</key>
        <string>#{plist_name}</string>
        <key>ProgramArguments</key>
        <array>
          <string>#{opt_bin}/lighttpd</string>
          <string>-D</string>
          <string>-f</string>
          <string>#{config_path}/lighttpd.conf</string>
        </array>
        <key>RunAtLoad</key>
        <true/>
        <key>KeepAlive</key>
        <false/>
        <key>WorkingDirectory</key>
        <string>#{HOMEBREW_PREFIX}</string>
        <key>StandardErrorPath</key>
        <string>#{log_path}/output.log</string>
        <key>StandardOutPath</key>
        <string>#{log_path}/output.log</string>
        <key>HardResourceLimits</key>
        <dict>
          <key>NumberOfFiles</key>
          <integer>#{MAX_FDS}</integer>
        </dict>
        <key>SoftResourceLimits</key>
        <dict>
          <key>NumberOfFiles</key>
          <integer>#{MAX_FDS}</integer>
        </dict>
      </dict>
      </plist>
    EOS
  end

  test do
    system "#{bin}/lighttpd", "-t", "-f", config_path/"lighttpd.conf"
  end
end
