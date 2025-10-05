import 'package:flutter/material.dart';
import 'package:jbmanager/providers/auth_provider.dart';
import 'package:jbmanager/screens/login.dart';
import 'package:jbmanager/screens/home.dart';
import 'package:jbmanager/screens/splash.dart';
import 'package:jbmanager/theme/app_theme.dart';
import 'package:jbmanager/widgets/error_page.dart';
import 'package:provider/provider.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthProvider(),
      builder: (context, _) => MaterialApp(
        navigatorKey: navigatorKey,
        theme: AppTheme.themeData,
        home: const RootScreen(),
        onUnknownRoute: (settings) => MaterialPageRoute(
          builder: (_) => ErrorPage(
            title: 'Page Not Found',
            message: 'The page you requested does not exist.',
            onRetry: () {
              navigatorKey.currentState?.pop();
            },
          ),
        ),
      ),
    );
  }
}

class RootScreen extends StatefulWidget {
  const RootScreen({super.key});

  @override
  State<RootScreen> createState() => _RootScreenState();
}

class _RootScreenState extends State<RootScreen> {
  bool _isSimulatingSplash = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).loadUser();
    });
    // Future.delayed(const Duration(seconds: 4), () {
    //   setState(() {
    //     _isSimulatingSplash = false;
    //   });
    // });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        if (authProvider.isLoadingUser || _isSimulatingSplash) {
          return SplashScreen();
        }
        if (authProvider.isLoggedIn) {
          return MainScreen();
        } else {
          return LoginScreen();
        }
      },
    );
    // return FutureBuilder<bool>(
    //   future: _initialFetch,
    //   builder: (context, snapshot) {
    //     if (snapshot.connectionState == ConnectionState.waiting) {
    //       // Splash screen with spinner
    //       return Scaffold(body: Center(child: CircularProgressIndicator()));
    //     }
    //     if (snapshot.hasError) {
    //       // Optional error screen
    //       return Scaffold(body: Center(child: Text("Error loading settings")));
    //     }
    //
    //     if (snapshot.hasData && snapshot.data == true) {
    //       return MainScreen();
    //     } else {
    //       return LoginScreen();
    //     }
    //   },
    // );
  }
}
