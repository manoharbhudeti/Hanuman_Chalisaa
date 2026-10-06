enum VerseType {
  openingDoha,
  chaupai,
  closingDoha;

  String get displayName {
    switch (this) {
      case VerseType.openingDoha:
        return 'Opening Doha';
      case VerseType.chaupai:
        return 'Chaupai';
      case VerseType.closingDoha:
        return 'Closing Doha';
    }
  }

  String get displayNameHindi {
    switch (this) {
      case VerseType.openingDoha:
        return 'प्रारम्भिक दोहा';
      case VerseType.chaupai:
        return 'चौपाई';
      case VerseType.closingDoha:
        return 'समापन दोहा';
    }
  }

  String get displayNameTelugu {
    switch (this) {
      case VerseType.openingDoha:
        return 'ప్రారంభ దోహా';
      case VerseType.chaupai:
        return 'చౌపాయీ';
      case VerseType.closingDoha:
        return 'ముగింపు దోహా';
    }
  }
}

class ChalisaVerse {
  final int id;
  final VerseType type;
  final int verseNumber;
  final String title;
  final String awadhi;
  final String telugu;
  final String transliteration;
  final String meaningEn;
  final String meaningTe;
  final String spiritualInsight;

  const ChalisaVerse({
    required this.id,
    required this.type,
    required this.verseNumber,
    required this.title,
    required this.awadhi,
    required this.telugu,
    required this.transliteration,
    required this.meaningEn,
    required this.meaningTe,
    required this.spiritualInsight,
  });

  factory ChalisaVerse.fromJson(Map<String, dynamic> json) {
    VerseType parseType(String typeStr) {
      switch (typeStr) {
        case 'opening_doha':
          return VerseType.openingDoha;
        case 'closing_doha':
          return VerseType.closingDoha;
        case 'chaupai':
        default:
          return VerseType.chaupai;
      }
    }

    return ChalisaVerse(
      id: json['id'] as int,
      type: parseType(json['type'] as String? ?? 'chaupai'),
      verseNumber: json['verse_number'] as int? ?? 1,
      title: json['title'] as String? ?? '',
      awadhi: json['awadhi'] as String? ?? '',
      telugu: json['telugu'] as String? ?? '',
      transliteration: json['transliteration'] as String? ?? '',
      meaningEn: json['meaning_en'] as String? ?? '',
      meaningTe: json['meaning_te'] as String? ?? '',
      spiritualInsight: json['spiritual_insight'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type.name,
        'verse_number': verseNumber,
        'title': title,
        'awadhi': awadhi,
        'telugu': telugu,
        'transliteration': transliteration,
        'meaning_en': meaningEn,
        'meaning_te': meaningTe,
        'spiritual_insight': spiritualInsight,
      };
}
