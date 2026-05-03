void main() {
  String p = 'https://291013.tayssir-bac.com/storage/610/01K6ACP23M6VP3DRJHX8FQW7Q2.png';
  final storageRegex = RegExp(r'https?://.*tayssir-bac\.com/storage/');
  if (storageRegex.hasMatch(p)) {
    final parts = p.split('/storage/');
    if (parts.length > 1) {
      print('MATCHED: https://291013.tayssir-bac.com/images.php?path=${parts.last}');
    }
  } else {
    print('DID NOT MATCH');
  }
}
