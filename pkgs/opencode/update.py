#!/usr/bin/env nix
#! nix shell --inputs-from .# nixpkgs#python3 nixpkgs#gh nixpkgs#nix --command python3

"""Update script for opencode package (binary releases)."""

import json
import subprocess
from pathlib import Path

HASHES_FILE = Path(__file__).parent / "hashes.json"

# Map nix platforms to release asset names
PLATFORMS = {
    "x86_64-linux": "opencode-linux-x64.tar.gz",
    "aarch64-linux": "opencode-linux-arm64.tar.gz",
    "x86_64-darwin": "opencode-darwin-x64.zip",
    "aarch64-darwin": "opencode-darwin-arm64.zip",
}


def fetch_github_latest_release(owner: str, repo: str) -> str:
    """Fetch the latest release tag using the gh CLI."""
    result = subprocess.run(
        ["gh", "release", "list", "--repo", f"{owner}/{repo}", "--limit", "10", "--json", "tagName,isLatest,isDraft,isPrerelease"],
        capture_output=True,
        text=True,
        check=True,
    )
    releases = json.loads(result.stdout)
    for release in releases:
        if release.get("isLatest"):
            return release["tagName"].lstrip("v")
    # Fallback: first non-draft non-prerelease
    for release in releases:
        if not release.get("isDraft") and not release.get("isPrerelease"):
            return release["tagName"].lstrip("v")
    raise RuntimeError(f"No stable release found for {owner}/{repo}")


def load_hashes(path: Path) -> dict:
    with open(path) as f:
        return json.load(f)


def save_hashes(path: Path, data: dict) -> None:
    with open(path, "w") as f:
        json.dump(data, f, indent=2)
        f.write("\n")


def should_update(current: str, latest: str) -> bool:
    return current != latest


def nix_prefetch_url(url: str) -> str:
    """Return the SRI hash for a URL using nix-prefetch-url."""
    result = subprocess.run(
        ["nix-prefetch-url", "--type", "sha256", url],
        capture_output=True,
        text=True,
        check=True,
    )
    sha256_hex = result.stdout.strip()
    result2 = subprocess.run(
        ["nix", "hash", "to-sri", "--type", "sha256", sha256_hex],
        capture_output=True,
        text=True,
        check=True,
    )
    return result2.stdout.strip()


def calculate_platform_hashes(url_template: str, platforms: dict) -> dict:
    """Download each platform asset and compute its SRI hash."""
    hashes = {}
    for platform, asset in platforms.items():
        url = url_template.format(platform=asset)
        print(f"  Fetching hash for {platform}: {url}")
        sri = nix_prefetch_url(url)
        hashes[platform] = sri
        print(f"    {sri}")
    return hashes


def main() -> None:
    """Update the opencode package."""
    data = load_hashes(HASHES_FILE)
    current = data["version"]
    latest = fetch_github_latest_release("anomalyco", "opencode")

    print(f"Current: {current}, Latest: {latest}")

    if not should_update(current, latest):
        print("Already up to date")
        return

    url_template = f"https://github.com/anomalyco/opencode/releases/download/v{latest}/{{platform}}"
    hashes = calculate_platform_hashes(url_template, PLATFORMS)

    save_hashes(HASHES_FILE, {"version": latest, "hashes": hashes})
    print(f"Updated to {latest}")


if __name__ == "__main__":
    main()
