# ENHANCEMENT_REPORT — Rabbaniyyah App (naik taraf interaktif)

Tarikh: 25 September 2026 · Stack: Flutter web (dikekalkan; tiada migrasi) · Status: **belum di-commit / push / deploy**

Aliran pembelajaran dalam setiap dars kini:

```
Hero + objektif → Video (jika ada) → bahagian asal dars → تدريبات إضافية (Aktiviti Pengukuhan)
→ الخاتمة (asal) → kad penutup → Ringkasan kemajuan → Dars sebelum / seterusnya
```

## 1. Penambahbaikan UI

- **Papan unit (الفصل الدراسي الأول)** direka semula. Setiap unit ada ikon (keluarga Material yang
  seragam; emoji tidak lagi digunakan), bar kemajuan unit, dan kiraan "x / 3 pelajaran selesai".
  Setiap dars ada cip status (**Belum mula / Sedang belajar / Selesai**), ikon video (hanya jika
  video wujud), ikon tanda ulang kaji, dan bintang yang diperoleh.
- Pada skrin lebar (≥ 980 px), unit disusun dalam grid dua lajur.
- **Kepala buku** memaparkan cincin kemajuan keseluruhan, pelajaran selesai, latihan selesai dan XP.
- **Papan pemuka**: kad "الدرس الجاري" kini menunjuk dars terakhir yang dibuka (sebelum ini
  sentiasa Dars 1), dan statistik diambil daripada data sebenar.
- Kad latihan menggunakan satu gaya seragam: nombor, jenis, bintang, tajuk Arab dan arahan BM.

## 2. Penambahbaikan UX

- **Rangka dars bersama (`LessonShell`)**. Kesemua 12 dars kini berkongsi pengalaman yang sama:
  rel langkah yang melekat di atas (kini mengikut bahagian aktif), mod projektor, togol baris,
  penanda ulang kaji, cincin kemajuan, butang kembali ke atas, serta navigasi dars
  sebelum/seterusnya.
- **Tandakan pelajaran selesai** dan **Tandakan untuk ulang kaji** disediakan dalam panel Ringkasan kemajuan.
- Penapis **Ulang kaji (n)** pada papan unit memaparkan hanya dars yang ditanda, dengan empty state yang kemas.
- **Carian** tanpa pelayan (client-side) merangkumi tajuk, unit, kosa kata (Arab dan makna BM) dan
  baris teks bacaan. Carian tidak sensitif kepada baris/tashkeel dan bentuk alif/ya/ta marbutah.
  Boleh dibuka dari papan pemuka dan papan unit.
- **Set semula**: setiap dars mempunyai set semula sendiri (dalam menu). Set semula semua kemajuan
  diletakkan sebagai pautan kecil di kaki papan pemuka, dengan dialog pengesahan.
- **Video**: dars tanpa video tidak memaparkan apa-apa blok. Jika fail video gagal dimuatkan, notis
  kecil dipaparkan menggantikan spinner yang tidak berhenti.

## 3. Penambahbaikan responsif

Semakan dibuat dengan fon sebenar (Amiri/Tajawal) pada 390 px dan 1280–1366 px, termasuk tangkapan skrin dalam Chrome.

- Kad bacaan asal: baris perawi hadis melimpah hingga 101 px di telefon (Dars 5). Kini semua
  baris perawi (8 dars) boleh balut ke baris baharu.
- Kepala ayat Dars 1 (butang terjemahan) melimpah 6 px. Kini `Flexible`.
- Cip hero dars (unit dan objektif) bertindih di telefon. Kini `Wrap`.
- Bar aplikasi dars di telefon: tindakan sekunder dipindahkan ke menu ⋮ supaya tajuk ada ruang.
- Bar atas papan pemuka di telefon: tajuk kini `Flexible`, dan butang skrin penuh disembunyikan di bawah 480 px.
- Latihan: pilihan jawapan menggunakan `Wrap`. Kotak kategori tersusun menegak di telefon dan
  sebaris di desktop. Semua sasaran sentuh ≥ 44–48 px.

## 4. Ciri interaktif

- **65 aktiviti pengukuhan** untuk 12 dars (1 Semakan Pantas + 2–5 aktiviti setiap dars).
  52 dibina verbatim daripada teks dars; 13 **dikarang baharu** (✎): Betul/Salah kefahaman bagi
  dars 2–7 dan 9–12, serta aplikasi kaedah dengan ayat baharu (khabar – Dars 1, لا/ليس – Dars 8,
  iḍāfah – Dars 9). Pemetaan penuh dalam `EXERCISE_MAPPING.md`.
- Maklum balas segera: **✓ Betul** atau **Cuba lagi** (warna + ikon, bukan warna sahaja). Setiap
  aktiviti boleh dicuba semula, diulang, atau hanya item yang salah dialihkan.
- Kategori: ketik item, kemudian ketik kategori. Tekan lama dan seret turut disokong. Tidak bergantung pada seret sahaja.
- Susun urutan: ketik mengikut urutan; ketik semula untuk mengalih.
- Kad imbas: kad terbalik (animasi 3D ringan), dengan navigasi dan kiraan kad yang sudah diulang kaji.

### Audio TTS dipulihkan (26 Sep 2026)

Sebelum ini 15 baris bacaan (Dars 2, 3, 7, 8, 10, 12) dan 1 kosa kata (Dars 12) **tiada audio
langsung**, termasuk semua baris bacaan Dars 8. Puncanya: teks itu menyebut lafẓ al-jalālah di
tengah ayat, dan suara TTS tidak menyebut lām «الله» dengan tafkhīm, jadi butangnya disembunyikan.

Kini ke-16 teks itu ada audio yang dicantum (`tool/audio/build_jalalah_lines.py`):
- perkataan lain dibaca oleh suara Hamed yang sama (kadar -10%, sama dengan klip lain);
- lafẓ al-jalālah diambil daripada rakaman qāriʾ word-by-word mengikut iʿrāb
  (ٱللَّهُ / ٱللَّهِ / ٱللَّهَ / لِلَّهِ);
- lām ketiga-tiga klip utama diukur **gelap (tafkhīm)**, F2 ≈ 770–800 Hz. «لِلَّهِ» nipis,
  dan itu betul selepas kasrah.

Butang audio kini dipaparkan melalui `TtsService.canSpeak`. `test/tts_coverage_test.dart`
memastikan setiap baris bacaan dan kosa kata dalam 12 dars ada audio, dan disahkan dalam Chrome
(klip `tts_dars18/*.mp3` dimuatkan apabila diklik).

## 5. Gamifikasi (ringan)

- Bintang 1–3 setiap aktiviti (berdasarkan jawapan betul pada cubaan pertama; skor terbaik disimpan).
- XP: 10 setiap bintang + 50 setiap dars yang ditanda selesai.
- Kemajuan dars = ½ penilaian kendiri asal (الخاتمة) + ½ Aktiviti Pengukuhan. Dars yang ditanda selesai = 100%.
- Tamat satu unit: dialog tahniah + konfeti ringan (sekali sahaja bagi setiap unit, tanpa pakej luar).
- Dialog tahniah dars kini memaparkan nombor dars yang betul.

## 6. Komponen boleh guna semula baharu

| Fail | Komponen |
|---|---|
| `lib/data/lesson_catalog.dart` | `LessonMeta`, `kLessons` — satu tempat untuk unit, id storan, **video** |
| `lib/data/exercise_models.dart` | `McqExercise` (termasuk Semakan Pantas), `TrueFalseExercise`, `CategorizeExercise`, `SequenceExercise`, `FlashcardExercise`, `PairMatchExercise` |
| `lib/data/supplemental_exercises.dart` | Data latihan setiap dars (lapisan berasingan daripada teks asal) |
| `lib/widgets/exercises/` | `ExerciseFrame`, `ExerciseFeedback`, `StarRow`, pandangan untuk setiap jenis latihan, `SupplementalSection` |
| `lib/widgets/lesson/` | `LessonShell`, `LessonSection`, `LessonCompletionPanel`, `LessonPager`, `LessonVideo`, `LessonStatusChip`, `ProgressRing` |
| `lib/utils/lesson_router.dart` | `screenForLesson`, `openLesson` |
| `lib/screens/search_screen.dart` | Carian |
| `lib/widgets/confetti.dart` | Konfeti CustomPainter |

**Menambah video kemudian:** letakkan fail dalam `assets/video/` dan set
`video: 'assets/video/topik10.mp4'` pada dars itu dalam `lib/data/lesson_catalog.dart`.
Tiada kod UI perlu diubah.

**Menambah latihan:** tambah entri dalam senarai dars tersebut dalam
`lib/data/supplemental_exercises.dart`, kemudian jalankan `flutter test` dan
`dart run tool/content_check/export_exercise_mapping.dart`.

## 7. Prestasi

- Tiada pakej baharu ditambah (`pubspec.yaml` tidak diubah).
- Kod skrin dars dikurangkan daripada ~489 baris × 11 kepada ~195 baris setiap satu, kerana logik berulang kini dalam `LessonShell`.
- Video masih dimuat hanya apabila butang main ditekan.
- Animasi latar ("breathing") dihentikan apabila reduced motion diminta.
- Build web berjaya (`flutter build web --release --base-href /rabbaniyyah_app/`), tanpa ralat konsol dalam ujian Chrome.

## 8. Kebolehcapaian

- `prefers-reduced-motion` dihormati: animasi masuk, animasi latar, flip kad, konfeti, skala dialog dan skrol.
- `Semantics`: butang pilihan jawapan (label + betul/salah), kotak kategori, cip, kad imbas,
  cincin kemajuan, status dars, tajuk dars (`header`), serta maklum balas sebagai `liveRegion`.
- Tooltip pada semua butang ikon baharu. Sasaran sentuh ≥ 44 px.
- Tiada kawalan seret sahaja; semua aktiviti boleh dibuat dengan ketik atau papan kekunci.
- Jika localStorage disekat, app tidak ranap. Kemajuan disimpan dalam memori untuk sesi itu dan notis kecil dipaparkan.

## 9. QA yang dijalankan

| Semakan | Keputusan |
|---|---|
| `flutter analyze` | 19 isu, **semuanya sedia ada sebelum kerja ini** (amaran `hint` tidak digunakan, `dart:html`, dan direktori `assets/data/` yang disenaraikan dalam pubspec tetapi tiada). 0 isu baharu |
| `flutter test` | **28/28 lulus** (termasuk liputan audio TTS): integriti latihan, logik kemajuan/localStorage/set semula/data rosak, smoke test 12 dars (desktop 1280 px + telefon 390 px, fon sebenar, tiada limpahan), video hanya pada dars 1–9, carian, dan interaksi Semakan Pantas |
| `content_check.py verify` | PASS (lihat CONTENT_PRESERVATION_REPORT.md) |
| `flutter build web --release --base-href /rabbaniyyah_app/` | Berjaya |
| Chrome headless (1366 px dan 390 px, mod gelap dan terang) | Papan pemuka, papan unit, dars, latihan (salah → Cuba lagi → betul → bintang/kemajuan dikemas kini), ringkasan dan pager semuanya dipaparkan betul. Tiada ralat konsol |

Ujian `widget_test.dart` (skrin pembuka) sebenarnya gagal **sebelum** kerja ini kerana ia mencari
tajuk yang tiada pada skrin. Ujian itu telah dibetulkan untuk memadankan tajuk sebenar.

## 10. Belum disahkan / cadangan seterusnya

- Build Android/iOS tidak diuji (hanya web).
- Belum diuji pada peranti sentuh sebenar (iPad/telefon). Ujian dibuat dengan emulasi Chrome.
- Aliran GitHub Pages (`.github/workflows/flutter_web.yml`) tidak diubah. Hash routing Flutter
  mengelakkan 404 semasa refresh, jadi deployment sepatutnya berfungsi seperti biasa selepas push.
