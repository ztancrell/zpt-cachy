# zpt-cachy — DESIGN

## Idea
My own CachyOS setup, not a distro, on two machines: the desktop and a MacBookPro16,1 (2019 16",
Intel T2, i9-9880H + Radeon Pro 5500M). Three parts:
- **CachyOS** repos and kernels used as-is.
- **This repo:** a local pacman repo with my homestead X stack (`../homestead`: xserver, libinput
  driver, openbox, fastcompmgr, tint2) and the meta-package `zpt-cachy-desktop`; for the Mac, T2
  packages built from KaiT2en-Fedora plus `bankstown-lv2`, and the meta-package `zpt-cachy-mac`.
- **Dotfiles repo** ([ztancrell/dotfiles](https://github.com/ztancrell/dotfiles), bare repo at
  `~/.dotfiles`, `$HOME` as work tree): configs, wallpapers, icons, themes. Backed up hourly by
  `dotfiles-backup.timer`.

A fresh install is CachyOS + dotfiles checkout + this repo (steps in README "Fresh install").

## Status
- 2026-11-11: the CI-built packages (release `repo`) were built with the container's `-march=native`,
  i.e. for the runner's AVX-512 CPU: `libobt.so` in openbox-homestead 3.6.0.r7671.gc91ce46-2 had zmm
  instructions, openbox died with SIGILL on the Zen 3 desktop and ly logins bounced back. Fixed: CI
  forces x86-64-v3 flags (C/C++ and Rust) and fails on any zmm instruction (see README "CI").

- Superseded (2026-11-11): see the 2026-11-11 entry above; held only for the locally built packages.
  2026-11-09: desktop packages installed and working. `zpt2linux-desktop` from the local repo; ly's
  "Openbox Patchwork" session runs X, openbox, tint2 and fastcompmgr all from the packages.

- 2026-11-09: Mac packages back (`t2-dkms`, `t2-support`, `t2-apps`, `bankstown-lv2`, `zpt2linux-mac`),
  built into the local repo. No hardware test yet; CachyOS not yet installed on the Mac.

## Open questions
- Upstream's patched in-tree modules (`patches/runtime`: amdgpu GPU runtime PM incl. MacBookPro16,1
  fixes, i915 PSR/backlight, brcmfmac/Bluetooth incl. AWDL for `t2-drop`) are not packaged. Worth a
  per-kernel rebuild package later, or wait for them upstream?
- Ask KaiT2en whether shipping their binaries/units that contain "kait2en" (`kait2en-touchbar`,
  `kait2en-t2-*.service`) in my repo is fine.
- Should `zpt-cachy-desktop` also depend on my everyday apps, so one install restores everything?

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
- CI builds target x86-64-v3 (`-march=x86-64-v3 -mtune=generic`, Rust `target-cpu=x86-64-v3`): both
  machines support it (Ryzen 5 5600G, i9-9880H), neither has AVX-512. (2026-11-11)
- Name: zpt2linux. Layered on CachyOS. (2026-11-09)
- Renamed zpt2linux → zpt-cachy: it's my CachyOS setup, not a distro. (2026-11-09) Repo `[zpt-cachy]`,
  meta-packages `zpt-cachy-desktop`/`zpt-cachy-mac` (they replace the `zpt2linux-*` ones), GitHub repo
  ztancrell/zpt-cachy. New signing key `zpt-cachy.asc` (ed25519, fingerprint
  3A6F07D9D227FB888250B4A3AB192A45ADE20A55); the private key is the `GPG_PRIVATE_KEY` secret, backup
  and revocation certificate outside the repo. (2026-11-09)
- Upstream first: every patch or package carried here that isn't upstream gets submitted to the right
  upstream project; local patches are temporary until upstream takes them. (2026-11-09)

Superseded (2026-11-09): the name zpt2linux. Dated entries above that say `zpt2linux`,
`zpt2linux-desktop`, `zpt2linux-mac` or `zpt2linux.asc` (key 1DEAC296…A4F94116) describe the past; the
current names and key are in the rename entry under Decided.

Superseded (2026-11-09): the own-distro plan (archiso ISO, `linux-cachyos-t2` kernel, a
`zpt2linux-config` dotfiles package). Current approach: the Idea above; configs live in the dotfiles
repo. The T2 packages and `zpt2linux-mac`, dropped for a while, are back in `pkgs/` (see Decided).
