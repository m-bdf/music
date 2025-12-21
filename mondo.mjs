import fs from 'node:fs';
import { styleText } from 'node:util';
import { scheduler } from 'node:timers/promises';

import webAudio from 'node-web-audio-api';
import wavEncode from 'audiobuffer-to-wav';

import * as core from '@strudel/core';
import * as tonal from '@strudel/tonal';
import { mondo } from '@strudel/mondo';

const src = process.argv[2];
const code = fs.readFileSync(src, 'utf8');
const out = process.argv[3];

await core.evalScope(webAudio);

const {
  samples,
  registerSynthSounds,
  webaudioOutput,
  setAudioContext,
  getAudioContext,
} = await import('@strudel/webaudio');

await core.evalScope(core, tonal, { window: globalThis });

strudelScope.samples = url => pure({
  fetch: () => samples(url.__pure),
});

registerControl('markcss');

await registerSynthSounds();

let pat = mondo(code);
await Promise.all(pat.firstCycleValues.map(v => v.fetch?.()));
pat = pat.filterValues(v => !v.fetch);

const repl = core.repl({
  getTime: () => !out ? audioCtx.currentTime :
    repl.scheduler.clock.getPhase() - repl.scheduler.clock.minLatency,
  defaultOutput: webaudioOutput,
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
    await scheduler.wait(1000);
  }

  repl.stop();
  console.log(`\nRecording ${duration} seconds...`);
  repl.scheduler.clock.setDuration(() => duration / 10);

  setAudioContext(new OfflineAudioContext(2, 48000 * duration, 48000));
}

else if (process.stderr.isTTY) {
  const highlightCode = (str, loc) =>
    str.slice(0, loc.start) +
    styleText('green', str.slice(loc.start, loc.end)) +
    str.slice(loc.end);

  function printHighlightedCode(hap) {
    const highlighted = hap.context.locations
      .sort((a, b) => b.start - a.start)
      .reduce(highlightCode, code);

    console.clear();
    console.warn(highlighted);
  }

  pat = pat.onTriggerTime(printHighlightedCode, false);
}

const audioCtx = getAudioContext();
await audioCtx.audioWorklet.addModule('superdough/worklets.mjs');
await repl.setPattern(pat);

if (out) {
  await scheduler.wait(1000);
  repl.stop();

  console.log(`\nRendering to ${out}...`);
  const buf = await audioCtx.startRendering();
  const wav = Buffer.from(wavEncode(buf));
  fs.writeFileSync(out, wav);
}

else {
  await audioCtx.suspend();
  await scheduler.wait(1000);
  await audioCtx.resume();
}
