const fs = require('fs');
const path = require('path');

const soundsDir = path.join(__dirname, 'sounds');
if (!fs.existsSync(soundsDir)) {
  fs.mkdirSync(soundsDir, { recursive: true });
}

function writeWav(filename, samples, sampleRate = 44100) {
  const numSamples = samples.length;
  const buffer = Buffer.alloc(44 + numSamples * 2);

  // RIFF chunk
  buffer.write('RIFF', 0);
  buffer.writeUInt32LE(36 + numSamples * 2, 4);
  buffer.write('WAVE', 8);

  // fmt subchunk
  buffer.write('fmt ', 12);
  buffer.writeUInt32LE(16, 16); // subchunk size
  buffer.writeUInt16LE(1, 20);  // PCM format
  buffer.writeUInt16LE(1, 22);  // mono
  buffer.writeUInt32LE(sampleRate, 24);
  buffer.writeUInt32LE(sampleRate * 2, 28); // byte rate (sampleRate * numChannels * bitsPerSample / 8)
  buffer.writeUInt16LE(2, 32);  // block align
  buffer.writeUInt16LE(16, 34); // bits per sample

  // data subchunk
  buffer.write('data', 36);
  buffer.writeUInt32LE(numSamples * 2, 40);

  for (let i = 0; i < numSamples; i++) {
    // Clamp sample between -1.0 and 1.0
    let s = Math.max(-1.0, Math.min(1.0, samples[i]));
    let val = Math.floor(s < 0 ? s * 32768 : s * 32767);
    buffer.writeInt16LE(val, 44 + i * 2);
  }

  const filePath = path.join(soundsDir, filename);
  fs.writeFileSync(filePath, buffer);
  console.log(`Generated: ${filename} (${(numSamples / sampleRate).toFixed(2)}s)`);
}

const SR = 44100;

// 1. JUMP SFX: Rising pitch sweep with snappy pulse envelope
function generateJump() {
  const duration = 0.18;
  const numSamples = Math.floor(SR * duration);
  const samples = new Float32Array(numSamples);
  let phase = 0;

  for (let i = 0; i < numSamples; i++) {
    const t = i / numSamples;
    const freq = 180 + Math.pow(t, 1.3) * 600; // 180Hz to 780Hz
    phase += (2 * Math.PI * freq) / SR;
    
    // Square/pulse wave with decaying amplitude
    let raw = Math.sin(phase) > 0 ? 0.7 : -0.7;
    // Add softer sine undertone
    raw = raw * 0.6 + Math.sin(phase) * 0.4;
    const env = (1.0 - t * 0.9) * Math.min(1.0, i / (SR * 0.01)); // Fast attack, gentle decay
    samples[i] = raw * env * 0.8;
  }
  return samples;
}

// 2. FAIL SFX: Descending pitch with gritty wobble
function generateFail() {
  const duration = 0.65;
  const numSamples = Math.floor(SR * duration);
  const samples = new Float32Array(numSamples);
  let phase = 0;

  for (let i = 0; i < numSamples; i++) {
    const t = i / numSamples;
    // Slide down from 360Hz to 65Hz
    const freq = Math.max(50, 360 * Math.pow(1.0 - t, 1.8));
    phase += (2 * Math.PI * freq) / SR;

    // Sawtooth-like wave with vibrato/noise
    let saw = 2.0 * (phase / (2 * Math.PI) - Math.floor(0.5 + phase / (2 * Math.PI)));
    const wobble = Math.sin(2 * Math.PI * 18 * (i / SR));
    let raw = saw * (0.8 + 0.2 * wobble);
    const env = (1.0 - Math.pow(t, 0.7)) * Math.min(1.0, i / (SR * 0.02));
    samples[i] = raw * env * 0.85;
  }
  return samples;
}

// 3. WIN SFX: Triumphant 4-note arpeggio (C5 -> E5 -> G5 -> C6)
function generateWin() {
  const notes = [
    { freq: 523.25, dur: 0.14 }, // C5
    { freq: 659.25, dur: 0.14 }, // E5
    { freq: 783.99, dur: 0.16 }, // G5
    { freq: 1046.50, dur: 0.45 } // C6
  ];
  const totalDur = notes.reduce((acc, n) => acc + n.dur, 0);
  const numSamples = Math.floor(SR * totalDur);
  const samples = new Float32Array(numSamples);

  let currentIdx = 0;
  for (const note of notes) {
    const noteSamples = Math.floor(SR * note.dur);
    let phase = 0;
    for (let i = 0; i < noteSamples && currentIdx + i < numSamples; i++) {
      const t = i / noteSamples;
      phase += (2 * Math.PI * note.freq) / SR;
      // Combination of square & sine for classic 80s arcade brass
      let wave = (Math.sin(phase) > 0 ? 0.4 : -0.4) + 0.6 * Math.sin(phase) + 0.2 * Math.sin(2 * phase);
      const env = Math.min(1.0, i / (SR * 0.015)) * Math.pow(1.0 - t * 0.7, 1.2);
      samples[currentIdx + i] = wave * env * 0.7;
    }
    currentIdx += noteSamples;
  }
  return samples;
}

// 4. COLLECT SFX: Sparkling two-tone chime
function generateCollect() {
  const duration = 0.24;
  const numSamples = Math.floor(SR * duration);
  const samples = new Float32Array(numSamples);

  let phase1 = 0;
  let phase2 = 0;
  const split = Math.floor(numSamples * 0.4);

  for (let i = 0; i < numSamples; i++) {
    const isSecondNote = i >= split;
    const freq = isSecondNote ? 1318.51 : 987.77; // B5 -> E6
    const noteT = isSecondNote ? (i - split) / (numSamples - split) : i / split;
    
    if (!isSecondNote) {
      phase1 += (2 * Math.PI * freq) / SR;
      const wave = Math.sin(phase1) + 0.3 * Math.sin(2 * phase1);
      const env = Math.min(1.0, (i / (SR * 0.01))) * (1.0 - noteT * 0.5);
      samples[i] = wave * env * 0.5;
    } else {
      phase2 += (2 * Math.PI * freq) / SR;
      const wave = Math.sin(phase2) + 0.25 * Math.sin(2 * phase2);
      const env = Math.min(1.0, ((i - split) / (SR * 0.01))) * (1.0 - noteT);
      samples[i] = wave * env * 0.6;
    }
  }
  return samples;
}

// 5. CLICK SFX: Quick, crisp UI tap
function generateClick() {
  const duration = 0.045;
  const numSamples = Math.floor(SR * duration);
  const samples = new Float32Array(numSamples);
  let phase = 0;

  for (let i = 0; i < numSamples; i++) {
    const t = i / numSamples;
    const freq = 1200 - t * 700; // 1200Hz to 500Hz
    phase += (2 * Math.PI * freq) / SR;
    const wave = Math.sin(phase);
    const env = Math.pow(1.0 - t, 2.5);
    samples[i] = wave * env * 0.6;
  }
  return samples;
}

writeWav('jump.wav', generateJump());
writeWav('fail.wav', generateFail());
writeWav('win.wav', generateWin());
writeWav('collect.wav', generateCollect());
writeWav('click.wav', generateClick());
