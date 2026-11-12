# AQAF Homebrew tap

Install the AQAF architecture assessment CLI from the `focsd/aqaf` custom tap:

```sh
brew install focsd/aqaf/aqaf
aqaf --version
aqaf profiles list
aqaf ./your-repository --pack web --format md
```

The fully qualified install command adds the tap automatically. For Homebrew
versions requiring explicit trust before short-name access:

```sh
brew tap focsd/aqaf
brew trust --formula focsd/aqaf/aqaf
brew install aqaf
```

AQAF is a local, read-only heuristic architecture assessment tool. Its quality
index is provisional, not certification of security, scalability or production
readiness. The scanner does not upload source or execute target-repository code.

## Runtime and source

The formula installs AQAF 1.1.1 from its checksummed published PyPI source into
an isolated virtual environment with system-site packages disabled. Homebrew
provides Python 3.15; users do not need a separate pip install or PATH adjustment.
Installation downloads the source and build dependencies. Subsequent scans are
offline. No bottles are currently provided; source installation is used.

Project: https://aqaf.focsd.com

Python release: https://pypi.org/project/aqaf/1.1.1/

License: MIT. This is a custom tap, not a homebrew/core formula.

## Validation and maintenance

The validation workflow covers macOS Apple Silicon, macOS Intel and Linux.
Consult actual workflow results for platform evidence; workflow configuration
alone is not a compatibility guarantee. Local macOS 26.5 arm64 checks also passed
style, strict audit, install/reinstall, functional scans, data packaging, linkage,
and network-denied scanning. Initial-release evidence is recorded with the release.

```sh
HOMEBREW_NO_AUTO_UPDATE=1 brew style focsd/aqaf/aqaf
HOMEBREW_NO_AUTO_UPDATE=1 brew audit --strict focsd/aqaf/aqaf
HOMEBREW_NO_AUTO_UPDATE=1 brew test focsd/aqaf/aqaf
HOMEBREW_NO_AUTO_UPDATE=1 brew linkage --test focsd/aqaf/aqaf
HOMEBREW_NO_AUTOREMOVE=1 brew uninstall focsd/aqaf/aqaf
```

For each release, verify the published source archive URL/SHA256, review the
Homebrew Python dependency and test actual installed behavior before merging.
The upstream build currently resolves setuptools from its declared build-system
requirement; no bit-for-bit rebuild guarantee is claimed. Report upstream CLI
issues through the project site; report tap packaging issues in this repository.

## Upgrade to 1.1.1

```sh
brew update
brew upgrade focsd/aqaf/aqaf
```

This release includes native project discovery, default gitignore/dependency scope filtering, optional documentation checks and book-informed review agendas. Findings remain heuristic; experimental review and book agendas are opt-in and unscored. Review scope changes before replacing an older baseline. See https://aqaf.focsd.com/docs/29-release-1-1-1 for upgrade notes.
