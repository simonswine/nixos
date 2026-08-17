#!/usr/bin/env bash

set -euo pipefail

# The image format module lives in targets/kubevirt-vpn/qcow.nix and the
# system is exposed as kubevirtConfigurations rather than nixosConfigurations,
# so `nix flake check` does not evaluate it as a standalone system.
# Builds $out/nixos.qcow2, which is the docker build context below.
image_dir=$(nix build --no-link --print-out-paths \
  '.#kubevirtConfigurations.kubevirt-vpn.config.system.build.qcow')

DOCKERFILE=$(mktemp /tmp/Dockerfile.XXXXXX)
trap 'rm -f -- "${DOCKERFILE}"' EXIT

cat > "${DOCKERFILE}" <<EOF
FROM scratch

COPY --chown=107:107 ./nixos.qcow2 /disk/
EOF

docker build -t simonswine/kubevirt-vpn-container-disk -f "${DOCKERFILE}" "${image_dir}"
