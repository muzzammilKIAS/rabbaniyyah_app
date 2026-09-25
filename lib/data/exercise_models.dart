import 'curriculum.dart';

/// Data model for the supplemental ("Aktiviti Pengukuhan") exercises.
///
/// Every exercise is plain data; the widgets in lib/widgets/exercises/
/// render any of them. Arabic strings in an exercise must be taken from
/// the lesson's own text in curriculum.dart (test/supplemental_exercises_
/// test.dart enforces this), so an exercise can reinforce the lesson but
/// never introduce new academic content.
sealed class ExerciseSpec {
  const ExerciseSpec({
    required this.id,
    required this.title,
    required this.instruction,
    required this.source,
    required this.purpose,
    this.authored = false,
  });

  /// Stable id, unique within a lesson — the progress key.
  final String id;

  /// Short Arabic heading for the card.
  final String title;

  /// What to do, in Malay (the students' language of instruction).
  final String instruction;

  /// Which part of the original lesson the items come from (documentation
  /// only — rendered as a small "Sumber" note and listed in
  /// EXERCISE_MAPPING.md).
  final String source;

  /// Learning purpose, in Malay (documentation + tooltip).
  final String purpose;

  /// True for exercises whose sentences were newly written for practice
  /// (not quoted verbatim from curriculum.dart). The lesson text itself is
  /// never edited; only these practice items are new.
  final bool authored;

  String get kindLabel;
}

class McqQuestion {
  const McqQuestion({required this.prompt, required this.options, required this.answer, this.promptIsArabic = true});

  /// The stem. When [blank] appears in it, it is rendered as a gap.
  final String prompt;
  final List<String> options;

  /// Index into [options].
  final int answer;
  final bool promptIsArabic;

  static const blank = '____';
}

/// Multiple choice (also used for the "Semakan Pantas" quick check).
class McqExercise extends ExerciseSpec {
  const McqExercise({
    required super.id,
    required super.title,
    required super.instruction,
    required super.source,
    required super.purpose,
    super.authored,
    required this.questions,
    this.optionsAreArabic = true,
    this.isQuickCheck = false,
  });

  final List<McqQuestion> questions;
  final bool optionsAreArabic;
  final bool isQuickCheck;

  @override
  String get kindLabel => isQuickCheck ? 'Semakan Pantas' : 'Aneka Pilihan';
}

class TrueFalseItem {
  const TrueFalseItem({required this.term, required this.claim, required this.isTrue});

  /// A whole Arabic sentence to judge, with no separate claim.
  const TrueFalseItem.statement(this.term, {required this.isTrue}) : claim = '';

  /// Arabic word/phrase from the lesson.
  final String term;

  /// What is claimed about it (a Malay meaning from the lesson vocab, or an
  /// Arabic phrase from the lesson).
  final String claim;
  final bool isTrue;
}

class TrueFalseExercise extends ExerciseSpec {
  const TrueFalseExercise({
    required super.id,
    required super.title,
    required super.instruction,
    required super.source,
    required super.purpose,
    super.authored,
    required this.items,
    this.claimIsArabic = false,
  });

  final List<TrueFalseItem> items;
  final bool claimIsArabic;

  @override
  String get kindLabel => 'Betul / Salah';
}

class CategorizeItem {
  const CategorizeItem(this.text, this.category);
  final String text;

  /// Index into [CategorizeExercise.categories].
  final int category;
}

class CategorizeExercise extends ExerciseSpec {
  const CategorizeExercise({
    required super.id,
    required super.title,
    required super.instruction,
    required super.source,
    required super.purpose,
    super.authored,
    required this.categories,
    required this.items,
  });

  final List<String> categories;
  final List<CategorizeItem> items;

  @override
  String get kindLabel => 'Kategori';
}

class SequenceExercise extends ExerciseSpec {
  const SequenceExercise({
    required super.id,
    required super.title,
    required super.instruction,
    required super.source,
    required super.purpose,
    super.authored,
    required this.correctOrder,
  });

  /// Items in the correct order; the widget shuffles them.
  final List<String> correctOrder;

  @override
  String get kindLabel => 'Susun Urutan';
}

class FlashcardExercise extends ExerciseSpec {
  const FlashcardExercise({
    required super.id,
    required super.title,
    required super.instruction,
    required super.source,
    required super.purpose,
    super.authored,
    required this.cards,
  });

  final List<VocabItem> cards;

  @override
  String get kindLabel => 'Kad Imbas';
}

class PairMatchExercise extends ExerciseSpec {
  const PairMatchExercise({
    required super.id,
    required super.title,
    required super.instruction,
    required super.source,
    required super.purpose,
    super.authored,
    required this.pairs,
    this.rightIsArabic = false,
  });

  /// (Arabic prompt, its correct match).
  final List<(String, String)> pairs;
  final bool rightIsArabic;

  @override
  String get kindLabel => 'Padanan';
}

/// Stars for a best score: 3 = all correct first time, 2 = most, 1 = done.
int starsFor(int score, int total) {
  if (total <= 0) return 0;
  final r = score / total;
  if (r >= 1) return 3;
  if (r >= 0.6) return 2;
  return 1;
}
