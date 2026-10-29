#!/bin/sh
# Inside dbus-run-session: Hokum ($1) with the desktop set up by $3, three cards (one with
# buttons, one waiting behind the "more" pill), a screenshot; then $4 (a live change, if any)
# and a second screenshot without restarting Hokum. Shots: /out/scale-$2.png, -live.png.
bin=$1 name=$2 setup=$3 live=$4
sway -c /harness/sway.conf > /out/scale-$name.sway.log 2>&1 &
for i in $(seq 50); do [ -S "$XDG_RUNTIME_DIR/wayland-1" ] && break; sleep 0.1; done
export WAYLAND_DISPLAY=wayland-1
mkdir -p /root/.config/hokum /root/.local/state/hokum && touch /root/.local/state/hokum/welcomed
printf 'theme "capsule"\nbehaviour {\n    show-at-most 2\n    stay 900\n    appearance "light"\n    check-for-updates #false\n}\nmodules {\n    sound #false\n    bluetooth #false\n}\n' > /root/.config/hokum/config.kdl
sh -c "$setup"
if [ -n "${PORTAL:-}" ]; then
  /usr/libexec/xdg-desktop-portal-gtk > /out/scale-$name.portal-gtk.log 2>&1 &
  sleep 1
  /usr/libexec/xdg-desktop-portal -r > /out/scale-$name.portal.log 2>&1 &
  sleep 2
fi
"$bin" service > /out/scale-$name.hokum.log 2>&1 &
for i in $(seq 100); do
  gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.NameHasOwner org.freedesktop.Notifications 2>/dev/null | grep -q true && break
  sleep 0.1
done
sleep 1.5
notify-send -a Backup -i drive-harddisk "Backup finished" "412 files, 2.1 GB copied to the external drive"
sleep 0.3
gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify \
  "Calendar" 0 "x-office-calendar" "Design review" "Today 15:00 · Room 2" "['default', 'Open', 'snooze', 'Snooze', 'dismiss', 'Dismiss']" "{}" "int32 0" >/dev/null
sleep 0.3
notify-send -a Mail "Weekly report" "Ready to download"
sleep 2
grim /out/scale-$name.png
if [ -n "$live" ]; then
  sh -c "$live"
  sleep 3
  grim /out/scale-$name-live.png
fi
