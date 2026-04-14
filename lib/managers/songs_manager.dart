import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:just_audio/just_audio.dart';
import 'package:Rusic/managers/audio_manager.dart';
import 'package:Rusic/managers/video_manager.dart';

enum RepeatMode { off, all, one }

class QueueItem {
  final String id;
  final String title;
  final String path;
  final String? artist;
  final String? source;

  QueueItem({
    required this.id,
    required this.title,
    required this.path,
    this.artist,
    this.source,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is QueueItem &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          path == other.path;

  @override
  int get hashCode => id.hashCode ^ path.hashCode;
}

class SongsManager extends ChangeNotifier {
  static final SongsManager _instance = SongsManager._internal();
  factory SongsManager() => _instance;

  SongsManager._internal() {
    // Listen to the audio player's state to auto-play the next song when finished
    AudioManager().instance.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        playNext(isAutoPlay: true);
      }
    });
  }

  List<QueueItem> _originalQueue = [];
  List<QueueItem> _currentQueue = [];
  int _currentIndex = -1;

  bool _isShuffle = false;
  RepeatMode _repeatMode = RepeatMode.off;

  // Getters
  List<QueueItem> get currentQueue => _currentQueue;
  int get currentIndex => _currentIndex;
  bool get isShuffle => _isShuffle;
  RepeatMode get repeatMode => _repeatMode;

  QueueItem? get currentSong =>
      (_currentIndex >= 0 && _currentIndex < _currentQueue.length)
      ? _currentQueue[_currentIndex]
      : null;

  /// Set a new queue and start playing a specific song
  Future<void> setQueue({
    required List<QueueItem> queue,
    int startIndex = 0,
  }) async {
    if (queue.isEmpty) return;

    _originalQueue = List.from(queue);

    if (_isShuffle) {
      final startingSong = _originalQueue[startIndex];
      _currentQueue = List.from(_originalQueue)..shuffle(Random());
      // Ensure the selected song is the first one playing
      _currentQueue.remove(startingSong);
      _currentQueue.insert(0, startingSong);
      _currentIndex = 0;
    } else {
      _currentQueue = List.from(_originalQueue);
      _currentIndex = startIndex;
    }

    notifyListeners();
    await _playCurrent();
  }

  /// Add a single song to the end of the queue
  void addToQueue(QueueItem item) {
    if (!_originalQueue.contains(item)) {
      _originalQueue.add(item);
    }
    if (!_currentQueue.contains(item)) {
      _currentQueue.add(item);
      notifyListeners();
    }
  }

  /// Reorder the current queue
  void reorderQueue(int oldIndex, int newIndex) {
    if (oldIndex < 0 ||
        oldIndex >= _currentQueue.length ||
        newIndex < 0 ||
        newIndex > _currentQueue.length) {
      return;
    }

    final item = _currentQueue.removeAt(oldIndex);
    _currentQueue.insert(newIndex, item);

    if (_currentIndex == oldIndex) {
      _currentIndex = newIndex;
    } else if (_currentIndex > oldIndex && _currentIndex <= newIndex) {
      _currentIndex--;
    } else if (_currentIndex < oldIndex && _currentIndex >= newIndex) {
      _currentIndex++;
    }

    notifyListeners();
  }

  /// Insert a song to play right after the current one (Play Next)
  void insertNext(QueueItem item) {
    // Remove if it exists elsewhere to avoid duplicates, or just insert.
    _currentQueue.remove(item);
    _originalQueue.remove(item);

    if (_currentIndex >= 0 && _currentIndex < _currentQueue.length) {
      _currentQueue.insert(_currentIndex + 1, item);
    } else {
      _currentQueue.add(item);
    }

    // Also manage original queue roughly right after the current standard item
    if (currentSong != null) {
      final originalIndex = _originalQueue.indexOf(currentSong!);
      if (originalIndex != -1) {
        _originalQueue.insert(originalIndex + 1, item);
      } else {
        _originalQueue.add(item);
      }
    } else {
      _originalQueue.add(item);
    }

    notifyListeners();
  }

  /// Go to the next song
  Future<void> playNext({bool isAutoPlay = false}) async {
    if (_currentQueue.isEmpty) return;

    if (isAutoPlay && _repeatMode == RepeatMode.one) {
      // Loop single song
      await _playCurrent();
      return;
    }

    if (_currentIndex < _currentQueue.length - 1) {
      _currentIndex++;
      notifyListeners();
      await _playCurrent();
    } else {
      // Reached the end of the queue
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = 0;
        notifyListeners();
        await _playCurrent();
      } else {
        // Stop or just pause at the end
        await AudioManager().stop();
      }
    }
  }

  /// Go to the previous song
  Future<void> playPrevious() async {
    if (_currentQueue.isEmpty) return;

    // If more than 3 seconds in, just restart the song (Spotify logic)
    if (AudioManager().instance.position.inSeconds > 3) {
      await AudioManager().seek(Duration.zero);
      return;
    }

    if (_currentIndex > 0) {
      _currentIndex--;
      notifyListeners();
      await _playCurrent();
    } else {
      // If at the first song, maybe go to the last song if repeating all?
      if (_repeatMode == RepeatMode.all) {
        _currentIndex = _currentQueue.length - 1;
        notifyListeners();
        await _playCurrent();
      } else {
        await AudioManager().seek(Duration.zero);
      }
    }
  }

  /// Toggle shuffle state
  void toggleShuffle() {
    _isShuffle = !_isShuffle;

    if (_currentQueue.isEmpty) {
      notifyListeners();
      return;
    }

    if (_isShuffle) {
      final activeSong = _currentQueue[_currentIndex];
      _currentQueue = List.from(_originalQueue)..shuffle(Random());

      // Move current song to the top of the shuffled queue
      _currentQueue.remove(activeSong);
      _currentQueue.insert(0, activeSong);
      _currentIndex = 0;
    } else {
      // Restore original queue order
      final activeSong = _currentQueue[_currentIndex];
      _currentQueue = List.from(_originalQueue);
      _currentIndex = _currentQueue.indexOf(activeSong);
      if (_currentIndex == -1) _currentIndex = 0; // Fallback
    }

    notifyListeners();
  }

  /// Toggle repeat state (Off -> All -> One -> Off)
  void toggleRepeat() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        break;
    }
    notifyListeners();
  }

  Future<void> _playCurrent() async {
    if (_currentIndex >= 0 && _currentIndex < _currentQueue.length) {
      final song = _currentQueue[_currentIndex];
      // Dispose old video if active
      VideoManager().disposeVideo();
      await AudioManager().play(song.path);
      // Initialize new video if compatible
      VideoManager().initializeVideo();
    }
  }
}
