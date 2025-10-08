# Simplified Containerfile for Fedora Silverblue with NVIDIA drivers
# Based on ublue-os/main
# Scripts are fetched directly from ublue-os/main repo - no local maintenance needed!

# Build configuration
ARG FEDORA_VERSION="${FEDORA_VERSION:-42}"
ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"

# Image sources
ARG UBLUE_REGISTRY="ghcr.io/ublue-os"
ARG FEDORA_IMAGE="quay.io/fedora-ostree-desktops/silverblue"

# Optional digest pinning for reproducible builds
ARG BASE_IMAGE_DIGEST=""
ARG AKMODS_DIGEST=""
ARG NVIDIA_AKMODS_DIGEST=""

# Stage 1: Clone ublue-os/main and merge packages
FROM alpine/git AS buildctx
ARG UBLUE_MAIN_VERSION="main"

RUN apk add --no-cache yq jq

RUN <<EOF
  echo "Cloning ublue-os/main repo (branch: $UBLUE_MAIN_VERSION)..."
  git clone --depth=1 --branch "${UBLUE_MAIN_VERSION}" \
    https://github.com/ublue-os/main.git ./ublue-os
  mv ublue-os/sys_files /
  mv ublue-os/build_files/* /
  mv ublue-os/packages.json /ublue-packages.json
EOF

COPY packages.yml /

RUN <<EOF
  set -ex
  echo "Merging ublue packages with custom packages..."

  # Extract ublue packages for "all" and "silverblue" sections
  UBLUE_ALL=$(jq -r '.all.include.all[]' /ublue-packages.json)
  UBLUE_SILVERBLUE=$(jq -r '.all.include.silverblue[]' /ublue-packages.json)

  # Convert your YAML packages to JSON array
  YOUR_PACKAGES=$(yq -o=json '.packages' /packages.yml)

  # Merge all three lists, deduplicate and sort
  jq -n \
    --arg ublue_all "$UBLUE_ALL" \
    --arg ublue_sb "$UBLUE_SILVERBLUE" \
    --argjson yours "$YOUR_PACKAGES" \
    '{"packages": (($ublue_all | split("\n")) + ($ublue_sb | split("\n")) + $yours | unique | sort)}' \
    > /packages.json

  echo "Final package list ($(jq -r '.packages | length' /packages.json) packages):"
  jq -r '.packages[]' /packages.json
EOF

# Stage 2: Get kernel modules from ublue-os
FROM ${UBLUE_REGISTRY}/akmods:main-${FEDORA_VERSION}${AKMODS_DIGEST:+@${AKMODS_DIGEST}} AS akmods

# Stage 3: Get NVIDIA drivers from ublue-os
FROM ${UBLUE_REGISTRY}/akmods-nvidia-open:main-${FEDORA_VERSION}${NVIDIA_AKMODS_DIGEST:+@${NVIDIA_AKMODS_DIGEST}} AS nvidia_akmods

# Stage 4: Build final image
FROM ${FEDORA_IMAGE}:${FEDORA_VERSION}${BASE_IMAGE_DIGEST:+@${BASE_IMAGE_DIGEST}}

# Re-declare ARGs for use in this stage
ARG FEDORA_VERSION="${FEDORA_VERSION:-42}"
ARG IMAGE_NAME="${IMAGE_NAME:-silverblue}"
ARG UBLUE_MAIN_VERSION="${UBLUE_MAIN_VERSION:-main}"

# Download build scripts from ublue-os/main repo and execute
RUN --mount=type=bind,from=buildctx,src=/,dst=/ctx \
  --mount=type=bind,from=akmods,src=/rpms/ublue-os,dst=/tmp/akmods-rpms \
  --mount=type=bind,from=akmods,src=/kernel-rpms,dst=/tmp/kernel-rpms \
  --mount=type=bind,from=nvidia_akmods,src=/rpms,dst=/tmp/akmods-nv-rpms \
  --mount=type=cache,target=/var/cache \
  --mount=type=cache,target=/var/log \
  <<EOF
set -ouex pipefail

rm -f /usr/bin/chsh /usr/bin/lchsh

echo "Running ublue-os build scripts..."

/ctx/install.sh

AKMODNV_PATH=/tmp/akmods-nv-rpms /ctx/nvidia-install.sh

/ctx/initramfs.sh
/ctx/post-install.sh

EOF

# Validate the image
RUN ["bootc", "container", "lint"]

