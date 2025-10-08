## Custom Silverblue ostree

as of now, nothing much out of the box, just installing nvidia drivers, and hoping it boots up 😎

### How to Use
```bash
# it pins our current ostree to index 0, so that we can always boot into it
sudo ostree admin pin 0 # pin to an index number

# check for pinned status with
sudo rpm-ostree status -v


sudo rpm-ostree reset # will remove all layerd packages, and prepare the system for rebasing

rpm-ostree update && reboot # will update the system, and reboot
```

Once, done with above:
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/nxtcoder17/silverblue:sha256-5e67a1d
```

> if many other old pinned/unpinned deployments are there, we must clean it up, otherwise it will just fill up the /boot partition with
> `sudo ostree admin pin -u <index>`
> `sudo ostree admin undeploy <index>`
