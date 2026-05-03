
void main() {
  final path = 'https://291013.tayssir-bac.com/storage/291/01K5GP6F5E23GWY5CW1K81PW4W.png';
  final storageRegex = RegExp(r'https?://.*tayssir-bac\.com/storage/');
  print('Matches: ${storageRegex.hasMatch(path)}');
  if (storageRegex.hasMatch(path)) {
    final parts = path.split('/storage/');
    print('Parts: $parts');
    print('Result: https://291013.tayssir-bac.com/images.php?path=${parts.last}');
  }
}
