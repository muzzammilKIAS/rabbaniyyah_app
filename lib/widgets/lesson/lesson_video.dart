import 'package:flutter/material.dart';
import '../../data/lesson_catalog.dart';
import '../dars1/topic_intro_video.dart';

/// The lesson's intro video, taken from [kLessons]. A lesson without a
/// video renders nothing at all — no empty card, no placeholder.
class LessonVideo extends StatelessWidget {
  const LessonVideo({super.key, required this.lesson});
  final int lesson;

  @override
  Widget build(BuildContext context) {
    final meta = lessonByN(lesson);
    if (meta == null || !meta.hasVideo) return const SizedBox.shrink();
    return TopicIntroVideo(assetPath: meta.video!);
  }
}
