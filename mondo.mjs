import fs from 'node:fs';

import * as core from '@strudel/core';
import { getAudioContext } from 'superdough';
import { webaudioRepl } from '@strudel/webaudio';
import { mondo } from '@strudel/mondo';

import encodeWav from 'audiobuffer-to-wav';

const file = process.argv[2];
const code = fs.readFileSync(file, 'utf8');
const duration = +process.argv[3];

await core.evalScope(core,
  core.registerControl('markcss'),
  await import('node-web-audio-api'),
);

if (duration) {
  AudioContext = class extends OfflineAudioContext {
    constructor(sampleRate = 44100) {
      super(2, sampleRate * duration, sampleRate);
    }
  };
}

const ctx = getAudioContext();
const repl = webaudioRepl();

if (duration) {
  repl.setPattern(mondo(code), false);
  const buf = encodeWav(await ctx.startRendering());
  fs.writeFileSync(`${file}.wav`, Buffer.from(buf));
}

else {
  await ctx.audioWorklet.addModule('supradough/dough-worklet.mjs');
  repl.setPattern(mondo(code).supradough());
}
