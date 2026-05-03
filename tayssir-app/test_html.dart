import 'package:flutter/widgets.dart';

void main() {
  HtmlElementView.fromTagName(
    tagName: 'img',
    onElementCreated: (Object element) {
      // (element as web.HTMLImageElement).src = 'test';
    },
  );
}
