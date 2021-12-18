class X8664ElfGdb < Formula
  desc "GNU debugger for x86_64-elf cross development"
  homepage "https://www.gnu.org/software/gdb/"
  # Please add to synced_versions_formulae.json once version synced with gdb
  url "https://ftp.gnu.org/gnu/gdb/gdb-10.2.tar.xz"
  mirror "https://ftpmirror.gnu.org/gdb/gdb-10.2.tar.xz"
  sha256 "aaa1223d534c9b700a8bec952d9748ee1977513f178727e1bee520ee000b4f29"
  license "GPL-3.0-or-later"
  revision 2
  head "https://sourceware.org/git/binutils-gdb.git", branch: "master"

  livecheck do
    formula "gdb"
  end

  bottle do
    sha256 arm64_monterey: "26c14e55930d02fe1fbdae9e291eebe6c61be3024dff60aca750e9b0b02a2934"
    sha256 arm64_big_sur:  "58cb24351d365c96711bf75dc289f8f9de3604d3b8b422f4a15d2ee1ae083985"
    sha256 monterey:       "869cf4bac78d9633651b179ad0100b1608a95622442b732edc936d71a1abfb35"
    sha256 big_sur:        "76e99b179908710c660b9d54a5de1fa69e5349664ae080f49775206d90a8b626"
    sha256 catalina:       "275e715114dfed54f12e6bfc94ba2aadb6bd7e71d9bbd3cd56a84b27b031bc59"
  end

  depends_on "x86_64-elf-gcc" => :test
  depends_on "python@3.10"
  depends_on "xz"

  uses_from_macos "zlib"

  # Fix for https://sourceware.org/bugzilla/show_bug.cgi?id=26949#c8
  # Remove when upstream includes this commit
  # https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;h=b413232211bf
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/242630de4b54d6c57721e12ce88988a0f4e41202/gdb/gdb-10.2.patch"
    sha256 "36652e9d97037266650a3b31f9f39539c4b376d31016fa4fc325dc0aa7930acc"
  end

  def install
    target = "x86_64-elf"
    args = %W[
      --target=#{target}
      --prefix=#{prefix}
      --datarootdir=#{share}/#{target}
      --includedir=#{include}/#{target}
      --infodir=#{info}/#{target}
      --mandir=#{man}
      --disable-debug
      --disable-dependency-tracking
      --with-lzma
      --with-python=#{which("python3")}
      --with-system-zlib
      --disable-binutils
    ]

    mkdir "build" do
      system "../configure", *args
      system "make"

      system "make", "install-gdb"
    end
  end

  test do
    (testpath/"test.c").write "void _start(void) {}"
    system "#{Formula["x86_64-elf-gcc"].bin}/x86_64-elf-gcc", "-g", "-nostdlib", "test.c"
    assert_match "Symbol \"_start\" is a function at address 0x",
          shell_output("#{bin}/x86_64-elf-gdb -batch -ex 'info address _start' a.out")
  end
end
