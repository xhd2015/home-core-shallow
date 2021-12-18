class ApacheArchiva < Formula
  desc "Build Artifact Repository Manager"
  homepage "https://archiva.apache.org/"
  url "https://www.apache.org/dyn/closer.lua?path=archiva/2.2.6/binaries/apache-archiva-2.2.6-bin.tar.gz"
  mirror "https://archive.apache.org/dist/archiva/2.2.6/binaries/apache-archiva-2.2.6-bin.tar.gz"
  sha256 "407490ca925a3b128ddf528bc9574f9284ae4d99d37031215c85a7713c5593c6"
  license all_of: ["Apache-2.0", "GPL-2.0-only"]

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_big_sur: "505a9e101fd62efa819146c7511a370dca2eb2ea2df4ac9f021ba39fff70531c"
    sha256 cellar: :any_skip_relocation, big_sur:       "505a9e101fd62efa819146c7511a370dca2eb2ea2df4ac9f021ba39fff70531c"
    sha256 cellar: :any_skip_relocation, catalina:      "505a9e101fd62efa819146c7511a370dca2eb2ea2df4ac9f021ba39fff70531c"
    sha256 cellar: :any_skip_relocation, x86_64_linux:  "01db1f7644ac0328ce146a540d37e1aec42619a987806f219af8606701b6ff71"
  end

  depends_on "ant" => :build
  depends_on "java-service-wrapper"
  depends_on "openjdk"

  def install
    libexec.install Dir["*"]
    rm_f libexec.glob("bin/wrapper*")
    rm_f libexec.glob("lib/libwrapper*")
    (bin/"archiva").write_env_script libexec/"bin/archiva", Language::Java.java_home_env

    wrapper = Formula["java-service-wrapper"].opt_libexec
    ln_sf wrapper/"bin/wrapper", libexec/"bin/wrapper"
    libext = OS.mac? ? "jnilib" : "so"
    ln_sf wrapper/"lib/libwrapper.#{libext}", libexec/"lib/libwrapper.#{libext}"
    ln_sf wrapper/"lib/wrapper.jar", libexec/"lib/wrapper.jar"
  end

  def post_install
    (var/"archiva/logs").mkpath
    (var/"archiva/data").mkpath
    (var/"archiva/temp").mkpath

    cp_r libexec/"conf", var/"archiva"
  end

  service do
    run [opt_bin/"archiva", "console"]
    environment_variables ARCHIVA_BASE: var/"archiva"
    log_path var/"archiva/logs/launchd.log"
  end

  test do
    assert_match "was not running.", shell_output("#{bin}/archiva stop")
  end
end
