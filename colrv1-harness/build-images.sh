#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
cd "$root"
for name in builder runtime dejavu verify arch ubuntu opensuse fedora debian; do
 docker build -t "hokum-colrv1/$name" -f "colrv1-harness/Dockerfile.$name" .
done
