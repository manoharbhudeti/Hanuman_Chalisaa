import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/chalisa_data.dart';
import '../models/chalisa_verse.dart';
import '../services/chalisa_service.dart';

class MeaningScreen extends StatefulWidget {
  final ChalisaService chalisaService;

  const MeaningScreen({super.key, required this.chalisaService});

  @override
  State<MeaningScreen> createState() => _MeaningScreenState();
}

class _MeaningScreenState extends State<MeaningScreen> {
  late Future<ChalisaData> _dataFuture;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedFilterIndex = 0; // 0: All, 1: Opening Dohas, 2: Chaupais, 3: Closing Doha

  @override
  void initState() {
    super.initState();
    _dataFuture = widget.chalisaService.loadChalisaData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.primaryColor;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(
              'अर्थ एवं भावार्थ',
              style: GoogleFonts.notoSansDevanagari(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary,
              ),
            ),
            Text(
              'Translations & Meanings • తాత్పర్యములు',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white60 : Colors.black54,
              ),
            ),
          ],
        ),
      ),
      body: FutureBuilder<ChalisaData>(
        future: _dataFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text('Unable to load meanings from offline storage'),
            );
          }

          final data = snapshot.data!;
          List<ChalisaVerse> activeList;
          if (_selectedFilterIndex == 1) {
            activeList = data.openingDohas;
          } else if (_selectedFilterIndex == 2) {
            activeList = data.chaupais;
          } else if (_selectedFilterIndex == 3) {
            activeList = data.closingDohas;
          } else {
            activeList = data.allVerses;
          }

          final filteredList =
              widget.chalisaService.searchVerses(activeList, _searchQuery);

          return Column(
            children: [
              // Search & Filter Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
                child: TextField(
                  controller: _searchController,
                  onChanged: (val) {
                    setState(() {
                      _searchQuery = val;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Search verse by word, meaning, or number...',
                    hintStyle: GoogleFonts.outfit(
                      fontSize: 13,
                      color: isDark ? Colors.white38 : Colors.black38,
                    ),
                    prefixIcon: Icon(Icons.search_rounded, color: primary),
                    suffixIcon: _searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _searchQuery = '';
                              });
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: isDark
                        ? const Color(0xFF1E1A26)
                        : const Color(0xFFF7F3EC),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: primary.withValues(alpha: 0.2)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(
                          color: primary.withValues(alpha: 0.2)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide(color: primary, width: 1.5),
                    ),
                  ),
                ),
              ),

              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    _buildFilterChip('All Verses (${data.allVerses.length})', 0, primary, isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Opening Dohas (2)', 1, primary, isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('40 Chaupais', 2, primary, isDark),
                    const SizedBox(width: 8),
                    _buildFilterChip('Closing Doha (1)', 3, primary, isDark),
                  ],
                ),
              ),

              // Verses List
              Expanded(
                child: filteredList.isEmpty
                    ? Center(
                        child: Text(
                          'No verses match "$_searchQuery"',
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredList.length,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        itemBuilder: (context, index) {
                          final verse = filteredList[index];
                          return _MeaningCard(
                            verse: verse,
                            isDark: isDark,
                            primary: primary,
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildFilterChip(
      String label, int index, Color primary, bool isDark) {
    final isSelected = _selectedFilterIndex == index;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedFilterIndex = index;
          });
        }
      },
      selectedColor: primary,
      labelStyle: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        color: isSelected
            ? (isDark ? Colors.black87 : Colors.white)
            : (isDark ? Colors.white70 : Colors.black87),
      ),
      backgroundColor:
          isDark ? const Color(0xFF1E1A26) : const Color(0xFFF0EAE1),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      showCheckmark: false,
    );
  }
}

class _MeaningCard extends StatefulWidget {
  final ChalisaVerse verse;
  final bool isDark;
  final Color primary;

  const _MeaningCard({
    required this.verse,
    required this.isDark,
    required this.primary,
  });

  @override
  State<_MeaningCard> createState() => _MeaningCardState();
}

class _MeaningCardState extends State<_MeaningCard> {
  bool _isExpanded = true;

  @override
  Widget build(BuildContext context) {
    final v = widget.verse;
    final isDark = widget.isDark;
    final primary = widget.primary;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1F1A28) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.25 : 0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          InkWell(
            onTap: () {
              setState(() {
                _isExpanded = !_isExpanded;
              });
            },
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: isDark ? 0.15 : 0.08),
                borderRadius: _isExpanded
                    ? const BorderRadius.vertical(top: Radius.circular(18))
                    : BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${v.verseNumber}',
                      style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: isDark ? Colors.black87 : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      v.title,
                      style: GoogleFonts.cinzel(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: primary,
                      ),
                    ),
                  ),
                  Icon(
                    _isExpanded
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: primary,
                  ),
                ],
              ),
            ),
          ),

          if (_isExpanded) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Devanagari Script
                  Text(
                    v.awadhi,
                    style: GoogleFonts.notoSansDevanagari(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFFFF8E7)
                          : const Color(0xFF3E2723),
                      height: 1.6,
                      letterSpacing: 0.25,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Telugu Script
                  Text(
                    v.telugu,
                    style: GoogleFonts.notoSansTelugu(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: isDark
                          ? const Color(0xFFFFECB3)
                          : const Color(0xFF4E342E),
                      height: 1.55,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Transliteration
                  Text(
                    v.transliteration,
                    style: GoogleFonts.outfit(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: isDark ? Colors.white60 : Colors.black54,
                    ),
                  ),
                  const Divider(height: 24),

                  // English Meaning
                  Row(
                    children: [
                      Icon(Icons.translate_rounded, size: 16, color: primary),
                      const SizedBox(width: 6),
                      Text(
                        'English Meaning',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    v.meaningEn,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark ? Colors.white.withValues(alpha: 0.9) : const Color(0xFF212121),
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Telugu Bhavam
                  Row(
                    children: [
                      Icon(Icons.auto_awesome_rounded, size: 16, color: primary),
                      const SizedBox(width: 6),
                      Text(
                        'తెలుగు భావార్థము (Telugu Meaning)',
                        style: GoogleFonts.outfit(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    v.meaningTe,
                    style: GoogleFonts.notoSansTelugu(
                      fontSize: 13.5,
                      color: isDark ? const Color(0xFFECEFF1) : const Color(0xFF37474F),
                      height: 1.5,
                    ),
                  ),

                  // Spiritual Insight
                  if (v.spiritualInsight.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: isDark ? 0.12 : 0.06),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: primary.withValues(alpha: 0.2),
                        ),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(Icons.lightbulb_rounded,
                              size: 18, color: primary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Spiritual Significance',
                                  style: GoogleFonts.outfit(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: primary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  v.spiritualInsight,
                                  style: GoogleFonts.outfit(
                                    fontSize: 12.5,
                                    color: isDark
                                        ? Colors.white70
                                        : Colors.black87,
                                    height: 1.35,
                                  ),
                                ),
                              ],
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
        ],
      ),
    );
  }
}
