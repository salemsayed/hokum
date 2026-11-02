#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
for distro in arch ubuntu opensuse fedora debian; do
 for variant in dev branch colrv1; do
  for case in emoji stock; do
   out="$root/evidence/matrix/$distro/$variant/$case"
   rm -rf "$out"
   mkdir -p "$out"
   docker run --rm -e VARIANT="$variant" -e CASE="$case" -v "$root/bins:/bins:ro" -v "$root/colrv1-harness:/harness:ro" -v "$out:/evidence" "hokum-colrv1/$distro" sh /harness/session.sh
  done
 done
done
