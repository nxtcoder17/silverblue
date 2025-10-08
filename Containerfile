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
RUN apk add --no-cache yq jq

RUN <<EOF
  git_branch="main"
  echo "Cloning ublue-os/main repo (branch: $git_branch)..."
  git clone --depth=1 --branch "${git_branch}" \
    https://github.com/ublue-os/main.git ./ublue-os
  mv ublue-os/sys_files /
  mv ublue-os/build_files/* /
  mv ublue-os/packages.json /ublue-packages.json
EOF

COPY packages.yml /

RUN <<EOF
  set -ex
  echo "Merging ublue packages with custom packages..."

  # Convert your YAML packages to JSON array
  yq -o=json /packages.yml > /additional-packages.json

  jq --slurpfile pkgs /additional-packages.json \
   '.all.include.silverblue += $pkgs[0].packages' \
   /ublue-packages.json > /packages.json

  echo "also installing user packages"
  jq -r '.all.include.silverblue' </packages.json
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

# RUN rpm-ostree override remove firefox firefox-langpacks
# RUN rpm-ostree cleanup -m
#
# RUN sed -i "s|^NAME=.*|NAME=nxtcoder17 edition silverblue ${FEDORA_VERSION}|" /usr/lib/os-release
# RUN sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=nxtcoder17 edition silverblue ${FEDORA_VERSION}|" /usr/lib/os-release
