# zpt2linux

My Arch/CachyOS-based distro, built as a pacman repo on top of CachyOS. See `DESIGN.md` for the idea and plan.

## What's here

- `pkgs/<name>/PKGBUILD`: one directory per package.
  - `xlibre-xserver-homestead`: XLibre X server (ztancrell/xserver). Server, common files and SDK in one package.
    Replaces `xlibre-xserver`, `xlibre-xserver-common`, `xlibre-xserver-devel` (and provides `xorg-server*`).
  - `xlibre-input-libinput-homestead`: libinput input driver. homestead's submodule commit is upstream
    X11Libre/xf86-input-libinput master and not yet in the fork (ztancrell/xf86-input-libinput), so it is fetched
    from upstream. Replaces `xlibre-input-libinput` / `xf86-input-libinput`.
  - `openbox-homestead`: Openbox (ztancrell/openbox-patchwork), `--enable-debug`. Replaces `openbox`.
  - `fastcompmgr-homestead`: compositor (ztancrell/fastcompmgr). Replaces `fastcompmgr`.
  - `tint2-homestead`: panel (ztancrell/tint2), no `tint2conf`. Replaces `tint2`.
  - `zpt2linux-desktop`: meta-package depending on the five packages above.
- `build.sh`: builds every package in `pkgs/` with `makepkg -f` (never installs anything), copies the
  results into `repo/` and indexes them with `repo-add` into `repo/zpt2linux.db.tar.zst`.
- `repo/`: the built local repo (not committed).

The homestead packages build from the forks at the commits the `../homestead` submodules point at
(`_commit=` in each PKGBUILD; the libinput driver comes from upstream, see above). To pick up new homestead work: bump `_commit` and `pkgver`, rerun `./build.sh`.
Build options follow `../homestead/CLAUDE.md`, with prefix `/usr` instead of `/usr/local`.

Not here yet: `zpt2linux-config` (dotfiles), the KaiT2en packages, `linux-cachyos-t2`, `zpt2linux-mac`.

## Build

```sh
./build.sh
```

If makepkg reports missing build dependencies, install them with `sudo pacman -S <deps>` and rerun.

## Install

Add to `/etc/pacman.conf`, after the CachyOS and Arch repos:

```ini
[zpt2linux]
SigLevel = Optional TrustAll
Server = file:///home/zpt/projects/zpt2linux/repo
```

Then:

```sh
sudo pacman -Sy zpt2linux-desktop
```

pacman asks to remove the stock packages each one conflicts with; answer yes.
After installing, point ly at the packaged server (`x_cmd = /usr/bin/X` in `/etc/ly/config.ini`)
and note that homestead's own `/usr/local` builds still come first in PATH (and openbox's autostart
starts `/usr/local/bin/fastcompmgr` by full path) until they are removed or the paths are changed.
