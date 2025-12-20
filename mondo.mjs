import fs from 'node:fs';
import webAudio from 'node-web-audio-api';
import wavEncode from 'audiobuffer-to-wav';

import * as core from '@strudel/core';
import { mondo } from '@strudel/mondo';
import { doughsamples } from '@strudel/webaudio';
import { getAudioContext } from 'superdough';
import { workletUrl } from 'supradough';

const src = process.argv[2];
const code = fs.readFileSync(src, 'utf8');
const out = process.argv[3];

await core.evalScope(core, webAudio, {
  samples: url => pure({
    fetch: () => doughsamples(url.__pure),
  }),
});

registerControl('markcss');

let pat = mondo(code);
await Promise.all(pat.firstCycleValues.map(v => v.fetch?.()));
pat = pat.filterValues(v => !v.fetch);

const repl = core.repl({
  getTime: () => !out ? performance.now() / 1000 :
    repl.scheduler.clock.getPhase() - repl.scheduler.clock.minLatency,
});

repl.setCps(1);

if (out) {
  let duration;
  const haps = [];

  const layeredPat = pat.revv().stack(pat)
    .onTrigger(hap => {
      const n = haps.push(stringifyValues(hap.value));

      if (n > layeredPat.firstCycle().length &&
        haps.slice(n / 2).every((v, i) => v === haps[i])
      ) {
        duration = hap.endClipped / 2;
      }
    });

  console.log('\nFinding track duration...');
  await repl.setPattern(layeredPat);

  while (!duration) {
    await new Promise(r => setTimeout(r, 1000));
  }

  repl.stop();
  console.log(`\nRecording ${duration} seconds...`);
  repl.scheduler.clock.setDuration(() => duration / 10);

  AudioContext = class extends OfflineAudioContext {
    constructor(sampleRate = 48000) {
      super(2, sampleRate * duration, sampleRate);
    }
  };
}

const audioCtx = getAudioContext();

let doughWorklet = `import('${workletUrl}')`;

if (out) {
  doughWorklet += `
    import { workerData } from 'node:worker_threads';

    import nativeAudio from '${
      import.meta.resolve('node-web-audio-api')
    }/../load-native.cjs';

    const wrapped = registerProcessor;

    registerProcessor = (name, Processor) =>
      wrapped(name, class extends Processor {
        process(...args) {
          if (super.process(...args) && this.dough.t >= ${audioCtx.length}) {
            nativeAudio.exit_audio_worklet_global_scope(workerData.workletId);
          }
        }
      });
  `;
}

const doughWorkletUrl = URL.createObjectURL(new Blob([doughWorklet]));
await audioCtx.audioWorklet.addModule(doughWorkletUrl);
URL.revokeObjectURL(doughWorkletUrl);

await repl.setPattern(pat.supradough());

if (out) {
  await new Promise(r => setTimeout(r, 1000));
  repl.stop();

  console.log(`\nRendering to ${out}...`);
  const buf = await audioCtx.startRendering();
  const wav = Buffer.from(wavEncode(buf));
  fs.writeFileSync(out, wav);
}
