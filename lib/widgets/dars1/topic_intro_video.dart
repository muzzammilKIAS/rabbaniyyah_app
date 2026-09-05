import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_colors.dart';
import '../common.dart';

/// Short intro video for the topic, played from a bundled asset — never
/// streamed from a third-party site, so it stays free of unrelated
/// recommendations or ads for the student.
class TopicIntroVideo extends StatefulWidget {
  const TopicIntroVideo({super.key});

  @override
  State<TopicIntroVideo> createState() => _TopicIntroVideoState();
}

class _TopicIntroVideoState extends State<TopicIntroVideo> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset('assets/video/topik1.mp4')
      ..initialize().then((_) {
        if (mounted) setState(() => _ready = true);
      })
      ..addListener(_onTick);
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _controller.removeListener(_onTick);
    _controller.dispose();
    super.dispose();
  }

  void _togglePlay() {
    _controller.value.isPlaying ? _controller.pause() : _controller.play();
  }

  String _fmt(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final playing = _ready && _controller.value.isPlaying;
    final position = _ready ? _controller.value.position : Duration.zero;
    final duration = _ready ? _controller.value.duration : Duration.zero;

    return SectionCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CardHeading('🎬 مُقَدِّمَةُ الدَّرْسِ'),
          const CardInstruction('شَاهِدِ الفِيدْيُو القَصِيرَ قَبْلَ أَنْ تَبْدَأَ الدَّرْسَ.'),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AspectRatio(
              aspectRatio: _ready ? _controller.value.aspectRatio : 16 / 9,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  if (_ready)
                    VideoPlayer(_controller)
                  else
                    Container(
                      color: c.surface2,
                      child: Center(child: CircularProgressIndicator(color: c.accent)),
                    ),
                  if (_ready)
                    GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTap: _togglePlay,
                      child: AnimatedOpacity(
                        opacity: playing ? 0 : 1,
                        duration: const Duration(milliseconds: 200),
                        child: Container(
                          color: Colors.black.withValues(alpha: 0.25),
                          child: Center(
                            child: Container(
                              width: 64,
                              height: 64,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withValues(alpha: 0.92),
                              ),
                              child: Icon(Icons.play_arrow_rounded, size: 36, color: c.accent),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (_ready) ...[
            const SizedBox(height: 6),
            Row(
              children: [
                IconButton(
                  onPressed: _togglePlay,
                  icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: c.accent),
                ),
                Expanded(
                  child: SliderTheme(
                    data: SliderThemeData(
                      trackHeight: 3,
                      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                      overlayShape: SliderComponentShape.noOverlay,
                      activeTrackColor: c.accent,
                      inactiveTrackColor: c.border,
                      thumbColor: c.accent,
                    ),
                    child: Slider(
                      value: position.inMilliseconds
                          .clamp(0, duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds)
                          .toDouble(),
                      max: duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds.toDouble(),
                      onChanged: (v) => _controller.seekTo(Duration(milliseconds: v.round())),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Directionality(
                    // Plain LTR so the bidi algorithm doesn't reorder the
                    // two neutral "00:00" chunks around the slash.
                    textDirection: TextDirection.ltr,
                    child: Text('${_fmt(position)} / ${_fmt(duration)}',
                        style: TextStyle(fontSize: 11, color: c.textMuted)),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
