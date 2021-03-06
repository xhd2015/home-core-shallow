class Crun < Formula
  desc "Fast and lightweight fully featured OCI runtime and C library"
  homepage "https://github.com/containers/crun"
  url "https://github.com/containers/crun/releases/download/1.3/crun-1.3.tar.xz"
  sha256 "27ef1e0628e5f077174be86d62d3f7f2e27690dfb72f1dbd599fffb620357125"
  license any_of: ["GPL-2.0-or-later", "LGPL-2.1-or-later"]

  bottle do
    rebuild 1
    sha256 cellar: :any_skip_relocation, x86_64_linux: "97bee9bcd63807320f098f03d4a86f774a16a18bb10ab3f5ae067c0f3a764e86"
  end

  depends_on "autoconf" => :build
  depends_on "automake" => :build
  depends_on "go-md2man" => :build
  depends_on "libtool" => :build
  depends_on "pkg-config" => :build
  depends_on "python@3.10" => :build

  depends_on "libcap"
  depends_on "libseccomp"
  depends_on :linux
  depends_on "systemd"
  depends_on "yajl"

  def install
    system "./autogen.sh"
    system "./configure", "--prefix=#{prefix}"
    system "make"
    system "make", "install"
  end

  test do
    assert_equal "", shell_output("crun --rootless=true list -q").strip
  end
end
