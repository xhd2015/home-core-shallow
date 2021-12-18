class Ooniprobe < Formula
  desc "Network interference detection tool"
  homepage "https://ooni.org/"
  url "https://github.com/ooni/probe-cli/archive/v3.13.0.tar.gz"
  sha256 "a055aed8c2d0d898b7cdb843cf247cf3b593c8ac7045103c08b3088b7d4d1737"
  license "GPL-3.0-or-later"

  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_monterey: "207b5687cc32f010d5f6f55e2b95f69e086fb28a2825078bbbfd4861bfc09c61"
    sha256 cellar: :any_skip_relocation, arm64_big_sur:  "d5d36efcb051f08355c23b62c0a244cd67e706b8674302903a908c428a2ac6d5"
    sha256 cellar: :any_skip_relocation, monterey:       "e6fc0c3d3350eea9206523e06283e6842989d63cbd865d80610c1e1a3c7867d8"
    sha256 cellar: :any_skip_relocation, big_sur:        "7125b855b7a0edeb91597e8b0aa525a5ccde50c6ac0bd2c23b5671b898b12699"
    sha256 cellar: :any_skip_relocation, catalina:       "0c57f460123364905bbfa22a88943bc7566e318c26298847d3925664a67a5196"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "8321538ff21f1692b8b9f569476ba61dc76feda24bc05a9adab72a9f2a77c177"
  end

  depends_on "go" => :build

  def install
    system "go", "run", "./internal/cmd/getresources"
    system "go", "build", *std_go_args, "-ldflags", "-s -w", "./cmd/ooniprobe"
    (var/"ooniprobe").mkpath
  end

  test do
    (testpath/"config.json").write <<~EOS
      {
        "_version": 3,
        "_informed_consent": true,
        "sharing": {
          "include_ip": false,
          "include_asn": true,
          "upload_results": false
        },
        "nettests": {
          "websites_url_limit": 1,
          "websites_enabled_category_codes": []
        },
        "advanced": {
          "send_crash_reports": true,
          "collect_usage_stats": true
        }
      }
    EOS

    mkdir_p "#{testpath}/ooni_home"
    ENV["OONI_HOME"] = "#{testpath}/ooni_home"
    Open3.popen3(bin/"ooniprobe", "--config", testpath/"config.json", "run", "websites", "--batch") do |_, _, stderr|
      stderr.to_a.each do |line|
        j_line = JSON.parse(line)
        assert_equal j_line["level"], "info"
      end
    end
  end
end
