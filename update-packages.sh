#!/usr/bin/env bash
set -euo pipefail

# Discover kubernetes packages from flake outputs and update to latest patch on each branch
while IFS= read -r pkg; do
    # kubernetes-1-32 -> v(1\.32\.[0-9]+)
    IFS='-' read -r _ major minor <<< "$pkg"
    regex="v(${major}\\.${minor}\\.[0-9]+)"
    nix-update --flake --commit --version-regex="$regex" "$pkg"
done < <(
    nix flake show --json 2>/dev/null \
        | jq -r '.packages | to_entries[0].value | keys[]
            | select(test("^kubernetes-[0-9]+-[0-9]+$"))' \
        | sort -u
)

nix-update crush --flake --use-update-script --commit --build
nix-update claude-code --flake --use-update-script --commit --build
