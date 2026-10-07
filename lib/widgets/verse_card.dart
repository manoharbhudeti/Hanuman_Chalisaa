import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chalisa_verse.dart';
import '../providers/reading_settings_provider.dart';

class VerseCard extends StatefulWidget {
  final ChalisaVerse verse;
  final LanguageMode languageMode;
  final MeaningLanguageMode meaningLanguageMode;
  final DevanagariFontStyle devanagariFontStyle;
  final double fontSize;
  final bool showTransliteration;
  final bool showQuickMeaning;
  final bool isHighlighted;
  final VoidCallback? onTap;

  const VerseCard({
    super.key,
    required this.verse,
    required this.languageMode,
    this.meaningLanguageMode = MeaningLanguageMode.both,
    this.devanagariFontStyle = DevanagariFontStyle.notoSans,
    required this.fontSize,
    required this.showTransliteration,
    this.showQuickMeaning = true,
    this.isHighlighted = false,
    this.onTap,
  });

  @override
  State<VerseCard> createState() => _VerseCardState();
}

class _VerseCardState extends State<VerseCard> {
  bool? _isLocallyExpanded;

  bool get _shouldShowMeaning =>
      _isLocallyExpanded ?? widget.showQuickMeaning;

  void _toggleMeaning() {
    setState(() {
      _isLocallyExpanded = !_shouldShowMeaning;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.primaryColor;

    final textStyleDevanagari = widget.devanagariFontStyle ==
            DevanagariFontStyle.martel
        ? GoogleFonts.martel(
            fontSize: widget.fontSize * 1.05,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFFFF8E7) : const Color(0xFF2C1E18),
            height: 1.65,
          )
        : GoogleFonts.notoSansDevanagari(
            fontSize: widget.fontSize,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFFFFF8E7) : const Color(0xFF2C1E18),
            height: 1.65,
            letterSpacing: 0.25,
          );

    final textStyleTelugu = GoogleFonts.notoSansTelugu(
      fontSize: widget.fontSize * 0.95,
      fontWeight: FontWeight.w600,
      color: isDark ? const Color(0xFFFFECB3) : const Color(0xFF3E2723),
      height: 1.65,
    );

    final textStyleTranslit = GoogleFonts.outfit(
      fontSize: widget.fontSize * 0.75,
      fontStyle: FontStyle.italic,
      fontWeight: FontWeight.w400,
      color: isDark ? const Color(0xFFD7CCC8) : const Color(0xFF6D4C41),
      height: 1.45,
    );

    return GestureDetector(
      onTap: widget.onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: widget.isHighlighted
              ? primaryColor.withValues(alpha: isDark ? 0.22 : 0.09)
              : theme.cardTheme.color,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.isHighlighted
                ? const Color(0xFFFFB300)
                : (isDark ? const Color(0xFF3F344F) : const Color(0xFFFFE0B2)),
            width: widget.isHighlighted ? 2.0 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.isHighlighted
                  ? const Color(0xFFFFB300).withValues(alpha: isDark ? 0.35 : 0.2)
                  : Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
              blurRadius: widget.isHighlighted ? 14 : 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header Ribbon
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: widget.isHighlighted
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
                          color: widget.isHighlighted
                              ? const Color(0xFFFFB300)
                              : primaryColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '#${widget.verse.verseNumber}',
                          style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        widget.verse.title,
                        style: GoogleFonts.cinzel(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: widget.isHighlighted
                              ? const Color(0xFFFFB300)
                              : primaryColor,
                        ),
                      ),
                      if (widget.isHighlighted) ...[
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
                              const Icon(Icons.auto_stories_rounded,
                                  size: 12, color: Color(0xFFFFB300)),
                              const SizedBox(width: 3),
                              Text(
                                'Reading',
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
                  Row(
                    children: [
                      // Quick Meaning Toggle Chip
                      InkWell(
                        onTap: _toggleMeaning,
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 3),
                          decoration: BoxDecoration(
                            color: _shouldShowMeaning
                                ? primaryColor.withValues(alpha: 0.2)
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: primaryColor.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                _shouldShowMeaning
                                    ? Icons.menu_book_rounded
                                    : Icons.menu_book_outlined,
                                size: 13,
                                color: primaryColor,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                'భావము',
                                style: GoogleFonts.outfit(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: primaryColor,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Copy Verse Button
                      IconButton(
                        icon: const Icon(Icons.copy_rounded, size: 18),
                        tooltip: 'Copy verse with meaning',
                        color: primaryColor.withValues(alpha: 0.8),
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {
                          final buffer = StringBuffer();
                          buffer.writeln(widget.verse.title);
                          if (widget.languageMode == LanguageMode.awadhi ||
                              widget.languageMode == LanguageMode.both) {
                            buffer.writeln(widget.verse.awadhi);
                          }
                          if (widget.languageMode == LanguageMode.telugu ||
                              widget.languageMode == LanguageMode.both) {
                            buffer.writeln(widget.verse.telugu);
                          }
                          if (widget.showTransliteration &&
                              widget.verse.transliteration.isNotEmpty) {
                            buffer.writeln(widget.verse.transliteration);
                          }
                          if (widget.verse.meaningTe.isNotEmpty) {
                            buffer.writeln('\nభావార్థము (Telugu): ${widget.verse.meaningTe}');
                          }
                          if (widget.verse.meaningEn.isNotEmpty) {
                            buffer.writeln('Meaning (English): ${widget.verse.meaningEn}');
                          }
                          Clipboard.setData(ClipboardData(text: buffer.toString()));
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Copied ${widget.verse.title} to clipboard'),
                              duration: const Duration(seconds: 2),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        },
                      ),
                    ],
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
                  // Awadhi/Devanagari (Crystal Clear Noto Sans Devanagari)
                  if (widget.languageMode == LanguageMode.awadhi ||
                      widget.languageMode == LanguageMode.both) ...[
                    SelectableText(
                      widget.verse.awadhi,
                      textAlign: TextAlign.center,
                      style: textStyleDevanagari,
                    ),
                  ],

                  // Divider if both languages
                  if (widget.languageMode == LanguageMode.both) ...[
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
                  if (widget.languageMode == LanguageMode.telugu ||
                      widget.languageMode == LanguageMode.both) ...[
                    SelectableText(
                      widget.verse.telugu,
                      textAlign: TextAlign.center,
                      style: textStyleTelugu,
                    ),
                  ],

                  // Transliteration (English phonetic)
                  if (widget.showTransliteration &&
                      widget.verse.transliteration.isNotEmpty) ...[
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
                        widget.verse.transliteration,
                        textAlign: TextAlign.center,
                        style: textStyleTranslit,
                      ),
                    ),
                  ],

                  // Verse Meanings (Telugu & English)
                  if (_shouldShowMeaning) ...[
                    const SizedBox(height: 14),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primaryColor.withValues(alpha: isDark ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primaryColor.withValues(alpha: isDark ? 0.25 : 0.16),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Telugu Meaning
                          if ((widget.meaningLanguageMode == MeaningLanguageMode.telugu ||
                                  widget.meaningLanguageMode == MeaningLanguageMode.both) &&
                              widget.verse.meaningTe.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.auto_awesome_rounded,
                                    size: 14, color: primaryColor),
                                const SizedBox(width: 6),
                                Text(
                                  'తెలుగు భావార్థము (Telugu Meaning)',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            SelectableText(
                              widget.verse.meaningTe,
                              style: GoogleFonts.notoSansTelugu(
                                fontSize: widget.fontSize * 0.78,
                                fontWeight: FontWeight.w500,
                                color: isDark
                                    ? const Color(0xFFECEFF1)
                                    : const Color(0xFF263238),
                                height: 1.55,
                              ),
                            ),
                          ],

                          if (widget.meaningLanguageMode == MeaningLanguageMode.both &&
                              widget.verse.meaningTe.isNotEmpty &&
                              widget.verse.meaningEn.isNotEmpty)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Divider(
                                color: primaryColor.withValues(alpha: 0.15),
                                height: 1,
                              ),
                            ),

                          // English Meaning
                          if ((widget.meaningLanguageMode == MeaningLanguageMode.english ||
                                  widget.meaningLanguageMode == MeaningLanguageMode.both) &&
                              widget.verse.meaningEn.isNotEmpty) ...[
                            Row(
                              children: [
                                Icon(Icons.translate_rounded,
                                    size: 13,
                                    color: primaryColor.withValues(alpha: 0.85)),
                                const SizedBox(width: 6),
                                Text(
                                  'English Meaning',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: primaryColor.withValues(alpha: 0.9),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 3),
                            SelectableText(
                              widget.verse.meaningEn,
                              style: GoogleFonts.outfit(
                                fontSize: widget.fontSize * 0.74,
                                color: isDark
                                    ? const Color(0xFFCFD8DC)
                                    : const Color(0xFF455A64),
                                height: 1.45,
                              ),
                            ),
                          ],
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
