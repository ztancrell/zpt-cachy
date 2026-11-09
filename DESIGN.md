# zpt2linux — DESIGN

## Idea
My own CachyOS setup, not a distro, on two machines: the desktop and a MacBookPro16,1 (2019 16",
Intel T2, i9-9880H + Radeon Pro 5500M). Three parts:
- **CachyOS** repos and kernels used as-is.
- **This repo:** a local pacman repo with my homestead X stack (`../homestead`: xserver, libinput
  driver, openbox, fastcompmgr, tint2) and the meta-package `zpt2linux-desktop`; for the Mac, T2
  packages built from KaiT2en-Fedora plus `bankstown-lv2`, and the meta-package `zpt2linux-mac`.
- **Dotfiles repo** ([ztancrell/dotfiles](https://github.com/ztancrell/dotfiles), bare repo at
  `~/.dotfiles`, `$HOME` as work tree): configs, wallpapers, icons, themes. Backed up hourly by
  `dotfiles-backup.timer`.

A fresh install is CachyOS + dotfiles checkout + this repo (steps in README "Fresh install").

## Status
- 2026-11-09: desktop packages installed and working. `zpt2linux-desktop` from the local repo; ly's
  "Openbox Patchwork" session runs X, openbox, tint2 and fastcompmgr all from the packages.

- 2026-11-09: Mac packages back (`t2-dkms`, `t2-support`, `t2-apps`, `bankstown-lv2`, `zpt2linux-mac`),
  built into the local repo. No hardware test yet; CachyOS not yet installed on the Mac.

## Open questions
- Upstream's patched in-tree modules (`patches/runtime`: amdgpu GPU runtime PM incl. MacBookPro16,1
  fixes, i915 PSR/backlight, brcmfmac/Bluetooth incl. AWDL for `t2-drop`) are not packaged. Worth a
  per-kernel rebuild package later, or wait for them upstream?
- Ask KaiT2en whether shipping their binaries/units that contain "kait2en" (`kait2en-touchbar`,
  `kait2en-t2-*.service`) in my repo is fine.
- Should `zpt2linux-desktop` also depend on my everyday apps, so one install restores everything?

## Decided
- Not a distro; my CachyOS setup. Packages here, configs/wallpapers in the dotfiles repo (bare repo,
  hourly backup). (2026-11-09)
- Mac support is back: T2 packages for my CachyOS install on the MBP 16,1. Bug fixes still go
  upstream via `../macbook/t2-decomp`; packages here use upstream's `t2-*` names, say "from KaiT2en",
  ship no logos. (2026-11-09)
- Kernel: stock linux-cachyos. KaiT2en's DKMS modules target stock kernels (its README: "stock Fedora
  using DKMS modules"); dkms adds `LLVM=1` for clang-built kernels itself. No `linux-cachyos-t2`. (2026-11-09)
- Stock-driver blacklist ships as `t2-blacklist` (modprobe.d, upstream's list plus `macsmc_acpi`);
  kernel cmdline args (initcall blacklist, power args) stay manual, listed in the README. (2026-11-09)
- `bankstown-lv2` is packaged here; `t2-dsp` depends on it. (2026-11-09)
- `t2-hybrid-gpu-control` is not packaged (writes to the ESP). (2026-11-09)
- The optional extras `t2-airshare`, `t2-sidecar`, `t2-drop`, `t2-debug`, `t2-power-explorer` are
  packaged and in `zpt2linux-mac`. (2026-11-09)
- Keep the homestead desktop packages and local repo for the desktop. (2026-11-09)
- Hosting and rebuilds: GitHub Actions builds, checks (namcap report, DKMS build against the latest
  linux-cachyos-headers) and signs every package on push to main, weekly and by hand, and publishes
  the signed repo as the rolling GitHub release `repo`. Signing key `zpt2linux.asc`. The local
  `file://` repo stays for testing unpushed changes. (2026-11-09)
- Name: zpt2linux. Layered on CachyOS. (2026-11-09)
- Upstream first: every patch or package carried here that isn't upstream gets submitted to the right
  upstream project; local patches are temporary until upstream takes them. (2026-11-09)

Superseded (2026-11-09): the own-distro plan (archiso ISO, `linux-cachyos-t2` kernel, a
`zpt2linux-config` dotfiles package). Current approach: the Idea above; configs live in the dotfiles
repo. The T2 packages and `zpt2linux-mac`, dropped for a while, are back in `pkgs/` (see Decided).
