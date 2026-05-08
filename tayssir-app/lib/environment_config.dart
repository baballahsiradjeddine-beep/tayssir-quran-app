import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  static const String localIp = 'localhost';
  static const String apiBaseUrl = 'http://$localIp:8000/api/';

  static const String staticContentBaseUrl = 'http://$localIp:8000/api/';
  static const String boxPassword = 'tayssir';
  static const String imagesBaseUrl = 'http://$localIp:8000/storage/';

  static String resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return "";
    String p = path.trim();
    
    if (p.startsWith('http')) {
      // Replace localhost or emulator IP with the real local IP
      return p.replaceAll('localhost', localIp).replaceAll('10.0.2.2', localIp);
    }
    if (p.startsWith('assets/')) return p;
    
    p = p.replaceFirst(RegExp(r'^/'), '');

    const String directUrl = 'http://$localIp:8000/storage/';
    
    if (p.startsWith('storage/')) {
      p = p.replaceFirst('storage/', '');
    }

    if (p.isEmpty || p == '/') return "";
    
    return '$directUrl$p';
  }
}
