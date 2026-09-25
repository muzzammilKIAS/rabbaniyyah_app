# CONTENT_PRESERVATION_REPORT — Rabbaniyyah App

Tarikh: 25 September 2026 · Cawangan: `main` (belum di-commit, belum di-push, belum di-deploy)

## 1. Ringkasan

Kandungan silibus asal **tidak diubah**. `lib/data/curriculum.dart` (sumber semua teks
bacaan, kosa kata, kaedah, dalil, soalan dan terjemahan) kekal **sama bait demi bait**.
Semua 202 fail aset (gambar, video, audio, fon) juga tidak berubah.

| Semakan | Keputusan |
|---|---|
| SHA-256 `lib/data/curriculum.dart` | **Tidak berubah** |
| Rentetan teks yang direkod sebelum kerja (Arab + semua rentetan curriculum.dart) | 1514 diperiksa, **0 hilang** |
| Rentetan UI yang dibuang dengan sengaja | 2 (lihat §4); kedua-duanya bukan teks silibus |
| Aset (`assets/**`) | 202 diperiksa, 0 hilang, 0 berubah |
| Unit | 4 / 4 masih ada |
| Dars | 12 / 12 masih ada, setiap satu dengan semua bahagian asalnya |
| Video asal (topik1–topik9) | Kekal, dipaparkan pada dars 1–9 seperti sebelum ini |
| Dars tanpa video (10–12) | Tiada pemain video, tiada placeholder |

## 2. Kaedah semakan

1. **Sebelum** sebarang perubahan kod, snapshot diambil dengan
   `python3 tool/content_check/content_check.py snapshot`. Snapshot merekod:
   - setiap literal rentetan Dart dalam `lib/` yang mengandungi huruf Arab;
   - setiap literal dalam `lib/data/curriculum.dart` (termasuk makna Bahasa Melayu);
   - SHA-256 `curriculum.dart` dan SHA-256 setiap fail di bawah `assets/`.

   Hasilnya disimpan dalam `tool/content_check/baseline_content_snapshot.json`.
2. **Selepas** kerja, `python3 tool/content_check/content_check.py verify` memastikan setiap
   rentetan yang direkod masih wujud di mana-mana dalam `lib/`, `curriculum.dart` tidak
   berubah, dan tiada aset hilang atau berubah.
3. Semakan boleh diulang pada bila-bila masa. Keputusan terkini:

```
strings checked : 1514
strings missing : 0
approved removals: 2 (see approved_removals.json)
curriculum.dart : UNCHANGED
assets checked  : 202 (lost 0, changed 0)
RESULT: PASS
```

4. Sebagai tambahan, `test/supplemental_exercises_test.dart` menyemak bahawa teks Arab dalam
   latihan yang dibina daripada teks dars wujud verbatim dalam `curriculum.dart`. Latihan yang
   **dikarang baharu** atas persetujuan pengguna (26 Sep 2026) ditanda `authored: true` dan ✎ dalam
   `EXERCISE_MAPPING.md`. Latihan jenis ini hanya ada dalam fail latihan, bukan dalam teks silibus.

## 3. Perubahan teknikal yang tidak mengubah kandungan

| Perubahan | Kesan pada kandungan |
|---|---|
| 12 skrin dars kini menggunakan rangka bersama `LessonShell`. Setiap skrin hanya membekalkan hero, tajuk dan kad bahagiannya sendiri | Tiada. Kelas hero, susunan bahagian, label bahagian, kad asal, teks penutup dan mesej tahniah dipindahkan verbatim melalui skrip. Semakan rentetan mengesahkan tiada yang hilang |
| Laluan video dars kini dibaca daripada `lib/data/lesson_catalog.dart`, bukan ditulis dalam setiap skrin | Tiada. Dars 1–9 guna fail yang sama (`topik1.mp4`…`topik9.mp4`) |
| Baris perawi hadis dalam kad bacaan dibungkus dengan `Expanded` supaya teks panjang boleh balut ke baris baharu di telefon | Teks sama. Sebelum ini teks itu terpotong/melimpah pada skrin sempit |
| Baris cip dalam hero dars ditukar daripada `Row + Spacer` kepada `Wrap` | Teks sama; cip tidak lagi bertindih di telefon |
| `dart format` dijalankan pada fail yang disentuh | Hanya susun atur kod (inden/baris); tiada literal berubah |
| Label lencana dalam dialog tahniah: sebelum ini **semua** dars memaparkan «أتممت كل أهداف الدرس ١» | Teks asal dikekalkan untuk dars 1; dars 2–12 kini memaparkan nombor dars yang betul |
| Butang set semula dalam dars kini juga memadam markah latihan tambahan dan tanda selesai dars itu | Tiada kesan pada teks |

### Audio tambahan (26 Sep 2026)

17 fail MP3 **baharu** ditambah dalam folder `assets/audio/tts_dars*` sedia ada, untuk teks yang
sebelum ini tiada audio kerana menyebut lafẓ al-jalālah. Tiada fail audio sedia ada yang diubah
atau dipadam (semakan aset: 202 asal, 0 berubah). Pemalar `readingNoAudio`/`vocabNoAudio` dalam
`curriculum.dart` tidak disentuh. Kad dars kini bergantung pada `TtsService.canSpeak`, jadi
komen tentang "tiada audio" dalam `curriculum.dart` sudah lapuk, tetapi dibiarkan kerana fail
itu baca sahaja.

## 4. Rentetan UI yang dibuang dengan sengaja

Rentetan ini direkod dalam `tool/content_check/approved_removals.json` berserta sebabnya:

| Rentetan | Lokasi | Sebab |
|---|---|---|
| ٨ مفردات متقنة | Jubin statistik di papan pemuka | Nombor tetap ("8 perkataan dikuasai") yang dipaparkan tanpa mengira aktiviti pelajar, jadi mengelirukan. Diganti dengan XP dan bilangan latihan sebenar |
| أسماء الله الحسنى والقواعد | Sub-tajuk jubin yang sama | Sama seperti di atas |

Kedua-duanya teks antara muka, bukan teks silibus.

## 5. Perkara yang TIDAK dilakukan

- Tiada teks Arab, terjemahan, dalil, ayat, hadis atau istilah diubah, diringkaskan atau dipindahkan.
- Tiada topik, gambar atau video dipadam.
- Tiada video diambil dari internet, tiada video/URL/thumbnail palsu, tiada video diduplikasi.
- Latihan tambahan diletakkan dalam fail berasingan (`lib/data/supplemental_exercises.dart`)
  dan dilabel jelas «تدريبات إضافية · Aktiviti Pengukuhan». Ia tidak dicampur ke dalam teks asal,
  termasuk latihan yang dikarang baharu.

## 6. Nota untuk semakan pengguna

- Komen sedia ada dalam `curriculum.dart` (Dars 12) mencatat bahawa baris kosa kata
  "Keadilan" dalam manuskrip telah dibetulkan kepada «الْعَدْلُ». Pembetulan itu dibuat
  **sebelum** kerja ini. Ia tidak disentuh dan dicatat di sini untuk makluman sahaja.
