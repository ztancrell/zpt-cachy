# zpt2linux

My own CachyOS setup (not a distro) for two machines, the desktop and a MacBookPro16,1: CachyOS
as-is, plus this local pacman repo with my homestead X stack and T2 Mac packages, plus my configs, wallpapers, icons and themes in the
[dotfiles repo](https://github.com/ztancrell/dotfiles). See `DESIGN.md` for the idea and decisions.

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
    reserves the name "KAIT2EN" for its own distribution, so nothing here is called `kait2en-*`, and no
    KaiT2en logos are shipped). Three split PKGBUILDs, one per kind of build:
    - `t2-dkms`: 12 DKMS packages, one per upstream `dkms.conf`, sources in `/usr/src/<name>-<ver>/`:
      `t2bce_stack-dkms` (BCE: DMA, core, VHCI/USB, audio, AVE, Sidecar), `t2smc-dkms`, `t2bdrm-dkms`,
      `t2touchbar-dkms`, `hid_t2magicmouse-dkms`, `t2_precision_trackpad-dkms`, `t2_trackpad_actuator-dkms`,
      `t2mfi_fastcharge-dkms`, `t2gmux-dkms`, `t2thunderbolt-dkms`, `t2smp-dkms`, `t2sbs-dkms`.
    - `t2-support` (no compiling): `t2-dsp` (speaker DSP for PipeWire/WirePlumber), `t2bce_audio-alsa-ucm-conf`,
      `t2-services-common`, `t2-power-tune`, `t2-sidecar` (GNOME/Mutter only), `t2-blacklist`
      (`/usr/lib/modprobe.d/t2-blacklist.conf`, see the Mac section).
    - `t2-apps` (Rust): `t2-fan-control`, `t2-smc-control`, `t2-zone-power`, `t2-force-click`,
      `t2-kbd-backlight`, `t2-touchbar`, `t2-touchid`, `t2-ave` (t2remote), `t2-journal`, and the extras
      `t2-airshare`, `t2-drop`, `t2-debug`, `t2-power-explorer`.
  - `bankstown-lv2`: bass enhancer LV2 plugin ([chadmed/bankstown](https://github.com/chadmed/bankstown),
    tag 1.1.0 pinned), needed by `t2-dsp`.
  - `zpt2linux-mac`: meta-package depending on all 31 T2 packages above (`bankstown-lv2` comes in via `t2-dsp`).
- `build.sh`: builds every package in `pkgs/` (or only the `pkgs/<dir>/` arguments) with `makepkg -f`
  (never installs anything), copies the results into `repo/` and indexes them with `repo-add` into
  `repo/zpt2linux.db.tar.zst`. `MAKEPKG_EXTRA` adds makepkg flags (CI uses `-s --noconfirm`).
- `repo/`: the built local repo (not committed).
- `.github/workflows/repo.yml`: CI, see [CI](#ci).
- `zpt2linux.asc`: the repo's public signing key.

The homestead packages build from the forks at the commits the `../homestead` submodules point at
(`_commit=` in each PKGBUILD; the libinput driver comes from upstream, see above). To pick up new homestead work: bump `_commit` and `pkgver`, rerun `./build.sh`.
Build options follow `../homestead/CLAUDE.md`, with prefix `/usr` instead of `/usr/local`.

Not packaged from KaiT2en: `t2sep` (retired upstream), `linux-apfs-rw` (third-party; AUR has it),
`t2-dgpu-control` (MacBookPro15,3 only), `t2-hybrid-gpu-control` (writes a UEFI preboot app to the ESP),
`t2-truetone` (GNOME Shell only), `kait2en-update`, `t2-kernel-builder` (Fedora tools), the deprecated
`t2-cpu-control`, and upstream's patched in-tree modules (`patches/runtime`: amdgpu GPU runtime PM, i915
PSR/backlight, brcmfmac/Bluetooth incl. AWDL), which its Fedora installer rebuilds per kernel.
Known bugs in KaiT2en's code (from our T2 reverse-engineering review) are not patched here yet.
To pick up new KaiT2en work: bump `_commit` and `pkgver` in the three `t2-*` PKGBUILDs.

Not here: configs (they live in the dotfiles repo).

## Build

```sh
./build.sh
```

If makepkg reports missing build dependencies, install them with `sudo pacman -S <deps>` and rerun.
`t2-apps` and `bankstown-lv2` need pacman's Rust (`rustup` or `rust`); a rustup install only in
`~/.cargo` does not satisfy makepkg. `build.sh` skips the dep check for `zpt2linux-*` and `*-dkms`
directories (their dependencies live only in this repo, or are runtime-only).

## CI

`.github/workflows/repo.yml` runs on every push to `main`, weekly (Monday 04:17 UTC) and by hand
(Actions tab, "Run workflow", or `gh workflow run repo`). In a fresh `cachyos/cachyos-v3` container it:

1. builds every package with `build.sh` (the X server first, installed, then the rest; build deps come
   from the CachyOS/Arch repos via `makepkg -s`);
2. runs `namcap` on every package: report only, in the run's summary page (namcap's errors include
   false positives, so they don't fail the run);
3. builds every DKMS module set with `dkms build` against the latest `linux-cachyos-headers`
   (summary lists each one); any failure fails the run, which is what the weekly run is for;
4. signs every package and the db with the repo key (private key in the `GPG_PRIVATE_KEY` secret);
5. only if all of that passed: replaces the rolling release [`repo`](https://github.com/ztancrell/zpt2linux/releases/tag/repo)
   with the new packages, `.sig` files and `zpt2linux.db`/`.files` (+ `.sig`), so it always mirrors the
   current repo.

Results: <https://github.com/ztancrell/zpt2linux/actions>. Signing key `zpt2linux.asc`, fingerprint
`1DEAC2960F73252F7D1DA8CCACDEC7B1A4F94116`.

## Install

Once on each machine, trust the repo key:

```sh
curl -sLO https://raw.githubusercontent.com/ztancrell/zpt2linux/main/zpt2linux.asc
sudo pacman-key --add zpt2linux.asc
sudo pacman-key --lsign-key 1DEAC2960F73252F7D1DA8CCACDEC7B1A4F94116
```

Add to `/etc/pacman.conf`, after the CachyOS and Arch repos (default `SigLevel`, signatures required):

```ini
[zpt2linux]
Server = https://github.com/ztancrell/zpt2linux/releases/download/repo
```

(Needs the GitHub repo to be public; release downloads of a private repo 404.)

To test unpushed changes, use the local build instead: `./build.sh`, and point the same section at it
(unsigned, so `SigLevel = Optional TrustAll`):

```ini
[zpt2linux]
SigLevel = Optional TrustAll
Server = file:///home/zpt/projects/zpt2linux/repo
```

pacman downloads as the `alpm` user (`DownloadUser = alpm`), and `/home/zpt` is closed to
others, so for the `file://` route give `alpm` traverse-only access once:

```sh
sudo setfacl -m u:alpm:x /home/zpt
```

Superseded (2026-11-09): the `file://` repo with `SigLevel = Optional TrustAll` as the everyday setup;
it is now only for testing local changes. The everyday source is the signed GitHub release above.

Then, on the desktop:

```sh
sudo pacman -Sy zpt2linux-desktop
```

(on the Mac, see [below](#on-the-mac-macbookpro161))

pacman asks to remove the stock packages each one conflicts with; answer yes.
After installing, point ly at the packaged server (`x_cmd = /usr/bin/X` in `/etc/ly/config.ini`)
and note that homestead's own `/usr/local` builds still come first in PATH (and openbox's autostart
starts `/usr/local/bin/fastcompmgr` by full path) until they are removed or the paths are changed.

## Fresh install

1. Install CachyOS.
2. Restore the dotfiles (bare repo, `$HOME` as work tree):

   ```sh
   git clone --bare https://github.com/ztancrell/dotfiles.git ~/.dotfiles
   git --git-dir=$HOME/.dotfiles --work-tree=$HOME checkout
   git --git-dir=$HOME/.dotfiles config status.showUntrackedFiles no
   ```

   If `checkout` refuses because files already exist (fresh-install defaults), move those aside and rerun it.
3. Follow [Install](#install): trust the key, add the `[zpt2linux]` repo, and
   `sudo pacman -Sy zpt2linux-desktop`. (Clone this repo to `~/projects/zpt2linux` only to build locally.)
4. Set `x_cmd = /usr/bin/X` in `/etc/ly/config.ini`.
5. Turn the hourly dotfiles backup back on: `systemctl --user enable --now dotfiles-backup.timer`.

### On the Mac (MacBookPro16,1)

1. Install CachyOS. The internal keyboard and trackpad sit behind the T2 (BCE) and work in the
   installer only if its kernel has T2 BCE drivers (linux-cachyos 7.3 ships `t2bce_*` in staging, so a
   current ISO may; untested), otherwise use a T2-capable ISO or a USB keyboard/mouse on a USB-C adapter. Turn off Secure Boot / allow external boot in macOS Recovery's
   Startup Security Utility first.
2. Restore the dotfiles and add this repo as in [Fresh install](#fresh-install) and [Install](#install).
3. Install:

   ```sh
   sudo pacman -Sy linux-cachyos-headers zpt2linux-mac
   ```

   dkms builds the modules for every installed kernel with headers. CachyOS kernels are clang-built;
   dkms (3.x) appends `LLVM=1` to the build itself when the kernel config has `CONFIG_CC_IS_CLANG=y`.
   No kernel patches are needed: KaiT2en targets stock kernels with these DKMS modules.
4. Blacklist: `t2-blacklist` stops the in-tree drivers the modules replace (`acpi_tad applesmc macsmc
   macsmc_acpi hid_apple hid_appletb_bl hid_appletb_kbd hid_magicmouse appletbdrm apple_bce
   apple_mfi_fastcharge apple_gmux sbs`; all `=m` or absent in linux-cachyos 7.3, so modprobe.d works).
   linux-cachyos 7.3 also ships KaiT2en's `t2bce_*` in staging; the DKMS copies in `updates/dkms` take
   precedence. The `modconf` hook copies the blacklist into the initramfs; rebuild it once after
   installing: `sudo mkinitcpio -P` (or `sudo limine-mkinitcpio` with Limine). Optional, as upstream's
   installer does: load the keyboard, SMC and battery drivers early, so the keyboard works at a LUKS
   prompt and the clock is set early, with
   `MODULES=(t2bce_dma t2bce_core t2bce_vhci t2hid t2smc t2sbs)` in `/etc/mkinitcpio.conf`.
5. Kernel command line, by hand (not done by the packages; upstream's
   `scripts/fedora/install-kernel-args.sh` has the current list):
   - Recommended: `initcall_blacklist=cmos_init,magicmouse_driver_init` (`rtc_cmos` is built in, `=y`,
     so modprobe.d cannot stop it; t2smc provides the RTC).
   - Optional power arguments: `amdgpu.aspm=1 i915.enable_guc=2 intel_iommu=on iommu=pt pcie_aspm=force
     pcie_aspm.policy=powersave pcie_ports=compat pci=noaer mem_sleep_default=deep`.
6. Enable the services you want:

   ```sh
   sudo systemctl enable --now t2-fancontrol t2-zonepowerd t2-smc-gaugingd t2-force-click \
     t2-kbd-backlight kait2en-touchbar-attach kait2en-t2-touchid kait2en-t2-remote t2-services-suspend
   systemctl --user enable kait2en-touchbar t2-airshare
   ```

   `t2-sidecar` (GNOME only) starts its user units itself (`t2-sidecar on`); `t2-drop` and the AirShare
   hotspot helper start on demand over D-Bus. `t2-drop` needs AirDrop
   (AWDL) support in brcmfmac, which is in upstream's wireless patches, not in the stock kernel.
