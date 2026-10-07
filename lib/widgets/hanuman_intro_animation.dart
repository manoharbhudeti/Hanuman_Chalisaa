import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:video_player/video_player.dart';

class HanumanIntroAnimation extends StatefulWidget {
  final VoidCallback onBeginJourney;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const HanumanIntroAnimation({
    super.key,
    required this.onBeginJourney,
    this.showCloseButton = false,
    this.onClose,
  });

  @override
  State<HanumanIntroAnimation> createState() => _HanumanIntroAnimationState();
}

class _HanumanIntroAnimationState extends State<HanumanIntroAnimation>
    with SingleTickerProviderStateMixin {
  late VideoPlayerController _videoController;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isMuted = true;
  bool _isVideoEnded = false;

  late final AnimationController _pulseController;
  late final Animation<double> _buttonScaleAnimation;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);

    _buttonScaleAnimation = Tween<double>(begin: 0.98, end: 1.04).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _initVideo();
  }

  Future<void> _initVideo() async {
    try {
      // Strategy 1: Asset controller
      bool initialized = false;
      try {
        _videoController =
            VideoPlayerController.asset('assets/videos/hanuman_intro.mp4');
        await _videoController.initialize();
        initialized = true;
      } catch (assetErr) {
        debugPrint('Asset controller initialization failed: $assetErr');
      }

      // Strategy 2: Relative web URL fallback if asset init failed
      if (!initialized) {
        try {
          final uri = Uri.base.resolve('assets/videos/hanuman_intro.mp4');
          _videoController = VideoPlayerController.networkUrl(uri);
          await _videoController.initialize();
          initialized = true;
        } catch (netErr) {
          debugPrint('Network controller fallback failed: $netErr');
        }
      }

      if (!initialized) {
        throw Exception('All video controller initialization strategies failed');
      }

      _videoController.setLooping(false);
      // Volume 0.0 is required so browsers allow automatic autoplay without gesture requirement
      await _videoController.setVolume(0.0);
      _isMuted = true;

      _videoController.addListener(() {
        if (!mounted) return;
        final position = _videoController.value.position;
        final duration = _videoController.value.duration;

        if (duration > Duration.zero && position >= duration) {
          if (!_isVideoEnded) {
            setState(() {
              _isVideoEnded = true;
            });
          }
        } else if (_isVideoEnded && position < duration) {
          setState(() {
            _isVideoEnded = false;
          });
        }
      });

      // Play by default immediately upon load
      await _videoController.play();

      if (mounted) {
        setState(() {
          _isInitialized = true;
          _hasError = false;
        });
      }
    } catch (e) {
      debugPrint('Error initializing intro video: $e');
      if (mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _togglePlayPause() {
    if (!_isInitialized) return;
    HapticFeedback.selectionClick();
    if (_isMuted) {
      // Unmute on first user interaction so audio plays
      _videoController.setVolume(1.0);
      setState(() {
        _isMuted = false;
      });
      return;
    }
    setState(() {
      if (_videoController.value.isPlaying) {
        _videoController.pause();
      } else {
        if (_isVideoEnded) {
          _videoController.seekTo(Duration.zero);
          _videoController.play();
          _isVideoEnded = false;
        } else {
          _videoController.play();
        }
      }
    });
  }

  void _replayVideo() {
    if (!_isInitialized) return;
    HapticFeedback.lightImpact();
    _videoController.seekTo(Duration.zero);
    _videoController.play();
    setState(() {
      _isVideoEnded = false;
    });
  }

  void _toggleMute() {
    if (!_isInitialized) return;
    HapticFeedback.selectionClick();
    setState(() {
      _isMuted = !_isMuted;
      _videoController.setVolume(_isMuted ? 0.0 : 1.0);
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    if (_isInitialized) {
      _videoController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Dynamic responsive sizing across phones, tablets, and widescreen desktop
        final isWideScreen = screenWidth > 600;
        final maxCardWidth = isWideScreen ? 450.0 : screenWidth * 0.94;
        final maxCardHeight = math.min(screenHeight * 0.94, 820.0);

        final videoAspect = _isInitialized && _videoController.value.aspectRatio > 0
            ? _videoController.value.aspectRatio
            : (9.0 / 16.0);

        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxCardWidth,
              maxHeight: maxCardHeight,
            ),
            child: Container(
              margin: EdgeInsets.symmetric(
                horizontal: isWideScreen ? 16 : 8,
                vertical: isWideScreen ? 16 : 8,
              ),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF14101A) : const Color(0xFFFFFDF8),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: const Color(0xFFFFB300).withValues(alpha: 0.45),
                  width: 1.8,
                ),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFFFF8F00).withValues(alpha: isDark ? 0.35 : 0.22),
                    blurRadius: 28,
                    spreadRadius: 2,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Stack(
                children: [
                  // Video & Backdrop Viewport
                  Positioned.fill(
                    child: Column(
                      children: [
                        // Main Video Display Area
                        Expanded(
                          child: GestureDetector(
                            onTap: _togglePlayPause,
                            behavior: HitTestBehavior.opaque,
                            child: Container(
                              color: Colors.black,
                              alignment: Alignment.center,
                              child: _buildVideoContent(videoAspect, primaryColor),
                            ),
                          ),
                        ),

                        // Bottom Actions Area matching the video aesthetic
                        _buildBottomActionPanel(primaryColor, isDark),
                      ],
                    ),
                  ),

                  // Top Header Overlay: Title & Controls
                  Positioned(
                    top: 12,
                    left: 14,
                    right: 14,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Spiritual Aura Badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: Colors.black.withValues(alpha: 0.65),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                              width: 1.0,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.stars_rounded,
                                  size: 15, color: Color(0xFFFFB300)),
                              const SizedBox(width: 5),
                              Text(
                                'श्री हनुमान चालीसा',
                                style: GoogleFonts.notoSansDevanagari(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFE082),
                                ),
                              ),
                            ],
                          ),
                        ),

                        // Quick Controls: Mute & Close
                        Row(
                          children: [
                            if (_isInitialized)
                              IconButton(
                                icon: Icon(
                                  _isMuted
                                      ? Icons.volume_off_rounded
                                      : Icons.volume_up_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.black.withValues(alpha: 0.6),
                                  padding: const EdgeInsets.all(8),
                                ),
                                tooltip: _isMuted ? 'Unmute' : 'Mute',
                                onPressed: _toggleMute,
                              ),
                            if (widget.showCloseButton) ...[
                              const SizedBox(width: 8),
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: Colors.white, size: 20),
                                style: IconButton.styleFrom(
                                  backgroundColor:
                                      Colors.black.withValues(alpha: 0.6),
                                  padding: const EdgeInsets.all(8),
                                ),
                                tooltip: 'Close',
                                onPressed: widget.onClose ??
                                    () => Navigator.of(context).pop(),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildVideoContent(double videoAspect, Color primaryColor) {
    if (_hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.video_library_rounded,
                  size: 54, color: Color(0xFFFFB300)),
              const SizedBox(height: 14),
              Text(
                'श्री हनुमान चालीसा',
                style: GoogleFonts.notoSansDevanagari(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFFFFE082),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Sacred Journey is Ready',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 38,
              height: 38,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB300)),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'लोड हो रहा है • Loading Video...',
              style: GoogleFonts.outfit(
                fontSize: 13,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    }

    return Stack(
      alignment: Alignment.center,
      children: [
        // Video Player maintaining natural aspect ratio seamlessly
        Center(
          child: AspectRatio(
            aspectRatio: videoAspect,
            child: VideoPlayer(_videoController),
          ),
        ),

        // Pause/Play overlay indicator when paused
        if (!_videoController.value.isPlaying && !_isVideoEnded)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Colors.white,
              size: 42,
            ),
          ),

        // Tap to unmute hint pill
        if (_isMuted && _videoController.value.isPlaying)
          Positioned(
            bottom: 24,
            child: GestureDetector(
              onTap: _toggleMute,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.75),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.6),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.4),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.volume_off_rounded,
                        color: Color(0xFFFFB300), size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Tap for Audio / ఆడియో ఆన్ చేయండి',
                      style: GoogleFonts.outfit(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Video Progress Tracker Bar at Bottom of Video Area
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: VideoProgressIndicator(
            _videoController,
            allowScrubbing: true,
            colors: VideoProgressColors(
              playedColor: const Color(0xFFFFB300),
              bufferedColor: Colors.white.withValues(alpha: 0.3),
              backgroundColor: Colors.white.withValues(alpha: 0.1),
            ),
            padding: const EdgeInsets.symmetric(vertical: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActionPanel(Color primaryColor, bool isDark) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1B1624) : const Color(0xFFFFFDF9),
        border: Border(
          top: BorderSide(
            color: const Color(0xFFFFB300).withValues(alpha: 0.25),
            width: 1.0,
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Subtitle info line
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '॥ संकट कटे मिटे सब पीरा ॥',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFFFF9800),
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '• Sacred Recitation',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Action Buttons: Replay + Prominent "Begin Sacred Journey" Button
          Row(
            children: [
              // Replay button if video ended or playing
              if (_isInitialized) ...[
                IconButton.filledTonal(
                  onPressed: _replayVideo,
                  icon: const Icon(Icons.replay_rounded, size: 22),
                  tooltip: 'Replay Video',
                  style: IconButton.styleFrom(
                    backgroundColor: const Color(0xFFFFB300).withValues(alpha: 0.15),
                    foregroundColor: const Color(0xFFFFB300),
                    padding: const EdgeInsets.all(14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
              ],

              // Main "Begin Journey" Dynamic Button
              Expanded(
                child: ScaleTransition(
                  scale: _isVideoEnded ? _buttonScaleAnimation : const AlwaysStoppedAnimation(1.0),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [
                          Color(0xFFFF8F00),
                          Color(0xFFFF5722),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6F00).withValues(alpha: 0.4),
                          blurRadius: 14,
                          spreadRadius: 1,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: () {
                        HapticFeedback.heavyImpact();
                        widget.onBeginJourney();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 20, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Begin Sacred Journey',
                              style: GoogleFonts.cinzel(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.4,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            const Icon(Icons.arrow_forward_rounded,
                                size: 20, color: Colors.white),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
