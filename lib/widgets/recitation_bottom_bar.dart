import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chalisa_verse.dart';
import '../providers/recitation_provider.dart';
import 'recitation_sheet.dart';

class RecitationBottomBar extends StatelessWidget {
  final List<ChalisaVerse> verses;
  final VoidCallback onScrollToActiveVerse;

  const RecitationBottomBar({
    super.key,
    required this.verses,
    required this.onScrollToActiveVerse,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void _openRecitationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecitationSheet(
        verses: verses,
        onJumpToVerse: () => onScrollToActiveVerse(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final recitation = context.watch<RecitationProvider>();

    final activeIndex = recitation.currentVerseIndex.clamp(0, verses.length - 1);
    final currentVerse = verses.isNotEmpty ? verses[activeIndex] : null;

    final progressFraction = recitation.duration.inMilliseconds > 0
        ? (recitation.position.inMilliseconds /
                recitation.duration.inMilliseconds)
            .clamp(0.0, 1.0)
        : 0.0;

    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF221C2B) : const Color(0xFFFFFBF5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: recitation.isPlaying
              ? const Color(0xFFFFB300)
              : (isDark ? const Color(0xFF423755) : const Color(0xFFFFE0B2)),
          width: recitation.isPlaying ? 1.6 : 1.0,
        ),
        boxShadow: [
          BoxShadow(
            color: recitation.isPlaying
                ? const Color(0xFFFFB300).withValues(alpha: isDark ? 0.28 : 0.22)
                : Colors.black.withValues(alpha: isDark ? 0.35 : 0.08),
            blurRadius: recitation.isPlaying ? 14 : 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openRecitationSheet(context),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Thin top progress bar
              LinearProgressIndicator(
                value: progressFraction,
                minHeight: 3.5,
                backgroundColor: primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  recitation.isPlaying ? const Color(0xFFFFB300) : primary,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    // Play / Pause glowing button
                    GestureDetector(
                      onTap: () => recitation.togglePlayPause(),
                      child: Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: recitation.isPlaying
                                ? [const Color(0xFFFF8F00), const Color(0xFFFFB300)]
                                : [primary, const Color(0xFFFF7043)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: (recitation.isPlaying
                                      ? const Color(0xFFFFB300)
                                      : primary)
                                  .withValues(alpha: 0.35),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Center(
                          child: recitation.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white),
                                  ),
                                )
                              : Icon(
                                  recitation.isPlaying
                                      ? Icons.pause_rounded
                                      : Icons.play_arrow_rounded,
                                  color: Colors.white,
                                  size: 26,
                                ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 12),

                    // Verse Information & Audio Mode
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  currentVerse?.title ?? 'Shree Hanuman Chalisa',
                                  style: GoogleFonts.rozhaOne(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: isDark
                                        ? const Color(0xFFFFE0B2)
                                        : const Color(0xFF3E2723),
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 6, vertical: 1.5),
                                decoration: BoxDecoration(
                                  color: primary.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'Auto-Scroll',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                '${_formatDuration(recitation.position)} / ${_formatDuration(recitation.duration)}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              if (recitation.repeatTarget > 1) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '• ${recitation.completedCycles + 1}/${recitation.repeatTarget}',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFFB300),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),

                    // Auto-scroll indicator & quick actions
                    IconButton(
                      icon: Icon(
                        recitation.isAutoScrollEnabled
                            ? Icons.navigation_rounded
                            : Icons.near_me_disabled_rounded,
                        color: recitation.isAutoScrollEnabled
                            ? const Color(0xFFFFB300)
                            : (isDark ? Colors.white38 : Colors.black38),
                        size: 22,
                      ),
                      tooltip: recitation.isAutoScrollEnabled
                          ? 'Auto-Scroll Active'
                          : 'Auto-Scroll Paused',
                      onPressed: () {
                        recitation.toggleAutoScroll();
                        if (recitation.isAutoScrollEnabled) {
                          onScrollToActiveVerse();
                        }
                      },
                    ),

                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 24),
                      tooltip: 'Expand Player',
                      color: isDark ? Colors.white70 : Colors.black87,
                      onPressed: () => _openRecitationSheet(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
