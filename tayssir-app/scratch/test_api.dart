import 'package:dio/dio.dart';
import 'dart:convert';

// Mocking ResponseX extension
extension ResponseX on Response {
  Map<String, dynamic> get customData {
    if (data is Map<String, dynamic>) {
      return data['data'];
    }
    return {};
  }
}

Future<void> main() async {
  final dio = Dio();
  dio.options.baseUrl = 'https://291013.tayssir-bac.com/api';
  dio.options.headers = {
    'Accept': 'application/json',
    'Authorization': 'Bearer 86776|HuryNRGeiNkjG0dQyENjO7ZlkeIjvy3fomfhjk75589603ac',
  };

  print('📡 Fetching /v2/content...');
  try {
    final response = await dio.get('/v2/content');
    print('✅ Response Status: ${response.statusCode}');
    
    final customData = response.customData;
    final modules = customData['modules'] as List? ?? [];
    print('📦 Modules Count: ${modules.length}');
    
    if (modules.isNotEmpty) {
      print('First Module: ${modules[0]['name']}');
    }
    
    final exercises = customData['exercices'] as List? ?? [];
    print('📝 Exercises (containers) Count: ${exercises.length}');
    
    if (exercises.isNotEmpty) {
      final firstEx = exercises[0];
      print('First Exercise contains questions: ${firstEx['questions'] != null}');
      if (firstEx['questions'] is List) {
        print('Questions count in first exercise: ${(firstEx['questions'] as List).length}');
      }
    }

  } catch (e) {
    print('❌ Error: $e');
  }
}
