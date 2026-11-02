# Emoji presentation regression harness

These runs use the real `hokum service` in isolated distro containers, each with headless sway and its own session bus. They do not send notifications to an existing desktop. Hardware modules and update checks are disabled. GNOME and Plasma identify font/package environments; neither shell is running here because Hokum requires layer-shell.

Build images from this branch's root:

```sh
sh emoji-harness/build-images.sh
sh emoji-harness/build-release.sh /path/to/hokum dev dev
sh emoji-harness/build-release.sh /path/to/hokum emoji-presentation branch
sh emoji-harness/matrix.sh
docker run --rm -v "$PWD:/evidence" hokum-emoji/dejavu python3 /evidence/emoji-harness/compare.py
```

The repository passed to `build-release.sh` must contain the named committed branches. Builds invoke upstream `scripts/build-linux.sh` on Ubuntu 24.04, including its four snapshot smoke tests. The integration branch pins the public Rune backport by SHA. Build outputs go in `bins/`; screenshots, installed font inventories, font matches, compositor/service logs and OS versions go in `outline-evidence/`.

The Arch image installs DejaVu, Liberation, Noto and Noto Color Emoji. The other images install their distributions' packaged fonts, including DejaVu, Liberation and Noto Emoji, without custom fontconfig ordering. These are representative font/package environments, not full stock desktop installations. Container images use current distribution repositories; preserve the captured versions when comparing future runs.

Sway's `cap_sys_nice` file capability is removed inside the Arch and Fedora test images because it cannot be acquired in an ordinary Docker container. No extra host capability, privileged container or host service modification is required.

The stress card covers default emoji, ZWJ families and professions, skin tones, flags, keycaps with and without VS16, VS15/VS16 pairs, Arabic, long text and action buttons. The stock case contains three ordinary notifications, one with two buttons. `compare.py` counts differing full-screen pixels both before and after masking the narrow clock column, and writes a labelled before/after composite.

Fedora 44 ships `Noto-COLRv1.ttf`. Rune's current swash renderer supports bitmap colour and nonzero COLR v0 base-glyph records regardless of table version, but not COLRv1-only or SVG-only glyphs. Both discovered and already-loaded symbol fonts are checked so available outlines remain visible. Colour rendering on this Fedora font set requires a separate rasterizer change. The `no-color` image additionally removes Noto Emoji from Arch to exercise outline fallback.

Segoe from `ttf-wps-fonts` is not included: the AUR package points to redistributed proprietary fonts and a restrictive EULA. The harness uses distro-provided free fonts only. macOS, Windows, physical GPU drivers and a full live desktop are outside this harness.

The `fedora-renamed` image renames Fedora's unmodified COLRv1 font to `NotoColorEmoji.ttf` to exercise the known-file-name loader. To compare the earlier branch against the guarded branch, preserve the earlier executable (Hokum `e1519cf7a8b33836f35c5ab637f1aeb392ceffbc`, Rune `f14ea24f15438cdc34494f67b728d76261ec99cf`) as `bins/hokum-pre-review`, then run:

```sh
sh emoji-harness/renamed-font.sh
docker run --rm -v "$PWD:/evidence" hokum-emoji/dejavu python3 /evidence/emoji-harness/compare-renamed.py
```

This regression shows the earlier branch losing entire emoji rows while the updated branch retains the available outline glyphs. It does not claim COLRv1 colour support.
