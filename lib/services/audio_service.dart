import 'package:just_audio/just_audio.dart';

import 'progress_service.dart';

/// Plays bundled voiceover and sound-effect assets.
///
/// Lesson audio paths are resolved as assets/audio/{language}/{file}, so
/// switching language never touches lesson code.
class AudioService {
  AudioService(this._progress);

  final ProgressService _progress;
  final AudioPlayer _player = AudioPlayer();

  /// Play the voiceover for a lesson item in the current language.
  Future<void> playLesson(String audioFile) =>
      _play('assets/audio/${_progress.language.code}/$audioFile');

  /// Language-independent sound effects (quiz feedback).
  Future<void> playCorrect() => _play('assets/audio/fx/correct.m4a');
  Future<void> playTryAgain() => _play('assets/audio/fx/try_again.m4a');

  Future<void> _play(String assetPath) async {
    if (_progress.muted) return;
    try {
      await _player.stop();
      await _player.setAsset(assetPath);
      await _player.play();
    } catch (_) {
      // A missing/corrupt asset must never crash a toddler mid-lesson.
    }
  }

  void dispose() => _player.dispose();
}
