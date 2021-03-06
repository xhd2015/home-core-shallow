class Pipgrip < Formula
  include Language::Python::Virtualenv

  desc "Lightweight pip dependency resolver"
  homepage "https://github.com/ddelange/pipgrip"
  url "https://files.pythonhosted.org/packages/9e/30/e5779f9dbe1a470ee72d34843c7414bcbc3e025db50d50f3e7d50232704d/pipgrip-0.6.12.tar.gz"
  sha256 "b29e48dd8a9a6e6be2b1f0c3bf1aafb2bd16d609169f43ef254b7503b70daaaa"
  license "BSD-3-Clause"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "3cbe666e083749001c83953248641c1bdf9e5156be0a3b05a6aa4b53ad6477cf"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "bc81bc9d56af0565abf4dc741f27389804e0f5ea82eae42e12f80bd8b8a3673e"
    sha256 cellar: :any_skip_relocation, monterey:       "d019aa022d60398fdbbaeb83b6eb1ec68a823720227aca2ef0ddcfcd9b966783"
    sha256 cellar: :any_skip_relocation, big_sur:        "e53b4d46599826185ac266ea7638310f6418bcb6021beb0b04be553ab584d076"
    sha256 cellar: :any_skip_relocation, catalina:       "492fbe789d5a115971fc157a634a0be82f6732f3a0f89d8fb9f4fc454f4ae2b0"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "56a9e23ef63392d84791d6d33b85b8cad6aef06de243783868adaf3e510b6134"
  end

  depends_on "python@3.10"
  depends_on "six"

  resource "anytree" do
    url "https://files.pythonhosted.org/packages/d8/45/de59861abc8cb66e9e95c02b214be4d52900aa92ce34241a957dcf1d569d/anytree-2.8.0.tar.gz"
    sha256 "3f0f93f355a91bc3e6245319bf4c1d50e3416cc7a35cc1133c1ff38306bbccab"
  end

  resource "click" do
    url "https://files.pythonhosted.org/packages/f4/09/ad003f1e3428017d1c3da4ccc9547591703ffea548626f47ec74509c5824/click-8.0.3.tar.gz"
    sha256 "410e932b050f5eed773c4cda94de75971c89cdb3155a72a0831139a79e5ecb5b"
  end

  resource "packaging" do
    url "https://files.pythonhosted.org/packages/df/9e/d1a7217f69310c1db8fdf8ab396229f55a699ce34a203691794c5d1cad0c/packaging-21.3.tar.gz"
    sha256 "dd47c42927d89ab911e606518907cc2d3a1f38bbd026385970643f9c5b8ecfeb"
  end

  resource "pkginfo" do
    url "https://files.pythonhosted.org/packages/23/3f/f2251c754073cda0f00043a707cba7db103654722a9afed965240a0b2b43/pkginfo-1.7.1.tar.gz"
    sha256 "e7432f81d08adec7297633191bbf0bd47faf13cd8724c3a13250e51d542635bd"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/ab/61/1a1613e3dcca483a7aa9d446cb4614e6425eb853b90db131c305bd9674cb/pyparsing-3.0.6.tar.gz"
    sha256 "d9bdec0013ef1eb5a84ab39a3b3868911598afa494f5faa038647101504e2b81"
  end

  resource "wheel" do
    url "https://files.pythonhosted.org/packages/4e/be/8139f127b4db2f79c8b117c80af56a3078cc4824b5b94250c7f81a70e03b/wheel-0.37.0.tar.gz"
    sha256 "e2ef7239991699e3355d54f8e968a21bb940a1dbf34a4d226741e64462516fad"
  end

  def install
    virtualenv_install_with_resources
  end

  test do
    assert_match "pipgrip==#{version}", shell_output("#{bin}/pipgrip pipgrip --no-cache-dir")
    # Test gcc dependency
    assert_match "dxpy==", shell_output("#{bin}/pipgrip dxpy --no-cache-dir")
  end
end
