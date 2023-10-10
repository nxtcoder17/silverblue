#! /usr/bin/env bash

set -o pipefail
set -o errexit

rpm-ostree override remove firefox firefox-langpacks

rpm-ostree update --uninstall rpmfusion-free-release --uninstall rpmfusion-nonfree-release --install rpmfusion-free-release --install rpmfusion-nonfree-release

rpm-ostree install \
  distrobox \
  gnome-tweaks \
  akmod-nvidia xorg-x11-drv-nvidia-cuda

rpm-ostree kargs \
  --append=rd.driver.blacklist=nouveau \
  --append=modprobe.blacklist=nouveau \
  --append=nvidia-drm.modeset=1 \
  initcall_blacklist=simpledrm_platform_driver_init

sed -i 's/#AutomaticUpdatePolicy.*/AutomaticUpdatePolicy=stage/' /etc/rpm-ostreed.conf
systemctl enable rpm-ostreed-automatic.timer
systemctl enable flatpak-automatic.timer
rpm-ostree cleanup -m
ostree container commit
