import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CounterProvider extends ChangeNotifier {
  static const String _keyTotalCount = 'counter_total_count';
  static const String _keyTodayCount = 'counter_today_count';
  static const String _keyLastDate = 'counter_last_date';
  static const String _keyTargetGoal = 'counter_target_goal';
  static const String _keyStreakDays = 'counter_streak_days';

  int _totalCount = 0;
  int _todayCount = 0;
  int _targetGoal = 11;
  int _streakDays = 0;
  String _lastDate = '';

  CounterProvider() {
    _loadCounterData();
  }

  int get totalCount => _totalCount;
  int get todayCount => _todayCount;
  int get targetGoal => _targetGoal;
  int get streakDays => _streakDays;
  double get progressFraction =>
      _targetGoal > 0 ? (_todayCount / _targetGoal).clamp(0.0, 1.0) : 0.0;
  bool get isTargetReached => _todayCount >= _targetGoal;

  String _formatDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  Future<void> _loadCounterData() async {
    final prefs = await SharedPreferences.getInstance();
    _totalCount = prefs.getInt(_keyTotalCount) ?? 0;
    _targetGoal = prefs.getInt(_keyTargetGoal) ?? 11;
    _streakDays = prefs.getInt(_keyStreakDays) ?? 0;
    _lastDate = prefs.getString(_keyLastDate) ?? '';

    final todayStr = _formatDate(DateTime.now());
    if (_lastDate == todayStr) {
      _todayCount = prefs.getInt(_keyTodayCount) ?? 0;
    } else {
      // Check if streak was yesterday
      final yesterdayStr =
          _formatDate(DateTime.now().subtract(const Duration(days: 1)));
      if (_lastDate != yesterdayStr && _lastDate.isNotEmpty) {
        // Missed a day, reset streak
        _streakDays = 0;
        await prefs.setInt(_keyStreakDays, 0);
      }
      _todayCount = 0;
      await prefs.setInt(_keyTodayCount, 0);
    }
    notifyListeners();
  }

  /// Mark Chalisa reading as complete (called at end of text or from counter)
  Future<bool> markReadingComplete() async {
    return await increment();
  }

  /// Increments reading counter with haptic feedback
  Future<bool> increment() async {
    HapticFeedback.mediumImpact();
    _totalCount++;
    _todayCount++;

    final todayStr = _formatDate(DateTime.now());
    if (_lastDate != todayStr) {
      _streakDays++;
      _lastDate = todayStr;
    }

    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotalCount, _totalCount);
    await prefs.setInt(_keyTodayCount, _todayCount);
    await prefs.setInt(_keyStreakDays, _streakDays);
    await prefs.setString(_keyLastDate, _lastDate);

    return isTargetReached;
  }

  /// Decrement counter if tapped by mistake
  Future<void> decrement() async {
    if (_todayCount > 0) {
      HapticFeedback.lightImpact();
      _todayCount--;
      if (_totalCount > 0) _totalCount--;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyTotalCount, _totalCount);
      await prefs.setInt(_keyTodayCount, _todayCount);
    }
  }

  /// Set user's custom daily target goal (e.g. 1, 7, 11, 21, 108)
  Future<void> setTargetGoal(int goal) async {
    if (goal > 0) {
      _targetGoal = goal;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt(_keyTargetGoal, goal);
    }
  }

  /// Reset today's count
  Future<void> resetToday() async {
    _todayCount = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTodayCount, 0);
  }

  /// Reset all counts (both today and all-time)
  Future<void> resetAll() async {
    _totalCount = 0;
    _todayCount = 0;
    _streakDays = 0;
    _lastDate = '';
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyTotalCount, 0);
    await prefs.setInt(_keyTodayCount, 0);
    await prefs.setInt(_keyStreakDays, 0);
    await prefs.setString(_keyLastDate, '');
  }
}
