ARG FEDORA_MAJOR_VERSION=39

# FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# COPY ./script.sh /tmp/script.sh
# RUN chmod +x /tmp/script.sh && /tmp/script.sh

FROM quay.io/fedora-ostree-desktops/silverblue:${FEDORA_MAJOR_VERSION}
# See https://pagure.io/releng/issue/11047 for final location


# rpmfusion setup
RUN rpm-ostree install \
  https://mirrors.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm \
  https://mirrors.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm

RUN mkdir -p /var/lib && ln -s /usr/lib/alternatives /var/lib/alternatives

# COPY pkgs /tmp/pkgs
RUN rpm-ostree install gnome-tweaks distrobox akmod-nvidia xorg-x11-drv-nvidia-cuda

RUN rpm-ostree kargs --append=rd.driver.blacklist=nouveau --append=modprobe.blacklist=nouveau --append=nvidia-drm.modeset=1 initcall_blacklist=simpledrm_platform_driver_init
# RUN rpm-ostree install $(cat /tmp/pkgs/base)
# RUN rpm-ostree install $(cat /tmp/pkgs/virt)

RUN sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf && \
  systemctl enable rpm-ostreed-automatic.timer

# RUN rpm-ostree override remove firefox firefox-langpacks && \
# RUN rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release && \
# RUN rpm-ostree install rpmfusion-free-release rpmfusion-nonfree-release && \
#   rpm-ostree install gnome-tweaks distrobox akmod-nvidia xorg-x11-drv-nvidia-cuda && \
#   rpm-ostree cleanup -m && \
#   ostree container commit
# RUN rpm-ostree install gnome-tweaks && \
#   systemctl enable dconf-update.service && \
#   rm -rf /usr/share/gnome-shell/extensions/background-logo@fedorahosted.org && \
#   systemctl enable flatpak-add-flathub-repo.service && \
#   systemctl enable flatpak-replace-fedora-apps.service && \
#   systemctl enable flatpak-cleanup.timer && \
#   sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=check/' /etc/rpm-ostreed.conf && \
#   systemctl enable rpm-ostreed-automatic.timer && \
#   sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/user.conf && \
#   sed -i 's/#DefaultTimeoutStopSec.*/DefaultTimeoutStopSec=15s/' /etc/systemd/system.conf && \
#   rpm-ostree cleanup -m && \
#   ostree container commit
