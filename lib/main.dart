import 'package:flutter/material.dart';
import 'package:flutter_app/navigation/app_navigation.dart';
import 'package:flutter_app/screens/login.dart';
import 'package:flutter_app/theme/app_theme.dart';
import 'package:provider/provider.dart';
import 'package:flutter_app/providers/auth_provider.dart';
import 'package:flutter_app/services/api_service.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthProvider(
            apiService: ApiService(baseUrl: 'https://app.jbmanager.com/api/mobile'),
          ),
        ),
      ],
      child: MaterialApp(
        theme: AppTheme.themeData,
        home: LoginScreen(),
      ),
    ),
  );
}
