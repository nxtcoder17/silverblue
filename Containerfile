ARG FEDORA_MAJOR_VERSION=39

# FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
FROM ghcr.io/ublue-os/silverblue-asus-nvidia:${FEDORA_MAJOR_VERSION}
ARG FEDORA_MAJOR_VERSION
#RUN sed -i "s,^PRETTY_NAME=.*,PRETTY_NAME=\"Fedora Linux ${FEDORA_MAJOR_VERSION} \(nxtcoder17\)\"," /usr/lib/os-release

RUN rpm-ostree install kitty distrobox picom docker

RUN rpm-ostree cleanup -m && ostree container commit
