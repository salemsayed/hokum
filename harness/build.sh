#!/bin/sh
# Builds hokum from $1 (a checkout) into $2 inside the Ubuntu 24.04 builder, as upstream's releases are.
set -eu
src=$(realpath "$1"); out=$(realpath -m "$2")
mkdir -p "$(dirname "$out")"
sudo docker run --rm -v "$src":/src:ro -v hokum-test-cargo:/root/.cargo/registry -v hokum-test-target-$(basename "$src"):/target \
  -e CARGO_TARGET_DIR=/target hokum-test/builder sh -c 'cd /src && cargo build --release --locked && cp /target/release/hokum /target/hokum.out'
id=$(sudo docker create -v hokum-test-target-$(basename "$src"):/target hokum-test/builder)
sudo docker cp "$id":/target/hokum.out "$out" >/dev/null; sudo docker rm "$id" >/dev/null
sudo chown "$(id -u):$(id -g)" "$out"
echo "$out"
