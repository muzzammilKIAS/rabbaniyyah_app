# Direction — video teks Dars 10, 11, 12 (السيرة)

Satu arahan untuk tiga video. Setiap projek (`dars10/`, `dars11/`, `dars12/`) dijana oleh `build_scenes.py`.

## Facts
- Teks bacaan, hadis/ayat, rujukan: `Dars1110`, `Dars1111`, `Dars1112` dalam `lib/data/curriculum.dart` (verbatim).
- Naratif setiap baris: `assets/audio/tts_dars110|111|112/reading_N.mp3` (Hamed; baris yang ada lafẓ al-jalālah dicantum dengan klip qāriʾ).
- Tajuk dars: `kSemester1Units` dalam `curriculum.dart`.
- Video topik1–9: 1280x720, ~24 fps, visual sinematik + naratif baris bacaan + kad ayat/hadis di hujung (dilihat dari bingkai `assets/video/topik2.mp4`, `topik9.mp4`).
- Ayat Dars 11 (Al-Isrāʾ 17:1): bacaan Alafasy, sumber sama dengan app (`everyayah.com/data/Alafasy_128kbps/017001.mp3`, `lib/services/quran_audio_service.dart`).

## Brief
- **Asked for:** "buatkan video berbaki pada unit 10-12 berdasarkan teks yang ada … bukan video pengenalan, video teks seperti unit2 sebelumnya … ia ikut teks setiap unit"
- **Promise:** pelajar mendengar dan membaca teks dars, baris demi baris, dengan gambaran yang membantu faham.
- **Format:** 1280x720 @ 30fps, ~55–70 s setiap satu, teks Arab bervokal (Amiri).
- **Assets:** klip naratif sedia ada, fon Amiri app, bacaan Alafasy 17:1.
- **Subject:** teks dars sendiri. Tiada jenama lain.
- **Invented:** ilustrasi pemandangan (SVG) — **tiada gambaran Nabi ﷺ, sahabat, malaikat atau Buraq**; hanya tempat, langit, cahaya, haiwan ternakan, objek dan nama dalam medalion kaligrafi.

## Concept
- **Options:** (1) Kad teks statik atas gambar kabur; (2) peta perjalanan tunggal yang ditelusuri sepanjang video; (3) setiap baris ialah satu "babak" ilustrasi yang beraksi sendiri (matahari terbit, kambing meragut, laluan malam dilukis, halaman dihimpun) dengan teks di kad kapsyen tetap.
- **Chosen:** (3) — paling hampir dengan topik1–9 (visual per baris + naratif), dan setiap baris dapat satu "verb moment" yang membantu faham tanpa menggambarkan tokoh.
- **Copy system:** caption track — satu baris bacaan setiap babak, kad krim-emas di bawah, sama seperti kad hadis topik9.

## Look
- **Frame and palette:** gelap-hangat (sinematik): malam zamrud `#06241b`, fajar `#f3d7a1`, pasir `#c8955a`, gunung `#4a3326`, emas `#d4a53a`, kad krim `#f8f1e1` dengan teks `#0b3b2e` (kontras > 10:1). Diambil daripada palet app (Emerald Rabbani & Royal Gold).
- **Type:** Amiri (fon silibus app) untuk semua teks Arab; Tajawal untuk label kecil.
- **World:** Makkah → gunung Ḥirāʾ → malam Isrāʾ → Bayt al-Maqdis → Madinah → medalion Khulafāʾ; satu gaya lapisan SVG (paralaks), cahaya hangat, butiran geometri Islamik halus.

## Sound
- **Mode:** voiceover sahaja (`sfx: false`). Tiada muzik, tiada kesan bunyi — sesuai untuk teks sīrah, dan klip naratif sudah dinormalkan.
- **Arc:** tenang; kad penutup dengan ayat/hadis.

## Beats
Setiap babak = 0.3 s + klip naratif + 0.5 s. Babak 0 = tajuk dars (naratif tajuk). Babak terakhir = kad ayat/hadis.
