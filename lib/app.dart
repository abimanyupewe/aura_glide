import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/game_screen.dart';

class AuraGlideApp extends StatelessWidget {
  const AuraGlideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AuraGlide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AppNavigator(),
    );
  }
}

class AppNavigator extends StatefulWidget {
  const AppNavigator({super.key});

  @override
  State<AppNavigator> createState() => _AppNavigatorState();
}

class _AppNavigatorState extends State<AppNavigator> {
  bool _showGame = false;

  @override
  Widget build(BuildContext context) {
    if (_showGame) {
      return const GameScreen();
    }

    return HomeScreen(
      onPlayPressed: () {
        setState(() {
          _showGame = true;
        });
      },
    );
  }
}