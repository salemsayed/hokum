#!/bin/sh
# Installs the apps a Linux desktop has that a container lacks: an AppImage (bb Nightly, whose
# desktop-entry hint doesn't match its launcher), a Flatpak (Hylki, by its exported entry) and a
# WhatsApp web app launcher in the style this distro's tools write. $1: omarchy|mint|app|none,
# $2: the browser program for the launcher.
set -eu
style=$1 browser=${2:-chromium}
A=/harness/assets
mkdir -p /root/AppImages/.icons /root/.local/share/applications /root/.local/share/icons/hicolor/256x256/apps \
  /var/lib/flatpak/exports/share/applications /var/lib/flatpak/exports/share/icons/hicolor/512x512/apps \
  /root/.config/hokum /root/.local/state/hokum
cp $A/bb_nightly /root/AppImages/.icons/bb_nightly
cat > /root/.local/share/applications/bb_nightly.desktop <<E
[Desktop Entry]
Type=Application
Name=bb Nightly (0.46.2-nightly.38756742631.1)
Exec=env DESKTOPINTEGRATION=1 /root/AppImages/bb_nightly.appimage --no-sandbox %U
Icon=/root/AppImages/.icons/bb_nightly
StartupWMClass=bb Nightly
E
cp $A/hylki.png /var/lib/flatpak/exports/share/icons/hicolor/512x512/apps/co.hyprlab.Hylki.Beta.png
cat > /var/lib/flatpak/exports/share/applications/co.hyprlab.Hylki.Beta.desktop <<E
[Desktop Entry]
Type=Application
Name=Hylki (beta)
Exec=/usr/bin/flatpak run --branch=beta --arch=x86_64 --command=hylki co.hyprlab.Hylki.Beta
Icon=co.hyprlab.Hylki.Beta
X-Flatpak=co.hyprlab.Hylki.Beta
E
case $style in
omarchy)
  mkdir -p /root/.local/share/applications/icons && cp $A/whatsapp.png /root/.local/share/applications/icons/WhatsApp.png
  printf '[Desktop Entry]\nVersion=1.0\nName=WhatsApp\nExec=omarchy-launch-webapp https://web.whatsapp.com/\nTerminal=false\nType=Application\nIcon=/root/.local/share/applications/icons/WhatsApp.png\nStartupNotify=true\n' \
    > /root/.local/share/applications/WhatsApp.desktop ;;
mint)
  mkdir -p /root/.local/share/ice/icons && cp $A/whatsapp.png /root/.local/share/ice/icons/WhatsApp.png
  cat > /root/.local/share/applications/WebApp-WhatsApp4821.desktop <<E
[Desktop Entry]
Version=1.0
Name=WhatsApp
Comment=Web App
Exec=sh -c 'XAPP_FORCE_GTKWINDOW_ICON="/root/.local/share/ice/icons/WhatsApp.png" $browser --app="https://web.whatsapp.com/" --class=WebApp-WhatsApp4821 --name=WebApp-WhatsApp4821 --user-data-dir=/root/.local/share/ice/profiles/WhatsApp4821'
Terminal=false
X-MultipleArgs=false
Type=Application
Icon=/root/.local/share/ice/icons/WhatsApp.png
Categories=GTK;WebApps;
StartupWMClass=WebApp-WhatsApp4821
StartupNotify=true
X-WebApp-Browser=Chromium
X-WebApp-URL=https://web.whatsapp.com/
E
  ;;
app)
  cp $A/whatsapp.png /root/.local/share/icons/hicolor/256x256/apps/whatsapp.png
  printf '[Desktop Entry]\nType=Application\nName=WhatsApp\nExec=%s --app=https://web.whatsapp.com/\nIcon=whatsapp\n' "$browser" \
    > /root/.local/share/applications/whatsapp-web.desktop ;;
esac
cat > /root/.config/hokum/config.kdl <<E
theme "capsule"
behaviour {
    show-at-most 9
    stay 900
    appearance "light"
    check-for-updates #false
}
modules {
    sound #false
    bluetooth #false
}
E
touch /root/.local/state/hokum/welcomed
