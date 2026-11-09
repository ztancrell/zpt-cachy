# zpt2linux — DESIGN

## Idea
My own CachyOS setup, not a distro. Three parts:
- **CachyOS** repos and kernels used as-is.
- **This repo:** a local pacman repo with my homestead X stack (`../homestead`: xserver, libinput
  driver, openbox, fastcompmgr, tint2) and the meta-package `zpt2linux-desktop`.
- **Dotfiles repo** ([ztancrell/dotfiles](https://github.com/ztancrell/dotfiles), bare repo at
  `~/.dotfiles`, `$HOME` as work tree): configs, wallpapers, icons, themes. Backed up hourly by
  `dotfiles-backup.timer`.

A fresh install is CachyOS + dotfiles checkout + this repo (steps in README "Fresh install").

## Status
- 2026-11-09: desktop packages installed and working. `zpt2linux-desktop` from the local repo; ly's
  "Openbox Patchwork" session runs X, openbox, tint2 and fastcompmgr all from the packages.

## Open questions
- Should `zpt2linux-desktop` also depend on my everyday apps, so one install restores everything?
- Where to host the repo publicly (GitHub releases, a static host)? For now: local (`file://`).

## Decided
- Not a distro; my CachyOS setup. Packages here, configs/wallpapers in the dotfiles repo (bare repo,
  hourly backup). (2026-11-09)
- T2/KaiT2en work goes upstream via `../macbook/t2-decomp`, not here. (2026-11-09)
- Keep the homestead desktop packages and local repo for the desktop. (2026-11-09)
- Name: zpt2linux. Layered on CachyOS. (2026-11-09)
- Upstream first: every patch or package carried here that isn't upstream gets submitted to the right
  upstream project; local patches are temporary until upstream takes them. (2026-11-09)

Superseded (2026-11-09): the own-distro plan (archiso ISO, `linux-cachyos-t2` kernel, KaiT2en T2
packages, `zpt2linux-mac`, a `zpt2linux-config` dotfiles package, Mac + desktop as targets). Current
approach: the Idea above; configs live in the dotfiles repo, T2 work in `../macbook/t2-decomp`. The
removed T2 PKGBUILDs are in git history (commit cfcc21b).
