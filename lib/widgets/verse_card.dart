import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chalisa_verse.dart';
import '../providers/reading_settings_provider.dart';

class VerseCard extends StatelessWidget {
  final ChalisaVerse verse;
  final LanguageMode languageMode;
  final double fontSize;
  final bool showTransliteration;
  final bool showQuickMeaning;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const VerseCard({
    super.key,
    required this.verse,
    required this.languageMode,
    required this.fontSize,
    required this.showTransliteration,
    this.showQuickMeaning = false,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final primaryColor = theme.primaryColor;
    final textStyleDevanagari = GoogleFonts.rozhaOne(
      fontSize: fontSize,
      fontWeight: FontWeight.w500,
      color: isDark ? const Color(0xFFFFF8E7) : const Color(0xFF3E2723),
      height: 1.6,
    );

    final textStyleTelugu = GoogleFonts.notoSansTelugu(
      fontSize: fontSize * 0.95,
      fontWeight: FontWeight.w600,
      color: isDark ? const Color(0xFFFFECB3) : const Color(0xFF4E342E),
      height: 1.65,
    );

    final textStyleTranslit = GoogleFonts.outfit(
      fontSize: fontSize * 0.75,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w400,
      color: isDark ? const Color(0xFFD7CCC8) : const Color(0xFF6D4C41),
      height: 1.45,
    );

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isHighlighted
              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.09)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isHighlighted
                ? const Color(0xFFFFB300)
                : (isDark ? const Color(0xFF3F344F) : const Color(0xFFFFE0B2)),
            width: isHighlighted ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? const Color(0xFFFFB300).withValues(alpha: isDark ? 0.35 : 0.2)
                  : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: isHighlighted ? 14 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: isHighlighted
                    ? primaryColor.withValues(alpha: isDark ? 0.25 : 0.14)
                    : primaryColor.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: const BorderRadius.vertical(top: Radius.circular(17)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: isHighlighted ? const Color(0xFFFFB300) : primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${verse.verseNumber}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        verse.title,
                        style: GoogleFonts.cinzel(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: isHighlighted ? const Color(0xFFFFB300) : primaryColor,
                        ),
                      ),
                      if (isHighlighted) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB300).withValues(alpha: 0.25),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                                color: const Color(0xFFFFB300), width: 0.8),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.graphic_eq_rounded,
                                  size: 12, color: Color(0xFFFFB300)),
                              const SizedBox(width: 3),
                              Text(
                                'Active',
                                style: GoogleFonts.outfit(
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                  color: const Color(0xFFFFB300),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                IconButton(
                  icon: const Icon(Icons.copy_rounded, size: 18),
                  tooltip: 'Copy verse',
                  color: primaryColor.withValues(alpha: 0.8),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    final buffer = StringBuffer();
                    buffer.writeln(verse.title);
                    if (languageMode == LanguageMode.awadhi ||
                        languageMode == LanguageMode.both) {
                      buffer.writeln(verse.awadhi);
                    }
                    if (languageMode == LanguageMode.telugu ||
                        languageMode == LanguageMode.both) {
                      buffer.writeln(verse.telugu);
                    }
                    if (showTransliteration) {
                      buffer.writeln(verse.transliteration);
                    }
                    buffer.writeln('\nMeaning: ${verse.meaningEn}');
                    Clipboard.setData(ClipboardData(text: buffer.toString()));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Copied ${verse.title} to clipboard'),
                        duration: const Duration(seconds: 2),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // Main Scripture Content
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Awadhi/Devanagari
                if (languageMode == LanguageMode.awadhi ||
                    languageMode == LanguageMode.both) ...[
                  SelectableText(
                    verse.awadhi,
                    textAlign: TextAlign.center,
                    style: textStyleDevanagari,
                  ),
                ],

                // Divider if both languages
                if (languageMode == LanguageMode.both) ...[
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                          child: Divider(
                              color: primaryColor.withValues(alpha: 0.2))),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Icon(Icons.stars_rounded,
                            size: 14, color: primaryColor.withValues(alpha: 0.5)),
                      ),
                      Expanded(
                          child: Divider(
                              color: primaryColor.withValues(alpha: 0.2))),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],

                // Telugu Script
                if (languageMode == LanguageMode.telugu ||
                    languageMode == LanguageMode.both) ...[
                  SelectableText(
                    verse.telugu,
                    textAlign: TextAlign.center,
                    style: textStyleTelugu,
                  ),
                ],

                // Transliteration (English phonetic)
                if (showTransliteration && verse.transliteration.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark
                          ? Colors.black.withValues(alpha: 0.2)
                          : const Color(0xFFF7F2EB),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SelectableText(
                      verse.transliteration,
                      textAlign: TextAlign.center,
                      style: textStyleTranslit,
                    ),
                  ),
                ],

                // Optional Quick Meaning in Reading View
                if (showQuickMeaning) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: primaryColor.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.15),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Meaning / భావము',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: primaryColor,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          verse.meaningEn,
                          style: GoogleFonts.outfit(
                            fontSize: fontSize * 0.75,
                            color: isDark
                                ? const Color(0xFFE0E0E0)
                                : const Color(0xFF424242),
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    ),
  );
}
}
