# Rabbaniyyah Mountain Challenge · سِبَاقٌ إِلَى الْقِمَّةِ

Permainan kelas Bahasa Arab secara langsung. Pelajar menjawab soalan di telefon masing-masing; setiap jawapan betul menaikkan avatar mereka di atas gunung yang dipaparkan pada skrin guru atau projektor.

## Mula di kelas

```sh
npm install        # sekali sahaja
npm start          # bina dan jalankan pada http://localhost:3001
```

1. Buka `http://localhost:3001/host.html` pada komputer yang disambung ke projektor.
2. Pilih level, kemudian tekan **Cipta sesi**. Kod 6 digit dan kod QR akan dipaparkan.
3. Pelajar mengimbas QR, atau membuka alamat yang dipaparkan, lalu memasukkan kod. Telefon mesti berada dalam **rangkaian Wi-Fi yang sama** dengan komputer guru.
4. Tekan **Mulakan pendakian**. Tekan **Projektor** (atau kekunci `P`) untuk paparan skrin penuh yang bersih. Kekunci `1`, `2` dan `3` menukar paparan Gunung, Pisah dan Kedudukan.
5. Tekan **Tamatkan** untuk melihat podium, anugerah dan analisis soalan, serta untuk muat turun CSV.

Jika halaman host dimuat semula, sesi dan kedudukan semua pendaki akan dipulihkan. Pelajar yang terputus sambungan boleh menyambung semula tanpa kehilangan kemajuan.

## Pembangunan

```sh
npm run dev                      # Vite (5173) + pelayan (3001)
npm test                         # ujian unit + ujian penerimaan Live Mountain
npm run simulate -- 123456 40    # hantar 40 bot ke sesi 123456 (ujian beban / demo)
npm run import-content           # import semula kandungan daripada curriculum.dart
```

## Dokumen

- [docs/TOPICS_AUDIT.md](docs/TOPICS_AUDIT.md): audit 12 topik sebenar dan item sumber yang bermasalah
- [docs/LEVEL_MAPPING.md](docs/LEVEL_MAPPING.md): pemetaan 7 level, skor dan altitud
- [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md): struktur kod, peristiwa soket dan had yang diketahui
