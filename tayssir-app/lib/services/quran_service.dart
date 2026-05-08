import 'package:dio/dio.dart';

class QuranService {
  final Dio _dio = Dio();

  Future<List<String>> getSurahVerses(int surahId) async {
    try {
      final response = await _dio.get('https://api.quran.com/api/v4/quran/verses/uthmani', queryParameters: {
        'chapter_number': surahId,
      });
      
      if (response.statusCode == 200) {
        final List verses = response.data['verses'];
        return verses.map((v) => v['text_uthmani'] as String).toList();
      }
      return [];
    } catch (e) {
      return [];
    }
  }
}
