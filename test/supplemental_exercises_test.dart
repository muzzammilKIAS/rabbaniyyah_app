// Guards the supplemental exercises. Exercises built from the lesson text
// must quote it verbatim: every Arabic string (and Malay vocab meaning) they
// show must exist in lib/data/curriculum.dart. Newly written practice
// (`authored: true`) is exempt from that, but still structurally checked.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rabbaniyyah_app/data/exercise_models.dart';
import 'package:rabbaniyyah_app/data/lesson_catalog.dart';
import 'package:rabbaniyyah_app/data/supplemental_exercises.dart';

final _arabic = RegExp(r'[؀-ۿ]');
final _guillemets = RegExp(r'«([^»]+)»');

void main() {
  final source = File('lib/data/curriculum.dart').readAsStringSync();

  /// Arabic text must appear verbatim in curriculum.dart. Mixed Malay text
  /// must wrap its Arabic in «…»; a cloze prompt is checked piece by piece.
  void expectFromSource(String s, String where) {
    if (!_arabic.hasMatch(s)) return;
    if (s.contains('«')) {
      for (final m in _guillemets.allMatches(s)) {
        expect(source.contains(m.group(1)!), isTrue, reason: '$where: «${m.group(1)}» not in curriculum.dart');
      }
      final outside = s.replaceAll(_guillemets, '');
      expect(_arabic.hasMatch(outside), isFalse, reason: '$where: Arabic outside «» in "$s"');
      return;
    }
    for (final part in s.split(McqQuestion.blank)) {
      final p = part.trim();
      if (p.isEmpty) continue;
      expect(source.contains(p), isTrue, reason: '$where: "$p" not in curriculum.dart');
    }
  }

  test('every lesson 1–12 has a quick check and 2–5 further activities', () {
    for (final l in kLessons) {
      final ex = exercisesFor(l.n);
      expect(ex.length, inInclusiveRange(3, 6), reason: 'lesson ${l.n}');
      expect(
        ex.first is McqExercise && (ex.first as McqExercise).isQuickCheck,
        isTrue,
        reason: 'lesson ${l.n} should open with a quick check',
      );
      final ids = ex.map((e) => e.id).toSet();
      expect(ids.length, ex.length, reason: 'duplicate exercise id in lesson ${l.n}');
    }
  });

  test('exercise content is taken from the original lesson text', () {
    kSupplementalExercises.forEach((n, list) {
      for (final e in list.where((e) => !e.authored)) {
        final w = 'lesson $n/${e.id}';
        switch (e) {
          case McqExercise():
            for (final q in e.questions) {
              expect(q.answer, inInclusiveRange(0, q.options.length - 1), reason: w);
              expect(q.options.toSet().length, q.options.length, reason: '$w duplicate options');
              expectFromSource(q.prompt, w);
              for (final o in q.options) {
                if (e.optionsAreArabic) {
                  expectFromSource(o, w);
                } else {
                  expect(source.contains(o), isTrue, reason: '$w: meaning "$o" not in curriculum.dart');
                }
              }
            }
          case TrueFalseExercise():
            for (final i in e.items) {
              expectFromSource(i.term, w);
              expect(source.contains(i.claim), isTrue, reason: '$w: "${i.claim}"');
            }
          case CategorizeExercise():
            expect(e.categories.length, greaterThanOrEqualTo(2), reason: w);
            for (final cat in e.categories) {
              expectFromSource(cat, w);
            }
            for (final i in e.items) {
              expect(i.category, inInclusiveRange(0, e.categories.length - 1), reason: w);
              expectFromSource(i.text, w);
            }
            for (var k = 0; k < e.categories.length; k++) {
              expect(e.items.any((i) => i.category == k), isTrue, reason: '$w: empty category $k');
            }
          case SequenceExercise():
            expect(e.correctOrder.length, greaterThanOrEqualTo(3), reason: w);
            expect(e.correctOrder.toSet().length, e.correctOrder.length, reason: '$w duplicate items');
            for (final s in e.correctOrder) {
              expectFromSource(s, w);
            }
          case FlashcardExercise():
            expect(e.cards, isNotEmpty, reason: w);
            for (final v in e.cards) {
              expectFromSource(v.word, w);
              expect(source.contains(v.meaning), isTrue, reason: w);
            }
          case PairMatchExercise():
            for (final (a, b) in e.pairs) {
              expectFromSource(a, w);
              e.rightIsArabic ? expectFromSource(b, w) : expect(source.contains(b), isTrue, reason: w);
            }
        }
      }
    });
  });

  test('cloze quick checks blank out part of an original reading line', () {
    kSupplementalExercises.forEach((n, list) {
      final lines = lessonByN(n)!.readingLines;
      final quick = list.first as McqExercise;
      for (final q in quick.questions.where((q) => q.prompt.contains(McqQuestion.blank))) {
        final filled = q.prompt.replaceFirst(McqQuestion.blank, q.options[q.answer]);
        final fromReading = lines.contains(filled);
        final fromOtherSource = source.contains(filled.replaceAll(McqQuestion.blank, ''));
        expect(fromReading || fromOtherSource, isTrue, reason: 'lesson $n: "$filled"');
      }
    });
  });

  test('newly written practice is well-formed', () {
    final authored = [for (final l in kSupplementalExercises.values) ...l.where((e) => e.authored)];
    expect(authored, isNotEmpty);
    for (final e in authored) {
      switch (e) {
        case McqExercise():
          for (final q in e.questions) {
            expect(q.answer, inInclusiveRange(0, q.options.length - 1), reason: e.id);
            expect(q.options.toSet().length, q.options.length, reason: e.id);
            expect(q.prompt.contains(McqQuestion.blank) || q.prompt.contains('?'), isTrue, reason: e.id);
          }
        case TrueFalseExercise():
          expect(
            e.items.any((i) => i.isTrue) && e.items.any((i) => !i.isTrue),
            isTrue,
            reason: '${e.id}: needs both true and false statements',
          );
          for (final i in e.items) {
            expect(_arabic.hasMatch(i.term), isTrue, reason: e.id);
          }
        default:
          break;
      }
    }
  });

  test('stars scale with score', () {
    expect(starsFor(3, 3), 3);
    expect(starsFor(2, 3), 2);
    expect(starsFor(1, 3), 1);
    expect(starsFor(0, 0), 0);
  });
}
