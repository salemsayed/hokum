#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
runs=${RUNS:-15}
out="$root/evidence/startup"
mkdir -p "$out"
: > "$out/runs.tsv"
for i in $(seq "$runs"); do
 for pair in fedora:branch fedora:colrv1 arch:colrv1; do
  distro=${pair%%:*}
  variant=${pair#*:}
  ms=$(docker run --rm -e VARIANT="$variant" -e CASE=emoji -e STARTUP=1 -v "$root/bins:/bins:ro" -v "$root/colrv1-harness:/harness:ro" -v "$out/scratch:/evidence" "hokum-colrv1/$distro" sh /harness/session.sh | tail -n 1)
  printf '%s\t%s\t%s\t%s\n' "$i" "$distro" "$variant" "$ms" >> "$out/runs.tsv"
 done
done
docker run --rm -v "$out:/out" hokum-colrv1/dejavu rm -rf /out/scratch
