import 'package:shared_preferences/shared_preferences.dart';

class TimerPrefs {
  static const String _key = 'last_timer_seconds';

  static Future<int> getLastDurationSeconds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_key) ?? 60; // default 60s if never set before
  }

  static Future<void> setLastDurationSeconds(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_key, seconds);
  }
}