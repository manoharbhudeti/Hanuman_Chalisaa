import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/chalisa_data.dart';
import '../providers/counter_provider.dart';
import '../providers/reading_settings_provider.dart';
import '../providers/recitation_provider.dart';
import '../services/chalisa_service.dart';
import '../widgets/completion_dialog.dart';
import '../widgets/font_size_sheet.dart';
import '../widgets/hanuman_intro_animation.dart';
import '../widgets/recitation_bottom_bar.dart';
import '../widgets/verse_card.dart';

class ReadingScreen extends StatefulWidget {
  final ChalisaService chalisaService;

  const ReadingScreen({super.key, required this.chalisaService});

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen> {
  late Future<ChalisaData> _dataFuture;
  final ScrollController _scrollController = ScrollController();
  final Map<int, GlobalKey> _verseKeys = {};
  bool _showBackToTop = false;
  int? _lastAutoScrolledIndex;

  @override
  void initState() {
    super.initState();
    _dataFuture = widget.chalisaService.loadChalisaData();
    _scrollController.addListener(() {
      final show = _scrollController.offset > 400;
      if (show != _showBackToTop) {
        setState(() {
          _showBackToTop = show;
        });
      }
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final recitation = context.read<RecitationProvider>();
        recitation.onCycleCompleted = () {
          if (mounted) {
            _handleMarkAsRead();
          }
        };
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToVerse(int index) {
    final key = _verseKeys[index];
    if (key?.currentContext != null) {
      Scrollable.ensureVisible(
        key!.currentContext!,
        duration: const Duration(milliseconds: 650),
        curve: Curves.easeInOutCubic,
        alignment: 0.12,
      );
    } else {
      if (_scrollController.hasClients) {
        final maxScroll = _scrollController.position.maxScrollExtent;
        final targetOffset = (index / 43.0) * maxScroll;
        _scrollController.animateTo(
          targetOffset,
          duration: const Duration(milliseconds: 650),
          curve: Curves.easeInOutCubic,
        );
      }
    }
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeOutCubic,
    );
  }

  void _showAnimationModal(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Animation',
      barrierColor: Colors.black.withValues(alpha: 0.85),
      pageBuilder: (ctx, anim1, anim2) {
        return Scaffold(
          backgroundColor: const Color(0xFF19161B),
          body: SafeArea(
            child: HanumanIntroAnimation(
              showCloseButton: true,
              onClose: () => Navigator.of(ctx).pop(),
              onBeginJourney: () => Navigator.of(ctx).pop(),
            ),
          ),
        );
      },
    );
  }

  void _showPreferencesSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const FontSizeSheet(),
    );
  }

  Future<void> _handleMarkAsRead() async {
    final counterProvider = context.read<CounterProvider>();
    final isTargetReached = await counterProvider.markReadingComplete();

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (_) => CompletionDialog(
        todayCount: counterProvider.todayCount,
        totalCount: counterProvider.totalCount,
        targetGoal: counterProvider.targetGoal,
        isGoalAchieved: isTargetReached,
        onReadAgain: _scrollToTop,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;
    final settings = context.watch<ReadingSettingsProvider>();
    final counter = context.watch<CounterProvider>();
    final recitation = context.watch<RecitationProvider>();

    if (recitation.isAutoScrollEnabled && recitation.isPlaying) {
      if (_lastAutoScrolledIndex != recitation.currentVerseIndex) {
        _lastAutoScrolledIndex = recitation.currentVerseIndex;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _scrollToVerse(recitation.currentVerseIndex);
        });
      }
    }

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.only(left: 10, top: 6, bottom: 6),
          child: InkWell(
            onTap: () => _showAnimationModal(context),
            borderRadius: BorderRadius.circular(10),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.asset(
                'assets/images/app_logo.png',
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
        title: Column(
          children: [
            Text(
              'श्री हनुमान चालीसा',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
                letterSpacing: 0.3,
              ),
            ),
            Text(
              'శ్రీ హనుమాన్ చాలీసా • Sacred Path',
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
            icon: const Icon(Icons.auto_awesome_rounded,
                color: Color(0xFFFFB300)),
            tooltip: 'Bal Hanuman Story Animation',
            onPressed: () => _showAnimationModal(context),
          ),
          IconButton(
            icon: const Icon(Icons.format_size_rounded),
            tooltip: 'Adjust text size & language',
            onPressed: _showPreferencesSheet,
          ),
        ],
      ),
      bottomNavigationBar: FutureBuilder<ChalisaData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const SizedBox.shrink();
          return RecitationBottomBar(
            verses: snapshot.data!.allVerses,
            onScrollToActiveVerse: () =>
                _scrollToVerse(recitation.currentVerseIndex),
          );
        },
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton.small(
              onPressed: _scrollToTop,
              tooltip: 'Scroll to top',
              child: const Icon(Icons.arrow_upward_rounded),
            )
          : null,
      body: FutureBuilder<ChalisaData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline_rounded,
                        size: 48, color: Colors.redAccent),
                    const SizedBox(height: 12),
                    Text(
                      'Failed to load Chalisa offline data',
                      style: GoogleFonts.outfit(fontSize: 16),
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _dataFuture = widget.chalisaService.loadChalisaData();
                        });
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          final data = snapshot.data!;

          return ListView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // Top Quick Bar & Auto-Scroll Session Invocation Card
              _buildTopInvocationCard(
                context,
                isDark,
                primary,
                settings,
                counter,
                recitation,
              ),

              // Section 1: Opening Dohas
              _buildSectionHeader(
                context,
                title: 'प्रारम्भिक दोहा (Opening Dohas)',
                subtitle: 'ప్రారంభ దోహాలు • Invocatory Verses',
                primary: primary,
              ),
              ...data.openingDohas.asMap().entries.map(
                (entry) {
                  final index = entry.key;
                  final verse = entry.value;
                  return VerseCard(
                    key: _verseKeys.putIfAbsent(index, () => GlobalKey()),
                    verse: verse,
                    languageMode: settings.languageMode,
                    meaningLanguageMode: settings.meaningLanguageMode,
                    devanagariFontStyle: settings.devanagariFontStyle,
                    fontSize: settings.fontSize,
                    showTransliteration: settings.showTransliteration,
                    showQuickMeaning: settings.showQuickMeaning,
                    isHighlighted: recitation.currentVerseIndex == index,
                    onTap: () {
                      recitation.jumpToVerse(index);
                      _scrollToVerse(index);
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Section 2: 40 Chaupais
              _buildSectionHeader(
                context,
                title: 'चालीसा चौपाई (40 Chaupais)',
                subtitle: 'చాలీసా చౌపాయీలు • 40 Sacred Stanzas',
                primary: primary,
              ),
              ...data.chaupais.asMap().entries.map(
                (entry) {
                  final index = 2 + entry.key;
                  final verse = entry.value;
                  return VerseCard(
                    key: _verseKeys.putIfAbsent(index, () => GlobalKey()),
                    verse: verse,
                    languageMode: settings.languageMode,
                    meaningLanguageMode: settings.meaningLanguageMode,
                    devanagariFontStyle: settings.devanagariFontStyle,
                    fontSize: settings.fontSize,
                    showTransliteration: settings.showTransliteration,
                    showQuickMeaning: settings.showQuickMeaning,
                    isHighlighted: recitation.currentVerseIndex == index,
                    onTap: () {
                      recitation.jumpToVerse(index);
                      _scrollToVerse(index);
                    },
                  );
                },
              ),

              const SizedBox(height: 16),

              // Section 3: Closing Doha
              _buildSectionHeader(
                context,
                title: 'समापन दोहा (Closing Doha)',
                subtitle: 'ముగింపు దోహా • Concluding Benediction',
                primary: primary,
              ),
              ...data.closingDohas.asMap().entries.map(
                (entry) {
                  final index = 42 + entry.key;
                  final verse = entry.value;
                  return VerseCard(
                    key: _verseKeys.putIfAbsent(index, () => GlobalKey()),
                    verse: verse,
                    languageMode: settings.languageMode,
                    meaningLanguageMode: settings.meaningLanguageMode,
                    devanagariFontStyle: settings.devanagariFontStyle,
                    fontSize: settings.fontSize,
                    showTransliteration: settings.showTransliteration,
                    showQuickMeaning: settings.showQuickMeaning,
                    isHighlighted: recitation.currentVerseIndex == index,
                    onTap: () {
                      recitation.jumpToVerse(index);
                      _scrollToVerse(index);
                    },
                  );
                },
              ),

              const SizedBox(height: 24),

              // End of Chalisa Completion Action Box
              _buildCompletionCard(context, isDark, primary),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTopInvocationCard(
    BuildContext context,
    bool isDark,
    Color primary,
    ReadingSettingsProvider settings,
    CounterProvider counter,
    RecitationProvider recitation,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: isDark ? 0.25 : 0.12),
            isDark ? const Color(0xFF1F1A28) : const Color(0xFFFFF9EE),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primary.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.auto_stories_rounded, color: primary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    'Parayan Session',
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: primary,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: isDark ? 0.3 : 0.15),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'Today: ${counter.todayCount} / ${counter.targetGoal}',
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Auto-Scroll Prominent Start / Pause Action Button
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: recitation.isPlaying
                  ? const Color(0xFFFFB300).withValues(alpha: 0.15)
                  : primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: recitation.isPlaying
                    ? const Color(0xFFFFB300)
                    : primary.withValues(alpha: 0.25),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      recitation.togglePlayPause();
                      if (recitation.isPlaying) {
                        _scrollToVerse(recitation.currentVerseIndex);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Icon(
                            recitation.isPlaying
                                ? Icons.pause_circle_filled_rounded
                                : Icons.play_circle_fill_rounded,
                            color: recitation.isPlaying
                                ? const Color(0xFFFFB300)
                                : primary,
                            size: 26,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  recitation.isPlaying
                                      ? 'Auto-Scrolling Active'
                                      : 'Start Auto-Scroll Reading',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: recitation.isPlaying
                                        ? const Color(0xFFFFB300)
                                        : primary,
                                  ),
                                ),
                                Text(
                                  recitation.isPlaying
                                      ? 'Reading Verse #${recitation.currentVerseIndex + 1} of 43'
                                      : 'స్వయం చలనం ప్రారంభించండి',
                                  style: GoogleFonts.outfit(
                                    fontSize: 11,
                                    color: isDark ? Colors.white60 : Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                // Speed Chip
                InkWell(
                  onTap: () => recitation.cyclePlaybackSpeed(),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: primary.withValues(alpha: 0.3)),
                    ),
                    child: Text(
                      '${recitation.playbackSpeed}x',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          // Language pills quick selector
          Row(
            children: [
              Expanded(
                child: _buildLangPill(
                  title: 'अवधी',
                  isSelected: settings.languageMode == LanguageMode.awadhi,
                  onTap: () => settings.setLanguageMode(LanguageMode.awadhi),
                  primary: primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLangPill(
                  title: 'తెలుగు',
                  isSelected: settings.languageMode == LanguageMode.telugu,
                  onTap: () => settings.setLanguageMode(LanguageMode.telugu),
                  primary: primary,
                  isDark: isDark,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildLangPill(
                  title: 'Both (ఉభయ)',
                  isSelected: settings.languageMode == LanguageMode.both,
                  onTap: () => settings.setLanguageMode(LanguageMode.both),
                  primary: primary,
                  isDark: isDark,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLangPill({
    required String title,
    required bool isSelected,
    required VoidCallback onTap,
    required Color primary,
    required bool isDark,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? primary
              : (isDark
                  ? Colors.black.withValues(alpha: 0.25)
                  : Colors.white.withValues(alpha: 0.8)),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected ? primary : primary.withValues(alpha: 0.2),
          ),
        ),
        child: Text(
          title,
          style: GoogleFonts.outfit(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected
                ? (isDark ? Colors.black87 : Colors.white)
                : (isDark ? Colors.white70 : Colors.black87),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Color primary,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 4,
                height: 18,
                decoration: BoxDecoration(
                  color: primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.cinzel(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 12, top: 2),
            child: Text(
              subtitle,
              style: GoogleFonts.outfit(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCompletionCard(BuildContext context, bool isDark, Color primary) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            primary.withValues(alpha: isDark ? 0.3 : 0.15),
            isDark ? const Color(0xFF241C2E) : const Color(0xFFFFF3E0),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: primary.withValues(alpha: 0.35), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          const Icon(
            Icons.verified_rounded,
            size: 42,
            color: Color(0xFFFF9800),
          ),
          const SizedBox(height: 10),
          Text(
            '॥ इति श्रीहनुमानचालीसा सम्पूर्णा ॥',
            style: GoogleFonts.notoSansDevanagari(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: primary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'You have reached the auspicious completion of your reading.',
            textAlign: TextAlign.center,
            style: GoogleFonts.outfit(
              fontSize: 14,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _handleMarkAsRead,
              icon: const Icon(Icons.check_circle_rounded, size: 22),
              label: const Text('Mark as Read / పూర్తయింది'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
