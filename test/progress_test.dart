import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rabbaniyyah_app/data/supplemental_exercises.dart';
import 'package:rabbaniyyah_app/services/quran_audio_service.dart';
import 'package:rabbaniyyah_app/services/storage_service.dart';
import 'package:rabbaniyyah_app/services/tts_service.dart';
import 'package:rabbaniyyah_app/state/app_state.dart';

Future<AppState> _fresh() async {
  final storage = await StorageService.create();
  return AppState(storage, TtsService(), QuranAudioService())..load();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('status moves from not started → in progress → completed', () async {
    final app = await _fresh();
    expect(app.lessonStatus(4), LessonStatus.notStarted);
    app.markVisited(4);
    expect(app.lessonStatus(4), LessonStatus.inProgress);
    expect(app.lastLesson, 4);
    app.setCompleted(4, true);
    expect(app.lessonStatus(4), LessonStatus.completed);
    expect(app.lessonProgress(4), 1);
  });

  test('exercise results keep the best score and drive progress and XP', () async {
    final app = await _fresh();
    final first = exercisesFor(2).first;
    app.recordExercise(2, first.id, score: 1, total: 3);
    app.recordExercise(2, first.id, score: 3, total: 3);
    app.recordExercise(2, first.id, score: 2, total: 3);
    final r = app.exerciseResult(2, first.id)!;
    expect(r.score, 3);
    expect(r.attempts, 3);
    expect(r.stars, 3);
    expect(app.exercisesDone(2), 1);
    expect(app.xp, 30);
    expect(app.lessonProgress(2), closeTo(0.5 / exercisesFor(2).length, 1e-9));
  });

  test('progress survives a reload (localStorage) and resets cleanly', () async {
    var app = await _fresh();
    app.toggleBookmark(7);
    app.setCompleted(1, true);
    app.recordExercise(1, 'quick', score: 3, total: 3);
    await Future<void>.delayed(Duration.zero);

    app = await _fresh(); // same mock prefs = page refresh
    expect(app.isBookmarked(7), isTrue);
    expect(app.isCompleted(1), isTrue);
    expect(app.exerciseResult(1, 'quick')?.score, 3);

    await app.resetLessonAll(1);
    expect(app.isCompleted(1), isFalse);
    expect(app.exerciseResult(1, 'quick'), isNull);
    expect(app.isBookmarked(7), isTrue, reason: 'resetting one lesson keeps other data');

    await app.resetAllProgress();
    expect(app.bookmarks, isEmpty);
    expect(app.xp, 0);
  });

  test('unit completes only when all its lessons are marked done', () async {
    final app = await _fresh();
    app.setCompleted(10, true);
    app.setCompleted(11, true);
    expect(app.unitCompleted(3), isFalse);
    app.setCompleted(12, true);
    expect(app.unitCompleted(3), isTrue);
  });

  test('corrupt stored progress does not crash loading', () async {
    SharedPreferences.setMockInitialValues({'rabbaniyyah_progress_v1': '{not json'});
    final app = await _fresh();
    expect(app.overallProgress, 0);
  });
}
