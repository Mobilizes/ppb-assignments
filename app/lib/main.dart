import 'dart:async';

import 'package:app/firebase_options.dart';
import 'package:app/pages/history_page.dart';
import 'package:app/pages/login_page.dart';
import 'package:app/pages/mic_page.dart';
import 'package:app/pages/register_page.dart';
import 'package:app/repositories/history_repository.dart';
import 'package:app/repositories/user_repository.dart';
import 'package:app/services/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

void main() {
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();
      await dotenv.load(fileName: ".env");

      await NotificationService.initializeNotification();

      try {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
      } catch (e) {
        debugPrint("Firebase initialization failed: $e");
      }

      runApp(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (context) => UserRepository()),
            ChangeNotifierProxyProvider<UserRepository, HistoryRepository>(
              create: (context) => HistoryRepository(),
              update: (context, userRepo, historyRepo) {
                final repo = historyRepo ?? HistoryRepository();
                debugPrint("ProxyProvider: Updating HistoryRepository with user ${userRepo.currentUser?.id}");
                repo.updateUserId(userRepo.currentUser?.id);
                return repo;
              },
            ),
          ],
          child: const HomePage(),
        ),
      );
    },
    (error, stack) {
      debugPrint('Uncaught Error: $error\n$stack');
    },
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Voice Volume Tracker',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.indigo,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(centerTitle: true, elevation: 0),
        cardTheme: CardThemeData(
          elevation: 2,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: ThemeMode.system,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashPage(),
        '/login': (context) => const LoginPage(),
        '/register': (context) => const RegisterPage(),
        '/': (context) => const MicPage(),
        '/history': (context) => const HistoryPage(),
      },
    );
  }
}

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  @override
  void initState() {
    super.initState();
    _checkSession();
  }

  Future<void> _checkSession() async {
    final userRepo = context.read<UserRepository>();
    try {
      await userRepo.checkSession();
    } catch (e) {
      debugPrint("Error checking session: $e");
    }
    if (mounted) {
      if (userRepo.isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }
}
