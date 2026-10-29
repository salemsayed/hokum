# Test harness for "Find every app's icon the way desktops do"

Build both binaries on Ubuntu 24.04 (`build.sh <checkout> <out>`, into ../bins as hokum-before-u2404 and hokum-after-u2404), build an image per distro (`docker build -t hokum-test/<d> -f Dockerfile.<d> .`), then `matrix.sh ubuntu fedora opensuse debian arch` runs each binary under headless sway with a private session bus, sends `scenarios.json` (shapes captured from Chrome, an Electron AppImage, xdg-desktop-portal-gtk and notify-send) and screenshots the cards; `compose.sh <d> <title>` puts before and after side by side.
