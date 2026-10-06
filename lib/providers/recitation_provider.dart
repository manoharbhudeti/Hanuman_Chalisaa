import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

enum AudioMode {
  traditionalChant,
  meditativeTanpura,
  silentGuided;

  String get label {
    switch (this) {
      case AudioMode.traditionalChant:
        return 'पारंपरिक पाठ (Traditional Chant)';
      case AudioMode.meditativeTanpura:
        return 'ध्यान तानपूरा (Meditative Tanpura)';
      case AudioMode.silentGuided:
        return 'मौन स्वतः-स्क्रोल (Silent Auto-Scroll)';
    }
  }

  String get shortLabel {
    switch (this) {
      case AudioMode.traditionalChant:
        return 'Chant Audio';
      case AudioMode.meditativeTanpura:
        return 'Tanpura Drone';
      case AudioMode.silentGuided:
        return 'Silent Scroll';
    }
  }
}

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

class RecitationProvider extends ChangeNotifier {
  // Public domain/archive streaming URL for Gulshan Kumar / Hariharan Shree Hanuman Chalisa
  static const String traditionalAudioUrl =
      'https://archive.org/download/hanuman-chalisa-i-gulshan-kumar-i-hariharan-full-hd-video-i-shree-hanuman-chalisa/%E0%A4%B9%E0%A4%A8%E0%A4%AE%E0%A4%A8%20%E0%A4%9A%E0%A4%B2%E0%A4%B8%20Hanuman%20Chalisa%20I%20GULSHAN%20KUMAR%20I%20HARIHARAN%2C%20Full%20HD%20Video%20I%20Shree%20Hanuman%20Chalisa.mp3';

  // Ambient Meditative Drone audio URL from public archive
  static const String meditativeAudioUrl =
      'https://archive.org/download/meditation-tanpura-c-sharp/Tanpura_Meditation_Om.mp3';

  final AudioPlayer _audioPlayer = AudioPlayer();

  AudioMode _audioMode = AudioMode.traditionalChant;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = const Duration(minutes: 9, seconds: 42);
  double _playbackSpeed = 1.0;
  bool _isAutoScrollEnabled = true;
  int _currentVerseIndex = 0;
  int _repeatTarget = 1; // 1, 3, 7, 11
  int _completedCycles = 0;
  bool _hasError = false;
  String _errorMessage = '';
  bool _isLoading = false;

  // Silent timer for silent guided mode
  Timer? _silentTimer;
  int _silentSecondsPerVerse = 12; // default seconds per verse in silent mode

  // Estimated verse timings across the 43 verses of traditional Chalisa recitation
  late final List<VerseTimestamp> _verseTimestamps;

  // Callback notified when a full parayan cycle completes
  VoidCallback? onCycleCompleted;

  RecitationProvider() {
    _initVerseTimestamps();
    _initAudioListeners();
  }

  AudioMode get audioMode => _audioMode;
  PlayerState get playerState => _playerState;
  bool get isPlaying =>
      _audioMode == AudioMode.silentGuided
          ? (_silentTimer != null && _silentTimer!.isActive)
          : (_playerState == PlayerState.playing);
  bool get isPaused =>
      _audioMode == AudioMode.silentGuided
          ? (_silentTimer == null && _currentVerseIndex > 0)
          : (_playerState == PlayerState.paused);
  Duration get position => _position;
  Duration get duration => _duration;
  double get playbackSpeed => _playbackSpeed;
  bool get isAutoScrollEnabled => _isAutoScrollEnabled;
  int get currentVerseIndex => _currentVerseIndex;
  int get repeatTarget => _repeatTarget;
  int get completedCycles => _completedCycles;
  bool get hasError => _hasError;
  String get errorMessage => _errorMessage;
  bool get isLoading => _isLoading;

  void _initVerseTimestamps() {
    final list = <VerseTimestamp>[];
    // 0: Opening Doha 1 (0:00 - 0:26)
    list.add(const VerseTimestamp(
      verseIndex: 0,
      start: Duration.zero,
      end: Duration(seconds: 26),
    ));
    // 1: Opening Doha 2 (0:26 - 0:50)
    list.add(const VerseTimestamp(
      verseIndex: 1,
      start: Duration(seconds: 26),
      end: Duration(seconds: 50),
    ));

    // Chaupais 1 to 40 (0:50 to 8:54, ~12.1 seconds per chaupai)
    const int chaupaisStartSec = 50;
    const double secPerChaupai = 12.1;
    for (int i = 0; i < 40; i++) {
      final startSec = chaupaisStartSec + (i * secPerChaupai).toInt();
      final endSec = chaupaisStartSec + ((i + 1) * secPerChaupai).toInt();
      list.add(VerseTimestamp(
        verseIndex: 2 + i,
        start: Duration(seconds: startSec),
        end: Duration(seconds: endSec),
      ));
    }

    // 42: Closing Doha (8:54 - 9:42)
    list.add(const VerseTimestamp(
      verseIndex: 42,
      start: Duration(minutes: 8, seconds: 54),
      end: Duration(minutes: 9, seconds: 42),
    ));

    _verseTimestamps = list;
  }

  void _initAudioListeners() {
    _audioPlayer.onPlayerStateChanged.listen((state) {
      _playerState = state;
      _isLoading = false;
      notifyListeners();
    });

    _audioPlayer.onPositionChanged.listen((pos) {
      _position = pos;
      _updateVerseFromPosition(pos);
      notifyListeners();
    });

    _audioPlayer.onDurationChanged.listen((dur) {
      if (dur > Duration.zero) {
        _duration = dur;
        notifyListeners();
      }
    });

    _audioPlayer.onPlayerComplete.listen((_) {
      _handleCycleComplete();
    });
  }

  void _updateVerseFromPosition(Duration pos) {
    for (int i = 0; i < _verseTimestamps.length; i++) {
      final vt = _verseTimestamps[i];
      if (pos >= vt.start && pos < vt.end) {
        if (_currentVerseIndex != vt.verseIndex) {
          _currentVerseIndex = vt.verseIndex;
          notifyListeners();
        }
        break;
      }
    }
  }

  Future<void> setAudioMode(AudioMode mode) async {
    if (_audioMode == mode) return;
    final wasPlaying = isPlaying;
    await pause();
    _audioMode = mode;
    _hasError = false;
    _errorMessage = '';
    notifyListeners();

    if (wasPlaying) {
      await play();
    }
  }

  Future<void> togglePlayPause() async {
    HapticFeedback.selectionClick();
    if (isPlaying) {
      await pause();
    } else {
      await play();
    }
  }

  Future<void> play() async {
    _hasError = false;
    _errorMessage = '';

    if (_audioMode == AudioMode.silentGuided) {
      _startSilentTimer();
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      notifyListeners();

      final url = _audioMode == AudioMode.traditionalChant
          ? traditionalAudioUrl
          : meditativeAudioUrl;

      await _audioPlayer.setPlaybackRate(_playbackSpeed);
      if (_playerState == PlayerState.paused) {
        await _audioPlayer.resume();
      } else {
        await _audioPlayer.play(UrlSource(url));
      }
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _hasError = true;
      _errorMessage = 'Could not load audio. Falling back to silent recitation.';
      debugPrint('Audio playback error: $e');
      // Graceful fallback to silent guided mode
      _audioMode = AudioMode.silentGuided;
      _startSilentTimer();
      notifyListeners();
    }
  }

  Future<void> pause() async {
    if (_audioMode == AudioMode.silentGuided) {
      _silentTimer?.cancel();
      _silentTimer = null;
      notifyListeners();
      return;
    }

    try {
      await _audioPlayer.pause();
    } catch (e) {
      debugPrint('Audio pause error: $e');
    }
  }

  Future<void> stop() async {
    _silentTimer?.cancel();
    _silentTimer = null;
    _position = Duration.zero;
    _currentVerseIndex = 0;
    try {
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Audio stop error: $e');
    }
    notifyListeners();
  }

  Future<void> seek(Duration target) async {
    if (_audioMode == AudioMode.silentGuided) {
      _position = target;
      _updateVerseFromPosition(target);
      notifyListeners();
      return;
    }

    try {
      await _audioPlayer.seek(target);
    } catch (e) {
      debugPrint('Audio seek error: $e');
    }
  }

  Future<void> jumpToVerse(int verseIndex) async {
    if (verseIndex < 0 || verseIndex >= _verseTimestamps.length) return;
    _currentVerseIndex = verseIndex;
    final timestamp = _verseTimestamps[verseIndex];

    if (_audioMode == AudioMode.silentGuided) {
      _position = timestamp.start;
      notifyListeners();
      return;
    }

    try {
      await seek(timestamp.start);
      if (!isPlaying) {
        await play();
      }
    } catch (e) {
      debugPrint('Jump to verse error: $e');
    }
  }

  Future<void> nextVerse() async {
    if (_currentVerseIndex < 42) {
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
    if (_audioMode != AudioMode.silentGuided) {
      try {
        await _audioPlayer.setPlaybackRate(speed);
      } catch (e) {
        debugPrint('Set speed error: $e');
      }
    } else {
      // Adjust silent seconds per verse based on speed
      _silentSecondsPerVerse = (12 / speed).round().clamp(5, 30);
    }
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

  void _startSilentTimer() {
    _silentTimer?.cancel();
    _silentTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final newPos = _position + const Duration(seconds: 1);
      _position = newPos;

      // Update verse progression in silent mode
      final nextVerseIndex = (_position.inSeconds / _silentSecondsPerVerse).floor();
      if (nextVerseIndex != _currentVerseIndex) {
        if (nextVerseIndex > 42) {
          _handleCycleComplete();
          return;
        } else {
          _currentVerseIndex = nextVerseIndex;
        }
      }

      notifyListeners();
    });
  }

  void _handleCycleComplete() {
    _completedCycles++;
    HapticFeedback.heavyImpact();
    onCycleCompleted?.call();

    if (_completedCycles < _repeatTarget) {
      // Loop again
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
    _silentTimer?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }
}
