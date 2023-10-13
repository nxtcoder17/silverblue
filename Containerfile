ARG FEDORA_MAJOR_VERSION=39

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location

COPY ./rootfs /

# rpmfusion setup
RUN rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN mkdir -p /var/lib && ln -s /usr/lib/alternatives /var/lib/alternatives

RUN rpm-ostree override remove firefox firefox-langpacks
RUN rpm-ostree update \
  --uninstall rpmfusion-free-release \
  --uninstall rpmfusion-nonfree-release \
  --install rpmfusion-free-release \
  --install rpmfusion-nonfree-release
RUN rpm-ostree install gnome-tweaks distrobox picom 

RUN rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1 initcall_blacklist=simpledrm_platform_driver_init

RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
  systemctl enable rpm-ostreed-automatic.timer

RUN rpm-ostree install akmod-nvidia xorg-x11-drv-nvidia-cuda xorg-x11-drv-nvidia-power asusctl supergfxctl

RUN flatpak remove --all && \
  flatpak remote-delete fedora  && \
  flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo && \
  flatpak update

RUN rpm-ostree cleanup -m && ostree container commit
