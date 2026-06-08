import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home_screen.dart';
import 'presentation/screens/game_screen.dart';
import 'presentation/providers/theme_provider.dart';

class AuraGlideApp extends ConsumerWidget {
  const AuraGlideApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeProvider);

    return MaterialApp(
      title: 'AuraGlide',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
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