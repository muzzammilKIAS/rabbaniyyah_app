import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/quran_audio_service.dart';
import 'services/storage_service.dart';
import 'services/tts_service.dart';
import 'state/app_state.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final storage = await StorageService.create();
  final tts = TtsService();
  final quranAudio = QuranAudioService();
  final appState = AppState(storage, tts, quranAudio)..load();

  // TTS init talks to the platform's speech engine; don't block first paint.
  tts.init();

  runApp(
    ChangeNotifierProvider.value(
      value: appState,
      child: const RabbaniyyahApp(),
    ),
  );
}

class RabbaniyyahApp extends StatelessWidget {
  const RabbaniyyahApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeMode = context.watch<AppState>().themeMode;
    return MaterialApp(
      title: 'في رحاب اللغة العربية الربانية',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      locale: const Locale('ar'),
      supportedLocales: const [Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: const SplashScreen(),
    );
  }
}
