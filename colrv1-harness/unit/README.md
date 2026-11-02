# Unit-level measurements

Neither test is part of the Rune change. Append `raster_bench.rs` to `crates/rune/src/text/colr_tests.rs` in a Rune checkout of the `colrv1` branch to run them.

- `bench_against_bitmaps`: per-glyph raster time of 16 Noto emoji, COLRv1 through the new painter against CBDT through swash, 40 alternating paired rounds after one warm-up, at 20, 32 and 64 px. Set `COLR_BENCH` to a folder with `Noto-COLRv1.ttf` and `NotoColorEmoji.ttf` from noto-emoji v2.051. Rune's library tests need debug assertions to compile, so the recorded run used `CARGO_PROFILE_DEV_OPT_LEVEL=3 CARGO_PROFILE_DEV_DEBUG=0 cargo test --locked -p rune --no-default-features --features dbus,embedded-fonts,svg --lib -- colr::tests::bench_against_bitmaps --nocapture --test-threads=1`.
- `dump_glyphs`: writes every COLRv1 glyph of the test font as a PNG plus placements. `compare_hb.py <font> <dump> <out.png> <size>` lays each one beside HarfBuzz's `hb-view` rendering of the same character (HarfBuzz 8.3 with cairo 1.18, Ubuntu 24.04 `libharfbuzz-bin`). `compare_cbdt.py` compares COLRv1 and CBDT dumps of the same emoji inside their ink boxes.
