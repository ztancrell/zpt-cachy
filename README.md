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
  - T2 support for the MacBookPro16,1, built from [KaiT2en-Fedora](https://github.com/kaiT2en/KaiT2en-Fedora)
    (pinned `_commit=`). Package names are upstream's own (KaiT2en ships RPM/Debian only; its TRADEMARK.md
    reserves the name "KAIT2EN" for its own distribution, so nothing here is called `kait2en-*`).
    Three split PKGBUILDs, one per kind of build:
    - `t2-dkms`: 12 DKMS packages, one per upstream `dkms.conf`, sources in `/usr/src/<name>-<ver>/`:
      `t2bce_stack-dkms` (BCE: DMA, core, VHCI/USB, audio, AVE, Sidecar), `t2smc-dkms`, `t2bdrm-dkms`,
      `t2touchbar-dkms`, `hid_t2magicmouse-dkms`, `t2_precision_trackpad-dkms`, `t2_trackpad_actuator-dkms`,
      `t2mfi_fastcharge-dkms`, `t2gmux-dkms`, `t2thunderbolt-dkms`, `t2smp-dkms`, `t2sbs-dkms`.
    - `t2-support` (no compiling): `t2-dsp` (speaker DSP for PipeWire/WirePlumber), `t2bce_audio-alsa-ucm-conf`,
      `t2-services-common`, `t2-power-tune`.
    - `t2-apps` (Rust): `t2-fan-control`, `t2-smc-control`, `t2-zone-power`, `t2-force-click`,
      `t2-kbd-backlight`, `t2-touchbar`, `t2-touchid`, `t2-ave` (t2remote), `t2-journal`.
  - `zpt2linux-mac`: meta-package depending on all 25 T2 packages above (not on a kernel yet).
- `build.sh`: builds every package in `pkgs/` with `makepkg -f` (never installs anything), copies the
  results into `repo/` and indexes them with `repo-add` into `repo/zpt2linux.db.tar.zst`.
- `repo/`: the built local repo (not committed).

Not packaged from KaiT2en: `t2sep` (retired upstream), `linux-apfs-rw` (third-party; AUR has it),
`t2-dgpu-control` (MacBookPro15,3 only), `t2-hybrid-gpu-control` (writes a UEFI preboot app to the ESP),
`t2-truetone` (GNOME Shell only), `kait2en-update`, `t2-kernel-builder` (Fedora tools), the deprecated
`t2-cpu-control`, and the optional extras `t2-airshare`, `t2-drop`, `t2-sidecar`, `t2-debug`, `t2-power-explorer`.
Known bugs in KaiT2en's code (from our T2 reverse-engineering review) are not patched here yet.
To pick up new KaiT2en work: bump `_commit` and `pkgver` in the three `t2-*` PKGBUILDs.

The homestead packages build from the forks at the commits the `../homestead` submodules point at
(`_commit=` in each PKGBUILD; the libinput driver comes from upstream, see above). To pick up new homestead work: bump `_commit` and `pkgver`, rerun `./build.sh`.
Build options follow `../homestead/CLAUDE.md`, with prefix `/usr` instead of `/usr/local`.

Not here yet: `zpt2linux-config` (dotfiles), `linux-cachyos-t2`.

## Build

```sh
./build.sh
```

If makepkg reports missing build dependencies, install them with `sudo pacman -S <deps>` and rerun.
`t2-apps` needs pacman's Rust (`sudo pacman -S --needed rust`); a rustup install in `~/.cargo` does not
satisfy makepkg. `build.sh` skips the dep check for `zpt2linux-*` and `*-dkms` directories (their
dependencies live only in this repo, or are runtime-only).

## Install

Add to `/etc/pacman.conf`, after the CachyOS and Arch repos:

```ini
[zpt2linux]
SigLevel = Optional TrustAll
Server = file:///home/zpt/projects/zpt2linux/repo
```

pacman downloads as the `alpm` user (`DownloadUser = alpm`), and `/home/zpt` is closed to
others, so give `alpm` traverse-only access once:

```sh
sudo setfacl -m u:alpm:x /home/zpt
```

Then:

```sh
sudo pacman -Sy zpt2linux-desktop
```

pacman asks to remove the stock packages each one conflicts with; answer yes.
After installing, point ly at the packaged server (`x_cmd = /usr/bin/X` in `/etc/ly/config.ini`)
and note that homestead's own `/usr/local` builds still come first in PATH (and openbox's autostart
starts `/usr/local/bin/fastcompmgr` by full path) until they are removed or the paths are changed.

### On the Mac (MacBookPro16,1)

```sh
sudo pacman -Sy linux-cachyos-headers zpt2linux-mac
```

dkms builds the modules for every installed kernel with headers. CachyOS kernels are built with clang;
all 12 module sets compile against them with `LLVM=1` (checked on the desktop). Current dkms sets that
for clang-built kernels by itself; if a build fails with gcc option errors, check `dkms status` and the log.
Not done by the packages, still to do by hand (KaiT2en's Fedora installer does it in
`scripts/fedora/install-kernel-args.sh`):

- Kernel command line: blacklist the in-tree drivers these modules replace, e.g.
  `module_blacklist=acpi_tad,applesmc,macsmc,hid_apple,hid_appletb_bl,hid_appletb_kbd,hid_magicmouse,appletbdrm,apple_bce,apple_mfi_fastcharge,apple_gmux,sbs`
  and `initcall_blacklist=cmos_init,magicmouse_driver_init`, plus its power arguments
  (see that script for the current list).
- Enable the services you want, e.g. `sudo systemctl enable --now t2-fancontrol t2-zonepowerd
  t2-smc-gaugingd t2-force-click t2-kbd-backlight kait2en-touchbar-attach kait2en-t2-touchid
  kait2en-t2-remote t2-services-suspend`, and `systemctl --user enable kait2en-touchbar`.
- `t2-dsp` uses `bankstown-lv2` from the AUR for the 16,1 speaker profile; install it separately.
