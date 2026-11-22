<div align="start">
  <h1>Kernel Build Action for Merlin (MT6768 / 4.19)</h1>
  <h3><i>Powered By GitHub Actions</i></h3>
</div>

A workflow to automatically build an Android kernel for **merlin** (Redmi Note 9 / 10X 4G)
from [Tanuki33/android_kernel_xiaomi_mt6768_S_Vendor](https://github.com/Tanuki33/android_kernel_xiaomi_mt6768_S_Vendor)
(branch `lineage-24.0`, Linux 4.19, S vendor / Android 17), with **MidoriSU** root
installed as the KernelSU driver.

## Usage Guide

> [!NOTE]
> You will need a GitHub account.

<details>
  <summary><i>Click to expand</i></summary>

> ### 1.
> ![01](guide/images/01.png)

> ### 2.
> ![02](guide/images/02.png)

> ### 3.
> ![03](guide/images/03.png)

> ### 4.
> ![04](guide/images/04.png)

> ### 5.
> ![05](guide/images/05.png)

> ### 6.
> ![06](guide/images/06.png)

> ### 7.
> ![07](guide/images/07.png)

> ### 8.
> ![08](guide/images/08.png)

> ### 9.
> ![09](guide/images/09.png)

> ### 10.
> ![10](guide/images/10.png)

> ### 11.
> ![11](guide/images/11.png)
> **Note:** Reload this page if the yellow circle does not appear.

> ### 12.
> ![12](guide/images/12.png)

> ### 13.
> ![13](guide/images/13.png)

> ### 14.
> ![14](guide/images/14.png)

</details>

## What each build gives you

Same kernel tree, same toolchain, same AnyKernel3 — the targets differ only in the root
solution and the kernel source patches they need. Detailed wiring notes are in
[OPTIONS.md](OPTIONS.md#kernel-side-wiring-per-target).

| | **MidoriSU** (default) | **KernelSU-Next** | **SukiSU-Nova** |
|---|---|---|---|
| Config file | [`config-midori.env`](config-midori.env) | [`config-ksun.env`](config-ksun.env) | [`config-sukisu.env`](config-sukisu.env) |
| Driver source | `midori01/KernelSU` branch `xx`, built into the kernel | `MrShockWAVEog/KernelSU-Next` `shockwave` (`kernel/setup.sh`) | `git.zako.shirkneko.top .../SukiSU` branch `builtin` |
| Kernel source patches | **none** | [`KSU_HOOKS_PATCH.patch`](patches/KSU_HOOKS_PATCH.patch) — 9 files, 288 lines | [`SUKISU_SUSFS_4.19.patch`](patches/SUKISU_SUSFS_4.19.patch) — 27 files, 5711 lines |
| How root enters the kernel | `CONFIG_KSU_HACK_ARM64_BRANCH_LINK=y` — call sites hooked at runtime | `CONFIG_KSU_MANUAL_HOOK=y` — static `ksu_handle_*` call sites | static `ksu_handle_*` call sites + [`SUKISU_DRIVER_4.19.patch`](patches/SUKISU_DRIVER_4.19.patch) driver fixups |
| SUSFS v2.4.0 | ✅ [`MIDORISU_SUSFS_4.19.patch`](patches/MIDORISU_SUSFS_4.19.patch) — 21 files, de-inlined | ❌ `KSU_SUSFS=false` | ✅ compiled into the hook patch (inline variant, 27th file is SUSFS) |
| KPM kernel modules | ❌ | ❌ | ✅ `CONFIG_KPM` + `CONFIG_KALLSYMS_ALL` |
| Metamodule needed for modules with `system/` | ✅ (KernelSU 3.x) | ✅ | ✅ |
| OverlayFS + tmpfs xattr config | ✅ `ADD_OVERLAYFS_CONFIG=true` | ⚪ off | ⚪ off |
| Boots LineageOS 24 (merlin) | ✅ | ⚪ untested | ✅ after the two hook fixes |
| Survives anti-tamper / banking apps | ✅ | ⚪ untested | ❌ flagged by app-level RASP |

Legend: ✅ shipped/tested · ⚪ available but not tested in this repo · ❌ not supported by design.

* **Pick MidoriSU** for daily use: fewest kernel changes, working SUSFS, and the only build
  confirmed to pass the anti-tamper checks of banking apps.
* **Pick KernelSU-Next** if you want a mainstream fork with a conventional hook set, or to
  A/B a driver against MidoriSU.
* **Pick SukiSU-Nova** only if you need KPM (loadable kernel modules) — expect stricter
  detection by anti-tamper apps.

## Options Guide

Every knob — kernel source, toolchain, AnyKernel3, KernelSU, APatch, build and misc
sections — is documented in **[OPTIONS.md](OPTIONS.md)**.

## Module mounting / metamodules (MidoriSU)

MidoriSU is KernelSU **3.x** lineage (`ksud` reports `uapi: 6`), and since KernelSU 3.0 the
manager no longer mounts modules itself: **mounting is delegated to a metamodule**.
Without one installed, modules still run their scripts, but nothing they ship under
`system/`, `vendor/`, `product/`, `system_ext`, `odm` or `oem` is applied.

That is why the current seven modules work untouched — none of them has a `system/`
directory (they are scripts, Zygisk, WebUI and config only). Install a metamodule before
using a module that replaces system files.

**Recommendation: [`mountify`](https://github.com/backslashxx/mountify) `205`.**
It is the only option here that is actively maintained, purpose-built for staying hidden
(it mimics an OEM mount such as `/mnt/vendor/<name>` instead of stacking obvious
`/data`-sourced overlays), and its tmpfs mode creates no `ext4` device nodes on
`/proc/fs`. `meta-overlayfs` (last release v1.3.1, repo archived) and `hybrid-mount`
(heaviest, mixes OverlayFS / magic mount / VFS per path) are the fallbacks if a module
misbehaves.

```bash
# download the release zip on the phone, then:
adb shell su -c 'ksud module install /sdcard/mountify.zip'
adb reboot
```

`mountify` config lives at `/data/adb/mountify/config.sh` (also editable in its WebUI):
`mountify_mounts=2` (default) mounts every module that has a `system/` folder,
`mountify_mounts=1` + `modules.txt` mounts only the listed ones, `FAKE_MOUNT_NAME` sets the
fake OEM folder name.

Verify after reboot:

```bash
adb shell su -c 'cat /proc/mounts | grep -c overlay'
adb shell su -c 'mount | grep -i vendor'          # /mnt/vendor/<fake>
adb shell 'cat /proc/self/mountinfo | grep -c overlay'   # 0 for a normal app = hidden
```

Rollback: `adb shell su -c 'rm -rf /data/adb/modules/mountify /data/adb/metamodule'`
and reboot.

Kernel side, this build sets `ADD_OVERLAYFS_CONFIG=true`, which adds
`CONFIG_OVERLAY_FS`, `CONFIG_OVERLAY_FS_REDIRECT_DIR`, `CONFIG_OVERLAY_FS_INDEX`,
`CONFIG_TMPFS_XATTR` and `CONFIG_TMPFS_POSIX_ACL`. The tmpfs options matter on this
device: `/data` is **f2fs**, which overlayfs refuses to use as an upperdir
(`ovl_dentry_weird`), so metamodules either stage on tmpfs (`mountify` tmpfs mode) or on
an ext4 image (ext4-sparse mode, `CONFIG_EXT4_FS` + `CONFIG_BLK_DEV_LOOP` are already `y`).
Without `CONFIG_TMPFS_XATTR`, only the ext4-sparse path works — that is the build you are
running right now, so **flash the next build before enabling tmpfs mode**.

SUSFS note: metamodule overlay mounts are ordinary kernel mounts, so hiding them from
non-root processes is the job of `CONFIG_KSU_SUSFS_SUS_MOUNT` (already on; the module
script runs in the `ksu` domain, which is what makes SUSFS tag the mounts as `sus_mount`).
Keep it on whenever a metamodule is installed, otherwise `mountinfo` exposes the overlays.

## Control variants (`build_sukisu_variants`)

Ticking **Also build control variants** in the workflow adds the no-SUSFS builds next to the
normal targets, each a plain matrix target with its own config file:

| Target | Config file | Differs from its base by | Purpose |
|---|---|---|---|
| `sukisu` | `config-sukisu.env` | - | the shipping SukiSU build |
| `sukisu-nosusfs` | `config-sukisu-nosusfs.env` | SUSFS off, plain hooks patch | control build |
| `midori-nosusfs` | `config-midori-nosusfs.env` | `KSU_SUSFS=false`, no SUSFS patch | isolates a SUSFS-only regression |

`patches/SUSFS_DISABLE_SUS_MOUNT.patch` and `patches/SUSFS_DISABLE_MONITOR.patch`
are kept for debugging a SUSFS boot problem; wire them in with
`KSU_EXTRA_PATCH=<patch>` (and `KSU_DRIVER_EXTRA_PATCH` for driver-side ones).
A SUSFS feature cannot be switched off through Kconfig: the driver calls
`susfs_add_*`/`susfs_set_*` unconditionally, so `CONFIG_KSU_SUSFS_*=n` fails the
vmlinux link.

Each target produces its own zip (`...-sukisu-nosusfs-...zip`) and flashes independently,
so one workflow run answers the whole question instead of one build per hour. The variant
configs are plain copies of `config-sukisu.env` — when you change the base config, update
them too. The kernel source can be pinned per config with `KERNEL_COMMIT` (empty = branch
tip) and the resolved commit is echoed in the build log.

## Installer branding

The flashable AnyKernel3 folder is branded during the build (`Anykernel3` step):

- `kernel.string` → `<KERNEL_NAME> Kernel for <device> by @<KERNEL_AUTHOR>`
- `device.name*` trimmed to the device that is being built
- a `version` file with `<KERNEL_NAME> for <device>` and `Linux 4.19.325 | LineageOS 24 | <build time>`
- the upstream ASCII art (`banner`) is deleted, unless this repo provides `assets/banner`,
  which is copied in instead

To ship your own ASCII art, commit it as `assets/banner` in this repo — no AnyKernel3 fork
needed. Size it for a recovery console: **≤ 60 columns wide and ≤ 36 rows tall**, plain ASCII
(`#`, `%`, `@`, `/`, `\\`, `.`, `:`, `-`, `=`), no tabs, no Unicode, keep trailing spaces if
your art needs them for alignment. The upstream ShockWave art is 54 × 36, so that is a known
safe canvas. Each line is printed verbatim by `ui_printfile`, so wider art wraps and breaks.

## Credits

- [xiaoleGun](https://github.com/xiaoleGun) for base
- [dabao1955](https://github.com/dabao1955) for format of README.md
- [midori01](https://github.com/midori01/KernelSU) for MidoriSU
- [backslashxx](https://github.com/backslashxx/KernelSU) for the non-GKI KernelSU driver
