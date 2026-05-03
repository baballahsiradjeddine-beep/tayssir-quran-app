import 'package:flutter/foundation.dart';

class EnvironmentConfig {
  static const String apiBaseUrl = 'http://localhost:8001/api';
  // static const String apiBaseUrl = 'http://localhost:8000/api';

  static const String staticContentBaseUrl = 'http://localhost:8001/api';
  static const String boxPassword = 'tayssir';
  static const String imagesBaseUrl = 'http://localhost:8001/storage/';

  static String resolveImageUrl(String? path) {
    if (path == null || path.trim().isEmpty) return "";
    String p = path.trim();
    
    if (p.startsWith('http')) return p;
    if (p.startsWith('assets/')) return p;
    
    p = p.replaceFirst(RegExp(r'^/'), '');

    const String directUrl = 'http://localhost:8001/storage/';
    
    if (p.startsWith('storage/')) {
      p = p.replaceFirst('storage/', '');
    }

    if (p.isEmpty || p == '/') return "";
    
    return '$directUrl$p';

    return p;
  }
}
