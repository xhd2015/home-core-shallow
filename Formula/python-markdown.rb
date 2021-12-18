class PythonMarkdown < Formula
  include Language::Python::Virtualenv

  desc "Python implementation of Markdown"
  homepage "https://python-markdown.github.io"
  url "https://files.pythonhosted.org/packages/15/06/d60f21eda994b044cbd496892d4d4c5c708aa597fcaded7d421513cb219b/Markdown-3.3.6.tar.gz"
  sha256 "76df8ae32294ec39dcf89340382882dfa12975f87f45c3ed1ecdb1e8cefc7006"
  license "BSD-3-Clause"
  head "https://github.com/Python-Markdown/markdown.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a185b719ea180907172dc532619b7d8f537c39b313670caf747ec5cb65b0972e"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "206bb9e8d0326b6832ef71e9833aed85427b644aefde375370a03e217c907d23"
    sha256 cellar: :any_skip_relocation, monterey:       "7b27f2ea884b0a028259baf5d2bb18a3439065b82fc7a1ff7649df9041c9f216"
    sha256 cellar: :any_skip_relocation, big_sur:        "8693cd64c46b53aad595b4730b47a17cd9ff867e7bab2364aca05c1f83b1dab2"
    sha256 cellar: :any_skip_relocation, catalina:       "20c03905cf6184166c3b5dc52729712a9fa704ea40f17854aa5431a946c4ed25"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "38987a75010f130e12a1130c01a179a39ad849647ae966a6634e8705b1c855ac"
  end

  depends_on "python@3.10"

  def install
    virtualenv_install_with_resources
  end

  test do
    (testpath/"test.md").write("# Hello World!")
    assert_equal "<h1>Hello World!</h1>", shell_output(bin/"markdown_py test.md").strip
  end
end
