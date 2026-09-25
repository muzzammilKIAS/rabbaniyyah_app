// Smoke test: every lesson screen, the unit list and search build without
// exceptions, show their title, and only lessons with a video get a player.

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rabbaniyyah_app/data/lesson_catalog.dart';
import 'package:rabbaniyyah_app/screens/search_screen.dart';
import 'package:rabbaniyyah_app/screens/semester1_screen.dart';
import 'package:rabbaniyyah_app/services/quran_audio_service.dart';
import 'package:rabbaniyyah_app/services/storage_service.dart';
import 'package:rabbaniyyah_app/services/tts_service.dart';
import 'package:rabbaniyyah_app/state/app_state.dart';
import 'package:rabbaniyyah_app/theme/app_theme.dart';
import 'package:rabbaniyyah_app/utils/lesson_router.dart';
import 'package:rabbaniyyah_app/widgets/dars1/topic_intro_video.dart';
import 'package:rabbaniyyah_app/widgets/exercises/supplemental_section.dart';

Future<AppState> _app() async {
  SharedPreferences.setMockInitialValues({});
  final storage = await StorageService.create();
  return AppState(storage, TtsService(), QuranAudioService())..load();
}

Future<void> _pump(WidgetTester tester, AppState app, Widget home, {Size size = const Size(1280, 900)}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(
    ChangeNotifierProvider.value(
      value: app,
      child: MaterialApp(theme: AppTheme.light, home: home),
    ),
  );
  await tester.pump(const Duration(milliseconds: 900));
}

/// Loads the app's real fonts so text is measured as in the browser (the
/// default test font draws every glyph as a wide box and fakes overflows).
Future<void> _loadFonts() async {
  const families = {
    'Amiri': ['assets/fonts/amiri/Amiri-Regular.ttf', 'assets/fonts/amiri/Amiri-Bold.ttf'],
    'AmiriQuran': ['assets/fonts/amiri_quran/AmiriQuran-Regular.ttf'],
    'Tajawal': ['assets/fonts/tajawal/Tajawal-Regular.ttf', 'assets/fonts/tajawal/Tajawal-Bold.ttf'],
  };
  for (final e in families.entries) {
    final loader = FontLoader(e.key);
    for (final f in e.value) {
      loader.addFont(Future.value(ByteData.sublistView(File(f).readAsBytesSync())));
    }
    await loader.load();
  }
  // Text with no explicit family (Material default) falls back to Tajawal.
  final roboto = FontLoader('Roboto')
    ..addFont(Future.value(ByteData.sublistView(File('assets/fonts/tajawal/Tajawal-Regular.ttf').readAsBytesSync())));
  await roboto.load();
}

void main() {
  setUpAll(_loadFonts);

  for (final l in kLessons) {
    testWidgets('lesson ${l.n} builds (desktop + phone)', (tester) async {
      final app = await _app();
      for (final size in const [Size(1280, 900), Size(390, 844)]) {
        await _pump(tester, app, screenForLesson(l.n), size: size);
        expect(tester.takeException(), isNull);
        expect(find.textContaining(l.ordinal), findsWidgets);
        expect(
          find.byType(TopicIntroVideo, skipOffstage: false),
          l.hasVideo ? findsOneWidget : findsNothing,
          reason: 'lesson ${l.n} video block',
        );
        expect(find.byType(SupplementalSection, skipOffstage: false), findsOneWidget);
      }
      expect(app.isVisited(l.n), isTrue);
    });
  }

  testWidgets('unit list and search build', (tester) async {
    final app = await _app();
    await _pump(tester, app, const Semester1Screen());
    expect(tester.takeException(), isNull);
    expect(find.text('الوحدة الأولى'), findsOneWidget);
    expect(find.text('Belum mula'), findsWidgets);

    await _pump(tester, app, const SearchScreen(), size: const Size(390, 844));
    await tester.enterText(find.byType(TextField), 'الرحمن');
    await tester.pump();
    expect(find.textContaining('الرَّحْمَنُ'), findsWidgets);
    expect(tester.takeException(), isNull);
  });

  testWidgets('quick check: wrong answer shows "Cuba lagi", full set records a result', (tester) async {
    final app = await _app();
    await _pump(tester, app, screenForLesson(4));
    // Lesson 4 quick check: answers شَرْطٌ, المِرْفَقَيْنِ, نَمْسَحُ; distractors رُكْنٌ, الكَعْبَيْنِ, نَغْسِلُ.
    Future<void> tapText(String t) async {
      final f = find.text(t, skipOffstage: false).last;
      await tester.ensureVisible(f);
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(f);
      await tester.pump(const Duration(milliseconds: 300));
    }

    await tapText('رُكْنٌ');
    expect(find.text('Cuba lagi', skipOffstage: false), findsOneWidget);
    await tapText('شَرْطٌ');
    await tapText('المِرْفَقَيْنِ');
    expect(app.exerciseResult(4, 'quick'), isNull, reason: 'not all questions answered yet');
    await tapText('نَمْسَحُ');
    final r = app.exerciseResult(4, 'quick');
    expect(r, isNotNull);
    expect(r!.score, 2, reason: 'first question needed a second try');
    expect(find.text('✓ Betul', skipOffstage: false), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
