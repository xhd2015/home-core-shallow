class Ortp < Formula
  desc "Real-time transport protocol (RTP, RFC3550) library"
  homepage "https://www.linphone.org/technical-corner/ortp"
  url "https://gitlab.linphone.org/BC/public/ortp/-/archive/5.0.55/ortp-5.0.55.tar.bz2"
  sha256 "c7bac004c9e42ef6f615042fedfe90965c1b7e3d5fd0d78ab960fee2ec6b3b57"
  license "GPL-3.0-or-later"
  head "https://gitlab.linphone.org/BC/public/ortp.git", branch: "master"

  bottle do
    sha256 cellar: :any, arm64_monterey: "00a458d7add85acdab0fa3b7d56c5dfd9c38fe7b32dbfed5b08fdd2a9fd56b00"
    sha256 cellar: :any, arm64_big_sur:  "e519fba20938fb6f113c72fdd8ca091e59a36979a5715686741ee7fde4e6c04a"
    sha256 cellar: :any, monterey:       "b305a0348a8db2df16803ccadc0cf654b8e2a45729f069224b3163ae366bdcac"
    sha256 cellar: :any, big_sur:        "2f45ffe2fe4a19fa11523bd17ace3220adedd4d5484e02421d067e8b19989457"
    sha256 cellar: :any, catalina:       "8d7ac1a980d57c486478bb34d79e700019a6a6910544f8d40f3dad648e123407"
  end

  depends_on "cmake" => :build
  depends_on "pkg-config" => :build
  depends_on "mbedtls@2"

  # bctoolbox appears to follow ortp's version. This can be verified at the GitHub mirror:
  # https://github.com/BelledonneCommunications/bctoolbox
  resource "bctoolbox" do
    url "https://gitlab.linphone.org/BC/public/bctoolbox/-/archive/5.0.55/bctoolbox-5.0.55.tar.bz2"
    sha256 "10bb2a63728c9923a2651bf4e33af63ce82009b7d8f93a62ba3534ec0d1d5810"
  end

  def install
    resource("bctoolbox").stage do
      args = std_cmake_args.reject { |s| s["CMAKE_INSTALL_PREFIX"] } + %W[
        -DCMAKE_INSTALL_PREFIX=#{libexec}
        -DENABLE_TESTS_COMPONENT=OFF
      ]
      system "cmake", ".", *args
      system "make", "install"
    end

    ENV.prepend_path "PKG_CONFIG_PATH", libexec/"lib/pkgconfig"

    args = std_cmake_args + %W[
      -DCMAKE_PREFIX_PATH=#{libexec}
      -DCMAKE_C_FLAGS=-I#{libexec}/include
      -DCMAKE_CXX_FLAGS=-I#{libexec}/include
      -DENABLE_DOC=NO
    ]
    mkdir "build" do
      system "cmake", "..", *args
      system "make", "install"
    end
  end

  test do
    (testpath/"test.c").write <<~EOS
      #include "ortp/logging.h"
      #include "ortp/rtpsession.h"
      #include "ortp/sessionset.h"
      int main()
      {
        ORTP_PUBLIC void ortp_init(void);
        return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-I#{libexec}/include", "-L#{lib}", "-lortp",
           testpath/"test.c", "-o", "test"
    system "./test"
  end
end
