import 'chalisa_verse.dart';

class ChalisaData {
  final String title;
  final String titleTe;
  final String titleEn;
  final String author;
  final String description;
  final List<ChalisaVerse> openingDohas;
  final List<ChalisaVerse> chaupais;
  final List<ChalisaVerse> closingDohas;

  const ChalisaData({
    required this.title,
    required this.titleTe,
    required this.titleEn,
    required this.author,
    required this.description,
    required this.openingDohas,
    required this.chaupais,
    required this.closingDohas,
  });

  /// Flat list of all verses sequentially: Opening Dohas -> Chaupais -> Closing Doha
  List<ChalisaVerse> get allVerses => [
        ...openingDohas,
        ...chaupais,
        ...closingDohas,
      ];

  factory ChalisaData.fromJson(Map<String, dynamic> json) {
    return ChalisaData(
      title: json['title'] as String? ?? 'श्री हनुमान चालीसा',
      titleTe: json['title_te'] as String? ?? 'శ్రీ హనుమాన్ చాలీసా',
      titleEn: json['title_en'] as String? ?? 'Shri Hanuman Chalisa',
      author: json['author'] as String? ?? 'गोस्वामी तुलसीदास',
      description: json['description'] as String? ?? '',
      openingDohas: (json['opening_dohas'] as List<dynamic>? ?? [])
          .map((v) => ChalisaVerse.fromJson(v as Map<String, dynamic>))
          .toList(),
      chaupais: (json['chaupais'] as List<dynamic>? ?? [])
          .map((v) => ChalisaVerse.fromJson(v as Map<String, dynamic>))
          .toList(),
      closingDohas: (json['closing_dohas'] as List<dynamic>? ?? [])
          .map((v) => ChalisaVerse.fromJson(v as Map<String, dynamic>))
          .toList(),
    );
  }
}
