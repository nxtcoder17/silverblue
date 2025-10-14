ARG FEDORA_VERSION="${FEDORA_VERSION:-42}"

FROM ghcr.io/ublue-os/silverblue-nvidia:${FEDORA_VERSION}
ARG FEDORA_VERSION="${FEDORA_VERSION:-42}"

# Customized Branding
RUN <<EOF
set -ex
sed -i "s|^NAME=.*|NAME=nxtcoder17 edition silverblue ${FEDORA_VERSION}|" /usr/lib/os-release
sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=nxtcoder17 edition silverblue ${FEDORA_VERSION}|" /usr/lib/os-release
EOF

RUN <<EOF
set -ex
rpm-ostree install docker distrobox hyprland
rpm-ostree cleanup -m
ostree container commit
EOF

