import fs from 'node:fs';
import wav from 'node-wav';

import * as core from '@strudel/core';
import { mondo } from '@strudel/mondo';
import { Dough } from 'supradough';
import {
  getAudioContext,
  doughsamples,
  webaudioRepl,
} from '@strudel/webaudio';

const file = process.argv[2];
const code = fs.readFileSync(file, 'utf8');
const duration = +process.argv[3];

await core.evalScope(core, core.registerControl('markcss'), {
  samples: url => pure({ promise: doughsamples(url.__pure) }),
});

let pat = mondo(code);
await Promise.all(pat.firstCycleValues.map(v => v.promise));
pat = pat.filterValues(v => !v.promise);

if (duration) {
  const dough = new Dough();

  for (const hap of pat.queryArc(0, duration)) {
    hap.value._begin = hap.whole.begin;
    hap.value._duration = hap.duration;
    dough.scheduleSpawn(hap.value);
  }

  const data = [
    new Float32Array(dough.sampleRate * duration),
    new Float32Array(dough.sampleRate * duration),
  ];

  while (dough.t < data[0].length) {
    dough.update();
    data[0][dough.t - 1] = dough.out[0];
    data[1][dough.t - 1] = dough.out[1];
  }

  const buf = wav.encode(data, dough);
  fs.writeFileSync(`${file}.wav`, buf);
}

else {
  await evalScope(import('node-web-audio-api'));
  await getAudioContext().audioWorklet
    .addModule('supradough/dough-worklet.mjs');

  const repl = webaudioRepl();
  repl.setCps(1);
  repl.setPattern(pat.supradough());
}
