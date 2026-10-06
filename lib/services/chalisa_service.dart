import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/chalisa_data.dart';
import '../models/chalisa_verse.dart';

class ChalisaService {
  ChalisaData? _cachedData;

  /// Loads Hanuman Chalisa data from bundled offline assets
  Future<ChalisaData> loadChalisaData() async {
    if (_cachedData != null) {
      return _cachedData!;
    }

    try {
      final jsonString =
          await rootBundle.loadString('assets/data/hanuman_chalisa.json');
      final dynamic decoded = jsonDecode(jsonString);
      _cachedData = ChalisaData.fromJson(decoded as Map<String, dynamic>);
      return _cachedData!;
    } catch (e) {
      throw Exception('Failed to load Hanuman Chalisa offline asset: $e');
    }
  }

  /// Search verses by query in Awadhi, Telugu, English transliteration, or meaning
  List<ChalisaVerse> searchVerses(List<ChalisaVerse> verses, String query) {
    if (query.trim().isEmpty) return verses;
    final q = query.toLowerCase().trim();

    return verses.where((verse) {
      return verse.awadhi.toLowerCase().contains(q) ||
          verse.telugu.toLowerCase().contains(q) ||
          verse.transliteration.toLowerCase().contains(q) ||
          verse.meaningEn.toLowerCase().contains(q) ||
          verse.meaningTe.toLowerCase().contains(q) ||
          verse.title.toLowerCase().contains(q) ||
          verse.verseNumber.toString() == q;
    }).toList();
  }
}
