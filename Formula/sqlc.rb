class Sqlc < Formula
  desc "Generate type safe Go from SQL"
  homepage "https://sqlc.dev/"
  url "https://github.com/kyleconroy/sqlc/archive/v1.11.0.tar.gz"
  sha256 "6e18562a066ea70687e7abb642e3dde48a128633f71d29788c4df6a886eac1d1"
  license "MIT"
  head "https://github.com/kyleconroy/sqlc.git", branch: "main"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "40452ecb6dc329fc185384409864581c4d30fa91315c6d949b06e1787d6a6c94"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "487313b46c7c867430588f1035a8d43a9d7baa3d13de3546ba87a985376c7db8"
    sha256 cellar: :any_skip_relocation, monterey:       "685dedde35b2bb87775f9ea49a35ad20570dbf668cedb2eb04bd8f8cfd5103b8"
    sha256 cellar: :any_skip_relocation, big_sur:        "098b43398bdea2d3fe4b9967084616f5854d8ad62d02966bcba5c8ff9532ae2d"
    sha256 cellar: :any_skip_relocation, catalina:       "1e26901a8a591cae25ab8a7297dc996f8d5a1ca69b6430067ba0feb00ccf7e59"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "39bec999ea802a733c401ae35744d0d31900f9b1f2230a7923dba2b6d04819de"
  end

  depends_on "go" => :build

  def install
    system "go", "build", *std_go_args, "-ldflags", "-s -w", "./cmd/sqlc"
  end

  test do
    (testpath/"sqlc.json").write <<~SQLC
      {
        "version": "1",
        "packages": [
          {
            "name": "db",
            "path": ".",
            "queries": "query.sql",
            "schema": "query.sql",
            "engine": "postgresql"
          }
        ]
      }
    SQLC

    (testpath/"query.sql").write <<~EOS
      CREATE TABLE foo (bar text);

      -- name: SelectFoo :many
      SELECT * FROM foo;
    EOS

    system bin/"sqlc", "generate"
    assert_predicate testpath/"db.go", :exist?
    assert_predicate testpath/"models.go", :exist?
    assert_match "// Code generated by sqlc. DO NOT EDIT.", File.read(testpath/"query.sql.go")
  end
end
