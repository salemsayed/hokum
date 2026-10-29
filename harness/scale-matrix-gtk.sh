#!/bin/sh
# Fedora and Debian under sway (Hokum needs layer-shell), GTK's settings through the GTK portal.
here=$(dirname "$(realpath "$0")"); bins=$(realpath "$here/../bins"); out="$here/out"
G='gsettings set org.gnome.desktop.interface text-scaling-factor'
for d in fedora debian; do
  for v in "large|$G 1.25|" "live|$G 1.0|$G 1.5"; do
    IFS='|' read -r kind setup live <<EOV
$v
EOV
    for b in dev scale; do
      sudo docker run --rm --cap-add SYS_NICE -v "$here":/harness:ro -v "$bins":/bins:ro -v "$out":/out \
        -e XDG_RUNTIME_DIR=/tmp/xdg -e WLR_BACKENDS=headless -e WLR_RENDERER=pixman -e WLR_LIBINPUT_NO_DEVICES=1 -e PORTAL=1 -e XDG_CURRENT_DESKTOP=sway \
        hokum-test/$d sh -c "mkdir -p -m 700 /tmp/xdg && dbus-run-session -- sh /harness/scale.sh /bins/hokum-$b-u2404 $d-sway-$kind-$b '$setup' '$live'" > "$out/scale-$d-sway-$kind-$b.run.log" 2>&1
      echo "$d $kind $b: $([ -s "$out/scale-$d-sway-$kind-$b.png" ] && echo ok || echo none)$([ -n "$live" ] && { [ -s "$out/scale-$d-sway-$kind-$b-live.png" ] && echo ' +live' || echo ' no-live'; })"
    done
  done
done
sudo chown -R "$(id -u):$(id -g)" "$out"
