import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';

/// Plays real Qur'an recitation audio (Sheikh Mishary Rashid Alafasy) for
/// a given ayah — never synthesized speech — sourced from everyayah.com's
/// per-ayah mp3 archive. Requires network access.
class QuranAudioService {
  final AudioPlayer _player = AudioPlayer();
  bool _playing = false;
  bool get isPlaying => _playing;

  String _urlFor(int surah, int ayah) {
    final s = surah.toString().padLeft(3, '0');
    final a = ayah.toString().padLeft(3, '0');
    return 'https://everyayah.com/data/Alafasy_128kbps/$s$a.mp3';
  }

  /// Plays the given ayah and waits for it to finish. Returns false (and
  /// leaves nothing playing) if playback couldn't start, e.g. no network.
  Future<bool> playAyah({required int surah, required int ayah}) async {
    _playing = true;
    try {
      await _player.setUrl(_urlFor(surah, ayah));
      await _player.play();
      // idle is included so a caller's stop() (which calls _player.stop(),
      // landing on idle rather than completed) actually unblocks this wait
      // instead of leaving it pending forever.
      await _player.playerStateStream.firstWhere(
        (s) => s.processingState == ProcessingState.completed || s.processingState == ProcessingState.idle,
      );
      return true;
    } catch (e) {
      debugPrint('QuranAudioService: failed to play $surah:$ayah ($e)');
      return false;
    } finally {
      _playing = false;
    }
  }

  Future<void> stop() => _player.stop();
}
