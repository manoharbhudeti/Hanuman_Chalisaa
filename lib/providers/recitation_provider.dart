import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Manages silent guided auto-scroll progression across the 43 verses
class RecitationProvider extends ChangeNotifier {
  static const int baseSecondsPerVerse = 12;
  static const int totalVersesCount = 43;

  Timer? _timer;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: baseSecondsPerVerse * totalVersesCount);
  double _playbackSpeed = 1.0;
  bool _isAutoScrollEnabled = true;
  int _currentVerseIndex = 0;
  int _repeatTarget = 1; // 1, 3, 7, 11 repetitions
  int _completedCycles = 0;
  bool _isPlaying = false;
  bool _isPaused = false;

  // Callback notified when a full parayan cycle completes
  VoidCallback? onCycleCompleted;

  RecitationProvider() {
    _updateDuration();
  }

  bool get isPlaying => _isPlaying;
  bool get isPaused => _isPaused;
  Duration get position => _position;
  Duration get duration => _duration;
  double get playbackSpeed => _playbackSpeed;
  bool get isAutoScrollEnabled => _isAutoScrollEnabled;
  int get currentVerseIndex => _currentVerseIndex;
  int get repeatTarget => _repeatTarget;
  int get completedCycles => _completedCycles;
  bool get isLoading => false;

  int get secondsPerVerse =>
      (baseSecondsPerVerse / _playbackSpeed).round().clamp(4, 30);

  double get progressFraction {
    if (_duration.inSeconds <= 0) return 0.0;
    return (_position.inSeconds / _duration.inSeconds).clamp(0.0, 1.0);
  }

  void _updateDuration() {
    _duration = Duration(seconds: totalVersesCount * secondsPerVerse);
  }

  Future<void> togglePlayPause() async {
    HapticFeedback.selectionClick();
    if (_isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> play() async {
    _isPlaying = true;
    _isPaused = false;
    _startTimer();
    notifyListeners();
  }

  Future<void> pause() async {
    _isPlaying = false;
    _isPaused = true;
    _timer?.cancel();
    _timer = null;
    notifyListeners();
  }

  Future<void> stop() async {
    _timer?.cancel();
    _timer = null;
    _isPlaying = false;
    _isPaused = false;
    _position = Duration.zero;
    _currentVerseIndex = 0;
    notifyListeners();
  }

  Future<void> seek(Duration target) async {
    _position = target;
    _updateVerseFromPosition(target);
    notifyListeners();
  }

  Future<void> jumpToVerse(int verseIndex) async {
    if (verseIndex < 0 || verseIndex >= totalVersesCount) return;
    _currentVerseIndex = verseIndex;
    _position = Duration(seconds: verseIndex * secondsPerVerse);
    notifyListeners();
  }

  Future<void> nextVerse() async {
    if (_currentVerseIndex < totalVersesCount - 1) {
      await jumpToVerse(_currentVerseIndex + 1);
    }
  }

  Future<void> previousVerse() async {
    if (_currentVerseIndex > 0) {
      await jumpToVerse(_currentVerseIndex - 1);
    }
  }

  Future<void> setPlaybackSpeed(double speed) async {
    _playbackSpeed = speed;
    _updateDuration();
    _position = Duration(seconds: _currentVerseIndex * secondsPerVerse);
    notifyListeners();
  }

  void cyclePlaybackSpeed() {
    if (_playbackSpeed == 0.75) {
      setPlaybackSpeed(1.0);
    } else if (_playbackSpeed == 1.0) {
      setPlaybackSpeed(1.25);
    } else if (_playbackSpeed == 1.25) {
      setPlaybackSpeed(1.5);
    } else {
      setPlaybackSpeed(0.75);
    }
  }

  void toggleAutoScroll() {
    _isAutoScrollEnabled = !_isAutoScrollEnabled;
    notifyListeners();
  }

  void setRepeatTarget(int target) {
    _repeatTarget = target;
    notifyListeners();
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _position += const Duration(seconds: 1);

      final nextVerseIndex = (_position.inSeconds / secondsPerVerse).floor();
      if (nextVerseIndex >= totalVersesCount) {
        _handleCycleComplete();
        return;
      }

      if (nextVerseIndex != _currentVerseIndex) {
        _currentVerseIndex = nextVerseIndex;
      }

      notifyListeners();
    });
  }

  void _updateVerseFromPosition(Duration pos) {
    final nextVerseIndex =
        (pos.inSeconds / secondsPerVerse).floor().clamp(0, totalVersesCount - 1);
    if (nextVerseIndex != _currentVerseIndex) {
      _currentVerseIndex = nextVerseIndex;
      notifyListeners();
    }
  }

  void _handleCycleComplete() {
    _completedCycles++;
    HapticFeedback.heavyImpact();
    onCycleCompleted?.call();

    if (_completedCycles < _repeatTarget) {
      _currentVerseIndex = 0;
      _position = Duration.zero;
      play();
    } else {
      stop();
    }
    notifyListeners();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
