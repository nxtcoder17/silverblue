ARG FEDORA_MAJOR_VERSION=40

# FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
FROM ghcr.io/ublue-os/silverblue-asus-nvidia:${FEDORA_MAJOR_VERSION}
ARG FEDORA_MAJOR_VERSION
RUN sed -i "s|^NAME=.*|NAME=nxtcoder17 edition silverblue ${FEDORA_MAJOR_VERSION}|" /usr/lib/os-release
RUN sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=nxtcoder17 edition silverblue ${FEDORA_MAJOR_VERSION}|" /usr/lib/os-release

# RUN rpm-ostree install kitty distrobox picom docker wayfire hyprland
RUN rpm-ostree override remove firefox firefox-langpacks
RUN rpm-ostree install kitty distrobox picom docker
RUN rpm-ostree cleanup -m && ostree container commit
