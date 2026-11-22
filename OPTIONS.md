# Options Guide

Options are read from the target's `config-*.env` and exported to the build environment.
The example values below are the ones shipped in `config-midori.env`.

> [!NOTE]
> All options are located in [config-midori.env](config-midori.env) (MidoriSU, default),
> [config-ksun.env](config-ksun.env) (KernelSU-Next) and
> [config-sukisu.env](config-sukisu.env) (SukiSU-Nova). The workflow picks the file that
> matches the selected build target. Control variants are plain copies of those files:
> [config-midori-nosusfs.env](config-midori-nosusfs.env) and
> [config-sukisu-nosusfs.env](config-sukisu-nosusfs.env).
>
> **MidoriSU** ([midori01/KernelSU](https://github.com/midori01/KernelSU), branch `xx`) is the
> non-GKI driver that supports Linux 3.0 – 5.4+; it hooks syscalls at runtime, so **no kernel
> patches are needed** and the `com.midori.supermanager` manager APK is recognised out of the box.
>
> **SukiSU-Nova** ([SukiSU-Nova/SukiSU-Nova](https://github.com/SukiSU-Nova/SukiSU-Nova), branch
> `builtin`) is the non-GKI variant of the SukiSU line: no kprobes, but it needs the kernel
> source to call its hook entry points, so it ships its own hook patch, extended with a
> backport of the SUSFS v2.4.0 kernel sources so the full hiding/spoofing feature set works.
> The manager APK is `com.sukisu.ultra`.

| Base section options | Optional | Description | Example value |
|---------------------|----------|-------------|----------------|
| KERNEL_SOURCE | <div align="center">❌</div> | Link to kernel repository | `https://github.com/Tanuki33/android_kernel_xiaomi_mt6768_S_Vendor` |
| KERNEL_SOURCE_BRANCH | <div align="center">❌</div> | Branch name of kernel repository | <div align="center">`lineage-24.0`</div> |
| KERNEL_ARCH | <div align="center">❌</div> | The Linux kernel architecture | <div align="center">`arm64`</div> |
| KERNEL_IMAGE_NAME | <div align="center">❌</div> | Format of the kernel image for flashable AnyKernel3 zip | <div align="center">`Image.gz-dtb`</div> |
| KERNEL_CONFIG_BASE | <div align="center">❌</div> | Base defconfig inside the kernel tree | <div align="center">`vendor/mt6768_defconfig`</div> |
| KERNEL_CONFIG_FRAGMENT_DIR | <div align="center">❌</div> | Directory holding the per-device config fragment (`<device>.config`) | <div align="center">`vendor`</div> |
| KERNEL_NAME | <div align="center">✅</div> | Kernel name: sets `CONFIG_LOCALVERSION`, so `uname -r` ends with `...-LineaTan`; also used for artifact names and the AnyKernel3 installer text | <div align="center">`LineaTan`</div> |
| KERNEL_AUTHOR | <div align="center">✅</div> | Handle shown in the AnyKernel3 installer line (`<KERNEL_NAME> Kernel for <device> by @<author>`) | <div align="center">`Tanuki33`</div> |

<br>

| KernelSU section options | Optional | Description | Example value |
|--------------------------|----------|-------------|---------------|
| ENABLE_KERNELSU | <div align="center">✅</div> | Enables accounting for the KernelSU options written below | <div align="center">`true`</div> |
| KSU_NAME | <div align="center">✅</div> | Name used in the uploaded artifact | <div align="center">`MidoriSU`</div> |
| KERNELSU_REPO | <div align="center">✅</div> | Git URL of the driver; when set the driver is cloned directly (MidoriSU mode) | `https://github.com/midori01/KernelSU` |
| KERNELSU_REPO_BRANCH | <div align="center">✅</div> | Branch/tag/commit of `KERNELSU_REPO` | <div align="center">`xx`</div> |
| KERNELSU_SETUP_SOURCE | <div align="center">✅</div> | Setup script used when `KERNELSU_REPO` is empty | `https://raw.githubusercontent.com/tiann/KernelSU/main/kernel/setup.sh` |
| KERNELSU_TAG | <div align="center">✅</div> | Repository branch or tag handed to that setup script | <div align="center">`v1.0.1`</div> |
| ADD_KPROBES_CONFIG | <div align="center">✅</div> | Apply [patches](https://kernelsu.org/guide/how-to-integrate-for-non-gki.html#integrate-with-kprobe) kernel source code to support KernelSU installation via kprobe | <div align="center">`false`</div> |
| KSU_HOOKS_PATCH | <div align="center">✅</div> | Apply [patches](https://kernelsu.org/guide/how-to-integrate-for-non-gki.html#manually-modify-the-kernel-source) kernel source code to support KernelSU (KernelSU-Next and SukiSU-Nova) | <div align="center">`false`</div> |
| KSU_HOOKS_PATCH_FILE | <div align="center">✅</div> | File in `patches/` applied when `KSU_HOOKS_PATCH` is true, defaults to `KSU_HOOKS_PATCH.patch` | <div align="center">`KSU_HOOKS_PATCH.patch`</div> |
| KSU_KALLSYMS | <div align="center">✅</div> | Sets `CONFIG_KALLSYMS=y` without enabling branch-link hooking — needed by drivers that resolve symbols at runtime (SukiSU-Nova) | <div align="center">`false`</div> |
| KSU_KPM | <div align="center">✅</div> | Sets `CONFIG_KPM=y` + `CONFIG_KALLSYMS_ALL=y` — SukiSU's KPM (kernel module) extension; 64-bit only, upstream warns about stability | <div align="center">`false`</div> |
| KSU_DRIVER_PATCH | <div align="center">✅</div> | File in `patches/` applied **inside the cloned driver repo** (not the kernel tree) after setup; empty = none | <div align="center">`SUKISU_DRIVER_4.19.patch`</div> |
| KSU_MANUAL_HOOKS | <div align="center">✅</div> | Sets `CONFIG_KSU_MANUAL_HOOK=y` (requires `KSU_HOOKS_PATCH`) | <div align="center">`false`</div> |
| KSU_BRANCH_LINK_HOOK | <div align="center">✅</div> | Sets `CONFIG_KSU_HACK_ARM64_BRANCH_LINK=y` + `CONFIG_KALLSYMS=y` — runtime call-site hooking, recommended for 4.19 | <div align="center">`true`</div> |
| KSU_SUSFS | <div align="center">✅</div> | Keeps `CONFIG_KSU_SUSFS` **and all its sub-options** enabled (sus_path, sus_mount, sus_kstat, uname spoof, cmdline/bootconfig spoof, open_redirect, sus_map, priority uid filter). Requires a kernel tree that carries the SUSFS sources: with SukiSU it lives inside `KSU_HOOKS_PATCH_FILE=SUKISU_SUSFS_4.19.patch`, with MidoriSU it comes from `KSU_SUSFS_PATCH_FILE` | <div align="center">`true`</div> |
| KSU_SUSFS_PATCH_FILE | <div align="center">✅</div> | File in `patches/` applied when `KSU_SUSFS` is true and the SUSFS sources are **not** part of the hook patch (MidoriSU). Empty = no separate SUSFS patch | <div align="center">`MIDORISU_SUSFS_4.19.patch`</div> |
| KSU_REVERT | <div align="center">✅</div> | Revert the [commit](https://github.com/tiann/KernelSU/commit/898e9d4f8ca9b2f46b0c6b36b80a872b5b88d899) that removed non-GKI kernel support | <div align="center">`true`</div> |
<!-- | KSU_EXPECTED_SIZE | idk | idk | idk | -->
<!-- | KSU_EXPECTED_HASH | idk | idk | idk | -->
> [!IMPORTANT]
> [KernelSU](https://kernelsu.org/guide/what-is-kernelsu.html) [no longer supports non-GKI kernels](https://github.com/tiann/KernelSU/issues/1705) after version [v1.0.0](https://github.com/tiann/KernelSU/releases/tag/v1.0.0). The last supported version is [v0.9.5](https://github.com/tiann/KernelSU/releases/tag/v0.9.5), please make sure to use the correct tag.

<br>

| APatch section options | Optional | Description | Example value |
|------------------------|----------|-------------|---------------|
| ADD_APATCH_SUPPORT | <div align="center">✅</div> | Add [required configs](https://apatch.dev/install.html#install-requirements) for [APatch](https://apatch.dev/what-is-apatch.html) and accounting for options written below | <div align="center">`false`</div> |
| FIX_APATCH_OPENELA | <div align="center">✅</div> | Apply fix for https://github.com/bmax121/APatch/issues/400 | <div align="center">`false`</div> |

<br>

| Compiler section options | Optional | Description | Example value |
|--------------------------|----------|-------------|---------------|
| USE_CLANG | <div align="center">✅</div> | Enable Clang toolchain usage and accounting for options written below | <div align="center">`true`</div> |
| CLANG_SOURCE | <div align="center">❌</div> | Link to clang archive or repository | `https://android.googlesource.com/platform/prebuilts/clang/host/linux-x86/+archive/b669748458572622ed716407611633c5415da25c/clang-r416183b.tar.gz` |
| CLANG_BRANCH | <div align="center">✅</div> | Branch name of clang repository | <div align="center">`main`</div> |
| USE_GCC | <div align="center">✅</div> | Enable GCC toolchain usage and accounting for options written below | <div align="center">`false`</div> |
| USE_GCC_64 | <div align="center">✅</div> | Enable GCC 64-bit | <div align="center">`true`</div> |
| GCC_64_SOURCE | <div align="center">❌</div> | Link to GCC 64-bit archive or repository | `https://snapshots.linaro.org/gnu-toolchain/14.0-2023.06-1/aarch64-linux-gnu/gcc-linaro-14.0.0-2023.06-x86_64_aarch64-linux-gnu.tar.xz` |
| GCC_64_BRANCH | <div align="center">✅</div> | Branch name of GCC 64-bit repository | <div align="center">`main`</div> |
| USE_GCC_32 | <div align="center">✅</div> | Enable GCC 32-bit | <div align="center">`true`</div> |
| GCC_32_SOURCE | <div align="center">❌</div> | Link to GCC 32-bit archive or repository | `https://snapshots.linaro.org/gnu-toolchain/14.0-2023.06-1/arm-linux-gnueabihf/gcc-linaro-14.0.0-2023.06-x86_64_arm-linux-gnueabihf.tar.xz` |
| GCC_32_BRANCH | <div align="center">✅</div> | Branch name of GCC 32-bit repository | <div align="center">`main`</div> |
> [!IMPORTANT]
> You can use only Clang or GCC, but not both at the same time.

<br>

| Anykernel3 section options | Optional | Description | Example value |
|----------------------------|----------|-------------|---------------|
| USE_ANYKERNEL3 | <div align="center">✅</div> | Enable creating flashable AnyKernel3 zip and accounting for options written below | <div align="center">`true`</div> |
| ANYKERNEL3_SOURCE | <div align="center">❌</div> | Link to AnyKernel3 source | `https://github.com/Jbub5/AnyKernel3.git` |
| ANYKERNEL3_BRANCH | <div align="center">✅</div> | Branch name of AnyKernel3 repository | <div align="center">`proton`</div> |

<br>

| Build section options | Optional | Description | Example value |
|-----------------------|----------|-------------|---------------|
| EXTRA_CMDS | <div align="center">✅</div> | Additional compiler options | `LLVM=1 LLVM_IAS=1 LD=ld.lld AS=llvm-as AR=llvm-ar NM=llvm-nm OBJCOPY=llvm-objcopy OBJDUMP=llvm-objdump READELF=llvm-readelf STRIP=llvm-strip CROSS_COMPILE=aarch64-linux-gnu- CROSS_COMPILE_ARM32=arm-linux-gnueabi- CROSS_COMPILE_COMPAT=arm-linux-gnueabi- CONFIG_NO_ERROR_ON_MISMATCH=y TARGET_BUILD_VARIANT=user` |
| DISABLE_LTO | <div align="center">✅</div> | [LTO](https://llvm.org/docs/LinkTimeOptimization.html) is used to optimize the kernel but sometimes causes errors | <div align="center">`false`</div> |
| DISABLE_CC_WERROR | <div align="center">✅</div> | Disable CONFIG_CC_WERROR | <div align="center">`false`</div> |
| ENABLE_PYTHON2 | <div align="center">✅</div> | Many old kernels require python2 to build them | <div align="center">`false`</div> |
| ENABLE_CCACHE | <div align="center">✅</div> | Enable [ccache](https://ccache.dev) | <div align="center">`false`</div> |
| REMOVE_UNUSED_PACKAGES| <div align="center">✅</div> | Remove unnecessary packages and free up more disk space for builder | <div align="center">`false`</div> |
| NEED_DTBO | <div align="center">✅</div> | Upload DTBO | <div align="center">`false`</div> |
| BUILD_BOOT_IMG | <div align="center">✅</div> | Repack boot.img by replacing the kernel in it with the compiled kernel | <div align="center">`false`</div> |
| SOURCE_BOOT_IMAGE | <div align="center">✅</div> | Link to the original boot.img for repackage it | `https://raw.githubusercontent.com/xiaoleGun/KernelSU_action/main/boot/boot.img` |

<br>

| Misc section options | Optional | Description | Example value |
|----------------------|----------|-------------|---------------|
| ADD_OVERLAYFS_CONFIG | <div align="center">✅</div> | Puts the configs an OverlayFS-based **KernelSU metamodule** needs into `.config`: `CONFIG_OVERLAY_FS`, `CONFIG_OVERLAY_FS_REDIRECT_DIR`, `CONFIG_OVERLAY_FS_INDEX`, plus `CONFIG_TMPFS_XATTR` and `CONFIG_TMPFS_POSIX_ACL` (metamodules stage the overlay upperdir on tmpfs when `/data` is f2fs) | <div align="center">`true`</div> |
<br>

| Proton specific section options | Optional | Description | Example value |
|----------------------------------|----------|-------------|---------------|
| FIX_WIFI_SPEED | <div align="center">✅</div> | Rollback to old connectivity drivers that have better Wi-Fi speed, but cause spontaneous reboots on some devices | <div align="center">`false`</div> |

## Kernel-side wiring per target

> [!IMPORTANT]
> This 4.19 tree has no kprobe/tracepoint KernelSU hooking (5.10+ only). Three wirings are
> supported:
> - **MidoriSU (default)** – branch-linked runtime hooking, no KernelSU kernel patches. SUSFS is
>   added by `KSU_SUSFS_PATCH_FILE=MIDORISU_SUSFS_4.19.patch`: the **de-inlined SUSFS v2.4.0**
>   backport for this 4.19 tree, adapted from [Midori's QGKI 5.4 patch](https://github.com/JackA1ltman/NonGKI_Kernel_Build_2nd)
>   (the same base [ShockWAVE](https://github.com/MrShockWAVEog/shockwave_kernel_xiaomi_mt6768)
>   uses). It carries no `ksu_handle_*` call-sites because the branch-link driver installs its
>   own hooks at runtime; the SUSFS side only needs the hooks the patch itself adds
>   (`namei`, `namespace`, `stat`, `statfs`, `super`, `readdir`, `proc/*`, `memory.c`,
>   `selinux/avc.c`, `kallsyms.c`). `fs/namespace.c` differs from upstream in one place: this
>   tree wraps `vfs_kern_mount()` around fs_context, so the fake SUS_MOUNT allocation sits in
>   `vfs_create_mount()`.
>   `KSU_EXTRA_PATCH=SUSFS_STATFS_GUARD.patch` is applied on top of it: it bounds the
>   `mnt_parent` walk in `susfs_get_non_sus_{mnt_id,vfsmnt}_from_*()` and takes refs on the
>   fallback mount, so a cyclic/short parent chain cannot spin while `lock_mount_hash()` is
>   held (that stalls every `statfs` caller — `df`, storage UIs, app startup — for minutes).
>   Set `KSU_SUSFS=false` (see `config-midori-nosusfs.env`) for a control build.
> - **KernelSU-Next** – `KSU_HOOKS_PATCH=true` + `KSU_MANUAL_HOOKS=true`, which applies
>   `patches/KSU_HOOKS_PATCH.patch` (specific to the 4.19.325 MT6768 tree).
> - **SukiSU-Nova** – `KSU_HOOKS_PATCH=true` with the `builtin` branch driver, applying
>   `patches/SUKISU_SUSFS_4.19.patch` (via `KSU_HOOKS_PATCH_FILE`). That patch is the core
>   hook set **plus** the SUSFS v2.4.0 kernel integration backported to this 4.19 tree:
>   `fs/susfs.c`, `include/linux/susfs*.h`, and the `fs/mm/security` hook sites
>   (`namei`, `namespace`, `namespace/proc_namespace`, `readdir`, `stat`, `statfs`, `super`,
>   `proc/*`, `memory.c`, `selinux/avc.c`, `kallsyms.c`), with the `vfs_kern_mount()` hunk
>   adapted to this tree's fs_context-based mount code. SUSFS mode also needs
>   `ksu_handle_setresuid` (kernel/sys.c) and `ksu_handle_post_execveat_sucompat`
>   (fs/exec.c) which the patch adds.
>   KPM is compiled in (`KSU_KPM=true`) and SUSFS is on (`KSU_SUSFS=true`, all sub-options).
>   `KSU_DRIVER_PATCH=SUKISU_DRIVER_4.19.patch` (applied inside the cloned driver)
>   fixes the driver's `elf_hwcap` over-write on 4.x and guards the 5.10-only
>   `<linux/static_call.h>` include the driver pulls in but never uses.
>   Drop `KSU_HOOKS_PATCH_FILE` back to `SUKISU_HOOKS_PATCH.patch` (and `KSU_SUSFS=false`)
>   for a SUSFS-less build.
>
> Two kernel-side details only the SUSFS build needs, both already in the patch:
> - the SUSFS driver keeps a second `ksu_handle_stat`/`ksu_handle_faccessat` that
>   takes a `struct filename **` (the non-SUSFS one takes a user string), so in
>   SUSFS mode the hooks sit in `filename_lookup()` and the plain-string hooks in
>   `vfs_statx()`/`do_faccessat()` are compiled out,
> - `ksu_handle_post_execveat_sucompat()` may only run when
>   `ksu_handle_execveat()` reported the `su` -> `ksud` rewrite. Running it on
>   every exec leaves an anon-inode fd (`st_mode` type bits = 0) at fd 3 of every
>   process and Android's zygote aborts with
>   `Unsupported st_mode for FD 3: Unknown`.
