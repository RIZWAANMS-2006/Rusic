import 'package:just_audio/just_audio.dart';

class AudioManager {
  // Singleton Logic
  static final AudioManager _instance = AudioManager._internal();
  factory AudioManager() => _instance;
  AudioManager._internal();

  // Core Player
  final AudioPlayer _player = AudioPlayer();
  AudioPlayer get instance => _player;

  // State
  String? currentSongPath;
  bool get isPlaying => _player.playing;
  Stream<Duration> get positionStream => _player.positionStream;
  Duration get totalDuration => _player.duration ?? Duration.zero;

  // Main Logic
  Future<void> play(String path) async {
    try {
      currentSongPath = path;
      if (path.startsWith('http:') || path.startsWith('https:')) {
        await _player.setUrl(path); // Cloud
      } else {
        await _player.setAudioSource(AudioSource.uri(Uri.file(path))); // Local
      }
      _player.play();
    } catch (e) {
      print("Audio Error: $e");
    }
  }

  // Simple Controls
  Future<void> pause() => _player.pause();
  Future<void> resume() => _player.play();
  Future<void> seek(Duration pos) => _player.seek(pos);

  Future<void> stop() async {
    await _player.stop();
    currentSongPath = null;
  }
}
