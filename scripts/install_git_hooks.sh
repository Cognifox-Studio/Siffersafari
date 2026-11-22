#!/usr/bin/env bash
#
# Aktivera repots git-hooks (just nu .githooks/pre-push).
#
#   scripts/install_git_hooks.sh
#
# Hooksen ligger i .githooks/ (versionerade) i stallet for .git/hooks/
# (lokala och kopieras inte med vid klon). Vi pekar om core.hooksPath en gang
# per klon i stallet for att kopiera filer, sa att andringar i hooksen slar
# igenom direkt utan ominstallation.

set -euo pipefail

repo_root="$(git rev-parse --show-toplevel 2>/dev/null || true)"
if [ -z "$repo_root" ]; then
  echo "error: kor detta inuti en git-arbetskopia." >&2
  exit 1
fi

cd "$repo_root"

if [ ! -d .githooks ]; then
  echo "error: saknar .githooks/ i $repo_root" >&2
  exit 1
fi

git config core.hooksPath .githooks

# Behall executable-biten aven pa filsystem dar den tappats (t.ex. ZIP-export).
chmod +x .githooks/* 2>/dev/null || true

echo "core.hooksPath = $(git config --get core.hooksPath)"
echo ""
echo "Aktiva hooks:"
for hook in .githooks/*; do
  [ -f "$hook" ] || continue
  echo "  - $(basename "$hook")"
done
echo ""
echo "pre-push kor 'flutter analyze' + 'flutter test test' innan push."
echo "Hoppa over en gang: SKIP_TESTS=1 git push  (eller git push --no-verify)"
