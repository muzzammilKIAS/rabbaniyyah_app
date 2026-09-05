// Basic smoke test: the app boots and shows the splash screen title.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:rabbaniyyah_app/screens/splash_screen.dart';
import 'package:rabbaniyyah_app/services/quran_audio_service.dart';
import 'package:rabbaniyyah_app/services/storage_service.dart';
import 'package:rabbaniyyah_app/services/tts_service.dart';
import 'package:rabbaniyyah_app/state/app_state.dart';
import 'package:rabbaniyyah_app/theme/app_theme.dart';

void main() {
  testWidgets('Splash screen shows the app title', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final storage = await StorageService.create();
    final appState = AppState(storage, TtsService(), QuranAudioService())..load();

    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: appState,
        child: MaterialApp(theme: AppTheme.light, home: const SplashScreen()),
      ),
    );

    expect(find.textContaining('في رحاب اللغة العربية الربانية'), findsOneWidget);

    // Let the splash's delayed CTA timer and pulse animation settle so no
    // timers are left pending when the test tears down.
    await tester.pump(const Duration(seconds: 2));
  });
}
