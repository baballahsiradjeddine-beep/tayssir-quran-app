import 'package:shared_preferences/shared_preferences.dart';

class ChallengeLimitsManager {
  static const String _arenaDateKey = 'arena_limit_date';
  static const String _arenaCountKey = 'arena_limit_count';
  static const String _socialDateKey = 'social_limit_date';
  static const String _socialCountKey = 'social_limit_count';

  static Future<bool> canPlayArena(bool isPremium) async {
    if (isPremium) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final savedDate = prefs.getString(_arenaDateKey) ?? '';
    if (savedDate != today) {
      await prefs.setString(_arenaDateKey, today);
      await prefs.setInt(_arenaCountKey, 0);
      return true;
    }
    
    final count = prefs.getInt(_arenaCountKey) ?? 0;
    return count < 3;
  }

  static Future<void> incrementArenaCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final savedDate = prefs.getString(_arenaDateKey) ?? '';
    if (savedDate != today) {
      await prefs.setString(_arenaDateKey, today);
      await prefs.setInt(_arenaCountKey, 1);
    } else {
      final count = prefs.getInt(_arenaCountKey) ?? 0;
      await prefs.setInt(_arenaCountKey, count + 1);
    }
  }

  static Future<bool> canPlaySocial(bool isPremium) async {
    if (isPremium) return true;
    
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final savedDate = prefs.getString(_socialDateKey) ?? '';
    if (savedDate != today) {
      await prefs.setString(_socialDateKey, today);
      await prefs.setInt(_socialCountKey, 0);
      return true;
    }
    
    final count = prefs.getInt(_socialCountKey) ?? 0;
    return count < 3;
  }

  static Future<void> incrementSocialCount() async {
    final prefs = await SharedPreferences.getInstance();
    final today = DateTime.now().toIso8601String().split('T')[0];
    
    final savedDate = prefs.getString(_socialDateKey) ?? '';
    if (savedDate != today) {
      await prefs.setString(_socialDateKey, today);
      await prefs.setInt(_socialCountKey, 1);
    } else {
      final count = prefs.getInt(_socialCountKey) ?? 0;
      await prefs.setInt(_socialCountKey, count + 1);
    }
  }
}
