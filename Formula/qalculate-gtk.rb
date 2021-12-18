class QalculateGtk < Formula
  desc "Multi-purpose desktop calculator"
  homepage "https://qalculate.github.io/"
  url "https://github.com/Qalculate/qalculate-gtk/releases/download/v3.22.0/qalculate-gtk-3.22.0.tar.gz"
  sha256 "ba6c0238b5f926ac94e234e15a2dfa84215938da5df6fea136db75c5db488556"
  license "GPL-2.0-or-later"

  bottle do
    sha256 arm64_big_sur: "ffa893d85b00e4201a97389f4b4ad4b1e223e61c6a943af2591bf448f6162746"
    sha256 monterey:      "9f5f210235d527925b99249cf24177a486ccba5d6ade109476e50670023acfae"
    sha256 big_sur:       "e4cd18b7b758de6bb51b0600034a4f121bebf1b1064357d4819533c2c1f5e765"
    sha256 catalina:      "d1773412e511081fe8abfbad538102e6d5193ca2c19a42a64a08e67a0df9ef92"
  end

  depends_on "intltool" => :build
  depends_on "pkg-config" => :build
  depends_on "adwaita-icon-theme"
  depends_on "gtk+3"
  depends_on "libqalculate"

  def install
    system "./configure", "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/qalculate-gtk", "-v"
  end
end
