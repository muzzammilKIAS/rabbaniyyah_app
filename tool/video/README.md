# Video teks Dars 10–12

Video `assets/video/topik10.mp4`–`topik12.mp4` dijana di sini. Setiap video: kad tajuk → satu babak
bagi setiap baris bacaan (teks verbatim daripada `lib/data/curriculum.dart`, naratif = klip audio app)
→ kad hadis/ayat. Ilustrasi hanya tempat, cahaya dan objek: **tiada gambaran Nabi ﷺ, sahabat,
malaikat atau Buraq**. Arahan penuh: `DIRECTION.md`.

## Jana semula

Perlukan skill `motion-video` (Node 20+, ffmpeg, Chrome).

```bash
MV=<folder skill motion-video>
for n in 10 11 12; do node $MV/scripts/video.mjs init dars$n; rm dars$n/scenes/01-hook.html; done
python3 build_scenes.py                       # tulis scenes/ dan video.json
for n in 10 11 12; do (cd dars$n && node $MV/scripts/video.mjs render); done
cp dars10/out/topik10.mp4 ../../assets/video/  # (dan 11, 12)
```

`extra_audio/`: naratif tajuk & matan hadis (ar-SA-HamedNeural, -10%) dan bacaan Alafasy
Al-Isrāʾ 17:1 (everyayah.com, sumber sama dengan app).
