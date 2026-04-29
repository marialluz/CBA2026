import 'package:flutter/material.dart';

import 'l10n/strings.dart';
import 'screens/home_screen.dart';

class CBA2026App extends StatelessWidget {
  const CBA2026App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: Strings.appTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1A73E8),
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
