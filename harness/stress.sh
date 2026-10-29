#!/bin/sh
# Inside dbus-run-session (Ubuntu image, GTK portal): Hokum ($1) at GNOME text scaling $3 with
# cards that stress layout: long names, long bodies, many long buttons, a picture, a progress
# bar, Arabic and emoji, and more cards than fit. Shot: /out/stress-$2.png.
bin=$1 name=$2 factor=$3
sway -c /harness/sway.conf > /out/stress-$name.sway.log 2>&1 &
for i in $(seq 50); do [ -S "$XDG_RUNTIME_DIR/wayland-1" ] && break; sleep 0.1; done
export WAYLAND_DISPLAY=wayland-1
mkdir -p /root/.config/hokum /root/.local/state/hokum && touch /root/.local/state/hokum/welcomed
printf 'theme "%s"\ntokens {\n    font-size %s\n}\nbehaviour {\n    stay 900\n    appearance "light"\n    check-for-updates #false\n}\nmodules {\n    sound #false\n    bluetooth #false\n}\n' "${THEME:-capsule}" "${FONT_SIZE:-13}" > /root/.config/hokum/config.kdl
gsettings set org.gnome.desktop.interface text-scaling-factor "$factor"
/usr/libexec/xdg-desktop-portal-gtk > /dev/null 2>&1 &
sleep 1
/usr/libexec/xdg-desktop-portal -r > /dev/null 2>&1 &
sleep 2
"$bin" service > /out/stress-$name.hokum.log 2>&1 &
for i in $(seq 100); do
  gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.NameHasOwner org.freedesktop.Notifications 2>/dev/null | grep -q true && break
  sleep 0.1
done
sleep 1.5
N() { gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify "$@" "int32 0" >/dev/null; sleep 0.3; }
N "Short" 0 "" "Hi" "" "[]" "{}"
N "Downloads" 0 "folder-download" "Copying files" "hokum-x86_64.tar.zst" "[]" "{'value': <int32 64>}"
N "A Very Long Application Name That Keeps Going" 0 "" "A long summary that will need more than one line to show completely on the card" \
  "Body line one keeps going for a while so it wraps across the width of the card. Line two adds more words. Line three. Line four. Line five has even more text to push the limit of eight lines. Line six. Line seven. Line eight. Line nine should be cut off with an ellipsis." "[]" "{'image-path': <'/harness/assets/avatar.png'>}"
N "Calendar" 0 "x-office-calendar" "Design review with the whole team" "Today 15:00 · Room 2" "['default', 'Open', 'snooze', 'Snooze for ten minutes', 'later', 'Remind me later today', 'decline', 'Decline the invitation', 'join', 'Join the call now']" "{}"
N "WhatsApp" 0 "" "عائلة سيد 🌺" "سلمى: صباح النور، إزيكم؟ 🚗💨" "[]" "{}"
N "Mail" 0 "" "Weekly report" "Ready to download" "[]" "{}"
sleep 2.5
grim /out/stress-$name.png
if [ -n "${WINDOW:-}" ]; then
  "$bin" > /dev/null 2>&1 &
  sleep 3
  grim /out/stress-$name-window.png
fi
