import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../../theme/app_colors.dart';
import '../common.dart';

/// Short intro video for the topic, played from a bundled asset — never
/// streamed from a third-party site, so it stays free of unrelated
/// recommendations or ads for the student.
class TopicIntroVideo extends StatefulWidget {
  const TopicIntroVideo({super.key, this.assetPath = 'assets/video/topik1.mp4'});

  final String assetPath;

  @override
  State<TopicIntroVideo> createState() => _TopicIntroVideoState();
}

class _TopicIntroVideoState extends State<TopicIntroVideo> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.asset(widget.assetPath)
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

  void _openProjectorMode() {
    Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        transitionDuration: const Duration(milliseconds: 220),
        pageBuilder: (_, anim, _) => FadeTransition(
          opacity: anim,
          child: _ProjectorVideoView(controller: _controller, fmt: _fmt),
        ),
      ),
    );
  }

  static String _fmt(Duration d) {
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
                  padding: const EdgeInsets.only(left: 4),
                  child: Directionality(
                    // Plain LTR so the bidi algorithm doesn't reorder the
                    // two neutral "00:00" chunks around the slash.
                    textDirection: TextDirection.ltr,
                    child: Text('${_fmt(position)} / ${_fmt(duration)}',
                        style: TextStyle(fontSize: 11, color: c.textMuted)),
                  ),
                ),
                IconButton(
                  tooltip: 'تكبير الفيديو — وضع العارض',
                  onPressed: _openProjectorMode,
                  icon: Icon(Icons.fullscreen_rounded, color: c.accent),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Full-screen playback for classroom projectors — shares the same
/// [VideoPlayerController] as the inline card, so play/pause/seek state
/// carries over seamlessly in both directions.
class _ProjectorVideoView extends StatefulWidget {
  const _ProjectorVideoView({required this.controller, required this.fmt});
  final VideoPlayerController controller;
  final String Function(Duration) fmt;

  @override
  State<_ProjectorVideoView> createState() => _ProjectorVideoViewState();
}

class _ProjectorVideoViewState extends State<_ProjectorVideoView> {
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTick);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTick);
    super.dispose();
  }

  void _onTick() {
    if (mounted) setState(() {});
  }

  void _togglePlay() {
    widget.controller.value.isPlaying ? widget.controller.pause() : widget.controller.play();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final playing = controller.value.isPlaying;
    final position = controller.value.position;
    final duration = controller.value.duration;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => setState(() => _showControls = !_showControls),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Center(
                child: AspectRatio(
                  aspectRatio: controller.value.aspectRatio,
                  child: VideoPlayer(controller),
                ),
              ),
              AnimatedOpacity(
                opacity: _showControls ? 1 : 0,
                duration: const Duration(milliseconds: 200),
                child: IgnorePointer(
                  ignoring: !_showControls,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 8,
                        left: 8,
                        child: IconButton(
                          tooltip: 'إغلاق وضع العارض',
                          onPressed: () => Navigator.of(context).pop(),
                          icon: const Icon(Icons.fullscreen_exit_rounded, color: Colors.white, size: 32),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black87],
                            ),
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: _togglePlay,
                                icon: Icon(playing ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 32),
                              ),
                              Expanded(
                                child: SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 3,
                                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                                    overlayShape: SliderComponentShape.noOverlay,
                                    activeTrackColor: Colors.white,
                                    inactiveTrackColor: Colors.white24,
                                    thumbColor: Colors.white,
                                  ),
                                  child: Slider(
                                    value: position.inMilliseconds
                                        .clamp(0, duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds)
                                        .toDouble(),
                                    max: duration.inMilliseconds == 0 ? 1 : duration.inMilliseconds.toDouble(),
                                    onChanged: (v) => controller.seekTo(Duration(milliseconds: v.round())),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Directionality(
                                  textDirection: TextDirection.ltr,
                                  child: Text('${widget.fmt(position)} / ${widget.fmt(duration)}',
                                      style: const TextStyle(fontSize: 13, color: Colors.white70)),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (!playing)
                Center(
                  child: GestureDetector(
                    onTap: _togglePlay,
                    child: Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white.withValues(alpha: 0.92)),
                      child: const Icon(Icons.play_arrow_rounded, size: 48, color: Colors.black87),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
