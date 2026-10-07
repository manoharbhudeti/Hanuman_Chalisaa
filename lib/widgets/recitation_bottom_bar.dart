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

  void _openRecitationSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RecitationSheet(
        verses: verses,
        onJumpToVerse: onScrollToActiveVerse,
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

    final progressFraction = recitation.progressFraction;

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
              // Top linear progress bar
              LinearProgressIndicator(
                value: progressFraction,
                minHeight: 3.5,
                backgroundColor: primary.withValues(alpha: 0.15),
                valueColor: AlwaysStoppedAnimation<Color>(
                  recitation.isPlaying ? const Color(0xFFFFB300) : primary,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    // Play / Pause glowing button
                    GestureDetector(
                      onTap: () {
                        recitation.togglePlayPause();
                        if (!recitation.isPlaying) {
                          onScrollToActiveVerse();
                        }
                      },
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
                          child: Icon(
                            recitation.isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: Colors.white,
                            size: 26,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(width: 10),

                    // Verse Information & Auto-Scroll Status
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
                                  style: GoogleFonts.cinzel(
                                    fontSize: 13,
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
                                  color: recitation.isPlaying
                                      ? const Color(0xFFFFB300).withValues(alpha: 0.2)
                                      : primary.withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: recitation.isPlaying
                                        ? const Color(0xFFFFB300)
                                        : primary.withValues(alpha: 0.3),
                                    width: 0.8,
                                  ),
                                ),
                                child: Text(
                                  recitation.isPlaying ? 'Auto-Scrolling' : 'Auto-Scroll',
                                  style: GoogleFonts.outfit(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: recitation.isPlaying
                                        ? const Color(0xFFFFB300)
                                        : primary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              Text(
                                'Verse ${activeIndex + 1} / ${verses.length}',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: isDark ? Colors.white60 : Colors.black54,
                                ),
                              ),
                              if (recitation.repeatTarget > 1) ...[
                                const SizedBox(width: 6),
                                Text(
                                  '• Cycle ${recitation.completedCycles + 1}/${recitation.repeatTarget}',
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

                    // Quick Speed Cycle Button (1.0x, 1.25x, etc.)
                    InkWell(
                      onTap: () => recitation.cyclePlaybackSpeed(),
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: isDark ? 0.2 : 0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: primary.withValues(alpha: 0.3),
                          ),
                        ),
                        child: Text(
                          '${recitation.playbackSpeed}x',
                          style: GoogleFonts.outfit(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                    ),

                    // Previous Verse Button
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, size: 22),
                      tooltip: 'Previous Verse',
                      color: isDark ? Colors.white70 : Colors.black87,
                      onPressed: () {
                        recitation.previousVerse();
                        onScrollToActiveVerse();
                      },
                    ),

                    // Next Verse Button
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, size: 22),
                      tooltip: 'Next Verse',
                      color: isDark ? Colors.white70 : Colors.black87,
                      onPressed: () {
                        recitation.nextVerse();
                        onScrollToActiveVerse();
                      },
                    ),

                    // Expand Sheet Button
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_up_rounded, size: 22),
                      tooltip: 'Auto-Scroll Settings',
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
