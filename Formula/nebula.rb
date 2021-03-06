class Nebula < Formula
  desc "Scalable overlay networking tool for connecting computers anywhere"
  homepage "https://github.com/slackhq/nebula"
  url "https://github.com/slackhq/nebula/archive/v1.5.2.tar.gz"
  sha256 "391ac38161561690a65c0fa5ad65a2efb2d187323cc8ee84caa95fa24cb6c36a"
  license "MIT"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "ba9506da111fa6b894cb7644a881937ee33f5916db6c4318a2042b3ec8fa6bb9"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "ba9506da111fa6b894cb7644a881937ee33f5916db6c4318a2042b3ec8fa6bb9"
    sha256 cellar: :any_skip_relocation, monterey:       "15a503c6ac19d80da1da831c6b71f43b1341001e12495daa55b6e50186c74c1a"
    sha256 cellar: :any_skip_relocation, big_sur:        "15a503c6ac19d80da1da831c6b71f43b1341001e12495daa55b6e50186c74c1a"
    sha256 cellar: :any_skip_relocation, catalina:       "15a503c6ac19d80da1da831c6b71f43b1341001e12495daa55b6e50186c74c1a"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "7ec3420a720d4bb2cf67a38b85f145af8a8a7bca27f7c50f30e6de1e4056da36"
  end

  depends_on "go" => :build

  def install
    ENV["BUILD_NUMBER"] = version
    system "make", "bin"
    bin.install "./nebula"
    bin.install "./nebula-cert"
    prefix.install_metafiles
  end

  plist_options startup: true
  service do
    run [opt_bin/"nebula", "-config", etc/"nebula/config.yml"]
    keep_alive true
    log_path var/"log/nebula.log"
    error_log_path var/"log/nebula.log"
  end

  test do
    system "#{bin}/nebula-cert", "ca", "-name", "testorg"
    system "#{bin}/nebula-cert", "sign", "-name", "host", "-ip", "192.168.100.1/24"
    (testpath/"config.yml").write <<~EOS
      pki:
        ca: #{testpath}/ca.crt
        cert: #{testpath}/host.crt
        key: #{testpath}/host.key
    EOS
    system "#{bin}/nebula", "-test", "-config", "config.yml"
  end
end
