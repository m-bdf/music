import fs from 'node:fs';
import webAudio from 'node-web-audio-api';
import wavEncode from 'audiobuffer-to-wav';

import * as core from '@strudel/core';
import { mondo } from '@strudel/mondo';
import { doughsamples } from '@strudel/webaudio';
import { getAudioContext } from 'superdough';
import { workletUrl } from 'supradough';

const file = process.argv[2];
const code = fs.readFileSync(file, 'utf8');
const duration = +process.argv[3];

await core.evalScope(core, webAudio, {
  samples: url => pure({
    fetch: () => doughsamples(url.__pure),
  }),
});

registerControl('markcss');

let pat = mondo(code);
await Promise.all(pat.firstCycleValues.map(v => v.fetch?.()));
pat = pat.filterValues(v => !v.fetch);

if (duration) {
  AudioContext = class extends OfflineAudioContext {
    constructor(sampleRate = 48000) {
      super(2, sampleRate * (duration + 1), sampleRate);
    }
  };
}

const audioCtx = getAudioContext();

let doughWorklet = `import('${workletUrl}')`;

if (duration) {
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

const repl = core.repl({
  getTime: () => repl.scheduler.lastTick,
});

console.log();
repl.setCps(1);
repl.setPattern(pat.supradough());

if (duration) {
  repl.scheduler.clock.setDuration(() => duration);
  await new Promise(r => setTimeout(r, 1000));
  repl.stop();

  console.log(`\nRendering to ${file}.wav...`);
  const buf = await audioCtx.startRendering();
  const wav = Buffer.from(wavEncode(buf));
  fs.writeFileSync(`${file}.wav`, wav);
}

else {
  await context.suspend();
  setTimeout(() => context.resume(), 1000);
}
