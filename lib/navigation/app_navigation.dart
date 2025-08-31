import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../screens/main.dart';
import '../theme/app_theme.dart';

class AppNavigation extends StatelessWidget {
  const AppNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'JB Manager',
      theme: AppTheme.themeData,
      home: const MainScreen(),
    );
  }
}
