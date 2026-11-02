#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
cd "$root"
for name in builder runtime dejavu verify arch ubuntu opensuse fedora debian no-color; do
 docker build -t "hokum-emoji/$name" -f "emoji-harness/Dockerfile.$name" .
done
