import 'package:intl/intl.dart';

class PrayerTimesHelper {
  static Map<String, String> getApproxPrayerTimes() {
    // This is a simplified version. In a real app, we'd use a package or API.
    // Here we return some generic times as a base.
    return {
      'Fajr': '04:30',
      'Dhuhr': '12:30',
      'Asr': '16:00',
      'Maghrib': '19:15',
      'Isha': '20:45',
    };
  }

  static bool isFlashChallengeActive() {
    final now = DateTime.now();
    final times = getApproxPrayerTimes();
    final formatter = DateFormat('HH:mm');
    final nowStr = formatter.format(now);

    // Flash challenge is active for 1 hour after each prayer
    for (var time in times.values) {
      final prayerTime = formatter.parse(time);
      final prayerDateTime = DateTime(now.year, now.month, now.day, prayerTime.hour, prayerTime.minute);
      final diff = now.difference(prayerDateTime).inMinutes;
      if (diff >= 0 && diff <= 60) {
        return true;
      }
    }
    return false;
  }

  static String getNextFlashTime() {
    final now = DateTime.now();
    final times = getApproxPrayerTimes();
    final formatter = DateFormat('HH:mm');

    for (var entry in times.entries) {
      final prayerTime = formatter.parse(entry.value);
      final prayerDateTime = DateTime(now.year, now.month, now.day, prayerTime.hour, prayerTime.minute);
      if (prayerDateTime.isAfter(now)) {
        return "${entry.key} (${entry.value})";
      }
    }
    return "الفجر (04:30)"; // Default for next day
  }
}
