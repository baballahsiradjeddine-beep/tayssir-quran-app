import 'package:quran/quran.dart' as quran;

void main() {
  print("Surah 1, Verse 1: ${quran.getVerse(1, 1)}");
  // Check if there is a tajweed version
  try {
    print("Tajweed Data: ${quran.getVerse(1, 1, verseEndSymbol: true)}");
  } catch (e) {
    print("Error: $e");
  }
}
