# Candidate for the focsd/aqaf custom tap, not homebrew/core.
# Refresh the source URL and SHA256 from the published sdist for each release.
class Aqaf < Formula
  include Language::Python::Virtualenv

  desc "Local architecture assessment with provisional heuristic findings"
  homepage "https://aqaf.focsd.com"
  url "https://files.pythonhosted.org/packages/b9/6d/33cb711a7b996c3ad9c2297ce47e90079e67ef97c5088751334977a5a039/aqaf-1.1.0.tar.gz"
  sha256 "6dde3e4ef8edf12f8ee5abcb6f536a2417d0283ccf374c1e8024a1342187b07c"
  license "MIT"

  depends_on "python@3.15"

  def install
    virtualenv_install_with_resources system_site_packages: false
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/aqaf --version")
    assert_match "api_backend", shell_output("#{bin}/aqaf profiles list")
    assert_match "web", shell_output("#{bin}/aqaf packs list")

    fixture = testpath/"fixture with spaces"
    fixture.mkpath
    (fixture/"pyproject.toml").write <<~TOML
      [project]
      name = "aqaf-formula-test"
      version = "0.1.0"
    TOML
    (fixture/"app.py").write "# Synthetic scan input; never executed.\n"
    before = fixture.children.to_h { |path| [path.basename.to_s, path.read] }

    command = "#{bin}/aqaf '#{fixture}' --profile api_backend --pack web --format json --output -"
    report = JSON.parse(shell_output(command))
    assert_equal version.to_s, report.fetch("aqaf_version")
    assert_equal "api_backend", report.fetch("product_type")
    assert_equal "web", report.fetch("selected_pack")
    assert_kind_of Array, report.fetch("findings")
    assert report.key?("score")
    assert_equal before, fixture.children.to_h { |path| [path.basename.to_s, path.read] }

    system libexec/"bin/python", "-c", <<~PYTHON
      import importlib.resources
      import json
      data = importlib.resources.files("aqaf").joinpath("data")
      assert json.loads(data.joinpath("catalog.json").read_text())
      assert data.joinpath("profiles/api_backend.json").is_file()
      assert data.joinpath("packs/web.json").is_file()
    PYTHON
  end
end
