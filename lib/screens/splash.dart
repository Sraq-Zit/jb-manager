import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jbmanager/theme/sizes.dart';
import 'package:jbmanager/widgets/blob.dart';
import 'package:jbmanager/widgets/ping_circle.dart';

import '../constants/assets.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Timer _timer;

  final double shift = 50.0;

  double scale = 0.8;
  List<double> bounce = List.filled(3, 0.0);
  int bounceRound = 0;

  final loadingRanges = [(0.0, 0.6), (0.2, 0.8), (0.4, 1.0)];
  final pings = [
    //          Size,Top,Left,Bottom,Right, Delay
    (Sizes.sapcing2, 1 / 4, 1 / 4, null, null, Duration.zero),
    (Sizes.sapcing1, 1 / 3, null, null, 1 / 4, Duration(milliseconds: 500)),
    (Sizes.sapcing1 * 1.5, null, 1 / 3, 1 / 3, null, Duration(seconds: 1)),
    (Sizes.sapcing2, null, null, 1 / 4, 1 / 3, Duration(milliseconds: 1500)),
    (Sizes.sapcing1, 1 / 2, 1 / 6, null, null, Duration(milliseconds: 800)),
    (
      Sizes.sapcing1 * 1.5,
      1 / 5,
      null,
      null,
      1 / 6,
      Duration(milliseconds: 1200),
    ),
  ];
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    animationController.addListener(() => setState(() {}));
    Future.delayed(
      const Duration(milliseconds: 100),
      () => setState(() {
        scale = 1.0;
      }),
    );

    _timer = Timer.periodic(const Duration(milliseconds: 150), (t) {
      setState(() {
        if (bounceRound == 6) {
          bounceRound = 0;
          return;
        }
        if (bounceRound <= 4) {
          for (var i = 0; i < bounce.length; i++) {
            final tick = bounceRound % 4;
            if (tick <= i || tick >= i + 2) {
              bounce[i] = 0.0;
            } else {
              bounce[i] = bounce[i] == 0.0 ? 0.2 : 0.0;
            }
          }
        }
        bounceRound++;
      });
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage(Assets.splashBg),
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xff312c85).withValues(alpha: 0.8), // indigo-900/80
                    Color(0xff372aac).withValues(alpha: 0.6), // indigo-800/60
                    Color(0xff312c85).withValues(alpha: 0.7), // indigo-900/70
                  ],
                ),
              ),
              child: Transform.translate(
                offset: Offset(0, -shift),
                child: AnimatedScale(
                  curve: Curves.easeInOutBack,
                  scale: scale,
                  duration: Duration(milliseconds: 1000),
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Transform.translate(
                          offset: Offset(0, shift),
                          child: Blob(),
                        ),
                        RichText(
                          text: TextSpan(
                            text: 'JB Manager',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 40,
                              fontWeight: Sizes.weightExtraBold,
                              letterSpacing: 1.25,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 16,
                        ), // Space between title and subtitle
                        RichText(
                          text: TextSpan(
                            text: 'Gestion Moderne & Intelligente',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 22,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        SizedBox(height: 48), // Space before indicators
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (index) {
                            bool isForward =
                                animationController.isForwardOrCompleted;
                            double animationValue = 0.0;
                            final targetIndex = isForward ? index : 2 - index;
                            final range = loadingRanges[targetIndex];
                            final targetValue =
                                (animationController.value - range.$1) /
                                (range.$2 - range.$1);
                            animationValue = targetValue.clamp(0.0, 1.0);

                            return AnimatedBuilder(
                              animation: animationController,
                              builder: (context, child) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6.0,
                                  ),
                                  child: Container(
                                    width: 48,
                                    height: 6,
                                    decoration: BoxDecoration(
                                      color: Colors.white.withValues(
                                        alpha: 0.5 + 0.5 * animationValue,
                                      ),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                  ),
                                );
                              },
                            );
                          }),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          ...pings.map(
            (e) => Positioned(
              top: e.$2 != null
                  ? MediaQuery.of(context).size.height * e.$2!
                  : null,
              left: e.$3 != null
                  ? MediaQuery.of(context).size.width * e.$3!
                  : null,
              bottom: e.$4 != null
                  ? MediaQuery.of(context).size.height * e.$4!
                  : null,
              right: e.$5 != null
                  ? MediaQuery.of(context).size.width * e.$5!
                  : null,
              child: PingCircle(size: e.$1, delay: e.$6),
            ),
          ),
          Positioned(
            bottom: 18,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    3,
                    (index) => AnimatedSlide(
                      offset: Offset(0, bounce[index]),
                      duration: Duration(milliseconds: 150),
                      curve: bounce[index] == 0
                          ? Curves.easeIn
                          : Curves.decelerate,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 2),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  "Chargement de l'application...",
                  style: TextStyle(color: Colors.white.withValues(alpha: 0.8)),
                ),
                const SizedBox(height: 36),
                Text(
                  '© 2024 JB Manager. Tous droits réservés.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.5),
                    fontSize: Sizes.textSm,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
