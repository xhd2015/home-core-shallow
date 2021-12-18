class N < Formula
  desc "Node version management"
  homepage "https://github.com/tj/n"
  url "https://github.com/tj/n/archive/v8.0.1.tar.gz"
  sha256 "8703ae88fd06ce7f2d0f4018d68bfbab7b26859ed86a86ce4b8f25d2110aee2f"
  license "MIT"
  head "https://github.com/tj/n.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "ec5463763ff6d1a25e35c1079b4e8a536f5e7b53b0dbf9c492787471964895eb"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "ec5463763ff6d1a25e35c1079b4e8a536f5e7b53b0dbf9c492787471964895eb"
    sha256 cellar: :any_skip_relocation, monterey:       "1be91183c7c5e6e002e62b4577596ea0b8648c740e94828831a4501373420846"
    sha256 cellar: :any_skip_relocation, big_sur:        "1be91183c7c5e6e002e62b4577596ea0b8648c740e94828831a4501373420846"
    sha256 cellar: :any_skip_relocation, catalina:       "1be91183c7c5e6e002e62b4577596ea0b8648c740e94828831a4501373420846"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "ec5463763ff6d1a25e35c1079b4e8a536f5e7b53b0dbf9c492787471964895eb"
  end

  def install
    bin.mkdir
    system "make", "PREFIX=#{prefix}", "install"
  end

  test do
    system bin/"n", "ls"
  end
end
