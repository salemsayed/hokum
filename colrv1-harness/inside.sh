#!/bin/sh
set -eu
sway -c /harness/sway.conf > /evidence/sway.log 2>&1 &
for i in $(seq 100); do [ ! -S "$XDG_RUNTIME_DIR/wayland-1" ] || break; sleep 0.1; done
export WAYLAND_DISPLAY=wayland-1
start=$(date +%s%N)
/bins/hokum-${VARIANT} service > /evidence/hokum.log 2>&1 &
for i in $(seq 2000); do
 gdbus call --session --dest org.freedesktop.DBus --object-path /org/freedesktop/DBus --method org.freedesktop.DBus.NameHasOwner org.freedesktop.Notifications | grep -q true && break
 sleep 0.005
done
ready=$(date +%s%N)
if [ -n "${STARTUP:-}" ]; then
 echo $(( (ready - start) / 1000000 ))
 exit 0
fi
if [ "$CASE" = stock ]; then
 notify-send -a 'Mail' -t 0 'Design review' 'The latest revision is ready. Please review the updated drawings.'
 notify-send -a 'Build' -t 0 'Build completed' 'All checks passed. Release artifacts are available.'
 gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify 'Calendar' 0 '' 'Meeting in ten minutes' 'Join the product discussion.' "['open', 'Open', 'later', 'Later']" '{}' 0 > /evidence/notification.txt
else
 gdbus call --session --dest org.freedesktop.Notifications --object-path /org/freedesktop/Notifications --method org.freedesktop.Notifications.Notify 'Emoji check' 0 '' 'Hello 😀 مرحبا 👩🏽‍💻' 'Faces: 😀 😃 😄 🎉 🚀\nZWJ: 👩🏽‍💻 👨‍👩‍👧‍👦\nTone: 👍🏽 👋🏿\nFlags: 🇪🇬 🇺🇸\nKeys: 1️⃣ #️⃣ 1⃣\nText/VS15/VS16: © ©︎ ©️ ☺ ☺︎ ☺️\nDefault/VS15/VS16: 😀 😀︎ 😀️\nمرحبا بالعالم. Long text wraps naturally across the notification card with joined emoji 👨‍👩‍👧‍👦 and ordinary words continuing beyond the line limit.' "['open', 'Open 😀', 'later', 'Later ☺︎']" '{}' 0 > /evidence/notification.txt
fi
sleep 3
grim /evidence/card.png
