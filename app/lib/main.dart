import 'package:app/history_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:app/mic_page.dart';
import 'package:app/repositories/history_repository.dart';

void main() async {
  await HistoryRepository.initialize();

  runApp(
    ChangeNotifierProvider(
      create: (context) => HistoryRepository(),
      child: const HomePage(),
    ),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => const MicPage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}
