class I386ElfGdb < Formula
  desc "GNU debugger for i386-elf cross development"
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
    sha256 arm64_monterey: "ea7d902a723c95cb18fe55d53c034cc245b663be9591fbc69139ce8c8b7382b0"
    sha256 arm64_big_sur:  "d943e7587d70a3e6a6c58e72688a5b302b8346abd95376ed50a69612fc1b503e"
    sha256 monterey:       "97989e0669664911ab1b563476d3b1e7094456c98b222c4ad54c7a51e25a34cc"
    sha256 big_sur:        "995a23f630c40101c11ad55d4f2b002398f282ea05934630acd4343a9a1aa407"
    sha256 catalina:       "ce22008756d411fbe5f3a4727e157ac7b4fb413f175b2da07793385f884f8cc7"
    sha256 x86_64_linux:   "de8f9b0dc7709e23f693fc38567e80e6b90b5bf3dd81d033e9580baabcaa96a3"
  end

  depends_on "i686-elf-gcc" => :test
  depends_on "python@3.10"
  depends_on "xz" # required for lzma support

  uses_from_macos "texinfo" => :build
  uses_from_macos "zlib"

  # Fix for https://sourceware.org/bugzilla/show_bug.cgi?id=26949#c8
  # Remove when upstream includes this commit
  # https://sourceware.org/git/gitweb.cgi?p=binutils-gdb.git;h=b413232211bf
  patch do
    url "https://raw.githubusercontent.com/Homebrew/formula-patches/242630de4b54d6c57721e12ce88988a0f4e41202/gdb/gdb-10.2.patch"
    sha256 "36652e9d97037266650a3b31f9f39539c4b376d31016fa4fc325dc0aa7930acc"
  end

  def install
    target = "i386-elf"
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
      --with-python=#{Formula["python@3.10"].opt_bin}/python3
      --with-system-zlib
      --disable-binutils
    ]

    mkdir "build" do
      system "../configure", *args
      system "make"

      # Don't install bfd or opcodes, as they are provided by binutils
      system "make", "install-gdb"
    end
  end

  test do
    (testpath/"test.c").write "void _start(void) {}"
    system Formula["i686-elf-gcc"].bin/"i686-elf-gcc", "-g", "-nostdlib", "test.c"
    assert_match "Symbol \"_start\" is a function at address 0x",
                 shell_output("#{bin}/i386-elf-gdb -batch -ex 'info address _start' a.out")
  end
end
