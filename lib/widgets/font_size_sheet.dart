import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/reading_settings_provider.dart';

class FontSizeSheet extends StatelessWidget {
  const FontSizeSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final settings = context.watch<ReadingSettingsProvider>();

    return Material(
      color: isDark ? const Color(0xFF1F1A28) : Colors.white,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reading Preferences',
                style: GoogleFonts.cinzel(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Script Selection Segmented Button
          Text(
            'Script / భాష',
            style: GoogleFonts.outfit(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
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
            selected: {settings.languageMode},
            onSelectionChanged: (Set<LanguageMode> newSelection) {
              settings.setLanguageMode(newSelection.first);
            },
            style: ButtonStyle(
              visualDensity: VisualDensity.compact,
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Font Size Slider
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Font Size',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white70 : Colors.black87,
                ),
              ),
              Text(
                '${settings.fontSize.toInt()} pt',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.text_decrease_rounded),
                color: primary,
                onPressed: () => settings.decreaseFontSize(),
              ),
              Expanded(
                child: Slider(
                  value: settings.fontSize,
                  min: 14.0,
                  max: 28.0,
                  divisions: 7,
                  activeColor: primary,
                  onChanged: (val) => settings.setFontSize(val),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.text_increase_rounded),
                color: primary,
                onPressed: () => settings.increaseFontSize(),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Transliteration Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: primary,
            title: Text(
              'Show Roman English Transliteration',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Phonetic pronunciation guide for each verse',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            value: settings.showTransliteration,
            onChanged: (_) => settings.toggleTransliteration(),
          ),

          // Quick Meaning Toggle
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            activeTrackColor: primary,
            title: Text(
              'Show Inline Meanings in Reading View',
              style: GoogleFonts.outfit(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
            subtitle: Text(
              'Display English summary directly under each verse',
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: isDark ? Colors.white38 : Colors.black45,
              ),
            ),
            value: settings.showQuickMeaning,
            onChanged: (_) => settings.toggleQuickMeaning(),
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}
}
