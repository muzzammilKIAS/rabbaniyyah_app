"""Builds one lesson audio line whose لفظ الجلالة comes from a reciter and
whose remaining words come from the teaching TTS voice.

Neural TTS cannot velarize the laam (measured F2 ~1600 Hz against a
reciter's ~800 Hz), so the divine name is never synthesized: it is spliced
in from the recitation clip, level-matched and joined at a word boundary.
"""
import sys
import wave

import numpy as np
import lameenc

SR = 24000


def read_wav(path):
    with wave.open(path, "rb") as w:
        assert w.getframerate() == SR, (path, w.getframerate())
        x = np.frombuffer(w.readframes(w.getnframes()), dtype=np.int16).astype(np.float64)
        if w.getnchannels() == 2:
            x = x.reshape(-1, 2).mean(axis=1)
    return x / 32768.0


def trim_silence(x, thresh_ratio=0.02, pad_ms=30):
    win = int(0.010 * SR)
    frames = [np.sqrt(np.mean(x[i:i + win] ** 2)) for i in range(0, max(len(x) - win, 1), win)]
    frames = np.array(frames)
    if frames.size == 0:
        return x
    thresh = max(frames.max() * thresh_ratio, 1e-5)
    voiced = np.where(frames > thresh)[0]
    if voiced.size == 0:
        return x
    pad = int(pad_ms / 1000 * SR)
    a = max(voiced[0] * win - pad, 0)
    b = min((voiced[-1] + 1) * win + pad, len(x))
    return x[a:b]


def rms(x):
    return float(np.sqrt(np.mean(x ** 2))) if len(x) else 0.0


def fade(x, ms=12):
    n = min(int(ms / 1000 * SR), len(x) // 2)
    if n <= 0:
        return x
    x = x.copy()
    ramp = np.linspace(0, 1, n)
    x[:n] *= ramp
    x[-n:] *= ramp[::-1]
    return x


def main(name_wav, rest_wav, out_mp3, gap_ms=110):
    name = fade(trim_silence(read_wav(name_wav)))
    rest = fade(trim_silence(read_wav(rest_wav)))

    # match the reciter's loudness to the teaching voice so the join is not
    # heard as a jump in volume
    target = rms(rest)
    if rms(name) > 0:
        name = name * (target / rms(name))

    gap = np.zeros(int(gap_ms / 1000 * SR))
    out = np.concatenate([name, gap, rest])

    peak = np.max(np.abs(out))
    if peak > 0.99:
        out = out * (0.99 / peak)

    pcm = (out * 32767).astype(np.int16)
    enc = lameenc.Encoder()
    enc.set_bit_rate(64)
    enc.set_in_sample_rate(SR)
    enc.set_channels(1)
    enc.set_quality(2)
    mp3 = enc.encode(pcm.tobytes()) + enc.flush()
    with open(out_mp3, "wb") as f:
        f.write(bytes(mp3))
    print(f"wrote {out_mp3}  {len(out) / SR:.2f}s  ({len(mp3)} bytes)")


if __name__ == "__main__":
    main(*sys.argv[1:4])
