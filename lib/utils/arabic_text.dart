/// Strips Arabic diacritics (tashkeel/harakat) from [s], collapsing any
/// resulting double spaces. Used both for the "baris" show/hide toggle and
/// for lenient answer-checking where the student's tashkeel needn't be exact.
String stripTashkeel(String s) {
  final withoutMarks = s.replaceAll(
    RegExp(r'[ؐ-ًؚ-ٟۖ-ۜ۟-۪ۨ-ٰۭ]'),
    '',
  );
  return withoutMarks.replaceAll(RegExp(r'\s+'), ' ').trim();
}

const _arabicDigits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];

String toArabicNumerals(int n) {
  return n.toString().split('').map((d) {
    final i = int.tryParse(d);
    return i != null ? _arabicDigits[i] : d;
  }).join();
}
