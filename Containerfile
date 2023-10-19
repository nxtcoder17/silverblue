ARG FEDORA_MAJOR_VERSION=39

# FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
FROM ghcr.io/ublue-os/vauxite-asus-nvidia:${FEDORA_MAJOR_VERSION}
ARG FEDORA_MAJOR_VERSION
# RUN sed -i "s,^PRETTY_NAME=.*,PRETTY_NAME=\"Fedora Linux ${FEDORA_MAJOR_VERSION} \(nxtcoder17\)\"," /usr/lib/os-release

# COPY ./rootfs /

# rpmfusion setup
RUN rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

# RUN mkdir -p /var/lib && ln -s /usr/lib/alternatives /var/lib/alternatives
RUN rpm-ostree install rpmfusion-free-release rpmfusion-nonfree-release \
  --uninstall rpmfusion-free-release 

RUN rpm-ostree override remove firefox firefox-langpacks
RUN rpm-ostree install gnome-tweaks distrobox picom docker \
  asusctl supergfxctl 
# akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-power

# RUN rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1 initcall_blacklist=simpledrm_platform_driver_init

# RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
#   systemctl enable rpm-ostreed-automatic.timer

# RUN flatpak remove --all && \
#   flatpak remote-delete fedora  && \
#   flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
#   flatpak update

# RUN rm -rf /var/lib
RUN rpm-ostree cleanup -m && ostree container commit
