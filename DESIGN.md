# zpt2linux — DESIGN

## Idea
My own Arch-based Linux distro for my two machines: the 2019 MacBook Pro 16" (MacBookPro16,1,
Intel T2) and my CachyOS desktop. CachyOS gaming optimizations as the base, KaiT2en T2 support on
the Mac, my homestead X11 stack on both. Personal use first.

## Shape (decided 2026-11-09)
- **Base:** CachyOS repos used as-is (optimized packages, kernels, gaming tweaks). Not a fork of
  the existing CachyOS T2 build, so CachyOS updates arrive for free.
- **Own pacman repo** on top:
  - `linux-cachyos-t2`: linux-cachyos PKGBUILD + KaiT2en (and/or t2linux) T2 kernel patches.
  - KaiT2en drivers (DKMS: t2bce, t2smc, touchbar, trackpad, ...) and services (zone-power,
    t2-ave/t2remote, touchid, fan control) as PKGBUILDs. KaiT2en ships only RPM/Debian today.
  - homestead X11 stack (`../homestead`: xserver, openbox, tint2, fastcompmgr, libinput) as packages.
  - Meta-packages per machine: `zpt2linux-mac`, `zpt2linux-desktop`.
- **ISO:** archiso profile derived from CachyOS's live-ISO profile, adding this repo.

## Related
- `../macbook/t2-decomp`: T2 reverse-engineering; findings/kait2en-review.md lists bugs in KaiT2en's
  encoder that this distro would ship. Fixes may be carried as patches here until upstream takes them.
- `../macbook/mbp16-power`: SMC power-budget research (zone-power behaviour on the 16,1).

## Open questions
- Which T2 patch source for the kernel: KaiT2en's set, t2linux's `linux-t2-patches`, or both? Do
  they apply cleanly on top of linux-cachyos's own patches?
- Where to host the repo publicly (GitHub releases, a static host)? For now: local.
- Rebuild automation: CachyOS ships kernels often; script/CI to rebuild + smoke-test.
- Licensing/naming: KaiT2en is MIT with a TRADEMARK.md; check what redistribution requires.

## Decided
- Name: zpt2linux. Layered on CachyOS, ISO + package repo, for Mac + desktop. (2026-11-09)
- Repo first, ISO last. Mac install = existing T2-capable ISO + CachyOS + this repo +
  `pacman -S zpt2linux-mac`. Own archiso profile only if reinstalls become frequent. (2026-11-09)
- Config ships too: dotfiles (openbox, tint2, ...) as a `zpt2linux-config` package, so both
  machines get the setup, not just the software. (2026-11-09)
- Build order: homestead packages + local repo + `zpt2linux-desktop`, proven on the desktop;
  then KaiT2en packages; then `linux-cachyos-t2`. Repo is local (`file://`) for now. (2026-11-09)
- Upstream first: every patch or package carried here that isn't upstream gets submitted to the right upstream project; local patches are temporary until upstream takes them. (2026-11-09)
