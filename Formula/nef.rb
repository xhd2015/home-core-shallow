class Nef < Formula
  desc "💊 steroids for Xcode Playgrounds"
  homepage "https://nef.bow-swift.io"
  url "https://github.com/bow-swift/nef/archive/0.7.0.tar.gz"
  sha256 "41c49552df2e98649a93fa0b011d9b380ca1c5255aa8469a085e096118d62be2"
  license "Apache-2.0"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "9b18b03102e950a93c946b0a92638a22e114e6cf56829e6249acb7a465b0ce0a"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "ebc41b222f6ec924c8e9cfa96436b35499ef16002169d27d01755655a06ecc4e"
    sha256 cellar: :any_skip_relocation, monterey:       "8a6cc8c5520d6d300cff4e86ab5076fc628e588c897abd65aab85fad50cf2460"
    sha256 cellar: :any_skip_relocation, big_sur:        "ce01b5d542de2cc0dde3b16ae7250d238b7a06ef5139c63458dea8918a63c170"
    sha256 cellar: :any_skip_relocation, catalina:       "770c78fd20020f2a5fa6fc30759d55af95e7aabab81f91680b6113917bdc2457"
  end

  depends_on xcode: "11.4"

  def install
    inreplace "Makefile", "$(MAKE) bash", ""
    inreplace "Makefile", "$(MAKE) zsh", ""
    system "make", "install", "prefix=#{prefix}", "version=#{version}"
  end

  test do
    system "#{bin}/nef", "markdown",
           "--project", "#{share}/tests/Documentation.app",
           "--output", "#{testpath}/nef"
    assert_path_exists "#{testpath}/nef/library/apis.md"
  end
end
