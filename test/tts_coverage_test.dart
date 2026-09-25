// Every reading line and vocab word must resolve to a bundled, existing
// audio file. Lines naming لفظ الجلالة are spliced clips (reciter + voice,
// see tool/audio/build_jalalah_lines.py) — never live synthesis.

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:rabbaniyyah_app/data/lesson_catalog.dart';
import 'package:rabbaniyyah_app/services/tts_service.dart';

void main() {
  test('all mapped audio files exist', () {
    final missing = TtsService.preRenderedAssets.values.toSet().where((p) => !File(p).existsSync()).toList();
    expect(missing, isEmpty);
  });

  test('every reading line and vocab word in all 12 lessons has audio', () {
    final gaps = <String>[];
    for (final l in kLessons) {
      for (var i = 0; i < l.readingLines.length; i++) {
        if (TtsService.assetFor(l.readingLines[i]) == null) gaps.add('Dars ${l.n} reading[$i]: ${l.readingLines[i]}');
      }
      for (var i = 0; i < l.vocab.length; i++) {
        if (TtsService.assetFor(l.vocab[i].word) == null) gaps.add('Dars ${l.n} vocab[$i]: ${l.vocab[i].word}');
      }
    }
    expect(gaps, isEmpty, reason: gaps.join('\n'));
  });

  test('the divine name is never left to the live voice', () {
    expect(TtsService.canSpeak('بِسْمِ اللهِ'), isFalse, reason: 'no clip → no button');
    expect(TtsService.canSpeak('اَلْقُرْآنُ كِتَابُ اللهِ، وَمُحَمَّدٌ رَسُولُ اللهِ.'), isTrue);
    expect(TtsService.canSpeak('نُورٌ'), isTrue);
  });
}
