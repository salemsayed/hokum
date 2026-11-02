#!/bin/sh
set -eu
root=$(CDPATH='' cd -- "$(dirname "$0")/.." && pwd)
repo=$(realpath "$1")
branch=$2
variant=$3
docker run --rm -v "$repo:/repo:ro" -v "$root/bins:/bins" -v hokum-colrv1-cargo:/root/.cargo/registry -v hokum-colrv1-git:/root/.cargo/git -v hokum-colrv1-release-target:/target -e CARGO_BUILD_JOBS=6 -e CARGO_TARGET_DIR=/target -e BRANCH="$branch" -e VARIANT="$variant" hokum-colrv1/dejavu sh -euc '
 git config --global --add safe.directory /repo
 git config --global --add safe.directory /repo/.git
 git clone --no-hardlinks --branch "$BRANCH" /repo /src
 cd /src
 executable=$(scripts/build-linux.sh)
 cp "$executable" "/bins/hokum-$VARIANT"
'
