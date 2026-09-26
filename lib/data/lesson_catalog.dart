import 'curriculum.dart';

/// One place that knows every lesson of Semester 1: which unit it belongs
/// to, its storage id, and which optional media it has.
///
/// ─── Adding a video later ───────────────────────────────────────────────
/// Drop the file in assets/video/ and set `video:` on the lesson below,
/// e.g. `video: 'assets/video/topik10.mp4'`. The lesson page, its projector
/// slide and the unit list all pick it up automatically. A lesson with
/// `video: null` simply renders no video block — never a placeholder.
/// ─────────────────────────────────────────────────────────────────────
class LessonMeta {
  const LessonMeta({
    required this.n,
    required this.id,
    required this.unit,
    required this.ordinal,
    required this.selfAssessCount,
    required this.readingLines,
    required this.vocab,
    this.video,
  });

  /// Lesson number in the book (1–12).
  final int n;

  /// Storage id used by [AppState] for this lesson's answers ('111' …).
  final String id;

  /// Index into [kSemester1Units].
  final int unit;

  /// 'الدرس الأول' … — the ordinal heading already used across the app.
  final String ordinal;

  /// Bundled intro video, or null when the lesson has none yet.
  final String? video;

  final int selfAssessCount;

  /// References to the lesson's own text (for search) — never copies.
  final List<String> readingLines;
  final List<VocabItem> vocab;

  UnitInfo get unitInfo => kSemester1Units[unit];
  LessonRef get ref => unitInfo.lessons.firstWhere((l) => l.n == n);
  String get title => ref.title;
  bool get hasVideo => video != null && video!.isNotEmpty;
}

final List<LessonMeta> kLessons = [
  LessonMeta(
    n: 1,
    id: '111',
    unit: 0,
    ordinal: 'الدرس الأول',
    video: 'assets/video/topik1.mp4',
    selfAssessCount: Dars111.selfAssessItems.length,
    readingLines: Dars111.readingLines,
    vocab: Dars111.vocab,
  ),
  LessonMeta(
    n: 2,
    id: '112',
    unit: 0,
    ordinal: 'الدرس الثاني',
    video: 'assets/video/topik2.mp4',
    selfAssessCount: Dars112.selfAssessItems.length,
    readingLines: Dars112.readingLines,
    vocab: Dars112.vocab,
  ),
  LessonMeta(
    n: 3,
    id: '113',
    unit: 0,
    ordinal: 'الدرس الثالث',
    video: 'assets/video/topik3.mp4',
    selfAssessCount: Dars113.selfAssessItems.length,
    readingLines: Dars113.readingLines,
    vocab: Dars113.vocab,
  ),
  LessonMeta(
    n: 4,
    id: '114',
    unit: 1,
    ordinal: 'الدرس الرابع',
    video: 'assets/video/topik4.mp4',
    selfAssessCount: Dars114.selfAssessItems.length,
    readingLines: Dars114.readingLines,
    vocab: Dars114.vocab,
  ),
  LessonMeta(
    n: 5,
    id: '115',
    unit: 1,
    ordinal: 'الدرس الخامس',
    video: 'assets/video/topik5.mp4',
    selfAssessCount: Dars115.selfAssessItems.length,
    readingLines: Dars115.readingLines,
    vocab: Dars115.vocab,
  ),
  LessonMeta(
    n: 6,
    id: '116',
    unit: 1,
    ordinal: 'الدرس السادس',
    video: 'assets/video/topik6.mp4',
    selfAssessCount: Dars116.selfAssessItems.length,
    readingLines: Dars116.readingLines,
    vocab: Dars116.vocab,
  ),
  LessonMeta(
    n: 7,
    id: '117',
    unit: 2,
    ordinal: 'الدرس السابع',
    video: 'assets/video/topik7.mp4',
    selfAssessCount: Dars117.selfAssessItems.length,
    readingLines: Dars117.readingLines,
    vocab: Dars117.vocab,
  ),
  LessonMeta(
    n: 8,
    id: '118',
    unit: 2,
    ordinal: 'الدرس الثامن',
    video: 'assets/video/topik8.mp4',
    selfAssessCount: Dars118.selfAssessItems.length,
    readingLines: Dars118.readingLines,
    vocab: Dars118.vocab,
  ),
  LessonMeta(
    n: 9,
    id: '119',
    unit: 2,
    ordinal: 'الدرس التاسع',
    video: 'assets/video/topik9.mp4',
    selfAssessCount: Dars119.selfAssessItems.length,
    readingLines: Dars119.readingLines,
    vocab: Dars119.vocab,
  ),
  // Lessons 10–12: text videos built in tool/video (build_scenes.py).
  LessonMeta(
    n: 10,
    id: '1110',
    unit: 3,
    ordinal: 'الدرس العاشر',
    video: 'assets/video/topik10.mp4',
    selfAssessCount: Dars1110.selfAssessItems.length,
    readingLines: Dars1110.readingLines,
    vocab: Dars1110.vocab,
  ),
  LessonMeta(
    n: 11,
    id: '1111',
    unit: 3,
    ordinal: 'الدرس الحادي عشر',
    video: 'assets/video/topik11.mp4',
    selfAssessCount: Dars1111.selfAssessItems.length,
    readingLines: Dars1111.readingLines,
    vocab: Dars1111.vocab,
  ),
  LessonMeta(
    n: 12,
    id: '1112',
    unit: 3,
    ordinal: 'الدرس الثاني عشر',
    video: 'assets/video/topik12.mp4',
    selfAssessCount: Dars1112.selfAssessItems.length,
    readingLines: Dars1112.readingLines,
    vocab: Dars1112.vocab,
  ),
];

/// Lookup by lesson number; null for an unknown number (bad route/data).
LessonMeta? lessonByN(int n) {
  for (final l in kLessons) {
    if (l.n == n) return l;
  }
  return null;
}

List<LessonMeta> lessonsInUnit(int unit) => kLessons.where((l) => l.unit == unit).toList();
