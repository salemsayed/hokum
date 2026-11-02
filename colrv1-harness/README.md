# COLRv1 emoji regression harness

These runs use the real `hokum service` in isolated distro containers, each with headless sway and its own session bus. They do not send notifications to an existing desktop. Hardware modules and update checks are disabled. GNOME and Plasma identify font/package environments; neither shell is running here because Hokum requires layer-shell.

Build images and executables from this folder's parent:

```sh
sh colrv1-harness/build-images.sh
sh colrv1-harness/build-release.sh /path/to/hokum <branch at upstream dev f30af6ae> dev
sh colrv1-harness/build-release.sh /path/to/hokum emoji-presentation branch
sh colrv1-harness/build-release.sh /path/to/hokum emoji-presentation-colrv1 colrv1
sh colrv1-harness/matrix.sh
docker run --rm -v "$PWD:/evidence" hokum-colrv1/dejavu python3 /evidence/colrv1-harness/compare.py
RUNS=15 sh colrv1-harness/startup.sh
```

`build-release.sh` clones the named committed branch and runs upstream `scripts/build-linux.sh` on Ubuntu 24.04, including its four snapshot smoke renders. `dev` is unchanged upstream Hokum, `branch` pins the emoji presentation fix and `colrv1` pins the same fix plus the COLRv1 painter, both backported onto Hokum's existing Rune revision.

`matrix.sh` runs every executable on Arch, Ubuntu 24.04, openSUSE Tumbleweed, Fedora 44 and Debian 13, with two cases: the emoji stress card (default emoji, ZWJ families and professions, skin tones, flags, keycaps with and without VS16, VS15/VS16 pairs, Arabic, long text and action buttons) and three stock notifications, one with two buttons. Screenshots, installed font inventories, the fontconfig `emoji` match and OS versions go in `evidence/matrix/`. `compare.py` counts differing full-screen pixels with and without the narrow clock column masked and writes the composites.

`startup.sh` measures milliseconds from launching `hokum service` to its ownership of `org.freedesktop.Notifications` on the session bus, alternating Fedora with the guard-only build, Fedora with the COLRv1 build and Arch (CBDT) with the COLRv1 build, one fresh container per run. It polls every 5 ms with `gdbus`, so each sample includes that polling cost; it does not include drawing the first card.

Fedora 44 installs `Noto-COLRv1.ttf`, whose COLR table has no v0 base-glyph records. The Arch image installs DejaVu, Liberation, Noto and Noto Color Emoji (CBDT). The other images install their distributions' packaged fonts, including DejaVu, Liberation and Noto Emoji, without custom fontconfig ordering. These are representative font/package environments, not full desktop installations. Images use current distribution repositories; the captured inventories identify what ran.

Sway's `cap_sys_nice` file capability is removed inside the Arch and Fedora images because it cannot be acquired in an ordinary Docker container. No extra host capability, privileged container or host service modification is required.
