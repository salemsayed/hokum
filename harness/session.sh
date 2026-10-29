#!/bin/sh
# Inside dbus-run-session: a headless sway, (the settings portal), Hokum, the scenarios, a screenshot.
set -u
bin=$1 out=$2
sway -c /harness/sway.conf > /out/$out.sway.log 2>&1 &
for i in $(seq 50); do [ -S "$XDG_RUNTIME_DIR/wayland-1" ] && break; sleep 0.1; done
export WAYLAND_DISPLAY=wayland-1
if [ -n "${PORTAL:-}" ]; then
  /usr/libexec/xdg-desktop-portal-gtk > /out/$out.portal-gtk.log 2>&1 &
  sleep 1
  /usr/libexec/xdg-desktop-portal -r > /out/$out.portal.log 2>&1 &
  sleep 2
  gdbus call --session --dest org.freedesktop.portal.Desktop --object-path /org/freedesktop/portal/desktop \
    --method org.freedesktop.portal.Settings.ReadOne org.gnome.desktop.interface icon-theme > /out/$out.portal-theme.txt 2>&1
fi
"$bin" service > /out/$out.hokum.log 2>&1 &
for i in $(seq 100); do
  gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.NameHasOwner org.freedesktop.Notifications 2>/dev/null | grep -q true && break
  sleep 0.1
done
python3 /harness/send.py /harness/scenarios.json > /out/$out.send.log 2>&1
sleep 3
grim /out/$out.png
# The settings window's Applications list, drawn headless from the apps this run recorded.
"$bin" --snap /out/$out-apps.png --scene applications > /out/$out.apps.log 2>&1
