import 'package:flutter/material.dart';

import '../screens/home.dart';
import '../theme/app_theme.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JB Manager',
      theme: AppTheme.themeData,
      // home: const MainScreen(),
    );
  }
}
