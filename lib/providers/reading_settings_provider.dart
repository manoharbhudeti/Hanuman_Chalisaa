import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum LanguageMode {
  awadhi,
  telugu,
  both;

  String get label {
    switch (this) {
      case LanguageMode.awadhi:
        return 'अवधी (Hindi)';
      case LanguageMode.telugu:
        return 'తెలుగు (Telugu)';
      case LanguageMode.both:
        return 'Both (ఉభయ)';
    }
  }
}

enum MeaningLanguageMode {
  telugu,
  english,
  both;

  String get label {
    switch (this) {
      case MeaningLanguageMode.telugu:
        return 'తెలుగు (Telugu)';
      case MeaningLanguageMode.english:
        return 'English';
      case MeaningLanguageMode.both:
        return 'Both (ఉభయ)';
    }
  }
}

enum DevanagariFontStyle {
  notoSans,
  martel;

  String get label {
    switch (this) {
      case DevanagariFontStyle.notoSans:
        return 'Noto Sans (Crystal Clear)';
      case DevanagariFontStyle.martel:
        return 'Martel (Sacred Serif)';
    }
  }
}

class ReadingSettingsProvider extends ChangeNotifier {
  static const String _keyLang = 'reading_lang_mode';
  static const String _keyMeaningLang = 'reading_meaning_lang_mode';
  static const String _keyDevanagariFont = 'reading_devanagari_font';
  static const String _keyFontSize = 'reading_font_size';
  static const String _keyShowTranslit = 'reading_show_translit';
  static const String _keyShowQuickMeaning = 'reading_show_quick_meaning';

  LanguageMode _languageMode = LanguageMode.both;
  MeaningLanguageMode _meaningLanguageMode = MeaningLanguageMode.both;
  DevanagariFontStyle _devanagariFontStyle = DevanagariFontStyle.notoSans;
  double _fontSize = 19.0;
  bool _showTransliteration = true;
  bool _showQuickMeaning = true;

  ReadingSettingsProvider() {
    _loadSettings();
  }

  LanguageMode get languageMode => _languageMode;
  MeaningLanguageMode get meaningLanguageMode => _meaningLanguageMode;
  DevanagariFontStyle get devanagariFontStyle => _devanagariFontStyle;
  double get fontSize => _fontSize;
  bool get showTransliteration => _showTransliteration;
  bool get showQuickMeaning => _showQuickMeaning;

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    final langStr = prefs.getString(_keyLang);
    if (langStr != null) {
      if (langStr == 'awadhi') {
        _languageMode = LanguageMode.awadhi;
      } else if (langStr == 'telugu') {
        _languageMode = LanguageMode.telugu;
      } else {
        _languageMode = LanguageMode.both;
      }
    }

    final meaningStr = prefs.getString(_keyMeaningLang);
    if (meaningStr != null) {
      if (meaningStr == 'telugu') {
        _meaningLanguageMode = MeaningLanguageMode.telugu;
      } else if (meaningStr == 'english') {
        _meaningLanguageMode = MeaningLanguageMode.english;
      } else {
        _meaningLanguageMode = MeaningLanguageMode.both;
      }
    }

    final fontStr = prefs.getString(_keyDevanagariFont);
    if (fontStr != null) {
      if (fontStr == 'martel') {
        _devanagariFontStyle = DevanagariFontStyle.martel;
      } else {
        _devanagariFontStyle = DevanagariFontStyle.notoSans;
      }
    }

    _fontSize = prefs.getDouble(_keyFontSize) ?? 19.0;
    _showTransliteration = prefs.getBool(_keyShowTranslit) ?? true;
    _showQuickMeaning = prefs.getBool(_keyShowQuickMeaning) ?? true;
    notifyListeners();
  }

  Future<void> setLanguageMode(LanguageMode mode) async {
    _languageMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLang, mode.name);
  }

  Future<void> setMeaningLanguageMode(MeaningLanguageMode mode) async {
    _meaningLanguageMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMeaningLang, mode.name);
  }

  Future<void> setDevanagariFontStyle(DevanagariFontStyle style) async {
    _devanagariFontStyle = style;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDevanagariFont, style.name);
  }

  Future<void> setFontSize(double size) async {
    final clamped = size.clamp(14.0, 28.0);
    _fontSize = clamped;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyFontSize, clamped);
  }

  Future<void> increaseFontSize() async {
    if (_fontSize < 28.0) {
      await setFontSize(_fontSize + 2.0);
    }
  }

  Future<void> decreaseFontSize() async {
    if (_fontSize > 14.0) {
      await setFontSize(_fontSize - 2.0);
    }
  }

  Future<void> toggleTransliteration() async {
    _showTransliteration = !_showTransliteration;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowTranslit, _showTransliteration);
  }

  Future<void> toggleQuickMeaning() async {
    _showQuickMeaning = !_showQuickMeaning;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyShowQuickMeaning, _showQuickMeaning);
  }
}
