# في رحاب اللغة العربية الربانية — Rabbaniyyah App

Modul pembelajaran interaktif Bahasa Arab Rabbani (KIAS), Semester 1: 4 unit, 12 dars.
Flutter web, di-deploy ke GitHub Pages: https://muzzammilkias.github.io/rabbaniyyah_app/

## Struktur ringkas

| Lokasi | Isi |
|---|---|
| `lib/data/curriculum.dart` | **Teks silibus asal (baca sahaja).** Bacaan, kosa kata, kaedah, dalil dan soalan setiap dars |
| `lib/data/lesson_catalog.dart` | Metadata dars: unit, id storan, **video** |
| `lib/data/supplemental_exercises.dart` | Aktiviti Pengukuhan (latihan tambahan) setiap dars |
| `lib/screens/dars_1_N_screen.dart` | Hero dan susunan bahagian asal setiap dars |
| `lib/widgets/lesson/lesson_shell.dart` | Rangka halaman dars yang dikongsi |
| `lib/widgets/exercises/` | Komponen latihan boleh guna semula |
| `lib/state/app_state.dart` | Jawapan, kemajuan, XP, tanda ulang kaji (localStorage) |

## Tugasan biasa

**Tambah video untuk sesuatu dars.** Letakkan fail dalam `assets/video/`, kemudian dalam
`lib/data/lesson_catalog.dart` set `video: 'assets/video/topik10.mp4'` pada dars tersebut.
Jika `video: null`, tiada blok video dipaparkan.

**Tambah/ubah latihan tambahan.** Sunting `lib/data/supplemental_exercises.dart`, kemudian jalankan:

```bash
flutter test                                               # termasuk semakan teks latihan vs sumber
dart run tool/content_check/export_exercise_mapping.dart   # kemas kini EXERCISE_MAPPING.md
```

**Semak kandungan asal tidak terusik.**

```bash
python3 tool/content_check/content_check.py verify
```

## Jalankan & bina

```bash
flutter pub get
flutter run -d chrome
flutter analyze && flutter test
flutter build web --release --base-href /rabbaniyyah_app/
```

Push ke `main` akan mencetuskan deployment automatik (`.github/workflows/flutter_web.yml`).

Laporan: `ENHANCEMENT_REPORT.md`, `EXERCISE_MAPPING.md`, `CONTENT_PRESERVATION_REPORT.md`.
