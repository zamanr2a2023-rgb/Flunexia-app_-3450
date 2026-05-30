import 'package:flutter/material.dart';
import 'package:flunexia_app/core/theme/app_theme.dart';
import 'package:flunexia_app/features/auth/screens/login_screen.dart';

void main() {
  runApp(const FlunexiaApp());
}

class FlunexiaApp extends StatelessWidget {
  const FlunexiaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flunexia',
      theme: AppTheme.light,
      debugShowCheckedModeBanner: false,
      home: const LoginScreen(),
    );
  }
}
