# Lesson audio — لفظ الجلالة and taghlīẓ al-lām

Dev-only scripts (not shipped with the app). They exist because of one
finding: **neural TTS cannot pronounce the divine name correctly.**

## The finding

The lām of لفظ الجلالة takes تفخيم after fatḥa or ḍamma. Measured on the
second formant of the lām — dark/velarized lām sits low, clear lām high:

| Source | F2 of the lām | Verdict |
| --- | --- | --- |
| Reciter (Qur'an 2:255, word 1) | ~410–790 Hz | تفخيم ✅ |
| Edge `ar-SA-HamedNeural`, every spelling tried | ~1630–1650 Hz | ترقيق ❌ |
| All 12 Edge Arabic voices (`ar-EG/AE/KW/QA/IQ/JO/MA/DZ/TN/YE/SY`) | 1466–1709 Hz | ترقيق ❌ |

Spelling does not help: `اللَّهُ`, `الله`, `ٱللَّهُ`, dagger-alif and a carrier
phrase all land in the same range. So the divine name is **never
synthesized** in this app — it is always played from recitation.

## Rules for lesson audio

1. Any text containing لفظ الجلالة must resolve to a pre-rendered asset in
   `TtsService._preRenderedAssets` — never to the live system voice.
2. A word on its own → play `assets/audio/quran/lafz_jalalah.mp3` directly.
3. A sentence that contains it → build a spliced line with `build_line.py`:
   the reciter says the name, the teaching voice says the rest, joined at a
   word boundary and level-matched. `assets/audio/tts/reading_0.mp3` is
   built this way. **Do not regenerate it with TTS alone** — that silently
   restores the light lām.

## Voice and pace

Teaching voice is `ar-EG-ShakirNeural` at **`--rate=-15%`** — the default
(0%) reads too fast for learners sounding out new words; -15% is the pace
approved after listening to samples. Use both for every new asset, or a
line will sound rushed next to its neighbors.

## Usage

```bash
python3 -m venv venv && ./venv/bin/pip install edge-tts numpy scipy lameenc

# 1. synthesize only the words AFTER the divine name
./venv/bin/edge-tts --voice ar-EG-ShakirNeural --rate=-15% \
    --text "هُوَ الإِلَهُ الحَقُّ." --write-media rest.mp3

# 2. decode both to 24 kHz mono (macOS afconvert; ffmpeg works too)
afconvert -f WAVE -d LEI16@24000 -c 1 ../../assets/audio/quran/lafz_jalalah.mp3 name.wav
afconvert -f WAVE -d LEI16@24000 -c 1 rest.mp3 rest.wav

# 3. splice
./venv/bin/python build_line.py name.wav rest.wav reading_0.mp3

# 4. verify the lām really is dark before shipping (needs 16 kHz mono wav)
afconvert -f WAVE -d LEI16@16000 -c 1 reading_0.mp3 check.wav
./venv/bin/python check_laam.py "line 0=check.wav"
```

`check_laam.py` prints an F2 track; read the frames covering the first word
only. Beware: هُوَ contains [u]/[w], which are also low-F2 — measuring a
whole sentence at once gives a false "dark" reading.

## Source of the recitation

`assets/audio/quran/lafz_jalalah.mp3` — word-by-word archive
(`audio.qurancdn.com/wbw/002_255_001.mp3`), Qur'an 2:255 word 1: ayah-initial
ٱللَّهُ, nominative, so the lām is مفخّم and the ending matches the vocab
entry's ḍamma.

## Mid-sentence lines (all lessons) — `build_jalalah_lines.py`

Every other text naming the divine name (15 reading lines in Dars 2, 3, 7,
8, 10, 12 and the Dars 12 vocab «عَلِيٌّ كَرَّمَ اللهُ وَجْهَهُ») is built by
`build_jalalah_lines.py`: the line is split at each divine name, the other
words are read by `ar-SA-HamedNeural` at `-10%` (the pace of all other
`tts_dars*` clips, matched by duration), and the name is a word-by-word
reciter clip in the right case ending:

| Form | Clip (audio.qurancdn.com/wbw/…) | Measured lām |
| --- | --- | --- |
| ٱللَّهُ (marfūʿ) | 002_255_001 (bundled as quran/lafz_jalalah.mp3) | F2 ≈ 776 Hz — dark |
| ٱللَّهِ (majrūr) | 001_001_002 | F2 ≈ 772 Hz — dark |
| ٱللَّهَ (manṣūb) | 002_153_008 | F2 ≈ 799 Hz — dark |
| لِلَّهِ | 001_002_002 | F2 ≈ 1625 Hz — clear, correct after kasra |

The reciter word starts afresh (ibtidāʾ with hamzat al-waṣl), so its lām is
مفخّم. Speak buttons are shown by `TtsService.canSpeak`: a text with the
divine name gets a button only when such a clip exists.

```bash
python build_jalalah_lines.py <dir with the 4 wbw mp3s> ../../assets/audio
```

`test/tts_coverage_test.dart` fails if any reading line or vocab word in
the 12 lessons has no bundled audio.

## Still synthesized

Reading lines 1–5 contain no divine name, so they remain plain TTS. If a
future lesson adds sentences containing it, splice them the same way — or
better, record the lines with a human qāriʾ.
