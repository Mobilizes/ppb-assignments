import 'package:flutter/material.dart';

import 'package:app/mic_page.dart';

void main() {
  runApp(const HomePage());
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MicPage();
  }
}
