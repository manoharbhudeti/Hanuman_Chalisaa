import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';
import '../widgets/completion_dialog.dart';

class CounterScreen extends StatelessWidget {
  const CounterScreen({super.key});

  void _showResetDialog(BuildContext context, CounterProvider counter) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          'Reset Reading Counter',
          style: GoogleFonts.cinzel(fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Choose which counter you would like to reset:',
          style: GoogleFonts.outfit(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await counter.resetToday();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            child: const Text("Reset Today's"),
          ),
          ElevatedButton(
            onPressed: () async {
              await counter.resetAll();
              if (ctx.mounted) Navigator.of(ctx).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              foregroundColor: Colors.white,
            ),
            child: const Text('Reset All (Lifetime)'),
          ),
        ],
      ),
    );
  }

  void _showTargetGoalPicker(BuildContext context, CounterProvider counter) {
    final targets = [1, 3, 7, 11, 21, 54, 108];
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(ctx).brightness == Brightness.dark;
        final primary = Theme.of(ctx).primaryColor;

        return Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E1A28) : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Select Daily Parayan Target',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Traditionally, 11 or 108 recitations are considered particularly auspicious.',
                textAlign: TextAlign.center,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 12,
                runSpacing: 12,
                alignment: WrapAlignment.center,
                children: targets.map((goal) {
                  final isSelected = counter.targetGoal == goal;
                  return ChoiceChip(
                    label: Text('$goal times'),
                    selected: isSelected,
                    selectedColor: primary,
                    labelStyle: GoogleFonts.outfit(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? (isDark ? Colors.black87 : Colors.white)
                          : (isDark ? Colors.white70 : Colors.black87),
                    ),
                    onSelected: (selected) {
                      if (selected) {
                        counter.setTargetGoal(goal);
                        Navigator.of(ctx).pop();
                      }
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final counter = context.watch<CounterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'जाप एवं पाठ ट्रैकर',
              style: GoogleFonts.rozhaOne(
                fontSize: 19,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            Text(
              'Parayan Counter & Daily Tracker',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Reset counter',
            onPressed: () => _showResetDialog(context, counter),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          children: [
            // Daily Streak Banner
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primary.withValues(alpha: isDark ? 0.25 : 0.15),
                    isDark ? const Color(0xFF261E33) : const Color(0xFFFFF3E0),
                  ],
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: primary.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: primary,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_fire_department_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '${counter.streakDays} Day Reading Streak',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        Text(
                          counter.streakDays > 0
                              ? 'Consistency strengthens the devotion and mind.'
                              : 'Start today to begin your sacred streak.',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Big Interactive Sacred Counter Ring (Tap Bead)
            GestureDetector(
              onTap: () async {
                final reached = await counter.increment();
                if (reached && context.mounted) {
                  showDialog(
                    context: context,
                    builder: (_) => CompletionDialog(
                      todayCount: counter.todayCount,
                      totalCount: counter.totalCount,
                      targetGoal: counter.targetGoal,
                      isGoalAchieved: true,
                      onReadAgain: () {},
                    ),
                  );
                }
              },
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Outer Glow Ring
                  Container(
                    width: 250,
                    height: 250,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: isDark ? 0.3 : 0.2),
                          blurRadius: 30,
                          spreadRadius: 4,
                        ),
                      ],
                    ),
                  ),

                  // Progress Circle
                  SizedBox(
                    width: 240,
                    height: 240,
                    child: CircularProgressIndicator(
                      value: counter.progressFraction,
                      strokeWidth: 10,
                      backgroundColor:
                          primary.withValues(alpha: isDark ? 0.15 : 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(primary),
                      strokeCap: StrokeCap.round,
                    ),
                  ),

                  // Center Bead
                  Container(
                    width: 205,
                    height: 205,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: isDark
                            ? [
                                const Color(0xFF2C243B),
                                const Color(0xFF191422),
                              ]
                            : [
                                Colors.white,
                                const Color(0xFFFFF7ED),
                              ],
                      ),
                      border: Border.all(
                        color: primary.withValues(alpha: 0.35),
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          '॥ ॐ ॥',
                          style: GoogleFonts.rozhaOne(
                            fontSize: 18,
                            color: primary,
                          ),
                        ),
                        Text(
                          '${counter.todayCount}',
                          style: GoogleFonts.outfit(
                            fontSize: 60,
                            fontWeight: FontWeight.w800,
                            color: primary,
                            height: 1.1,
                          ),
                        ),
                        Text(
                          'of ${counter.targetGoal} Completed',
                          style: GoogleFonts.outfit(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: isDark ? Colors.white60 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: primary.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'TAP TO LOG +1',
                            style: GoogleFonts.outfit(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                              color: primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),

            // Increment & Decrement Quick Controls
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton.filledTonal(
                  onPressed: () => counter.decrement(),
                  icon: const Icon(Icons.remove_rounded, size: 28),
                  tooltip: 'Decrement (-1)',
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(14),
                  ),
                ),
                const SizedBox(width: 24),
                IconButton.filled(
                  onPressed: () async {
                    final reached = await counter.increment();
                    if (reached && context.mounted) {
                      showDialog(
                        context: context,
                        builder: (_) => CompletionDialog(
                          todayCount: counter.todayCount,
                          totalCount: counter.totalCount,
                          targetGoal: counter.targetGoal,
                          isGoalAchieved: true,
                          onReadAgain: () {},
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.add_rounded, size: 28),
                  tooltip: 'Increment (+1)',
                  style: IconButton.styleFrom(
                    backgroundColor: primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 28),

            // Target Goal Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF1E1A28) : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: isDark
                      ? const Color(0xFF3F344F)
                      : const Color(0xFFFFE0B2),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Daily Target Goal',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                          Text(
                            'Aim for traditional 11, 21, or 108 recitations',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: isDark ? Colors.white54 : Colors.black45,
                            ),
                          ),
                        ],
                      ),
                      OutlinedButton(
                        onPressed: () => _showTargetGoalPicker(context, counter),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: primary.withValues(alpha: 0.4)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: Text(
                          '${counter.targetGoal} Times',
                          style: GoogleFonts.outfit(
                            fontWeight: FontWeight.bold,
                            color: primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(height: 24),

                  // Lifetime Total
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.workspace_premium_rounded,
                              color: Colors.amber, size: 22),
                          const SizedBox(width: 10),
                          Text(
                            'Lifetime Total Readings',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white70 : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${counter.totalCount} times',
                        style: GoogleFonts.outfit(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Sacred Benefit Note
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.08 : 0.05),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: primary.withValues(alpha: 0.15),
                ),
              ),
              child: Row(
                children: [
                  Icon(Icons.spa_rounded, color: primary, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'जो सत बार पाठ कर कोई, छूटहि बंदि महा सुख होई।\n(Chanting 100/108 times dispels all sorrows and brings boundless bliss)',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: isDark ? Colors.white70 : Colors.black87,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
