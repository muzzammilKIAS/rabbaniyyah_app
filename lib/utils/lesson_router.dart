import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/lesson_catalog.dart';
import '../screens/dars_1_1_screen.dart';
import '../screens/dars_1_2_screen.dart';
import '../screens/dars_1_3_screen.dart';
import '../screens/dars_1_4_screen.dart';
import '../screens/dars_1_5_screen.dart';
import '../screens/dars_1_6_screen.dart';
import '../screens/dars_1_7_screen.dart';
import '../screens/dars_1_8_screen.dart';
import '../screens/dars_1_9_screen.dart';
import '../screens/dars_1_10_screen.dart';
import '../screens/dars_1_11_screen.dart';
import '../screens/dars_1_12_screen.dart';
import '../state/app_state.dart';

/// Maps each lesson to its own screen by lesson number (LessonRef.n),
/// not by list position.
Widget screenForLesson(int n) {
  return switch (n) {
    2 => const Dars112Screen(),
    3 => const Dars113Screen(),
    4 => const Dars114Screen(),
    5 => const Dars115Screen(),
    6 => const Dars116Screen(),
    7 => const Dars117Screen(),
    8 => const Dars118Screen(),
    9 => const Dars119Screen(),
    10 => const Dars1110Screen(),
    11 => const Dars1111Screen(),
    12 => const Dars1112Screen(),
    _ => const Dars111Screen(),
  };
}

/// Opens lesson [n]. With [replace] the current lesson page is swapped out
/// (previous/next navigation) so the back button still returns to the
/// unit list instead of walking back through every lesson visited.
Future<void> openLesson(BuildContext context, int n, {bool replace = false}) {
  if (lessonByN(n) == null) return Future.value();
  context.read<AppState>().markVisited(n);
  final route = MaterialPageRoute<void>(
    settings: RouteSettings(name: '/lesson/$n'),
    builder: (_) => screenForLesson(n),
  );
  final nav = Navigator.of(context);
  return replace ? nav.pushReplacement(route) : nav.push(route);
}
