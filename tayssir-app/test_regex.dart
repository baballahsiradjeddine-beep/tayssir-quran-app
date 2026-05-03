void main() {
  String p = "https://291013.tayssir-bac.com/storage/812/01K7YQ6TN6Q769EEH7BVF4M5R0.png";
  final storageRegex = RegExp(r'https?://.*tayssir-bac\.com/storage/');
  print('MATCH: \${storageRegex.hasMatch(p)}');
  if (storageRegex.hasMatch(p)) {
    final parts = p.split('/storage/');
    print('PARTS LEN: \${parts.length}');
    if (parts.length > 1) {
      print('RESULT: https://291013.tayssir-bac.com/images.php?path=\${parts.last}');
    }
  }
}
