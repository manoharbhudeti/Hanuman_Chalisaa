import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

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
  late final AnimationController _controller;

  // Keyframe phase animations
  late final Animation<double> _phaseAnimation;
  late final Animation<double> _mandalaRotation;
  late final Animation<double> _buttonScale;

  int _currentFrameIndex = 0;

  static const List<String> _frameAssets = [
    'assets/animation/frame_0_intro.png',
    'assets/animation/frame_1_leap.png',
    'assets/animation/frame_2_catch.png',
    'assets/animation/frame_3_pranam.png',
  ];

  static const List<String> _phaseTitles = [
    '0s: Intro & Gada Appears',
    '1s: Hanuman Leaps & Gada Spins',
    '2s: Hanuman Catches Gada!',
    '3s: Final Pose & Begin!',
  ];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    );

    _phaseAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    );

    _mandalaRotation = Tween<double>(begin: 0.0, end: 2 * math.pi).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.65, 1.0, curve: Curves.linear),
      ),
    );

    _buttonScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.78, 0.98, curve: Curves.elasticOut),
      ),
    );

    _controller.addListener(() {
      final val = _controller.value;
      int newIndex;
      if (val < 0.28) {
        newIndex = 0; // 0s - 1s
      } else if (val < 0.58) {
        newIndex = 1; // 1s - 2s
      } else if (val < 0.82) {
        newIndex = 2; // 2s - 3s
      } else {
        newIndex = 3; // 3s+
      }

      if (newIndex != _currentFrameIndex) {
        if (newIndex == 2) {
          HapticFeedback.mediumImpact(); // Catch impact!
        } else if (newIndex == 3) {
          HapticFeedback.lightImpact(); // Pranam landing
        }
        setState(() {
          _currentFrameIndex = newIndex;
        });
      }
    });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _replay() {
    HapticFeedback.selectionClick();
    _controller.reset();
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final cardWidth = math.min(size.width * 0.88, 380.0);
    final cardHeight = cardWidth * 1.95; // Golden portrait ratio

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _phaseAnimation.value;

        // Micro squish-and-stretch bounces per phase
        double scaleY = 1.0;
        double scaleX = 1.0;
        double offsetY = 0.0;

        if (_currentFrameIndex == 0) {
          // Subtle peek bobbing
          offsetY = math.sin(progress * 16) * 4.0;
        } else if (_currentFrameIndex == 1) {
          // Dynamic upward stretch
          final leapProg = ((progress - 0.28) / 0.30).clamp(0.0, 1.0);
          scaleY = 1.0 + 0.08 * math.sin(leapProg * math.pi);
          scaleX = 1.0 - 0.04 * math.sin(leapProg * math.pi);
          offsetY = -12.0 * math.sin(leapProg * math.pi);
        } else if (_currentFrameIndex == 2) {
          // Impact pop squash
          final catchProg = ((progress - 0.58) / 0.24).clamp(0.0, 1.0);
          final pop = math.sin(catchProg * math.pi);
          scaleY = 1.0 + 0.12 * pop;
          scaleX = 1.0 + 0.12 * pop;
        } else {
          // Settling pranam breath
          final settleProg = ((progress - 0.82) / 0.18).clamp(0.0, 1.0);
          scaleY = 1.0 + 0.02 * math.sin(settleProg * 4 * math.pi);
        }

        return Container(
          color: const Color(0xFF19161B),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
              physics: const BouncingScrollPhysics(),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Top Controls Bar (Timeline progress + Close / Replay)
                  SizedBox(
                    width: cardWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Phase badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFF6D00).withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: const Color(0xFFFF9100).withValues(alpha: 0.6),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.movie_creation_rounded,
                                  color: Color(0xFFFFB300), size: 14),
                              const SizedBox(width: 6),
                              Text(
                                _phaseTitles[_currentFrameIndex],
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFD54F),
                                ),
                              ),
                            ],
                          ),
                        ),

                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.replay_rounded,
                                  color: Colors.white70, size: 20),
                              tooltip: 'Replay Animation',
                              onPressed: _replay,
                            ),
                            if (widget.showCloseButton)
                              IconButton(
                                icon: const Icon(Icons.close_rounded,
                                    color: Colors.white70, size: 20),
                                onPressed: widget.onClose,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Main Festive Saffron Flashcard
                  Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(28),
                      border: Border.all(
                        color: const Color(0xFFFF6D00),
                        width: 4.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFFF6D00).withValues(alpha: 0.35),
                          blurRadius: 28,
                          spreadRadius: 2,
                          offset: const Offset(0, 8),
                        ),
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.6),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(23.5),
                      child: Stack(
                        children: [
                          // Base Animated Illustration Frame
                          Positioned.fill(
                            child: Transform.translate(
                              offset: Offset(0, offsetY),
                              child: Transform.scale(
                                scaleX: scaleX,
                                scaleY: scaleY,
                                child: Image.asset(
                                  _frameAssets[_currentFrameIndex],
                                  fit: BoxFit.fill,
                                ),
                              ),
                            ),
                          ),

                          // Dynamic Particle / Energy Ray Overlay Painter
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _AnimationFxPainter(
                                phaseIndex: _currentFrameIndex,
                                animationValue: progress,
                                mandalaAngle: _mandalaRotation.value,
                              ),
                            ),
                          ),

                          // Phase 3: Interactive Begin Journey Button overlay
                          if (_currentFrameIndex == 3)
                            Positioned(
                              left: 20,
                              right: 20,
                              bottom: 28,
                              child: Transform.scale(
                                scale: _buttonScale.value,
                                child: Opacity(
                                  opacity: _buttonScale.value.clamp(0.0, 1.0),
                                  child: Container(
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(24),
                                      gradient: const LinearGradient(
                                        colors: [
                                          Color(0xFF8B0000),
                                          Color(0xFFB71C1C),
                                        ],
                                        begin: Alignment.topCenter,
                                        end: Alignment.bottomCenter,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: const Color(0xFFFFB300)
                                              .withValues(alpha: 0.45),
                                          blurRadius: 14,
                                          spreadRadius: 1,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                      border: Border.all(
                                        color: const Color(0xFFFFD54F)
                                            .withValues(alpha: 0.8),
                                        width: 1.8,
                                      ),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        borderRadius: BorderRadius.circular(24),
                                        onTap: () {
                                          HapticFeedback.heavyImpact();
                                          widget.onBeginJourney();
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 14, horizontal: 16),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.auto_stories_rounded,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                              const SizedBox(width: 8),
                                              Text(
                                                'Begin Journey',
                                                style: GoogleFonts.cinzel(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white,
                                                  letterSpacing: 0.8,
                                                ),
                                              ),
                                              const SizedBox(width: 6),
                                              const Icon(
                                                Icons.arrow_forward_rounded,
                                                color: Color(0xFFFFD54F),
                                                size: 18,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),

                          // Decorative Corner Film Camera Marks
                          Positioned(
                            top: 8,
                            left: 8,
                            child: _buildCameraCorner(),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Transform.rotate(
                              angle: math.pi / 2,
                              child: _buildCameraCorner(),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            left: 8,
                            child: Transform.rotate(
                              angle: -math.pi / 2,
                              child: _buildCameraCorner(),
                            ),
                          ),
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: Transform.rotate(
                              angle: math.pi,
                              child: _buildCameraCorner(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  // 4-Phase Step Timeline Selector
                  SizedBox(
                    width: cardWidth,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(4, (index) {
                        final isSelected = _currentFrameIndex == index;
                        final targetTime = [0.0, 0.35, 0.65, 0.95][index];

                        return InkWell(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            _controller.animateTo(targetTime,
                                duration: const Duration(milliseconds: 300));
                          },
                          borderRadius: BorderRadius.circular(10),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFFF6D00)
                                  : Colors.white.withValues(alpha: 0.08),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? const Color(0xFFFFB300)
                                    : Colors.white12,
                              ),
                            ),
                            child: Text(
                              '${index}s',
                              style: GoogleFonts.outfit(
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.w500,
                                color: isSelected ? Colors.white : Colors.white60,
                              ),
                            ),
                          ),
                        );
                      }),
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

  Widget _buildCameraCorner() {
    return Container(
      width: 14,
      height: 14,
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(color: Color(0x99FFFFFF), width: 1.8),
          left: BorderSide(color: Color(0x99FFFFFF), width: 1.8),
        ),
      ),
    );
  }
}

/// Dynamic canvas painter adding animated golden sparkles, impact starbursts, and speed rays
class _AnimationFxPainter extends CustomPainter {
  final int phaseIndex;
  final double animationValue;
  final double mandalaAngle;

  _AnimationFxPainter({
    required this.phaseIndex,
    required this.animationValue,
    required this.mandalaAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width * 0.5, size.height * 0.45);

    if (phaseIndex == 0) {
      // Phase 0: Tiny glittering gold stars around the top mace
      final starPaint = Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.fill;

      final t = animationValue * 10;
      _drawSparkle(canvas, Offset(size.width * 0.82, size.height * 0.12),
          4.0 + 2.0 * math.sin(t), starPaint);
      _drawSparkle(canvas, Offset(size.width * 0.70, size.height * 0.18),
          3.0 + 1.5 * math.cos(t), starPaint);
    } else if (phaseIndex == 1) {
      // Phase 1: Swoop speed lines and golden trail dots
      final trailPaint = Paint()
        ..color = const Color(0xFFFFE082).withValues(alpha: 0.6)
        ..strokeWidth = 2.0
        ..style = PaintingStyle.stroke;

      // Arc trail
      final rect = Rect.fromCircle(
          center: Offset(size.width * 0.65, size.height * 0.35),
          radius: size.width * 0.38);
      canvas.drawArc(rect, 0.2, 1.2, false, trailPaint);

      // Motion particles
      final dotPaint = Paint()
        ..color = const Color(0xFFFFD54F)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
          Offset(size.width * 0.48, size.height * 0.28), 2.5, dotPaint);
      canvas.drawCircle(
          Offset(size.width * 0.58, size.height * 0.32), 3.0, dotPaint);
    } else if (phaseIndex == 2) {
      // Phase 2: Comic impact starburst & radiating energy rays
      final rayPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.25)
        ..strokeWidth = 2.5
        ..style = PaintingStyle.stroke;

      const numRays = 8;
      for (int i = 0; i < numRays; i++) {
        final angle = (i * 2 * math.pi / numRays) + (animationValue * 2);
        final inner = Offset(
          center.dx + math.cos(angle) * 35,
          center.dy + math.sin(angle) * 35,
        );
        final outer = Offset(
          center.dx + math.cos(angle) * 65,
          center.dy + math.sin(angle) * 65,
        );
        canvas.drawLine(inner, outer, rayPaint);
      }
    } else if (phaseIndex == 3) {
      // Phase 3: Subtle rotating divine aura rings behind Pranam Hanuman
      final auraPaint = Paint()
        ..color = const Color(0xFFFFD54F).withValues(alpha: 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.44), 68, auraPaint);
      canvas.drawCircle(
          Offset(size.width * 0.5, size.height * 0.44), 82, auraPaint);
    }
  }

  void _drawSparkle(Canvas canvas, Offset pos, double size, Paint paint) {
    final path = Path();
    path.moveTo(pos.dx, pos.dy - size);
    path.lineTo(pos.dx + size * 0.3, pos.dy - size * 0.3);
    path.lineTo(pos.dx + size, pos.dy);
    path.lineTo(pos.dx + size * 0.3, pos.dy + size * 0.3);
    path.lineTo(pos.dx, pos.dy + size);
    path.lineTo(pos.dx - size * 0.3, pos.dy + size * 0.3);
    path.lineTo(pos.dx - size, pos.dy);
    path.lineTo(pos.dx - size * 0.3, pos.dy - size * 0.3);
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _AnimationFxPainter oldDelegate) {
    return oldDelegate.animationValue != animationValue ||
        oldDelegate.phaseIndex != phaseIndex;
  }
}
