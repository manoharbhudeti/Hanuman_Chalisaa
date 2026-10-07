import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class VerseTimestamp {
  final int verseIndex;
  final Duration start;
  final Duration end;

  const VerseTimestamp({
    required this.verseIndex,
    required this.start,
    required this.end,
  });
}

/// Manages silent guided recitation and auto-scroll progression across the 43 verses
class RecitationProvider extends ChangeNotifier {
  // Base reading duration per verse at 1.0x speed: 12 seconds
  static const int baseSecondsPerVerse = 12;
  static const int totalVersesCount = 43;

  Timer? _timer;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(seconds: baseSecondsPerVerse * totalVersesCount);
  double _playbackSpeed = 1.0;
  bool _isAutoScrollEnabled = true;
  int _currentVerseIndex = 0;
  int _repeatTarget = 1; // 1, 3, 7, 11
  int _completedCycles = 0;
  bool _isPlaying = false;
  bool _isPaused = false;

  late List<VerseTimestamp> _verseTimestamps;

  // Callback notified when a full parayan cycle completes
  VoidCallback? onCycleCompleted;

  RecitationProvider() {
    _calculateTimestamps();
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
  List<VerseTimestamp> get verseTimestamps => _verseTimestamps;

  int get _secondsPerVerse =>
      (baseSecondsPerVerse / _playbackSpeed).round().clamp(4, 30);

  void _calculateTimestamps() {
    final secPerVerse = _secondsPerVerse;
    final list = <VerseTimestamp>[];
    for (int i = 0; i < totalVersesCount; i++) {
      list.add(VerseTimestamp(
        verseIndex: i,
        start: Duration(seconds: i * secPerVerse),
        end: Duration(seconds: (i + 1) * secPerVerse),
      ));
    }
    _verseTimestamps = list;
    _duration = Duration(seconds: totalVersesCount * secPerVerse);
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
    _position = Duration(seconds: verseIndex * _secondsPerVerse);
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
    _calculateTimestamps();
    // Reposition within current verse
    _position = Duration(seconds: _currentVerseIndex * _secondsPerVerse);
    notifyListeners();
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

      final nextVerseIndex = (_position.inSeconds / _secondsPerVerse).floor();
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
        (pos.inSeconds / _secondsPerVerse).floor().clamp(0, totalVersesCount - 1);
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
      // Loop next cycle
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
