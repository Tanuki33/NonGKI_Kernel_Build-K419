#!/bin/sh
# Integrate a KernelSU driver into the kernel tree.
#
# Run from the kernel source root. Two modes:
#
#   1. Direct clone (preferred, used by MidoriSU):
#        KERNELSU_REPO        https://github.com/midori01/KernelSU
#        KERNELSU_REPO_BRANCH xx          (branch, tag or commit)
#
#   2. Upstream setup script (legacy, used by KernelSU-Next):
#        KERNELSU_SETUP_SOURCE  raw URL of kernel/setup.sh
#        KERNELSU_TAG           branch/tag/commit handed to that script
#
# After this script finishes, drivers/kernelsu points at the driver sources and
# drivers/{Makefile,Kconfig} know about them. The KSU configs themselves are
# written by the workflow (see "Setup Configuration for kernel").
set -eu

KSU_DIR_NAME=KernelSU

if [ -n "${KERNELSU_REPO:-}" ]; then
    BRANCH="${KERNELSU_REPO_BRANCH:-main}"
    echo "[+] Cloning driver ${KERNELSU_REPO} (${BRANCH})"
    rm -rf "$KSU_DIR_NAME"
    git clone --depth=1 --single-branch -b "$BRANCH" "$KERNELSU_REPO" "$KSU_DIR_NAME"
    echo "[+] Driver HEAD: $(git -C "$KSU_DIR_NAME" log -1 --format='%h %ad %s' --date=short)"

    ln -sfn "../$KSU_DIR_NAME/kernel" drivers/kernelsu
    grep -q 'kernelsu' drivers/Makefile \
        || printf '\nobj-$(CONFIG_KSU) += kernelsu/\n' >> drivers/Makefile
    grep -q 'drivers/kernelsu/Kconfig' drivers/Kconfig \
        || sed -i '/^endmenu/i source "drivers/kernelsu/Kconfig"' drivers/Kconfig
else
    echo "[+] Running setup script ${KERNELSU_SETUP_SOURCE}"
    curl -LSs "${KERNELSU_SETUP_SOURCE}" | bash -s "${KERNELSU_TAG:-}"
fi

if [ ! -e drivers/kernelsu ]; then
    echo "[-] drivers/kernelsu was not created, KernelSU setup failed"
    exit 1
fi

echo "[+] KernelSU source integrated:"
ls -l drivers/kernelsu
grep -n 'kernelsu' drivers/Makefile || true