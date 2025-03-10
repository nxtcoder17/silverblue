ARG FEDORA_VERSION=41

FROM ghcr.io/ublue-os/silverblue-asus-nvidia:${FEDORA_VERSION}
ARG FEDORA_VERSION
RUN sed -i "s|^NAME=.*|NAME=nxtcoder17 edition silverblue ${FEDORA_VERSION}|" /usr/lib/os-release
RUN sed -i "s|^PRETTY_NAME=.*|PRETTY_NAME=nxtcoder17 edition silverblue ${FEDORA_VERSION}|" /usr/lib/os-release

RUN rpm-ostree override remove firefox firefox-langpacks
RUN rpm-ostree install kitty distrobox docker wayfire hyprland \
  xorg-x11-xauth xorg-x11-xinit gnome-session-xsession
RUN rpm-ostree cleanup -m && ostree container commit
