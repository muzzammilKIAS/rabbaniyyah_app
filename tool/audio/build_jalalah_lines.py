"""Builds audio for every lesson text that names لفظ الجلالة mid-sentence.

These lines used to have no speak button at all (see README.md: neural TTS
cannot give the divine name its تفخيم). Here each line is split at the
divine name; the teaching voice (ar-SA-HamedNeural, -10%, same as every
other lesson clip) reads the words around it, and the name itself is a
real reciter's word-by-word clip in the right case ending:

  ٱللَّهُ  nominative   wbw/002_255_001  (already bundled: quran/lafz_jalalah.mp3)
  ٱللَّهِ  genitive     wbw/001_001_002  (بِسْمِ ٱللَّهِ)
  ٱللَّهَ  accusative   wbw/002_153_008  (إِنَّ ٱللَّهَ مَعَ ٱلصَّٰبِرِينَ)
  لِلَّهِ  li-llāhi     wbw/001_002_002  (ٱلْحَمْدُ لِلَّهِ) — tarqīq after kasra, as it should be

Each reciter word is pronounced as a fresh start (ibtidāʾ, hamzat al-waṣl
with fatḥa), so its lām is مفخّم — measured with check_laam.py.

Usage (from this folder, with a venv holding edge-tts numpy lameenc):
    python build_jalalah_lines.py <clips_dir> <assets/audio dir>
<clips_dir> must contain the four wbw mp3 files named as above.
"""
import asyncio
import os
import re
import subprocess
import sys
import tempfile

import edge_tts
import lameenc
import numpy as np

from build_line import SR, fade, read_wav, rms, trim_silence

VOICE = "ar-SA-HamedNeural"
RATE = "-10%"  # matches the existing tts_dars* clips (checked by duration)

# optional fatḥa/shadda on the second lām, then the case vowel on the hā'
NAME = re.compile("لِلَّهِ|الل[\u064E\u0651]*ه[\u064F\u0650\u064E]")

CLIP_FOR = {"ِ": "001_001_002", "ُ": "002_255_001", "َ": "002_153_008"}

# (asset path under assets/audio, exact text from lib/data/curriculum.dart)
LINES = [
    ("tts_dars12/reading_5.mp3", "اَلْقُرْآنُ كِتَابُ اللهِ، وَمُحَمَّدٌ رَسُولُ اللهِ."),
    ("tts_dars13/reading_2.mp3", "فِي ذَلِكَ الْيَوْمِ، يُحَاسِبُ اللهُ كُلَّ إِنْسَانٍ عَلَى عَمَلِهِ."),
    ("tts_dars13/reading_5.mp3", "اَلْقَدَرُ تَقْدِيرُ اللهِ لِكُلِّ شَيْءٍ."),
    ("tts_dars13/reading_6.mp3", "اَلْمُؤْمِنُ يَرْضَى بِقَضَاءِ اللهِ، وَيَعْمَلُ وَيَجْتَهِدُ."),
    ("tts_dars17/reading_6.mp3", "نَتَعَلَّمُ مِنَ الرَّسُولِ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ هَذِهِ الصِّفَاتِ الْحَسَنَةَ."),
    ("tts_dars18/reading_0.mp3", "أَنَا أُحِبُّ اللهَ، وَأُطِيعُهُ فِي كُلِّ أَمْرٍ."),
    ("tts_dars18/reading_1.mp3", "أَنَا أَتَّقِي اللهَ فِي السِّرِّ وَالْعَلَنِ."),
    ("tts_dars18/reading_2.mp3", "أَتَوَكَّلُ عَلَى اللهِ، وَأَشْكُرُهُ عَلَى نِعَمِهِ."),
    ("tts_dars18/reading_3.mp3", "أَنَا أُحِبُّ النَّبِيَّ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ، وَأَتَّبِعُ سُنَّتَهُ."),
    ("tts_dars18/reading_4.mp3", "لَا أَعْصِي اللهَ، وَلَا أَكْذِبُ عَلَى النَّبِيِّ."),
    ("tts_dars18/reading_5.mp3", "هَذَا هُوَ حُبِّي لِلَّهِ وَرَسُولِهِ."),
    ("tts_dars110/reading_0.mp3", "وُلِدَ النَّبِيُّ مُحَمَّدٌ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ فِي مَكَّةَ، عَامَ الْفِيلِ."),
    ("tts_dars110/reading_3.mp3", "تَزَوَّجَ خَدِيجَةَ رَضِيَ اللهُ عَنْهَا وَهُوَ فِي الْخَامِسَةِ وَالْعِشْرِينَ."),
    ("tts_dars112/reading_0.mp3", "اَلصَّحَابَةُ هُمُ الَّذِينَ رَافَقُوا النَّبِيَّ صَلَّى اللهُ عَلَيْهِ وَسَلَّمَ وَآمَنُوا بِهِ."),
    ("tts_dars112/reading_5.mp3", "عَلِيٌّ، كَرَّمَ اللهُ وَجْهَهُ، اشْتَهَرَ بِالْحِكْمَةِ وَالشَّجَاعَةِ."),
    ("tts_dars112/reading_6.mp3", "اِسْتُشْهِدَ بَعْضُهُمْ فِي سَبِيلِ اللهِ."),
    ("tts_dars112/vocab_4.mp3", "عَلِيٌّ كَرَّمَ اللهُ وَجْهَهُ"),
]


def to_wav(src, dst):
    subprocess.run(["ffmpeg", "-loglevel", "error", "-y", "-i", src, "-ac", "1", "-ar", str(SR), dst], check=True)
    return read_wav(dst)


async def tts(text, path):
    await edge_tts.Communicate(text, VOICE, rate=RATE).save(path)


def clip_for(token):
    if token == "لِلَّهِ":
        return "001_002_002"
    return CLIP_FOR[token[-1]]


def build(text, clips_dir, tmp):
    parts = []  # list of (kind, payload, pause_before_s): ("tts", text) / ("name", clip id)
    letters = re.compile("[\u0621-\u064A]")
    pos = 0
    pending_comma = False

    def add_text(chunk):
        nonlocal pending_comma
        chunk = chunk.strip()
        lead_comma = chunk.startswith("،")
        chunk = chunk.lstrip("،").strip()
        if letters.search(chunk):
            parts.append(("tts", chunk, 0.22 if (lead_comma or pending_comma) else 0.09))
            pending_comma = chunk.endswith("،")
        elif lead_comma or "،" in chunk:
            pending_comma = True

    for m in NAME.finditer(text):
        add_text(text[pos:m.start()])
        parts.append(("name", clip_for(m.group(0)), 0.22 if pending_comma else 0.09))
        pending_comma = False
        pos = m.end()
    add_text(text[pos:])

    audio = []
    for i, (kind, payload, pause) in enumerate(parts):
        if kind == "tts":
            mp3 = os.path.join(tmp, f"seg{i}.mp3")
            asyncio.run(tts(payload, mp3))
            a = to_wav(mp3, mp3 + ".wav")
        else:
            a = to_wav(os.path.join(clips_dir, payload + ".mp3"), os.path.join(tmp, payload + ".wav"))
        audio.append((kind, pause, fade(trim_silence(a))))

    tts_levels = [rms(a) for k, _, a in audio if k == "tts"]
    voice_rms = float(np.median(tts_levels)) if tts_levels else 0.1
    out = []
    for kind, pause, a in audio:
        if kind == "name" and rms(a) > 0:
            a = a * (voice_rms / rms(a))  # level-match the reciter to the voice
        if out:
            out.append(np.zeros(int(pause * SR)))
        out.append(a)
    y = np.concatenate(out)
    peak = np.max(np.abs(y))
    if peak > 0.99:
        y = y * (0.99 / peak)
    return y, parts


def write_mp3(y, path):
    pcm = (y * 32767).astype(np.int16)
    enc = lameenc.Encoder()
    enc.set_bit_rate(64)
    enc.set_in_sample_rate(SR)
    enc.set_channels(1)
    enc.set_quality(2)
    with open(path, "wb") as f:
        f.write(bytes(enc.encode(pcm.tobytes()) + enc.flush()))


def main(clips_dir, audio_dir):
    with tempfile.TemporaryDirectory() as tmp:
        for rel, text in LINES:
            y, parts = build(text, clips_dir, tmp)
            dst = os.path.join(audio_dir, rel)
            write_mp3(y, dst)
            plan = " + ".join(p if k == "name" else "«tts»" for k, p, _ in parts)
            print(f"{rel:28s} {len(y) / SR:5.2f}s  {plan}")


if __name__ == "__main__":
    main(sys.argv[1], sys.argv[2])
