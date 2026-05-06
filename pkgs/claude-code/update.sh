#!/usr/bin/env nix
#!nix shell --ignore-environment nixpkgs#cacert nixpkgs#coreutils nixpkgs#curl nixpkgs#bash --command bash

set -euo pipefail

BASE_URL="https://storage.googleapis.com/claude-code-dist-86c565f3-f756-42ad-8dfa-d59b1c096819/claude-code-releases"

VERSION="${1:-$(curl -fsSL "$BASE_URL/latest")}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# When run via nix-update the script is copied to the read-only nix store;
# fall back to the package path relative to the flake root (cwd set by nix-update).
if [[ "$SCRIPT_DIR" == /nix/store/* ]]; then
  SCRIPT_DIR="pkgs/claude-code"
fi

curl -fsSL "$BASE_URL/$VERSION/manifest.json" --output "$SCRIPT_DIR/manifest.json"
