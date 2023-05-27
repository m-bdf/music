// Only works with integer params to `speed` and `arrange`
fn track_bars(code: &str) -> usize {
    let ast = glicol_parser::get_ast(&code).unwrap();

    use glicol_synth::GlicolPara;
    fn arrangement_bars(params: &Vec<GlicolPara>) -> usize {
        params.iter().rev().fold(0, |len, param| match param {
            GlicolPara::Number(v) => (len + *v as isize).max(0),
                //len.saturating_add_signed(*v as isize), // rust 1.66
            _ => len
        }).max(1) as _
    }

    ast.values().flat_map(|(nodes, params)|
        nodes.iter().zip(params).filter_map(|(node, params)|
            (node == "arrange").then(|| arrangement_bars(params))
        )
    ).reduce(num::integer::lcm).unwrap_or(1)
}

fn main() -> hound::Result<()> {
    use clap::Parser;
    #[derive(Parser)]
    struct Params {
        path: std::path::PathBuf,
        //cycles: usize,
        bpm: f32,
    }
    let params = Params::parse();
    let code = std::fs::read_to_string(&params.path)?;
    let track_bars = track_bars(&code);

    let mut engine = glicol::Engine::<1>::new();
    engine.set_bpm(params.bpm);
    engine.livecoding = false;
    engine.update_with_code(&code);

    const SPEC: hound::WavSpec = hound::WavSpec {
        channels: 2,
        sample_rate: 44100,
        bits_per_sample: 16,
        sample_format: hound::SampleFormat::Int,
    };
    let outpath = params.path.with_extension("wav");
    let mut writer = hound::WavWriter::create(outpath, SPEC)?;
    let samples = ((track_bars * 4 * 60 * SPEC.sample_rate as usize) as f32 / params.bpm) as usize;
    let mut writer = writer.get_i16_writer(samples as u32 * SPEC.channels as u32);

    for _ in 0..samples {
        let block = engine.next_block(vec![]).0;
        unsafe {
            let l = block.get_unchecked(0).get_unchecked(0);
            let r = block.get_unchecked(1).get_unchecked(0);
            use dasp_sample::Sample;
            writer.write_sample_unchecked(l.to_sample::<i16>());
            writer.write_sample_unchecked(r.to_sample::<i16>());
        }
    }
    writer.flush()
}
