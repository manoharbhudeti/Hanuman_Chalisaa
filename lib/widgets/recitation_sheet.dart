import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chalisa_verse.dart';
import '../providers/recitation_provider.dart';

class RecitationSheet extends StatelessWidget {
  final List<ChalisaVerse> verses;
  final VoidCallback onJumpToVerse;

  const RecitationSheet({
    super.key,
    required this.verses,
    required this.onJumpToVerse,
  });

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes;
    final seconds = d.inSeconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final recitation = context.watch<RecitationProvider>();

    final activeIndex = recitation.currentVerseIndex.clamp(0, verses.length - 1);
    final currentVerse = verses.isNotEmpty ? verses[activeIndex] : null;

    final durationMs = recitation.duration.inMilliseconds.toDouble();
    final positionMs = recitation.position.inMilliseconds.toDouble().clamp(0.0, durationMs > 0 ? durationMs : 1.0);

    return Material(
      color: isDark ? const Color(0xFF1E1828) : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: SafeArea(
        top: false,
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Top Drag Handle
              Center(
                child: Container(
                  width: 44,
                  height: 4.5,
                  margin: const EdgeInsets.only(bottom: 14),
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // Sheet Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: primary.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(Icons.temple_hindu_rounded,
                            color: primary, size: 22),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'स्वाध्याय एवं स्वतः-स्क्रोल',
                            style: GoogleFonts.rozhaOne(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: primary,
                            ),
                          ),
                          Text(
                            'Guided Reading & Auto-Scroll • పారాయణం',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white60 : Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),

              const SizedBox(height: 18),

              // Active Verse Card Preview
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: isDark ? 0.22 : 0.08),
                      isDark ? const Color(0xFF261F33) : const Color(0xFFFFF8EC),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: const Color(0xFFFFB300).withValues(alpha: 0.5),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'VERSE #${(currentVerse?.verseNumber ?? 1)}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                        Text(
                          currentVerse?.title ?? '',
                          style: GoogleFonts.cinzel(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      currentVerse?.awadhi ?? '',
                      style: GoogleFonts.rozhaOne(
                        fontSize: 16,
                        height: 1.5,
                        color: isDark
                            ? const Color(0xFFFFF8E7)
                            : const Color(0xFF3E2723),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Progress Slider & Timestamps
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  trackHeight: 4,
                  activeTrackColor: const Color(0xFFFFB300),
                  inactiveTrackColor: primary.withValues(alpha: 0.2),
                  thumbColor: const Color(0xFFFFB300),
                  thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 7),
                  overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                ),
                child: Slider(
                  value: positionMs,
                  min: 0.0,
                  max: durationMs > 0 ? durationMs : 1.0,
                  onChanged: (val) {
                    recitation.seek(Duration(milliseconds: val.toInt()));
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDuration(recitation.position),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                    Text(
                      _formatDuration(recitation.duration),
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        color: isDark ? Colors.white60 : Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              // Main Playback Controls
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Previous Verse
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.skip_previous_rounded),
                    color: isDark ? Colors.white70 : Colors.black87,
                    tooltip: 'Previous Verse',
                    onPressed: () {
                      recitation.previousVerse();
                      onJumpToVerse();
                    },
                  ),
                  const SizedBox(width: 14),

                  // Stop Button
                  IconButton(
                    iconSize: 26,
                    icon: const Icon(Icons.stop_rounded),
                    color: isDark ? Colors.white54 : Colors.black45,
                    tooltip: 'Stop & Reset',
                    onPressed: () => recitation.stop(),
                  ),
                  const SizedBox(width: 14),

                  // Main Play / Pause Button
                  GestureDetector(
                    onTap: () => recitation.togglePlayPause(),
                    child: Container(
                      width: 60,
                      height: 60,
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
                                .withValues(alpha: 0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Center(
                        child: recitation.isLoading
                            ? const CircularProgressIndicator(
                                strokeWidth: 2.5,
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              )
                            : Icon(
                                recitation.isPlaying
                                    ? Icons.pause_rounded
                                    : Icons.play_arrow_rounded,
                                color: Colors.white,
                                size: 36,
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),

                  // Next Verse
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.skip_next_rounded),
                    color: isDark ? Colors.white70 : Colors.black87,
                    tooltip: 'Next Verse',
                    onPressed: () {
                      recitation.nextVerse();
                      onJumpToVerse();
                    },
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // Options: Playback Speed & Auto-Scroll
              Row(
                children: [
                  // Playback Speed
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pace / వేగం',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [0.75, 1.0, 1.25, 1.5].map((speed) {
                            final isSelected = recitation.playbackSpeed == speed;
                            return ChoiceChip(
                              label: Text('${speed}x'),
                              selected: isSelected,
                              selectedColor: const Color(0xFFFFB300),
                              onSelected: (_) =>
                                  recitation.setPlaybackSpeed(speed),
                              labelStyle: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.black87
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  // Repeat Target
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Repeat / ఆవర్తనాలు',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white70 : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          children: [1, 3, 7, 11].map((reps) {
                            final isSelected = recitation.repeatTarget == reps;
                            return ChoiceChip(
                              label: Text('${reps}x'),
                              selected: isSelected,
                              selectedColor: primary,
                              onSelected: (_) =>
                                  recitation.setRepeatTarget(reps),
                              labelStyle: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: isSelected
                                    ? Colors.white
                                    : (isDark ? Colors.white70 : Colors.black87),
                              ),
                              visualDensity: VisualDensity.compact,
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Auto-Scroll Toggle Switch
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(
                  'Auto-Scroll with Recitation',
                  style: GoogleFonts.outfit(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Automatically scroll reading view to active verse card',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                value: recitation.isAutoScrollEnabled,
                activeTrackColor: const Color(0xFFFFB300),
                onChanged: (_) {
                  recitation.toggleAutoScroll();
                  if (recitation.isAutoScrollEnabled) {
                    onJumpToVerse();
                  }
                },
              ),

              const SizedBox(height: 12),

              // Jump Directly to Verse Chips
              Text(
                'Jump to Verse / శీఘ్ర గమనం',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                height: 38,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  physics: const BouncingScrollPhysics(),
                  itemCount: verses.length,
                  separatorBuilder: (context, index) => const SizedBox(width: 6),
                  itemBuilder: (context, index) {
                    final v = verses[index];
                    final isCurrent = index == recitation.currentVerseIndex;
                    return InkWell(
                      onTap: () {
                        recitation.jumpToVerse(index);
                        onJumpToVerse();
                      },
                      borderRadius: BorderRadius.circular(10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: isCurrent
                              ? const Color(0xFFFFB300)
                              : (isDark
                                  ? const Color(0xFF2C2538)
                                  : const Color(0xFFF3ECE0)),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isCurrent
                                ? const Color(0xFFFFB300)
                                : (isDark
                                    ? const Color(0xFF483D59)
                                    : const Color(0xFFE0D5C1)),
                          ),
                        ),
                        child: Center(
                          child: Text(
                            v.verseNumber == 0 ? 'Doha' : '#${v.verseNumber}',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: isCurrent
                                  ? FontWeight.bold
                                  : FontWeight.w500,
                              color: isCurrent
                                  ? Colors.black87
                                  : (isDark ? Colors.white70 : Colors.black87),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
