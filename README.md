## Building the VM

**WARNING**: each time you (re-create) the overlay image, you lose all state of the VM. So back up
those Jupyter notebooks!

### Short answer:
1) `./buildvm.sh`
2) Use `overlay.img` as your disk image

### Long answer:
The VM image is built with Nix from a NixOS configuration (`configuration.nix`) using
[NixOS generators](https://github.com/nix-community/nixos-generators). Because the image
is built using Nix, the image will reside in the Nix store, to which ordinary users have
(and should have) no write rights.

A quick solution to this is to create an [overlay image](https://kashyapc.fedorapeople.org/virt/lc-2012/snapshots-handout.html) - this is encapsulated in `./scripts/make-overlay` and wrapped as an `app` entry in the flake file, which creates an environment where `qemu-img` is available.

## Running the VM

Assuming you wish to run using a development copy of QEMU, see `runvm.sh` and make appropriate changes.
