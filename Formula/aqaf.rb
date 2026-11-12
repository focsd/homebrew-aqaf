# Candidate for the focsd/aqaf custom tap, not homebrew/core.
# Refresh the source URL and SHA256 from the published sdist for each release.
class Aqaf < Formula
  include Language::Python::Virtualenv

  desc "Local architecture assessment with provisional heuristic findings"
  homepage "https://aqaf.focsd.com"
  url "https://files.pythonhosted.org/packages/df/bd/0272acf92fbb4a8feee96463e3d0a40ddf37f7c99fe620ec6df67bca283a/aqaf-1.1.2.tar.gz"
  sha256 "a665a39f8c987dd8939638f7a736e2558bb769d3270e473b93f68534facd24a3"
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

    command = "#{bin}/aqaf '#{fixture}' --profile api_backend --pack web --review-knowledge --format json --output -"
    report = JSON.parse(shell_output(command))
    assert_equal version.to_s, report.fetch("aqaf_version")
    assert_equal "api_backend", report.fetch("product_type")
    assert_equal "web", report.fetch("selected_pack")
    assert_kind_of Array, report.fetch("findings")
    assert_equal "none", report.fetch("review_knowledge").fetch("score_effect")
    assert report.key?("score")
    assert_equal before, fixture.children.to_h { |path| [path.basename.to_s, path.read] }

    system libexec/"bin/python", "-c", <<~PYTHON
      import importlib.resources
      import json
      data = importlib.resources.files("aqaf").joinpath("data")
      assert json.loads(data.joinpath("catalog.json").read_text())
      assert data.joinpath("profiles/api_backend.json").is_file()
      assert data.joinpath("packs/web.json").is_file()
      assert json.loads(data.joinpath("documentation_checks.json").read_text())
      knowledge = json.loads(data.joinpath("book_review_knowledge.json").read_text())
      assert len(knowledge["books"]) == 31
      assert len(knowledge["principles"]) == 14
      assert sum(len(b["reading_references"]) for b in knowledge["books"]) == 56
    PYTHON
  end
end
