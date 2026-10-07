import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/counter_provider.dart';
import '../providers/reading_settings_provider.dart';
import '../providers/theme_provider.dart';
import '../widgets/hanuman_intro_animation.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    final themeProvider = context.watch<ThemeProvider>();
    final readingSettings = context.watch<ReadingSettingsProvider>();
    final counterProvider = context.watch<CounterProvider>();

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'सेटिंग्स एवं सूचना',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            Text(
              'Settings & Devotional Info • విశేషాలు',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        children: [
          // Section: Appearance
          _buildSectionHeader('Appearance & Display', primary),
          _buildSettingsCard(
            isDark: isDark,
            primary: primary,
            children: [
              SwitchListTile(
                title: Text(
                  'Dark Mode (రాత్రి వేళ)',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Deep temple obsidian night palette',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                secondary: Icon(
                  isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                  color: primary,
                ),
                value: themeProvider.isDarkMode,
                activeTrackColor: primary,
                onChanged: (_) => themeProvider.toggleTheme(),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.format_size_rounded, color: primary),
                title: Text(
                  'Font Size: ${readingSettings.fontSize.toInt()} pt',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Slider(
                  value: readingSettings.fontSize,
                  min: 14.0,
                  max: 28.0,
                  divisions: 7,
                  activeColor: primary,
                  onChanged: (val) => readingSettings.setFontSize(val),
                ),
              ),
              const Divider(height: 1),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Default Scripture Language',
                      style: GoogleFonts.outfit(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SegmentedButton<LanguageMode>(
                      segments: const [
                        ButtonSegment(
                          value: LanguageMode.awadhi,
                          label: Text('अवधी'),
                        ),
                        ButtonSegment(
                          value: LanguageMode.telugu,
                          label: Text('తెలుగు'),
                        ),
                        ButtonSegment(
                          value: LanguageMode.both,
                          label: Text('Both'),
                        ),
                      ],
                      selected: {readingSettings.languageMode},
                      onSelectionChanged: (Set<LanguageMode> newSel) {
                        readingSettings.setLanguageMode(newSel.first);
                      },
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.auto_awesome_rounded,
                    color: Color(0xFFFFB300)),
                title: Text(
                  'Bal Hanuman Story Animation',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Playful 2D story animation with magical Gada',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                trailing: const Icon(Icons.play_circle_fill_rounded,
                    color: Color(0xFFFF6D00), size: 28),
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => Scaffold(
                        backgroundColor: const Color(0xFF19161B),
                        body: SafeArea(
                          child: HanumanIntroAnimation(
                            showCloseButton: true,
                            onClose: () => Navigator.of(context).pop(),
                            onBeginJourney: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section: Reading Options
          _buildSectionHeader('Reading Preferences', primary),
          _buildSettingsCard(
            isDark: isDark,
            primary: primary,
            children: [
              SwitchListTile(
                title: Text(
                  'Roman Transliteration',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Pronunciation guide in English script',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                secondary: Icon(Icons.spellcheck_rounded, color: primary),
                value: readingSettings.showTransliteration,
                activeTrackColor: primary,
                onChanged: (_) => readingSettings.toggleTransliteration(),
              ),
              const Divider(height: 1),
              SwitchListTile(
                title: Text(
                  'Quick Inline Meaning',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'Display English summary directly inside reading cards',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                secondary: Icon(Icons.subtitles_rounded, color: primary),
                value: readingSettings.showQuickMeaning,
                activeTrackColor: primary,
                onChanged: (_) => readingSettings.toggleQuickMeaning(),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section: Data & Storage
          _buildSectionHeader('Offline & Local Storage', primary),
          _buildSettingsCard(
            isDark: isDark,
            primary: primary,
            children: [
              ListTile(
                leading: const Icon(Icons.wifi_off_rounded, color: Colors.green),
                title: Text(
                  '100% Offline Capable',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                subtitle: Text(
                  'All Chalisa scriptures, Telugu scripts, and meanings are bundled locally. No internet needed.',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading:
                    const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                title: Text(
                  'Reset Reading Counts',
                  style: GoogleFonts.outfit(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.redAccent,
                  ),
                ),
                subtitle: Text(
                  'Clear all logged reading counts and streak records',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    color: isDark ? Colors.white54 : Colors.black45,
                  ),
                ),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => AlertDialog(
                      title: const Text('Reset All Data?'),
                      content: const Text(
                          'This will reset your lifetime reading counter and current streak.'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(ctx).pop(),
                          child: const Text('Cancel'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent),
                          onPressed: () {
                            counterProvider.resetAll();
                            Navigator.of(ctx).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Counter reset successfully'),
                              ),
                            );
                          },
                          child: const Text('Reset',
                              style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 20),

          // About Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: primary.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    'assets/images/app_logo.png',
                    width: 84,
                    height: 84,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '॥ श्री हनुमान चालीसा ॥',
                  style: GoogleFonts.notoSansDevanagari(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: primary,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Composed by Goswami Tulsidas in the 16th century in Awadhi language.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 13,
                    color: isDark ? Colors.white70 : Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Version 1.0.0 • Pure Devotional Edition',
                  style: GoogleFonts.outfit(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.black38,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color primary) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: GoogleFonts.cinzel(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: primary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard({
    required bool isDark,
    required Color primary,
    required List<Widget> children,
  }) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: isDark ? const Color(0xFF1E1A28) : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(
            color: isDark ? const Color(0xFF3F344F) : const Color(0xFFFFE0B2),
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: children,
        ),
      ),
    );
  }
}
