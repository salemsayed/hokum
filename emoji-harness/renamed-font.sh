#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
for variant in pre-review branch; do
 out="$root/review-evidence/fedora-renamed/$variant"
 mkdir -p "$out"
 docker run --rm -e VARIANT="$variant" -e CASE=emoji -v "$root/bins:/bins:ro" -v "$root/emoji-harness:/harness:ro" -v "$out:/evidence" hokum-emoji/fedora-renamed sh /harness/session.sh
done
