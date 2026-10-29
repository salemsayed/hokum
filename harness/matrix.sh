#!/bin/sh
# matrix.sh <distro...>: builds each image and runs the before and after binaries on it.
set -u
here=$(dirname "$(realpath "$0")"); bins=$(realpath "$here/../bins"); out=$(realpath -m "$here/out")
mkdir -p "$out"
for d in "$@"; do
  sudo docker image inspect hokum-test/$d >/dev/null 2>&1 || { echo "$d: no image"; continue; }
  for b in before after; do
    sudo docker run --rm --cap-add SYS_NICE -v "$here":/harness:ro -v "$bins":/bins:ro -v "$out":/out hokum-test/$d sh /harness/run.sh /bins/hokum-$b-u2404 $d-$b > "$out/$d-$b.run.log" 2>&1
    echo "$d $b: $( [ -s "$out/$d-$b.png" ] && echo ok || echo no-screenshot )"
  done
done
sudo chown -R "$(id -u):$(id -g)" "$out"
