"""Estimate the F2 track of a spoken word to tell a velarized (dark) laam
from a plain one.

Dark [ɫ] — the tafkhīm of lafẓ al-jalālah — pulls F2 down to roughly
700–1100 Hz; a plain [l] sits near 1400–1800 Hz. So the depth of the F2
valley between the two vowels of "Allāh" says which one the voice produced.
"""
import sys
import wave

import numpy as np
from scipy.signal import lfilter

SR = 16000
FRAME = int(0.025 * SR)
HOP = int(0.010 * SR)
LPC_ORDER = 14


def read_wav(path):
    with wave.open(path, "rb") as w:
        assert w.getframerate() == SR, (path, w.getframerate())
        n = w.getnframes()
        raw = w.readframes(n)
        x = np.frombuffer(raw, dtype=np.int16).astype(np.float64)
        if w.getnchannels() == 2:
            x = x.reshape(-1, 2).mean(axis=1)
    return x / 32768.0


def lpc(frame, order):
    # autocorrelation + Levinson-Durbin
    r = np.correlate(frame, frame, mode="full")[len(frame) - 1:][: order + 1]
    if r[0] == 0:
        return None
    a = np.zeros(order + 1)
    a[0] = 1.0
    e = r[0]
    for i in range(1, order + 1):
        acc = r[i] + np.dot(a[1:i], r[i - 1:0:-1]) if i > 1 else r[i]
        k = -acc / e
        a_new = a.copy()
        for j in range(1, i):
            a_new[j] = a[j] + k * a[i - j]
        a_new[i] = k
        a = a_new
        e *= (1 - k * k)
        if e <= 0:
            return None
    return a


def formants(frame):
    frame = frame * np.hamming(len(frame))
    frame = lfilter([1.0, -0.97], 1.0, frame)  # pre-emphasis
    a = lpc(frame, LPC_ORDER)
    if a is None:
        return []
    roots = np.roots(a)
    roots = roots[np.imag(roots) > 0.01]
    if roots.size == 0:
        return []
    freqs = np.arctan2(np.imag(roots), np.real(roots)) * (SR / (2 * np.pi))
    bws = -0.5 * (SR / (2 * np.pi)) * np.log(np.abs(roots))
    keep = (freqs > 200) & (freqs < 5000) & (bws < 500)
    return sorted(freqs[keep])


def track(path):
    x = read_wav(path)
    energy, f2s = [], []
    for i in range(0, len(x) - FRAME, HOP):
        fr = x[i:i + FRAME]
        e = float(np.sqrt(np.mean(fr ** 2)))
        energy.append(e)
        f = formants(fr)
        f2s.append(f[1] if len(f) >= 2 else np.nan)
    energy = np.array(energy)
    f2s = np.array(f2s)
    voiced = energy > max(energy.max() * 0.15, 1e-4)
    return energy, f2s, voiced


def summarize(name, path):
    energy, f2s, voiced = track(path)
    idx = np.where(voiced)[0]
    if idx.size == 0:
        print(f"{name:22s} (no voiced frames)")
        return
    lo, hi = idx[0], idx[-1]
    span = hi - lo
    # the laam sits between the two vowels: scan the middle 20–70% of the word
    a, b = lo + int(span * 0.20), lo + int(span * 0.70)
    mid = f2s[a:b]
    mid = mid[~np.isnan(mid)]
    if mid.size == 0:
        print(f"{name:22s} (no F2 estimates)")
        return
    valley = float(np.min(mid))
    p10 = float(np.percentile(mid, 10))
    whole = f2s[lo:hi][~np.isnan(f2s[lo:hi])]
    verdict = "DARK/tafkhim" if valley < 1150 else ("borderline" if valley < 1400 else "CLEAR/tarqiq")
    print(f"{name:22s} dur={span * HOP / SR:4.2f}s  F2valley={valley:6.0f}Hz  "
          f"F2p10={p10:6.0f}Hz  F2med(all)={np.median(whole):6.0f}Hz   -> {verdict}")


if __name__ == "__main__":
    for arg in sys.argv[1:]:
        name, path = arg.split("=", 1)
        summarize(name, path)
