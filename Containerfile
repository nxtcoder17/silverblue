ARG FEDORA_VERSION="${FEDORA_VERSION:-42}"

FROM ghcr.io/ublue-os/silverblue-nvidia:${FEDORA_VERSION}
ARG FEDORA_VERSION="${FEDORA_VERSION:-42}"

# Customized Branding
RUN sed -i "s|^NAME=.*|NAME=nxtcoder17 edition silverblue ${FEDORA_VERSION}|" /usr/lib/os-release
RUN sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=nxtcoder17 edition silverblue ${FEDORA_VERSION}|" /usr/lib/os-release

RUN rpm-ostree override remove firefox firefox-langpacks
RUN rpm-ostree install docker distrobox hyprland
RUN rpm-ostree cleanup -m && ostree container commit
