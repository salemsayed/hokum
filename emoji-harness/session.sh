#!/bin/sh
set -eu
export XDG_RUNTIME_DIR=/tmp/xdg WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1
export HOKUM_SOUND_BACKEND=mock HOKUM_BLUETOOTH_BACKEND=mock
mkdir -p -m700 "$XDG_RUNTIME_DIR" /root/.config/hokum /root/.local/state/hokum
cat > /root/.config/hokum/config.kdl <<'CONFIG'
theme "capsule"
behaviour {
 check-for-updates #false
 stay 900
 show-at-most 3
}
modules {
 sound #false
 bluetooth #false
}
CONFIG
touch /root/.local/state/hokum/welcomed
fc-list --format='%{family[0]}\t%{file}\t%{color}\n' | sort > /evidence/fonts.txt
fc-match -s 'sans-serif:charset=1f600' > /evidence/fallback.txt
fc-match emoji > /evidence/emoji-font.txt
cat /etc/os-release > /evidence/os-release.txt
exec dbus-run-session -- sh /harness/inside.sh
