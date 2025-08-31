import 'package:flutter/material.dart';
import 'package:flutter_app/screens/main.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'package:flutter_app/theme/sizes.dart';
import 'package:flutter_app/widgets/login_button.dart';
import 'package:lucide_icons/lucide_icons.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late AnimationController _bgAnimController;
  late AnimationController _animController;
  late Animation<double> _bgAnimation;
  late Animation<double> _animation;
  final _obscureCharacter = '•';
  bool _rememberMe = false;
  bool _isPasswordVisible = true;

  @override
  void initState() {
    super.initState();

    _emailController.text = 'dev@isium.fr';
    _passwordController.text = 'test@isium';

    _bgAnimController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    )..repeat(reverse: true);
    _bgAnimation = CurvedAnimation(
      parent: _bgAnimController,
      curve: Curves.easeInOut,
    );

    _animController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);
    _animation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeInOut,
    );
  }

  @override
  dispose() {
    _bgAnimController.stop();
    _animController.stop();
    _bgAnimController.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFF6F3F4), Color(0xFFEFF6FF), Color(0xFFF0FDF4)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _bgAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, 10 * _bgAnimation.value),
                  child: child,
                );
              },
              child: Stack(
                clipBehavior: Clip.none,
                children:
                    [
                      (-40, -40, null, null, 160, 160, 0xffbedbff, 0.2),
                      (
                        null,
                        (MediaQuery.of(context).size.height / 4).round(),
                        -80,
                        null,
                        240,
                        240,
                        0xffb9f8cf,
                        0.15,
                      ),
                      (
                        (MediaQuery.of(context).size.width / 3).round(),
                        null,
                        null,
                        -80,
                        320,
                        320,
                        0xffdbeafe,
                        0.1,
                      ),
                    ].map<Positioned>((elem) {
                      final int? left = elem.$1;
                      final int? top = elem.$2;
                      final int? right = elem.$3;
                      final int? bottom = elem.$4;
                      final width = elem.$5;
                      final height = elem.$6;
                      final color = elem.$7;
                      final a = elem.$8;
                      return Positioned(
                        left: left?.toDouble(),
                        top: top?.toDouble(),
                        right: right?.toDouble(),
                        bottom: bottom?.toDouble(),
                        width: width.toDouble(),
                        height: height.toDouble(),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Color(color).withValues(alpha: a),
                            shape: BoxShape.circle,
                            // color: Colors.blue.withValues(alpha: 0.2),
                          ),
                        ),
                      );
                    }).toList(),
              ),
            ),
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(Sizes.sapcing4),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedBuilder(
                        animation: _animation,
                        builder: (context, child) {
                          return Transform.translate(
                            offset: Offset(0, 10 * _animation.value),
                            child: child,
                          );
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.grey.withValues(alpha: 0.3),
                                spreadRadius: 3,
                                blurRadius: 16,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 32,
                            backgroundImage: NetworkImage(
                              'https://app.jbmanager.com/themes/default/images/rlogo.png',
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        'JB Manager',

                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Tableau de bord commercial',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: 400,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.2),
                              spreadRadius: 4,
                              blurRadius: 8,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(32.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Connexion',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                textAlign: TextAlign.center,
                                'Accédez à votre espace de gestion',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Email',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _emailController,
                                decoration: const InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  labelText: 'votre@email.com',
                                  prefixIcon: Icon(LucideIcons.mail),
                                ),
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Mot de passe',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 8),
                              TextField(
                                controller: _passwordController,
                                // can toggle obscureText
                                obscureText: _isPasswordVisible,
                                obscuringCharacter: _obscureCharacter,
                                decoration: InputDecoration(
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.never,
                                  labelText: _obscureCharacter * 8,
                                  prefixIcon: Icon(LucideIcons.lock),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _isPasswordVisible
                                          ? LucideIcons.eyeOff
                                          : LucideIcons.eye,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _isPasswordVisible =
                                            !_isPasswordVisible;
                                      });
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 30,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          onChanged: (bool? value) {
                                            setState(() {
                                              _rememberMe = value ?? false;
                                            });
                                          },
                                        ),
                                      ),
                                      const Text(
                                        'Se souvenir de moi',
                                        style: TextStyle(
                                          fontSize: Sizes.textXs,
                                        ),
                                      ),
                                    ],
                                  ),
                                  TextButton(
                                    onPressed: () {},
                                    child: const Text(
                                      'Mot de passe oublié ?',
                                      style: TextStyle(fontSize: Sizes.textXs),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Consumer<AuthProvider>(
                                builder: (context, authProvider, child) {
                                  return LoginButton(
                                    label: 'Se connecter',
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : () async {
                                            final email = _emailController.text;
                                            final password =
                                                _passwordController.text;
                                            await authProvider.login(
                                              email,
                                              password,
                                            );

                                            if (authProvider.isLoggedIn) {
                                              if (context.mounted) {
                                                Navigator.pushReplacement(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const MainScreen(),
                                                  ),
                                                );
                                              }
                                            } else {
                                              if (context.mounted) {
                                                showDialog(
                                                  context: context,
                                                  builder: (context) =>
                                                      AlertDialog(
                                                        title: const Text(
                                                          'Erreur de connexion',
                                                        ),
                                                        content: Text(
                                                          authProvider.error ??
                                                              'Unknown error',
                                                        ),
                                                        actions: [
                                                          TextButton(
                                                            onPressed: () =>
                                                                Navigator.pop(
                                                                  context,
                                                                ),
                                                            child: const Text(
                                                              'OK',
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                );
                                              }
                                            }
                                          },
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 32),
                      Text(
                        '© 2025 JB Manager. Tous droits réservés.',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
