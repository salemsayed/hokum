#!/bin/sh
# scale-matrix.sh: each desktop's text setting, stock and enlarged, with the dev and text-scale builds.
here=$(dirname "$(realpath "$0")"); bins=$(realpath "$here/../bins"); out="$here/out"
run() { # image name setup live [portal]
  for b in dev scale; do
    sudo docker run --rm --cap-add SYS_NICE -v "$here":/harness:ro -v "$bins":/bins:ro -v "$out":/out \
      -e XDG_RUNTIME_DIR=/tmp/xdg -e WLR_BACKENDS=headless -e WLR_RENDERER=pixman -e WLR_LIBINPUT_NO_DEVICES=1 ${5:+-e PORTAL=1} \
      hokum-test/$1 sh -c "mkdir -p -m 700 /tmp/xdg && dbus-run-session -- sh /harness/scale.sh /bins/hokum-$b-u2404 $2-$b '$3' '$4'" > "$out/scale-$2-$b.run.log" 2>&1
    echo "$2 $b: $([ -s "$out/scale-$2-$b.png" ] && echo ok || echo none)$([ -n "$4" ] && { [ -s "$out/scale-$2-$b-live.png" ] && echo ' +live' || echo ' no-live'; })"
  done
}
G='gsettings set org.gnome.desktop.interface text-scaling-factor'
run ubuntu gnome-stock "$G 1.0" "$G 1.5" portal
run ubuntu gnome-large "$G 1.25" "" portal
run opensuse plasma-stock 'printf "[General]\nfont=Noto Sans,10,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\n" > /root/.config/kdeglobals' 'sed -i "s/Noto Sans,10,/Noto Sans,12,/" /root/.config/kdeglobals'
run opensuse plasma-12pt 'printf "[General]\nfont=Noto Sans,12,-1,5,400,0,0,0,0,0,0,0,0,0,0,1\n" > /root/.config/kdeglobals' ""
run arch omarchy-stock 'mkdir -p /root/.local/state/omarchy/current/theme /root/.config/omarchy && printf "[font]\nbase-size = 12\n" > /root/.local/state/omarchy/current/theme/shell.toml' 'printf "[font]\nbase-size = 14\n" > /root/.config/omarchy/shell.toml'
run arch omarchy-14 'mkdir -p /root/.local/state/omarchy/current/theme /root/.config/omarchy && printf "[font]\nbase-size = 12\n" > /root/.local/state/omarchy/current/theme/shell.toml && printf "[font]\nbase-size = 14\n" > /root/.config/omarchy/shell.toml' ""
run fedora fedora-stock "" ""
run debian debian-stock "" ""
sudo chown -R "$(id -u):$(id -g)" "$out"
