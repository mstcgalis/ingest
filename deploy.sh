#!/usr/bin/env bash
# Deploy a new ingest release and update the Homebrew tap.
# Usage: ./deploy.sh <version>  (e.g. ./deploy.sh 1.1.0)

set -euo pipefail

TAP_DIR="$HOME/src/homebrew-tap"
FORMULA="$TAP_DIR/Formula/ingest.rb"

if [[ -z "${1:-}" ]]; then
  echo "Usage: ./deploy.sh <version>"
  echo "  e.g. ./deploy.sh 1.1.0"
  exit 1
fi

VERSION="$1"
TAG="v$VERSION"

# update version in script
sed -i '' "s/^VERSION=.*/VERSION=\"$VERSION\"/" ingest

# commit, tag, push
git add ingest ingest.config.example LICENSE deploy.sh README.md
git commit -m "Release $TAG"
git tag "$TAG"
git push && git push --tags

# create github release
gh release create "$TAG" --title "$TAG" --generate-notes

# get sha256 of the tarball
SHA=$(curl -sL "https://github.com/mstcgalis/ingest/archive/refs/tags/$TAG.tar.gz" | shasum -a 256 | awk '{print $1}')

# update formula
sed -i '' "s|/tags/v[0-9]*\.[0-9]*\.[0-9]*\.tar\.gz|/tags/$TAG.tar.gz|" "$FORMULA"
sed -i '' "s/sha256 \".*\"/sha256 \"$SHA\"/" "$FORMULA"

# commit and push tap
cd "$TAP_DIR"
git add Formula/ingest.rb
git commit -m "Bump ingest to $TAG"
git push

# upgrade local install (pull tap directly to avoid cache race)
cd "$(brew --repository mstcgalis/tap)" && git pull
brew reinstall ingest

echo ""
echo "Deployed ingest $TAG"
