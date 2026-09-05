class LessonRef {
  final int n;
  final String title;
  final bool enabled;
  const LessonRef(this.n, this.title, {this.enabled = false});
}

class UnitInfo {
  final String title;
  final String topic;
  final String icon;
  final List<LessonRef> lessons;
  const UnitInfo(this.title, this.topic, this.icon, this.lessons);
}

/// Real table of contents of كتاب اللغة العربية الربانية ١ — 4 units, 12
/// lessons. Only lesson 1 has its full interactive content built so far.
const List<UnitInfo> kSemester1Units = [
  UnitInfo('الوحدة الأولى', 'العقيدة', '🕋', [
    LessonRef(1, 'الإِيمَانُ بِاللهِ', enabled: true),
    LessonRef(2, 'الإِيمَانُ بِالْمَلَائِكَةِ وَالْكُتُبِ وَالرُّسُلِ'),
    LessonRef(3, 'الإِيمَانُ بِالْيَوْمِ الآخِرِ وَالْقَضَاءِ وَالْقَدَرِ'),
  ]),
  UnitInfo('الوحدة الثانية', 'الفقه', '🕌', [
    LessonRef(4, 'الطَّهَارَةُ: الوُضُوءُ وَالغُسْلُ'),
    LessonRef(5, 'الصَّلَاةُ المَفْرُوضَةُ: الأَوْقَاتُ، الأَرْكَانُ، وَالشُّرُوطُ'),
    LessonRef(6, 'صِيَامُ رَمَضَانَ: الشُّرُوطُ، الأَرْكَانُ، وَالمُبْطِلَاتُ'),
  ]),
  UnitInfo('الوحدة الثالثة', 'الأخلاق', '🌙', [
    LessonRef(7, 'صِفَاتُ الرَّسُولِ: الصِّدْقُ، الْأَمَانَةُ، التَّبْلِيغُ، الْفَطَانَةُ'),
    LessonRef(8, 'الأَخْلَاقُ مَعَ اللهِ وَرَسُولِهِ'),
    LessonRef(9, 'الأَخْلَاقُ فِي الأُسْرَةِ وَالمُجْتَمَعِ'),
  ]),
  UnitInfo('الوحدة الرابعة', 'السيرة', '📜', [
    LessonRef(10, 'مَوْلِدُ النَّبِيِّ وَحَيَاتُهُ الأُولَى'),
    LessonRef(11, 'الْإِسْرَاءُ وَالْمِعْرَاجُ وَالْهِجْرَةُ'),
    LessonRef(12, 'الصَّحَابَةُ الْمُخْتَارُونَ وَإِسْهَامَاتُهُمْ'),
  ]),
];

class VocabItem {
  final String word;
  final String meaning;
  const VocabItem(this.word, this.meaning);
}

class FillItem {
  final String before;
  final String after;
  final String answer;
  const FillItem(this.before, this.after, this.answer);
}

class WordOrderItem {
  final List<String> tokens;
  final String answer;
  const WordOrderItem(this.tokens, this.answer);
}

/// Full content of الدرس الأول: الإيمان بالله, ported verbatim from the
/// proofread manuscript.
class Dars111 {
  static const objectives = [
    ('📢', 'أنطق ستة أسماء من أسماء الله الحسنى بشكل صحيح.'),
    ('🗣️', 'أقرأ جملا عن الله تعالى من النص.'),
    ('✍️', 'أكتب جملة بسيطة: الله + خبر.'),
    ('👥', 'أعبر عن إيماني بالله في جملة قصيرة.'),
  ];

  static const readingLines = [
    'اللَّهُ هُوَ الإِلَهُ الحَقُّ.',
    'هُوَ وَاحِدٌ أَحَدٌ، لَيْسَ كَمِثْلِهِ شَيْءٌ.',
    'هُوَ الرَّحْمَنُ الرَّحِيمُ، يَرْحَمُ عِبَادَهُ.',
    'هُوَ الْعَلِيمُ الْخَبِيرُ، يَعْلَمُ كُلَّ شَيْءٍ.',
    'هُوَ السَّمِيعُ الْبَصِيرُ، يَسْمَعُ وَيَرَى.',
    'هُوَ الْعَزِيزُ الْحَكِيمُ.',
  ];

  static const ayahDisplay =
      'قَالَ تَعَالَى ﴿فَاطِرُ ٱلسَّمَاوَاتِ وَٱلْأَرْضِ ۚ جَعَلَ لَكُم مِّنْ أَنفُسِكُمْ '
      'أَزْوَاجًا وَمِنَ ٱلْأَنْعَامِ أَزْوَاجًا يَذْرَؤُكُمْ فِيهِ ۚ لَيْسَ كَمِثْلِهِ شَيْءٌ ۖ '
      'وَهُوَ ٱلسَّمِيعُ ٱلْبَصِيرُ﴾';
  static const ayahRef = 'سورة الشورى، الآية ١١';
  // Surah/ayah numbers (Ash-Shura, 42:11) — used to fetch the real
  // recitation (Sheikh Mishary Alafasy) rather than synthesizing it.
  static const ayahSurahNum = 42;
  static const ayahNum = 11;

  static const vocab = [
    VocabItem('اللَّهُ', 'Allah – Nama Zat'),
    VocabItem('الرَّحْمَنُ', 'Maha Pemurah'),
    VocabItem('الرَّحِيمُ', 'Maha Penyayang'),
    VocabItem('الْعَلِيمُ', 'Maha Mengetahui'),
    VocabItem('الْخَبِيرُ', 'Maha Mendalam Ilmu-Nya'),
    VocabItem('السَّمِيعُ', 'Maha Mendengar'),
    VocabItem('الْبَصِيرُ', 'Maha Melihat'),
    VocabItem('الْعَزِيزُ', 'Maha Perkasa'),
  ];

  static const ruleFormula = 'الْجُمْلَةُ الاِسْمِيَّةُ = الْمُبْتَدَأُ + الْخَبَرُ';
  static const ruleP1 =
      'المبتدأ هو الاسم الذي يوضع ليُخبر عنه (يسند إليه)، مثل: اللهُ رَحِيمٌ. '
      '(اللهُ: مبتدأ أُخبر عنه بأنه "رَحِيمٌ").';
  static const ruleP2 =
      'الخبر هو ما يخبر به عن المبتدأ ليتمم معنى الجملة، مثل: اللهُ رَحِيمٌ. '
      '(رَحِيمٌ: اسم مرفوع خبر للمبتدأ "اللهُ").';

  static const matchNames = ['الرَّحْمَنُ', 'السَّمِيعُ', 'الْعَلِيمُ', 'الْبَصِيرُ', 'الْعَزِيزُ'];
  static const matchMeanings = ['Maha Perkasa', 'Maha Pemurah', 'Maha Melihat', 'Maha Mendengar', 'Maha Mengetahui'];
  static const matchAnswer = {
    'الرَّحْمَنُ': 'Maha Pemurah',
    'السَّمِيعُ': 'Maha Mendengar',
    'الْعَلِيمُ': 'Maha Mengetahui',
    'الْبَصِيرُ': 'Maha Melihat',
    'الْعَزِيزُ': 'Maha Perkasa',
  };

  static const fillBank = ['السَّمِيعُ', 'الرَّحِيمُ', 'الْعَلِيمُ', 'الرَّحْمَنُ', 'الإِلَهُ'];
  static const fillItems = [
    FillItem('اللَّهُ', 'يَرْحَمُ جَمِيعَ النَّاسِ', 'الرَّحْمَنُ'),
    FillItem('اللَّهُ', 'يَسْمَعُ كُلَّ دُعَاءٍ', 'السَّمِيعُ'),
    FillItem('اللَّهُ هُوَ', 'الحَقُّ', 'الإِلَهُ'),
    FillItem('اللَّهُ', 'يَعْلَمُ مَا فِي القُلُوبِ', 'الْعَلِيمُ'),
    FillItem('اللَّهُ', 'يَرْحَمُ عِبَادَهُ المُؤْمِنِينَ', 'الرَّحِيمُ'),
  ];

  static const transformPairs = [
    ('عَلِيمٌ', 'الْعَلِيمُ'),
    ('سَمِيعٌ', 'السَّمِيعُ'),
    ('بَصِيرٌ', 'الْبَصِيرُ'),
    ('عَزِيزٌ', 'الْعَزِيزُ'),
    ('حَكِيمٌ', 'الْحَكِيمُ'),
  ];

  static const wordOrder = [
    WordOrderItem(['يَرْحَمُ', 'اللَّهُ', 'عِبَادَهُ', 'الرَّحِيمُ'], 'اللَّهُ الرَّحِيمُ يَرْحَمُ عِبَادَهُ.'),
    WordOrderItem(['الحَقُّ', 'الإِلَهُ', 'هُوَ', 'اللَّهُ'], 'اللَّهُ هُوَ الإِلَهُ الحَقُّ.'),
    WordOrderItem(['شَيْءٍ', 'اللَّهُ', 'كُلَّ', 'الْعَلِيمُ', 'يَعْلَمُ'], 'اللَّهُ الْعَلِيمُ يَعْلَمُ كُلَّ شَيْءٍ.'),
  ];

  static const selfAssessItems = [
    'أنطق ستة أسماء من أسماء الله الحسنى بشكل صحيح. 🗣️',
    'أقرأ النص الأساسي وأفهم معانيه. 📖',
    'أكتب جملة بسيطة: الله + خبر. ✍️',
    'أفرق بين الاسم بـ"الـ" وبدون "الـ". 💡',
    'أذكر معنى ثلاثة أسماء من أسماء الله. 🌟',
    'أعبر عن إيماني بالله في جملة قصيرة. 👥',
  ];
}
