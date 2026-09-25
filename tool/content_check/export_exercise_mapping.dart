// Regenerates EXERCISE_MAPPING.md from lib/data/supplemental_exercises.dart
// so the document always matches what the app actually shows.
//
//   dart run tool/content_check/export_exercise_mapping.dart

import 'dart:io';

import 'package:rabbaniyyah_app/data/curriculum.dart';
import 'package:rabbaniyyah_app/data/exercise_models.dart';
import 'package:rabbaniyyah_app/data/supplemental_exercises.dart';

String _items(ExerciseSpec e) => switch (e) {
      McqExercise() => '${e.questions.length} soalan',
      TrueFalseExercise() => '${e.items.length} pernyataan',
      CategorizeExercise() => '${e.items.length} item → ${e.categories.map((c) => '«$c»').join(' / ')}',
      SequenceExercise() => '${e.correctOrder.length} item',
      FlashcardExercise() => '${e.cards.length} kad',
      PairMatchExercise() => '${e.pairs.length} pasangan',
    };

void main() {
  final b = StringBuffer()
    ..writeln('# EXERCISE_MAPPING — Aktiviti Pengukuhan (تدريبات إضافية)')
    ..writeln()
    ..writeln('> Fail ini dijana automatik daripada `lib/data/supplemental_exercises.dart`.')
    ..writeln('> Jana semula: `dart run tool/content_check/export_exercise_mapping.dart`')
    ..writeln()
    ..writeln('Dua jenis latihan:')
    ..writeln('- **Dari teks dars**: teks Arab diambil verbatim daripada `lib/data/curriculum.dart` (baris bacaan,')
    ..writeln('  kosa kata, jadual kaedah, jadual أحلل وأطبق). `test/supplemental_exercises_test.dart` menguatkuasakannya.')
    ..writeln('- **Dikarang baharu** (ditanda ✎): pernyataan kefahaman Betul/Salah dan ayat aplikasi kaedah yang ditulis')
    ..writeln('  khusus untuk latihan. Teks silibus asal tidak diubah.')
    ..writeln();
  var total = 0;
  for (final unit in kSemester1Units) {
    b
      ..writeln('# ${unit.title}: ${unit.topic}')
      ..writeln();
    for (final l in unit.lessons) {
      final ex = exercisesFor(l.n);
      total += ex.length;
      b
        ..writeln('## Dars ${l.n} — ${l.title}')
        ..writeln()
        ..writeln('| # | Jenis | Tajuk kad | Kandungan | Sumber asal | Tujuan pembelajaran |')
        ..writeln('|---|---|---|---|---|---|');
      for (var i = 0; i < ex.length; i++) {
        final e = ex[i];
        b.writeln('| ${i + 1} | ${e.kindLabel}${e.authored ? ' ✎' : ''} | ${e.title} | ${_items(e)} | ${e.source} | ${e.purpose} |');
      }
      b.writeln();
    }
  }
  b.writeln('---');
  b.writeln('Jumlah: $total aktiviti untuk 12 dars.');
  File('EXERCISE_MAPPING.md').writeAsStringSync(b.toString());
  stdout.writeln('EXERCISE_MAPPING.md: $total activities');
}
