require "language/node"

class GitlabCiLocal < Formula
  desc "Run gitlab pipelines locally as shell executor or docker executor"
  homepage "https://github.com/firecow/gitlab-ci-local"
  url "https://registry.npmjs.org/gitlab-ci-local/-/gitlab-ci-local-4.27.1.tgz"
  sha256 "2ee40ca9dbafa2185de5a06c5aa7a6edd1c489079d39ec6e6db2136416cc9683"
  license "MIT"
  head "https://github.com/firecow/gitlab-ci-local.git", branch: "master"

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "a2e4f9eb718249c01846b2885f693755acd1c7efa5751e3cf762fa3ab3bc15f5"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "a2e4f9eb718249c01846b2885f693755acd1c7efa5751e3cf762fa3ab3bc15f5"
    sha256 cellar: :any_skip_relocation, monterey:       "6dfa31c65fb37c47cf848be4d7ef7f47254a0b19de16b87f2cedd2c299ccf69d"
    sha256 cellar: :any_skip_relocation, big_sur:        "6dfa31c65fb37c47cf848be4d7ef7f47254a0b19de16b87f2cedd2c299ccf69d"
    sha256 cellar: :any_skip_relocation, catalina:       "6dfa31c65fb37c47cf848be4d7ef7f47254a0b19de16b87f2cedd2c299ccf69d"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "a2e4f9eb718249c01846b2885f693755acd1c7efa5751e3cf762fa3ab3bc15f5"
  end

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  test do
    (testpath/".gitlab-ci.yml").write <<~YML
      ---
      stages:
        - build
        - tag
      variables:
        HELLO: world
      build:
        stage: build
        needs: []
        tags:
          - shared-docker
        script:
          - echo "HELLO"
      tag-docker-image:
        stage: tag
        needs: [ build ]
        tags:
          - shared-docker
        script:
          - echo $HELLO
    YML

    system "git", "init"
    system "git", "add", ".gitlab-ci.yml"
    system "git", "commit", "-m", "'some message'"
    rm ".git/config"

    (testpath/".git/config").write <<~EOS
      [core]
        repositoryformatversion = 0
        filemode = true
        bare = false
        logallrefupdates = true
        ignorecase = true
        precomposeunicode = true
      [remote "origin"]
        url = git@github.com:firecow/gitlab-ci-local.git
        fetch = +refs/heads/*:refs/remotes/origin/*
      [branch "master"]
        remote = origin
        merge = refs/heads/master
    EOS

    assert_equal shell_output("#{bin}/gitlab-ci-local --list"), <<~OUTPUT
      name              description  stage  when        allow_failure  needs
      build                          build  on_success  false          []
      tag-docker-image               tag    on_success  false          [build]
    OUTPUT
  end
end
