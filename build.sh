#!/bin/sh
# Build every package in pkgs/ and index it into repo/zpt2linux.db. Installs nothing:
# missing build deps make makepkg fail and are listed in the summary for you to install.
cd "$(dirname "$0")" || exit 1
export PATH=/usr/bin:$PATH  # a non-zstd "zstd" in ~/.local/bin breaks package compression
mkdir -p repo
failed=
for d in pkgs/*/; do
  n=$(basename "$d")
  echo "=== $n"
  # Meta-packages depend on packages that live only in this repo, and DKMS packages build
  # nothing but depend on dkms, so skip the dep check for both.
  case $n in zpt2linux-*|*-dkms) flags=-fd ;; *) flags=-f ;; esac
  if (cd "$d" && makepkg $flags && for f in $(makepkg --packagelist); do [ -f "$f" ] && cp "$f" ../../repo/; done); then
    echo "=== $n: OK"
  else
    echo "=== $n: FAILED"; failed="$failed $n"
  fi
done
repo-add -R repo/zpt2linux.db.tar.zst repo/*.pkg.tar.zst
echo "SUMMARY: failed:${failed:- none}"
ls repo/*.pkg.tar.zst
[ -z "$failed" ]
