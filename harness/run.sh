#!/bin/sh
# run.sh <hokum binary> <name>: one pass of the scenarios on this image.
export XDG_RUNTIME_DIR=/tmp/xdg WLR_BACKENDS=headless WLR_RENDERER=pixman WLR_LIBINPUT_NO_DEVICES=1
mkdir -p -m 700 $XDG_RUNTIME_DIR
exec dbus-run-session -- sh /harness/session.sh "$@"
