import 'package:flutter/material.dart';
import 'package:jbmanager/theme/color_palette.dart';
import 'package:jbmanager/widgets/blob.dart';

class Loader extends StatefulWidget {
  const Loader({super.key});
  @override
  State<Loader> createState() => _LoaderState();
}

class _LoaderState extends State<Loader> with SingleTickerProviderStateMixin {
  late AnimationController animationController;

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Transform.translate(offset: const Offset(0, 20), child: const Blob()),
          Transform.translate(
            offset: const Offset(0, -20),
            child: const Text('Chargement...', style: TextStyle(fontSize: 16)),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(3, (index) {
              final color = [
                ColorPalette.blue,
                ColorPalette.purple,
                ColorPalette.green,
              ][index % 3];
              return AnimatedBuilder(
                animation: animationController,
                builder: (context, child) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Container(
                      width: 44,
                      height: 5,

                      decoration: BoxDecoration(
                        color: color.withValues(
                          alpha: 0.5 + 0.5 * animationController.value,
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
    );
  }
}
