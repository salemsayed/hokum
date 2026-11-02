#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
for distro in arch ubuntu opensuse fedora debian; do
 for variant in dev branch; do
  for case in emoji stock; do
   out="$root/outline-evidence/matrix/$distro/$variant/$case"
   mkdir -p "$out"
   docker run --rm -e VARIANT="$variant" -e CASE="$case" -v "$root/bins:/bins:ro" -v "$root/emoji-harness:/harness:ro" -v "$out:/evidence" "hokum-emoji/$distro" sh /harness/session.sh
  done
 done
done
