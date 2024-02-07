#!/usr/bin/env bash
set -x
die () {
    echo >&2 "$@"
    exit 1
}

if [ "$#" -ne 1 ]; then
 echo "USAGE ${0} <overlay img destination>"
 die "1 argument required, $# provided"
fi

MEMORY=4096
CPU_CORES=2
SSH_PORT=2089
JUPITER_PORT=8888

# 192K
NVM_TST_IMG="nvm_tst.img"

QEMU_BIN="${HOME}/repos/qemu/build/qemu-system-x86_64"

if [ ! -f "${NVM_TST_IMG}" ]; then
    die "NVM image does not exist, create using \`qemu-img create -f raw ${NVM_TST_IMG} 10G\`"
fi

SYSTEM_IMG="$1"

"${QEMU_BIN}" \
    -nodefaults \
    -display "none" \
    -machine "q35,accel=kvm,kernel-irqchip=split" \
    -cpu "host" \
    -smp "${CPU_CORES}" \
    -m ${MEMORY} \
    -device "intel-iommu,intremap=on" \
    -netdev "user,id=net0,hostfwd=tcp::${SSH_PORT}-:22,hostfwd=tcp::${JUPYTER_PORT}-:8888" \
    -device "virtio-net-pci,netdev=net0" \
    -device "virtio-rng-pci" \
    -drive "id=boot,file=${SYSTEM_IMG},format=qcow2,if=virtio,discard=unmap,media=disk" \
    \
    -device "pcie-root-port,id=pcie_root_port0,chassis=1,slot=0" \
    -device "nvme,id=nvme0,serial=deadbeef,bus=pcie_root_port0,mdts=7" \
    -drive "id=nvm,file=${NVM_TST_IMG},format=raw,if=none,discard=unmap,media=disk" \
    -device "nvme-ns,id=nvm,drive=nvm,bus=nvme0,nsid=1,logical_block_size=4096,physical_block_size=4096" \
    -serial "mon:stdio"

