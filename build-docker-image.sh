#!/usr/bin/env bash

set -euo pipefail

image_path=$(nix run github:nix-community/nixos-generators/1.4.0 -- --format qcow --flake .#kubevirt-vpn)

DOCKERFILE=$(mktemp /tmp/Dockerfile.XXXXXX)
trap 'rm -f -- "${DOCKERFILE}"' EXIT

cat > "${DOCKERFILE}" <<EOF
FROM scratch

COPY --chown=107:107 ./nixos.qcow2 /disk/
EOF

docker build -t simonswine/kubevirt-vpn-container-disk -f "${DOCKERFILE}" "$(dirname "${image_path}")"
