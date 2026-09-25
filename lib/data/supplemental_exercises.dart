import 'curriculum.dart';
import 'exercise_models.dart';

/// Supplemental reinforcement exercises ("Aktiviti Pengukuhan") per lesson.
///
/// Kept apart from curriculum.dart on purpose: curriculum.dart is the
/// original syllabus (read-only), this file is the enhancement layer.
///
/// Two kinds of entries:
///  * built from the lesson text (`_fromLessonText`) — their Arabic is taken
///    verbatim from curriculum.dart (reading lines, vocab, rule tables), and
///    test/supplemental_exercises_test.dart enforces that;
///  * newly written practice (`_authored`, flagged `authored: true`) — new
///    comprehension statements and rule-application sentences. These are
///    practice items only; the syllabus text itself is never edited.

const _b = McqQuestion.blank;

/// Builds a cloze question from an original reading [line]: [answer] (an
/// exact substring of the line) is replaced by a gap, and the options are
/// the answer plus [distractors], with the answer placed at [pos].
McqQuestion _cloze(String line, String answer, List<String> distractors, {int pos = 0}) {
  assert(line.contains(answer), 'cloze answer "$answer" not in "$line"');
  final options = [...distractors];
  final at = pos.clamp(0, options.length);
  options.insert(at, answer);
  return McqQuestion(prompt: line.replaceFirst(answer, _b), options: options, answer: at);
}

/// "What does this word mean?" — options are meanings from the same vocab
/// list; distractors are the next three entries (wrapping around).
McqExercise _meaningMcq(
  String id,
  List<VocabItem> vocab,
  List<int> indices, {
  required String source,
  bool quick = false,
}) {
  final qs = <McqQuestion>[];
  for (var q = 0; q < indices.length; q++) {
    final i = indices[q];
    final distractors = <String>[];
    for (var k = 1; distractors.length < 3 && k < vocab.length; k++) {
      final m = vocab[(i + k) % vocab.length].meaning;
      if (m != vocab[i].meaning && !distractors.contains(m)) distractors.add(m);
    }
    final pos = q % (distractors.length + 1);
    final options = [...distractors]..insert(pos, vocab[i].meaning);
    qs.add(McqQuestion(prompt: vocab[i].word, options: options, answer: pos));
  }
  return McqExercise(
    id: id,
    title: quick ? 'تَحَقُّقٌ سَرِيعٌ' : 'مَا مَعْنَى الْكَلِمَةِ؟',
    instruction: 'Pilih maksud yang betul bagi setiap perkataan.',
    source: source,
    purpose: 'Mengukuhkan makna kosa kata pelajaran.',
    questions: qs,
    optionsAreArabic: false,
    isQuickCheck: quick,
  );
}

/// "word = meaning" statements from the lesson vocab: each (w, m) pair
/// shows vocab[w].word with vocab[m].meaning — true only when w == m.
TrueFalseExercise _vocabTrueFalse(String id, List<VocabItem> vocab, List<(int, int)> pairs, {required String source}) =>
    TrueFalseExercise(
      id: id,
      title: 'صَوَابٌ أَمْ خَطَأٌ؟',
      instruction: 'Adakah maksud yang diberi betul atau salah?',
      source: source,
      purpose: 'Menguji ingatan makna kosa kata.',
      items: [for (final (w, m) in pairs) TrueFalseItem(term: vocab[w].word, claim: vocab[m].meaning, isTrue: w == m)],
    );

FlashcardExercise _flashcards(String id, List<VocabItem> vocab, String source) => FlashcardExercise(
  id: id,
  title: 'بِطَاقَاتُ الْمُفْرَدَاتِ',
  instruction: 'Baca perkataan, cuba ingat maksudnya, kemudian ketik kad untuk menyemak.',
  source: source,
  purpose: 'Ulang kaji kosa kata secara aktif (active recall).',
  cards: vocab,
);

McqExercise _quick(String source, List<McqQuestion> qs) => McqExercise(
  id: 'quick',
  title: 'تَحَقُّقٌ سَرِيعٌ',
  instruction: 'Lengkapkan ayat daripada teks bacaan dengan pilihan yang betul.',
  source: source,
  purpose: 'Menyemak kefahaman teks bacaan asal.',
  questions: qs,
  isQuickCheck: true,
);

final Map<int, List<ExerciseSpec>> _fromLessonText = {
  // ── الدرس الأول: الإيمان بالله ─────────────────────────────────────
  1: [
    _quick('Dars111.readingLines (baris 3–5)', [
      _cloze(Dars111.readingLines[2], 'يَرْحَمُ', ['يَعْلَمُ', 'يَسْمَعُ'], pos: 0),
      _cloze(Dars111.readingLines[3], 'الْعَلِيمُ', ['الْعَزِيزُ', 'السَّمِيعُ'], pos: 1),
      _cloze(Dars111.readingLines[4], 'يَسْمَعُ وَيَرَى', ['يَعْلَمُ كُلَّ شَيْءٍ', 'يَرْحَمُ عِبَادَهُ'], pos: 2),
    ]),
    _flashcards('flash', Dars111.vocab, 'Dars111.vocab'),
    CategorizeExercise(
      id: 'al',
      title: 'صَنِّفِ الْكَلِمَاتِ',
      instruction: 'Asingkan perkataan: yang bermula dengan «الـ» dan yang tanpa «الـ».',
      source: 'Dars111.transformPairs; objektif penilaian kendiri ke-4',
      purpose: 'Membezakan isim nakirah dan isim ma‘rifah dengan «الـ».',
      categories: ['بدون "الـ"', 'بـ"الـ"'],
      items: [
        for (final p in Dars111.transformPairs.take(4)) ...[CategorizeItem(p.$1, 0), CategorizeItem(p.$2, 1)],
      ],
    ),
    const McqExercise(
      id: 'nahw',
      title: 'الْمُبْتَدَأُ وَالْخَبَرُ',
      instruction: 'Tentukan kedudukan perkataan dalam jumlah ismiyyah.',
      source: 'Dars111.ruleFormula, ruleP1, ruleP2',
      purpose: 'Mengenal pasti mubtada’ dan khabar mengikut kaedah pelajaran.',
      questions: [
        McqQuestion(
          prompt: 'Dalam ayat «اللهُ رَحِيمٌ», apakah kedudukan «اللهُ»?',
          promptIsArabic: false,
          options: ['مبتدأ', 'خبر'],
          answer: 0,
        ),
        McqQuestion(
          prompt: 'Dalam ayat «اللهُ رَحِيمٌ», apakah kedudukan «رَحِيمٌ»?',
          promptIsArabic: false,
          options: ['مبتدأ', 'خبر'],
          answer: 1,
        ),
        McqQuestion(
          prompt: 'الْجُمْلَةُ الاِسْمِيَّةُ = $_b',
          options: ['اِسْمٌ + صِفَةٌ', 'الْمُبْتَدَأُ + الْخَبَرُ', 'كَلِمَةُ التَّرْتِيبِ + الجُمْلَةُ'],
          answer: 1,
        ),
      ],
    ),
  ],

  // ── الدرس الثاني: الإيمان بالملائكة والكتب والرسل ─────────────────
  2: [
    _quick('Dars112.readingLines (baris 2, 4, 8)', [
      _cloze(Dars112.readingLines[1], 'جِبْرِيلُ', ['مِيكَائِيلُ', 'إِسْرَافِيلُ', 'عَزْرَائِيلُ'], pos: 2),
      _cloze(Dars112.readingLines[3], 'بِنَفْخِ الصُّورِ', [
        'بِالْوَحْيِ',
        'بِقَبْضِ الْأَرْوَاحِ',
        'بِالْمَطَرِ وَالرِّزْقِ',
      ], pos: 1),
      _cloze(Dars112.readingLines[7], 'بَشَرٌ', ['مَلَكٌ', 'كِتَابٌ'], pos: 0),
    ]),
    _flashcards('flash', Dars112.vocab, 'Dars112.vocab'),
    CategorizeExercise(
      id: 'groups',
      title: 'صَنِّفِ الْأَسْمَاءَ',
      instruction: 'Letakkan setiap nama di bawah kumpulan yang betul: malaikat, kitab atau rasul.',
      source: 'Dars112.angelNames, bookNames, bookProphets; ruleTable',
      purpose: 'Membezakan nama malaikat, kitab dan rasul yang disebut dalam pelajaran.',
      categories: const ['مَلَكٌ', 'كِتَابٌ', 'رَسُولٌ'],
      items: [
        for (final a in Dars112.angelNames.take(3)) CategorizeItem(a, 0),
        CategorizeItem(Dars112.bookNames[0], 1),
        CategorizeItem(Dars112.bookNames[2], 1),
        CategorizeItem(Dars112.bookNames[3], 1),
        CategorizeItem(Dars112.bookProphets[0], 2),
        CategorizeItem(Dars112.bookProphets[2], 2),
        CategorizeItem(Dars112.bookProphets[3], 2),
      ],
    ),
    _meaningMcq('meaning', Dars112.vocab, [4, 5, 6, 8], source: 'Dars112.vocab'),
  ],

  // ── الدرس الثالث: الإيمان باليوم الآخر والقضاء والقدر ─────────────
  3: [
    _quick('Dars113.readingLines (baris 2, 4, 6)', [
      _cloze(Dars113.readingLines[1], 'اَلْيَوْمُ الآخِرُ', ['اَلْقَدَرُ', 'اَلنَّارُ'], pos: 1),
      _cloze(Dars113.readingLines[5], 'اَلْقَدَرُ', ['اَلْحِسَابُ', 'اَلْبَعْثُ'], pos: 0),
      _cloze(Dars113.readingLines[3], 'الْجَنَّةَ', ['النَّارَ'], pos: 1),
    ]),
    const SequenceExercise(
      id: 'events',
      title: 'رَتِّبْ حَسَبَ التَّسَلْسُلِ',
      instruction: 'Susun peristiwa mengikut urutan seperti dalam teks bacaan.',
      source: 'Dars113.readingLines[0]; ruleTable ("اَلْبَعْثُ ثُمَّ الْحِسَابُ")',
      purpose: 'Memahami urutan peristiwa Hari Akhirat seperti yang dinyatakan dalam teks.',
      correctOrder: ['اَلْمَوْتُ', 'اَلْبَعْثُ', 'اَلْحِسَابُ'],
    ),
    const CategorizeExercise(
      id: 'istifham',
      title: 'أُسْلُوبُ الاِسْتِفْهَامِ',
      instruction: 'Jawapan ini menjawab soalan jenis apa: «هَلْ» atau «مَاذَا»?',
      source: 'Dars113.rulePattern1, rulePattern2, ruleTable',
      purpose: 'Membezakan jawapan bagi soalan «هل» (ya/tidak) dan «ماذا» (maklumat).',
      categories: ['هَلْ...؟', 'مَاذَا...؟'],
      items: [
        CategorizeItem('نَعَمْ، أُؤْمِنُ بِالْقَدَرِ.', 0),
        CategorizeItem('يُبْعَثُ النَّاسُ وَيُحَاسَبُونَ.', 1),
        CategorizeItem('نَعَمْ، أَرْضَى بِقَضَاءِ اللهِ.', 0),
        CategorizeItem('اَلْبَعْثُ ثُمَّ الْحِسَابُ.', 1),
      ],
    ),
    _flashcards('flash', Dars113.vocab, 'Dars113.vocab'),
  ],

  // ── الدرس الرابع: الطهارة — الوضوء والغسل ─────────────────────────
  4: [
    _quick('Dars114.readingLines (baris 1, 4, 5)', [
      _cloze(Dars114.readingLines[0], 'شَرْطٌ', ['رُكْنٌ'], pos: 0),
      _cloze(Dars114.readingLines[3], 'المِرْفَقَيْنِ', ['الكَعْبَيْنِ'], pos: 1),
      _cloze(Dars114.readingLines[4], 'نَمْسَحُ', ['نَغْسِلُ'], pos: 0),
    ]),
    SequenceExercise(
      id: 'wudu',
      title: 'رَتِّبْ خُطُوَاتِ الْوُضُوءِ',
      instruction: 'Susun ayat-ayat bacaan mengikut urutan langkah wuduk.',
      source: 'Dars114.readingLines (baris 2–6)',
      purpose: 'Mengukuhkan urutan wuduk dan penggunaan kata susunan (أولاً، ثم، بعد ذلك، أخيراً).',
      correctOrder: Dars114.readingLines.sublist(1, 6),
    ),
    CategorizeExercise(
      id: 'wudu-ghusl',
      title: 'الْوُضُوءُ أَمِ الْغُسْلُ؟',
      instruction: 'Letakkan setiap maklumat di bawah wuduk atau mandi wajib.',
      source: 'Dars114.compareRows (أحلل وأطبق)',
      purpose: 'Membezakan wuduk dan mandi wajib dari segi anggota, masa dan rukun.',
      categories: const ['الْوُضُوءُ', 'الْغُسْلُ'],
      items: [
        for (final r in Dars114.compareRows) ...[CategorizeItem(r.wudu, 0), CategorizeItem(r.ghusl, 1)],
      ],
    ),
    _flashcards('flash', Dars114.vocab, 'Dars114.vocab'),
  ],

  // ── الدرس الخامس: الصلاة المفروضة ──────────────────────────────────
  5: [
    _quick('Dars115.readingLines (baris 1, 8)', [
      _cloze(Dars115.readingLines[0], 'رُكْنٌ', ['شَرْطٌ'], pos: 1),
      _cloze(Dars115.readingLines[7], 'صَلِّ', ['اُسْجُدْ', 'اِرْكَعْ'], pos: 2),
    ]),
    const SequenceExercise(
      id: 'times',
      title: 'رَتِّبْ أَوْقَاتَ الصَّلَاةِ',
      instruction: 'Susun waktu solat fardu mengikut urutan dalam teks bacaan.',
      source: 'Dars115.readingLines[1]; vocab',
      purpose: 'Mengingat nama dan urutan lima waktu solat fardu.',
      correctOrder: ['الفَجْرُ', 'الظُّهْرُ', 'العَصْرُ', 'المَغْرِبُ', 'العِشَاءُ'],
    ),
    CategorizeExercise(
      id: 'shurut-arkan',
      title: 'شَرْطٌ أَمْ رُكْنٌ؟',
      instruction: 'Asingkan antara syarat solat dan rukun solat.',
      source: 'Dars115.compareLeft / compareRight (أحلل وأطبق)',
      purpose: 'Membezakan syarat dan rukun solat.',
      categories: const [Dars115.compareLeftLabel, Dars115.compareRightLabel],
      items: [
        for (final s in Dars115.compareLeft) CategorizeItem(s, 0),
        for (final s in Dars115.compareRight) CategorizeItem(s, 1),
      ],
    ),
    const McqExercise(
      id: 'amr',
      title: 'فِعْلُ الْأَمْرِ',
      instruction: 'Pilih fi‘l amr bagi setiap fi‘l mudari‘.',
      source: 'Dars115.ruleTable',
      purpose: 'Membentuk fi‘l amr daripada fi‘l mudari‘.',
      questions: [
        McqQuestion(prompt: 'يَسْجُدُ ← $_b', options: ['اُسْجُدْ', 'قُمْ', 'صَلِّ'], answer: 0),
        McqQuestion(prompt: 'يَرْكَعُ ← $_b', options: ['صَلِّ', 'اِرْكَعْ', 'اُسْجُدْ'], answer: 1),
        McqQuestion(prompt: 'يَقُومُ ← $_b', options: ['اِرْكَعْ', 'صَلِّ', 'قُمْ'], answer: 2),
        McqQuestion(prompt: 'يُصَلِّي ← $_b', options: ['صَلِّ', 'قُمْ', 'اِرْكَعْ'], answer: 0),
      ],
    ),
    _flashcards('flash', Dars115.vocab, 'Dars115.vocab'),
  ],

  // ── الدرس السادس: صيام رمضان ─────────────────────────────────────
  6: [
    _quick('Dars116.readingLines (baris 4, 6, 7)', [
      _cloze(Dars116.readingLines[3], 'قَبْلَ الْفَجْرِ', ['عِنْدَ غُرُوبِ الشَّمْسِ'], pos: 0),
      _cloze(Dars116.readingLines[5], 'عَمْدًا', ['نَاسِيًا'], pos: 1),
      _cloze(Dars116.readingLines[6], 'نُفْطِرُ', ['نَصُومُ', 'نَنْوِي'], pos: 0),
    ]),
    CategorizeExercise(
      id: 'iftar',
      title: 'مَتَى يَجُوزُ الْإِفْطَارُ؟',
      instruction: 'Siapakah yang dibenarkan berbuka puasa dan siapakah yang tidak?',
      source: 'Dars116.compareLeft / compareRight (أحلل وأطبق)',
      purpose: 'Mengenal pasti golongan yang diharuskan berbuka pada bulan Ramadan.',
      categories: const [Dars116.compareLeftLabel, Dars116.compareRightLabel],
      items: [
        for (final s in Dars116.compareLeft) CategorizeItem(s, 0),
        for (final s in Dars116.compareRight.where((s) => s != '—')) CategorizeItem(s, 1),
      ],
    ),
    const CategorizeExercise(
      id: 'nahy',
      title: 'أُسْلُوبُ النَّهْيِ',
      instruction:
          'Yang manakah berbentuk larangan (لَا + fi‘l mudari‘ majzum)? '
          'Perhatikan baris akhir fi‘l.',
      source: 'Dars116.ruleFormula, ruleNote, ruleTable; readingLines',
      purpose: 'Membezakan «لا» nahy (fi‘l majzum) daripada ayat biasa.',
      categories: ['نَهْيٌ', 'Bukan nahy'],
      items: [
        CategorizeItem('لَا تَأْكُلْ', 0),
        CategorizeItem('لَا يَجُوزُ', 1),
        CategorizeItem('لَا تَشْرَبْ', 0),
        CategorizeItem('نُفْطِرُ', 1),
        CategorizeItem('لَا يَكْذِبْ', 0),
        CategorizeItem('نَصُومُ', 1),
      ],
    ),
    _flashcards('flash', Dars116.vocab, 'Dars116.vocab'),
  ],

  // ── الدرس السابع: صفات الرسول ────────────────────────────────────
  7: [
    _quick('Dars117.readingLines (baris 4, 6)', [
      _cloze(Dars117.readingLines[3], 'فَطِنٌ', ['صَادِقٌ', 'أَمِينٌ'], pos: 2),
      _cloze(Dars117.readingLines[5], 'الْكَذِبُ', ['الْكِتْمَانُ', 'الْبَلَادَةُ'], pos: 0),
      _cloze(Dars117.readingLines[5], 'الْخِيَانَةُ', ['الْكِتْمَانُ', 'الْبَلَادَةُ'], pos: 1),
    ]),
    CategorizeExercise(
      id: 'wajib',
      title: 'الصِّفَاتُ الْوَاجِبَةُ لِلرَّسُولِ',
      instruction: 'Asingkan: sifat wajib Rasul dan yang bukan sifat wajib Rasul.',
      source: 'Dars117.readingLines[4]; vocab',
      purpose: 'Mengenal empat sifat wajib Rasul dan membezakannya daripada sifat yang bertentangan.',
      categories: const ['Sifat wajib Rasul', 'Bukan sifat wajib Rasul'],
      items: [for (var i = 0; i < 8; i++) CategorizeItem(Dars117.vocab[i].word, i < 4 ? 0 : 1)],
    ),
    _meaningMcq('meaning', Dars117.vocab, [0, 2, 3, 6], source: 'Dars117.vocab'),
    _flashcards('flash', Dars117.vocab, 'Dars117.vocab'),
  ],

  // ── الدرس الثامن: الأخلاق مع الله ورسوله ─────────────────────────
  8: [
    _meaningMcq('quick', Dars118.vocab, [0, 4, 5], source: 'Dars118.vocab', quick: true),
    const CategorizeExercise(
      id: 'nafy',
      title: 'مُثْبَتَةٌ أَمْ مَنْفِيَّةٌ؟',
      instruction: 'Asingkan ayat positif (مُثْبَتَةٌ) dan ayat negatif (مَنْفِيَّةٌ).',
      source: 'Dars118.ruleTable; readingLines',
      purpose: 'Mengenal ayat mutsbatah dan manfiyyah.',
      categories: ['مُثْبَتَةٌ', 'مَنْفِيَّةٌ'],
      items: [
        CategorizeItem('أَنَا أُطِيعُ اللهَ.', 0),
        CategorizeItem('لَا أَعْصِي اللهَ.', 1),
        CategorizeItem('أَنَا مُؤْمِنٌ.', 0),
        CategorizeItem('لَيْسَ النَّبِيُّ كَاذِبًا.', 1),
        CategorizeItem('أَنَا أَتَّقِي اللهَ فِي السِّرِّ وَالْعَلَنِ.', 0),
        CategorizeItem('لَا أَعْصِي اللهَ، وَلَا أَكْذِبُ عَلَى النَّبِيِّ.', 1),
      ],
    ),
    const McqExercise(
      id: 'la-laysa',
      title: 'أَدَاةُ النَّفْيِ',
      instruction: 'Pilih alat nafi yang sesuai mengikut kaedah pelajaran.',
      source: 'Dars118.ruleNote',
      purpose: 'Membezakan penggunaan «لا» dan «ليس».',
      questions: [
        McqQuestion(
          prompt: 'Untuk menafikan «الْفِعْلَ الْمُضَارِعَ», kita gunakan:',
          promptIsArabic: false,
          options: ['لَا', 'لَيْسَ'],
          answer: 0,
        ),
        McqQuestion(
          prompt: 'Untuk menafikan «الْجُمْلَةَ الِاسْمِيَّةَ», kita gunakan:',
          promptIsArabic: false,
          options: ['لَا', 'لَيْسَ'],
          answer: 1,
        ),
      ],
    ),
    _flashcards('flash', Dars118.vocab, 'Dars118.vocab'),
  ],

  // ── الدرس التاسع: الأخلاق في الأسرة والمجتمع ─────────────────────
  9: [
    _quick('Dars119.readingLines (baris 2, 5)', [
      _cloze(Dars119.readingLines[1], 'كَرِيمٌ', ['صَبُورَةٌ'], pos: 0),
      _cloze(Dars119.readingLines[4], 'الْكِبَارَ', ['الصِّغَارَ'], pos: 1),
    ]),
    CategorizeExercise(
      id: 'responsibility',
      title: 'مَسْؤُولِيَّتِي',
      instruction: 'Letakkan setiap tanggungjawab di bawah keluarga atau masyarakat.',
      source: 'Dars119.compareLeft / compareRight (أحلل وأطبق)',
      purpose: 'Membezakan tanggungjawab dalam keluarga dan dalam masyarakat.',
      categories: const [Dars119.compareLeftLabel, Dars119.compareRightLabel],
      items: [
        for (final s in Dars119.compareLeft) CategorizeItem(s, 0),
        for (final s in Dars119.compareRight) CategorizeItem(s, 1),
      ],
    ),
    _meaningMcq('meaning', Dars119.vocab, [3, 4, 7, 9], source: 'Dars119.vocab'),
    _flashcards('flash', Dars119.vocab, 'Dars119.vocab'),
  ],

  // ── الدرس العاشر: مولد النبي وحياته الأولى ───────────────────────
  10: [
    _quick('Dars1110.readingLines (baris 2, 4, 6)', [
      _cloze(Dars1110.readingLines[1], 'قَبْلَ', ['بَعْدَ'], pos: 1),
      _cloze(Dars1110.readingLines[3], 'الْخَامِسَةِ وَالْعِشْرِينَ', ['الْأَرْبَعِينَ'], pos: 0),
      _cloze(Dars1110.readingLines[5], 'الْأَرْبَعِينَ', ['الْخَامِسَةِ وَالْعِشْرِينَ'], pos: 1),
    ]),
    SequenceExercise(
      id: 'timeline',
      title: 'خَطُّ الزَّمَنِ',
      instruction: 'Susun peristiwa awal kehidupan Nabi ﷺ mengikut urutan masa.',
      source: 'Dars1110.compareLeft / compareRight (خط زمن)',
      purpose: 'Mengukuhkan kronologi sirah dan penggunaan fi‘l madi dalam penceritaan.',
      correctOrder: Dars1110.compareLeft,
    ),
    CategorizeExercise(
      id: 'majhul',
      title: 'مَعْلُومٌ أَمْ مَجْهُولٌ؟',
      instruction: 'Asingkan fi‘l ma‘lum dan fi‘l majhul.',
      source: 'Dars1110.ruleTable',
      purpose: 'Membezakan fi‘l ma‘lum dan fi‘l majhul dalam penceritaan sirah.',
      categories: const ['مَعْلُومٌ', 'مَجْهُولٌ'],
      items: [for (final r in Dars1110.ruleTable) CategorizeItem(r.$1, r.$2 == 'مَعْلُومٌ' ? 0 : 1)],
    ),
    _vocabTrueFalse('tf', Dars1110.vocab, [(0, 0), (1, 2), (3, 3), (4, 7), (5, 5), (7, 1)], source: 'Dars1110.vocab'),
    _flashcards('flash', Dars1110.vocab, 'Dars1110.vocab'),
  ],

  // ── الدرس الحادي عشر: الإسراء والمعراج والهجرة ───────────────────
  11: [
    _quick('Dars1111.readingLines (baris 4, 5, 7)', [
      _cloze(Dars1111.readingLines[4], 'الصَّلَاةُ', ['الصِّيَامُ'], pos: 0),
      _cloze(Dars1111.readingLines[6], 'الْأَنْصَارُ', ['الْمُهَاجِرُونَ'], pos: 1),
      _cloze(Dars1111.readingLines[3], 'حَتَّى', ['لَمَّا', 'حِينَ'], pos: 2),
    ]),
    SequenceExercise(
      id: 'journey',
      title: 'رَتِّبِ الْأَحْدَاثَ',
      instruction: 'Susun ayat-ayat bacaan mengikut urutan peristiwa.',
      source: 'Dars1111.readingLines (baris 1, 3, 4, 6, 7)',
      purpose: 'Memahami urutan peristiwa Israk, Mikraj dan Hijrah.',
      correctOrder: [
        Dars1111.readingLines[0],
        Dars1111.readingLines[2],
        Dars1111.readingLines[3],
        Dars1111.readingLines[5],
        Dars1111.readingLines[6],
      ],
    ),
    CategorizeExercise(
      id: 'compare',
      title: 'الْإِسْرَاءُ وَالْمِعْرَاجُ أَمِ الْهِجْرَةُ؟',
      instruction: 'Letakkan setiap maklumat di bawah peristiwa yang betul.',
      source: 'Dars1111.compareLeft / compareRight (أحلل وأطبق)',
      purpose: 'Membezakan ciri Israk-Mikraj dan Hijrah.',
      categories: const [Dars1111.compareRightLabel, Dars1111.compareLeftLabel],
      items: [
        for (final s in Dars1111.compareRight) CategorizeItem(s, 0),
        for (final s in Dars1111.compareLeft) CategorizeItem(s, 1),
      ],
    ),
    PairMatchExercise(
      id: 'rawabit',
      title: 'الرَّوَابِطُ الزَّمَانِيَّةُ',
      instruction: 'Padankan setiap penanda masa dengan maksudnya.',
      source: 'Dars1111.ruleTable',
      purpose: 'Memahami fungsi penanda masa dalam penceritaan.',
      pairs: [for (final r in Dars1111.ruleTable) (r.$1, r.$2)],
    ),
    _flashcards('flash', Dars1111.vocab, 'Dars1111.vocab'),
  ],

  // ── الدرس الثاني عشر: الصحابة المختارون وإسهاماتهم ───────────────
  12: [
    _quick('Dars1112.readingLines (baris 2, 4, 5)', [
      _cloze(Dars1112.readingLines[3], 'عُمَرُ الْفَارُوقُ', [
        'عُثْمَانُ ذُو النُّورَيْنِ',
        'أَبُو بَكْرٍ الصِّدِّيقُ',
      ], pos: 0),
      _cloze(Dars1112.readingLines[4], 'عُثْمَانُ ذُو النُّورَيْنِ', [
        'عُمَرُ الْفَارُوقُ',
        'أَبُو بَكْرٍ الصِّدِّيقُ',
      ], pos: 2),
      _cloze(Dars1112.readingLines[1], 'خَلَفَ', ['حَكَمَ', 'جَمَعَ'], pos: 1),
    ]),
    const SequenceExercise(
      id: 'tarjamah',
      title: 'تَرْتِيبُ التَّرْجَمَةِ',
      instruction: 'Susun bahagian-bahagian biodata ringkas (tarjamah) mengikut kaedah pelajaran.',
      source: 'Dars1112.ruleFormula',
      purpose: 'Mengukuhkan struktur tarjamah: nama + gelaran + sifat + sumbangan.',
      correctOrder: ['اِسْمٌ', 'لَقَبٌ', 'صِفَةٌ', 'إِسْهَامٌ'],
    ),
    SequenceExercise(
      id: 'abubakr',
      title: 'رَتِّبِ التَّرْجَمَةَ',
      instruction: 'Bina tarjamah ringkas Abu Bakar dengan menyusun bahagiannya.',
      source: 'Dars1112.ruleTable[0]',
      purpose: 'Mengaplikasikan struktur tarjamah pada contoh pelajaran.',
      correctOrder: [Dars1112.ruleTable[0].$1, Dars1112.ruleTable[0].$2, Dars1112.ruleTable[0].$3],
    ),
    _meaningMcq('meaning', Dars1112.vocab, [9, 10, 11, 5], source: 'Dars1112.vocab'),
    _flashcards('flash', Dars1112.vocab, 'Dars1112.vocab'),
  ],
};

/// "Betul atau salah?" on newly written sentences about the reading text.
TrueFalseExercise _comprehension(String source, List<(String, bool)> items) => TrueFalseExercise(
  id: 'faham',
  title: 'صَوَابٌ أَمْ خَطَأٌ؟',
  instruction: 'Berdasarkan teks bacaan, adakah pernyataan ini betul atau salah?',
  source: source,
  purpose: 'Menguji kefahaman teks bacaan dengan ayat baharu (bukan salinan teks).',
  authored: true,
  items: [for (final (t, v) in items) TrueFalseItem.statement(t, isTrue: v)],
);

/// Practice items written for this app (not quoted from curriculum.dart):
/// comprehension statements about the reading text, and rule-application
/// questions with new example sentences. Placed right after each lesson's
/// quick check.
final Map<int, List<ExerciseSpec>> _authored = {
  1: [
    const McqExercise(
      id: 'khabar',
      title: 'أُكْمِلُ الْجُمْلَةَ الاِسْمِيَّةَ',
      instruction: 'Pilih khabar yang sesuai dengan maksud yang diberi.',
      source: 'Aplikasi Dars111.ruleFormula (مبتدأ + خبر) dengan ayat baharu',
      purpose: 'Membina jumlah ismiyyah: اللهُ + khabar.',
      authored: true,
      questions: [
        McqQuestion(
          prompt: 'Maksud: "Allah Maha Mendengar" → «اللَّهُ $_b»',
          promptIsArabic: false,
          options: ['بَصِيرٌ', 'سَمِيعٌ', 'حَكِيمٌ'],
          answer: 1,
        ),
        McqQuestion(
          prompt: 'Maksud: "Allah Maha Melihat" → «اللَّهُ $_b»',
          promptIsArabic: false,
          options: ['بَصِيرٌ', 'عَزِيزٌ', 'سَمِيعٌ'],
          answer: 0,
        ),
        McqQuestion(
          prompt: 'Maksud: "Allah Maha Perkasa" → «اللَّهُ $_b»',
          promptIsArabic: false,
          options: ['عَلِيمٌ', 'رَحِيمٌ', 'عَزِيزٌ'],
          answer: 2,
        ),
        McqQuestion(
          prompt: 'Dalam ayat «اللَّهُ عَلِيمٌ», yang manakah khabar?',
          promptIsArabic: false,
          options: ['اللَّهُ', 'عَلِيمٌ'],
          answer: 1,
        ),
      ],
    ),
  ],
  2: [
    _comprehension('Teks bacaan Dars 2', [
      ('جِبْرِيلُ مُوَكَّلٌ بِالْوَحْيِ.', true),
      ('مِيكَائِيلُ مُوَكَّلٌ بِقَبْضِ الْأَرْوَاحِ.', false),
      ('خُلِقَتِ الْمَلَائِكَةُ مِنْ نُورٍ.', true),
      ('الزَّبُورُ كِتَابُ مُوسَى.', false),
      ('الرَّسُولُ مَلَكٌ مِنَ الْمَلَائِكَةِ.', false),
      ('مُحَمَّدٌ خَاتَمُ الرُّسُلِ.', true),
    ]),
  ],
  3: [
    _comprehension('Teks bacaan Dars 3', [
      ('كُلُّ إِنْسَانٍ يَمُوتُ.', true),
      ('الْحِسَابُ قَبْلَ الْبَعْثِ.', false),
      ('مَنْ عَمِلَ خَيْرًا دَخَلَ الْجَنَّةَ.', true),
      ('الْمُؤْمِنُ يَرْضَى بِالْقَضَاءِ وَلَا يَعْمَلُ.', false),
      ('الْقَدَرُ تَقْدِيرُ اللهِ لِكُلِّ شَيْءٍ.', true),
    ]),
  ],
  4: [
    _comprehension('Teks bacaan Dars 4', [
      ('نَتَوَضَّأُ قَبْلَ كُلِّ صَلَاةٍ.', true),
      ('نَمْسَحُ الْوَجْهَ بِالْمَاءِ.', false),
      ('نَغْسِلُ الرِّجْلَيْنِ إِلَى الْكَعْبَيْنِ.', true),
      ('الْغُسْلُ غَسْلُ الْيَدَيْنِ فَقَطْ.', false),
      ('نَغْتَسِلُ بَعْدَ الْجَنَابَةِ.', true),
    ]),
  ],
  5: [
    _comprehension('Teks bacaan Dars 5', [
      ('لِلصَّلَاةِ الْمَفْرُوضَةِ خَمْسَةُ أَوْقَاتٍ.', true),
      ('صَلَاةُ الْعَصْرِ قَبْلَ صَلَاةِ الظُّهْرِ.', false),
      ('الطَّهَارَةُ شَرْطٌ مِنْ شُرُوطِ الصَّلَاةِ.', true),
      ('قِرَاءَةُ الْفَاتِحَةِ شَرْطٌ مِنْ شُرُوطِ الصَّلَاةِ.', false),
      ('نَسْجُدُ بَعْدَ الرُّكُوعِ.', true),
    ]),
  ],
  6: [
    _comprehension('Teks bacaan Dars 6 dan hadis pelajaran', [
      ('نَصُومُ فِي شَهْرِ رَمَضَانَ.', true),
      ('نَنْوِي الصِّيَامَ بَعْدَ طُلُوعِ الْفَجْرِ.', false),
      ('نُفْطِرُ عِنْدَ غُرُوبِ الشَّمْسِ.', true),
      ('مَنْ أَكَلَ نَاسِيًا بَطَلَ صَوْمُهُ.', false),
      ('يَجُوزُ لِلْمُسَافِرِ أَنْ يُفْطِرَ.', true),
    ]),
  ],
  7: [
    _comprehension('Teks bacaan Dars 7', [
      ('الصِّدْقُ صِفَةٌ مِنْ صِفَاتِ الرَّسُولِ.', true),
      ('ضِدُّ الْأَمَانَةِ الْكَذِبُ.', false),
      ('الرَّسُولُ يُبَلِّغُ رِسَالَةَ رَبِّهِ إِلَى النَّاسِ.', true),
      ('الْفَطِنُ حَكِيمٌ فِي تَدْبِيرِ أُمُورِهِ.', true),
      ('لِلرَّسُولِ ثَلَاثُ صِفَاتٍ وَاجِبَةٍ فَقَطْ.', false),
    ]),
  ],
  8: [
    const McqExercise(
      id: 'la-laysa-2',
      title: 'أَنْفِي الْجُمْلَةَ',
      instruction: 'Isi tempat kosong dengan alat nafi yang betul: «لَا» atau «لَيْسَ».',
      source: 'Aplikasi Dars118.ruleNote dengan ayat baharu',
      purpose: 'Mengaplikasikan «لا» untuk fi‘l mudari‘ dan «ليس» untuk jumlah ismiyyah.',
      authored: true,
      questions: [
        McqQuestion(prompt: '$_b أُهْمِلُ صَلَاتِي.', options: ['لَا', 'لَيْسَ'], answer: 0),
        McqQuestion(prompt: '$_b الْكَذِبُ خُلُقًا حَسَنًا.', options: ['لَا', 'لَيْسَ'], answer: 1),
        McqQuestion(prompt: '$_b أَتْرُكُ سُنَّةَ النَّبِيِّ.', options: ['لَا', 'لَيْسَ'], answer: 0),
        McqQuestion(prompt: '$_b الْمُؤْمِنُ كَذَّابًا.', options: ['لَا', 'لَيْسَ'], answer: 1),
      ],
    ),
  ],
  9: [
    _comprehension('Teks bacaan Dars 9', [
      ('أَبِي رَجُلٌ كَرِيمٌ.', true),
      ('أُمِّي امْرَأَةٌ صَبُورَةٌ.', true),
      ('لَيْسَ لِي أَخٌ وَلَا أُخْتٌ.', false),
      ('جَدِّي وَجَدَّتِي يَعِيشَانِ بَعِيدًا عَنَّا.', false),
      ('جِيرَانُنَا طَيِّبُونَ.', true),
    ]),
    const McqExercise(
      id: 'idafah',
      title: 'التَّرْكِيبُ الْإِضَافِيُّ',
      instruction: 'Pilih bentuk idafah yang betul.',
      source: 'Aplikasi Dars119.ruleFormula dan ruleNote dengan contoh baharu',
      purpose: 'Membentuk idafah: mudaf tanpa «الـ» dan tanpa tanwin; mudaf ilaih majrur.',
      authored: true,
      questions: [
        McqQuestion(prompt: 'بَيْتٌ + أَنَا ← $_b', options: ['الْبَيْتِي', 'بَيْتِي', 'بَيْتٌ أَنَا'], answer: 1),
        McqQuestion(
          prompt: 'كِتَابٌ + اللهُ ← $_b',
          options: ['كِتَابُ اللهِ', 'الْكِتَابُ اللهِ', 'كِتَابٌ اللهُ'],
          answer: 0,
        ),
        McqQuestion(
          prompt: 'بَابٌ + الْمَسْجِدُ ← $_b',
          options: ['الْبَابُ الْمَسْجِدِ', 'بَابٌ الْمَسْجِدُ', 'بَابُ الْمَسْجِدِ'],
          answer: 2,
        ),
      ],
    ),
  ],
  10: [
    _comprehension('Teks bacaan Dars 10', [
      ('وُلِدَ النَّبِيُّ فِي مَكَّةَ.', true),
      ('مَاتَ أَبُوهُ بَعْدَ وِلَادَتِهِ بِسَنَوَاتٍ.', false),
      ('رَعَى النَّبِيُّ الْغَنَمَ فِي صِغَرِهِ.', true),
      ('بُعِثَ النَّبِيُّ وَهُوَ فِي الْخَامِسَةِ وَالْعِشْرِينَ.', false),
      ('كَانَ النَّبِيُّ يُسَمَّى الْأَمِينَ.', true),
    ]),
  ],
  11: [
    _comprehension('Teks bacaan Dars 11', [
      ('أُسْرِيَ بِالنَّبِيِّ مِنْ مَكَّةَ إِلَى بَيْتِ الْمَقْدِسِ.', true),
      ('رَكِبَ النَّبِيُّ الْبُرَاقَ فِي الْهِجْرَةِ.', false),
      ('فُرِضَتِ الصَّلَاةُ فِي لَيْلَةِ الْمِعْرَاجِ.', true),
      ('هَاجَرَ النَّبِيُّ مِنَ الْمَدِينَةِ إِلَى مَكَّةَ.', false),
      ('الْأَنْصَارُ أَهْلُ الْمَدِينَةِ.', true),
    ]),
  ],
  12: [
    _comprehension('Teks bacaan Dars 12', [
      ('خَلَفَ أَبُو بَكْرٍ النَّبِيَّ فِي الْخِلَافَةِ.', true),
      ('جَمَعَ عُمَرُ الْقُرْآنَ فِي مُصْحَفٍ وَاحِدٍ.', false),
      ('اشْتَهَرَ عَلِيٌّ بِالْحِكْمَةِ وَالشَّجَاعَةِ.', true),
      ('حَكَمَ عُمَرُ الْفَارُوقُ بِالْعَدْلِ.', true),
      ('لَقَبُ عُثْمَانَ الصِّدِّيقُ.', false),
    ]),
  ],
};

/// All supplemental exercises per lesson: the quick check first, then the
/// newly written practice, then the activities built from the lesson text.
final Map<int, List<ExerciseSpec>> kSupplementalExercises = {
  for (final e in _fromLessonText.entries) e.key: [e.value.first, ...?_authored[e.key], ...e.value.skip(1)],
};

/// Exercises of lesson [n] (empty for an unknown lesson).
List<ExerciseSpec> exercisesFor(int n) => kSupplementalExercises[n] ?? const [];
