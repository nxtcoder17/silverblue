## Custom Silverblue ostree

as of now, nothing much out of the box, just installing nvidia drivers, and hoping it boots up 😎

### How to Use
```bash
# it pins our current ostree to index 0, so that we can always boot into it
sudo ostree admin pin 0 # pin to an index number

sudo rpm-ostree reset # will remove all layerd packages, and prepare the system for rebasing

rpm-ostree update && reboot # will update the system, and reboot
```

Once, done with above:
```bash
rpm-ostree rebase ostree-unverified-registry:ghcr.io/nxtcoder17/silverblue:sha256-5e67a1d
```

