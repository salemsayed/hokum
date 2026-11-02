#[test]
fn bench_against_bitmaps() {
    let Ok(dir) = std::env::var("COLR_BENCH") else { return };
    let v1 = std::fs::read(format!("{dir}/Noto-COLRv1.ttf")).unwrap();
    let cb = std::fs::read(format!("{dir}/NotoColorEmoji.ttf")).unwrap();
    let cps = [0x1F600u32, 0x1F603, 0x1F604, 0x1F389, 0x1F680, 0x1F525, 0x1F308, 0x1F34E, 0x2764, 0x2B50, 0x1F44D, 0x1F431, 0x1F30D, 0x1F3A8, 0x1F4A1, 0x1F60D];
    let v1_ids: Vec<u32> = cps.iter().map(|&c| glyph(&v1, c)).collect();
    let cb_ids: Vec<u16> = cps.iter().map(|&c| glyph(&cb, c) as u16).collect();
    let font = swash::FontRef::from_index(&cb, 0).unwrap();
    let mut cx = swash::scale::ScaleContext::new();
    for ppem in [20.0f32, 32.0, 64.0] {
        let (mut a, mut b) = (Vec::new(), Vec::new());
        for rep in 0..41 {
            let t = std::time::Instant::now();
            for &id in &cb_ids {
                let mut scaler = cx.builder(font).size(ppem).hint(false).build();
                std::hint::black_box(crate::text::rasterize_color(&mut scaler, id).unwrap());
            }
            let cbdt = t.elapsed().as_secs_f64() * 1e6 / cps.len() as f64;
            let t = std::time::Instant::now();
            for &id in &v1_ids {
                std::hint::black_box(rasterize(&v1, 0, id, ppem, &[], BLUE_INK).unwrap());
            }
            let colr = t.elapsed().as_secs_f64() * 1e6 / cps.len() as f64;
            if rep > 0 { a.push(cbdt); b.push(colr); }
        }
        a.sort_by(f64::total_cmp); b.sort_by(f64::total_cmp);
        let q = |v: &Vec<f64>| (v[v.len() / 4], v[v.len() / 2], v[v.len() * 3 / 4]);
        println!("BENCH ppem={ppem} cbdt_us(q1,med,q3)={:?} colrv1_us(q1,med,q3)={:?}", q(&a), q(&b));
    }
}

#[test]
fn dump_glyphs() {
    let Ok(out) = std::env::var("COLR_DUMP") else { return };
    let size: f32 = std::env::var("COLR_SIZE").ok().and_then(|s| s.parse().ok()).unwrap_or(64.0);
    let mut meta = String::new();
    for g in 0..200 {
        let Some(img) = rasterize(TEST_GLYPHS, 0, g, size, &[], BLUE_INK) else { continue };
        meta += &format!("{g} {} {} {} {} {}\n", img.placement.left, img.placement.top, img.placement.width, img.placement.height, img.foreground);
        let file = std::fs::File::create(format!("{out}/{g}.png")).unwrap();
        let mut enc = png::Encoder::new(std::io::BufWriter::new(file), img.placement.width, img.placement.height);
        enc.set_color(png::ColorType::Rgba);
        enc.write_header().unwrap().write_image_data(&img.rgba).unwrap();
    }
    std::fs::write(format!("{out}/meta.txt"), meta).unwrap();
}
