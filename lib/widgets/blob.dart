// Blob animation widget that handles two functionalities:
// 1. Creating animation frames.
// 2. Displaying the created animation.

import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jbmanager/constants/assets.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:themed/themed.dart';

class Blob extends StatefulWidget {
  const Blob({super.key});

  @override
  State<Blob> createState() => _BlobState();
}

class BlobCreator extends StatefulWidget {
  const BlobCreator({super.key});

  @override
  State<BlobCreator> createState() => _BlobStateCreator();
}

class _BlobState extends State<Blob> {
  final size = 100.0; // Base size for the blob animation.
  @override
  Widget build(BuildContext context) {
    return Image.asset(Assets.loader, width: size * 2.5, height: size * 2.5);
  }
}

class _BlobStateCreator extends State<BlobCreator>
    with TickerProviderStateMixin {
  // Repaint key for capturing frames.
  final _repaintKey = GlobalKey();
  final List<Uint8List> _frames = []; // Stores the created animation frames.

  // Animation controllers and their configurations.
  late AnimationController _controller;
  late Animation<double> _animation;

  // Gradient color configurations used in animations.
  late List<Color?> colors1; // Primary gradient colors for morphing.
  late List<Color?> colors2; // Secondary gradient colors for blending effects.

  // Border radius percentages for animation morphing.
  late List<double> topLefts; // Animation values for the top-left corner.
  late List<double> topRights; // Animation values for the top-right corner.
  late List<double> bottomLefts; // Animation values for the bottom-left corner.
  late List<double>
  bottomRights; // Animation values for the bottom-right corner.

  // Rotation and scale configurations for animations.
  late List<double> rotations; // Rotation angles for the blob in degrees.
  late List<double> scales; // Scaling factors for zoom in/out effects.

  // Additional controllers for logo and ping animations.
  late AnimationController _logoController;
  late AnimationController _ping1Controller;
  late AnimationController _ping2Controller;
  late CurvedAnimation _logoAnimation;
  late CurvedAnimation _ping1Animation;
  late CurvedAnimation _ping2Animation;

  final size = 100.0; // Base size for the blob animation.

  int index = 0; // Current animation step.
  int frameIndex = 0; // Index of the current frame being played.

  // Calculates next index for animation steps.
  int get indexNext => (index + 1) % 4;

  // Calculates interpolated gradient colors based on animation progress.
  Color? get color1 => Color.lerp(
    colors1[index],
    colors1[indexNext],
    _animation.value,
  )?.withValues(alpha: 0.4);
  Color? get color2 => Color.lerp(
    colors2[index],
    colors2[indexNext],
    _animation.value,
  )?.withValues(alpha: 0.4);

  // Interpolates border radius percentages for animation morphing.
  double get topLeft => lerpDouble(
    topLefts[index],
    topLefts[indexNext],
    _animation.value,
  )!; // Smooth transition for the top-left corner.
  double get topRight => lerpDouble(
    topRights[index],
    topRights[indexNext],
    _animation.value,
  )!; // Smooth transition for the top-right corner.
  double get bottomLeft => lerpDouble(
    bottomLefts[index],
    bottomLefts[indexNext],
    _animation.value,
  )!; // Smooth transition for the bottom-left corner.
  double get bottomRight => lerpDouble(
    bottomRights[index],
    bottomRights[indexNext],
    _animation.value,
  )!; // Smooth transition for the bottom-right corner.

  // Interpolates rotation and scale values for animation effects.
  double get rotation =>
      lerpDouble(rotations[index], rotations[indexNext], _animation.value)!;
  double get scale =>
      lerpDouble(scales[index], scales[indexNext], _animation.value)!;

  @override
  void initState() {
    super.initState();
    // Main animation controller for blob morphing.
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
    );

    // Apply ease-in-out curve to the animation.
    final curve = CurvedAnimation(parent: _controller, curve: Curves.easeInOut);

    _animation = Tween<double>(begin: 0, end: 1).animate(curve)
      ..addListener(() async {
        setState(() {});

        // Update progress for secondary animations based on main animation.
        final progress = (_controller.value + index) / 2;
        _logoController.value = progress;
        _ping1Controller.value =
            (_controller.value / 2) + (index % 2 == 0 ? 0.5 : 0);
        _ping2Controller.value =
            (_controller.value / 2) + (index % 2 == 0 ? 0 : 0.5);
        if (progress > 1) {
          _logoController.value = 2 - progress;
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          index = indexNext; // Move to the next animation step.
          _controller.forward(from: 0); // Restart the animation.
        }
      });

    // Initialize gradients.
    colors1 = [
      Color(0xFF3B82F6),
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
    ];
    colors2 = [
      Color(0xFF8B5CF6),
      Color(0xFF10B981),
      Color(0xFFF59E0B),
      Color(0xFF3B82F6),
    ];

    // Border radius configurations for animation morphing.
    topLefts = [0.5, 0.4, 0.3, 0.6];
    topRights = [0.5, 0.6, 0.7, 0.3];
    bottomLefts = [0.5, 0.7, 0.4, 0.5];
    bottomRights = [0.5, 0.3, 0.6, 0.5];

    // Rotation configurations in degrees.
    rotations = [270.0, 0.0, 90.0, 180.0];

    // Scale configurations.
    scales = [1.1, 0.9, 1.1, 1.0];

    // Generate animation frames asynchronously.
    _generateFrames();

    // Initialize secondary controllers for logo and ping animations.
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );
    _logoAnimation = CurvedAnimation(
      parent: _logoController,
      curve: Curves.decelerate,
    );

    _ping1Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ping1Animation = CurvedAnimation(
      parent: _ping1Controller,
      curve: Curves.decelerate,
    );

    _ping2Controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _ping2Animation = CurvedAnimation(
      parent: _ping2Controller,
      curve: Curves.decelerate,
    );

    rootBundle.load(Assets.loader).then((data) {
      final bytes = data.buffer.asUint8List();
      final archive = ZipDecoder().decodeBytes(bytes);
      for (final file in archive) {
        if (file.isFile && file.name.endsWith('.png')) {
          _frames.add(file.content);
        }
      }
      print('Loaded ${_frames.length} cached blob frames from disk');

      // Update the current frame every 16 milliseconds (60 FPS).
      Timer.periodic(Duration(milliseconds: 1000 ~/ 60), (timer) {
        setState(() => frameIndex++);
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the main animation controller.
    super.dispose();
  }

  // Generates animation frames and saves them as a zip file.
  void _generateFrames() async {
    Future.delayed(const Duration(milliseconds: 500), () async {
      while (_repaintKey.currentContext == null) {
        await Future.delayed(const Duration(milliseconds: 500));
        continue;
      }

      // Request storage permission for saving frames.
      final request = await Permission.manageExternalStorage.request();
      if (!request.isGranted) {
        Fluttertoast.showToast(
          msg: "Storage permission is required to cache the blob animation",
        );
        _controller.forward();
        return;
      }

      const totalFrames = 60 * 3; // Total frames for 3 seconds at 60 FPS.

      print('Starting blob caching with $totalFrames frames');

      for (var i = 0; i < totalFrames; i++) {
        var frameValue = 4 * i / (totalFrames - 1);
        index = frameValue.floor() % 4;
        _controller.value = frameValue - frameValue.floor();

        _ping1Controller.value =
            (_controller.value / 2) + (index % 2 == 0 ? 0.5 : 0);
        _ping2Controller.value =
            (_controller.value / 2) + (index % 2 == 0 ? 0 : 0.5);

        _logoController.value = 2 - 2 * i / (totalFrames - 1);
        if (2 * i < (totalFrames - 1)) {
          _logoController.value = 2 * i / (totalFrames - 1);
        }

        setState(() {});

        final boundary =
            _repaintKey.currentContext!.findRenderObject()
                as RenderRepaintBoundary;
        final image = await boundary.toImage(pixelRatio: 3.0);
        final byteData = await image.toByteData(format: ImageByteFormat.png);
        final imageBytes = byteData?.buffer.asUint8List();
        _frames.add(imageBytes!);
        final totalBytes = _frames.fold<int>(
          0,
          (previousValue, element) => previousValue + element.lengthInBytes,
        );
        print(
          'Cached frame for $i, total: ${_frames.length}, bytes: ${totalBytes ~/ 1024} KB',
        );
      }

      final archive = Archive();

      // Save rendered frames to a zip file for debugging.
      for (var i = 0; i < totalFrames; i++) {
        archive.addFile(
          ArchiveFile(
            'blob_frame_$i.png',
            _frames[i].lengthInBytes,
            _frames[i].toList(),
          ),
        );
      }

      // Write the frames to a file system.
      final file = File('/storage/emulated/0/Download/blob_frames.zip');
      file.writeAsBytes(ZipEncoder().encode(archive));
      _controller.forward();
    });
  }

  // Calculates dynamic border radius based on widget width and height.
  BorderRadius _getBorderRadius(double w, double h) {
    return BorderRadius.only(
      topLeft: Radius.circular(topLeft * w),
      topRight: Radius.circular(topRight * w),
      bottomLeft: Radius.circular(bottomLeft * w),
      bottomRight: Radius.circular(bottomRight * w),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Build the blob animation widget.
    return RepaintBoundary(
      key: _repaintKey,
      child: SizedBox(
        width: size * 2.5,
        height: size * 2.5,
        child: Center(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (_, _) {
              return Stack(
                children: [
                  // Morph the blob.
                  Transform.rotate(
                    angle: rotation * math.pi / 180,
                    child: Transform.scale(
                      scale: scale,
                      child: Container(
                        width: size,
                        height: size,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [color1!, color2!],
                          ),
                          borderRadius: _getBorderRadius(size, size),
                        ),
                      ),
                    ),
                  ),
                  // Ping animation 1.
                  Positioned(
                    width: size,
                    height: size,
                    child: Center(
                      child: Transform.scale(
                        scale: 0.7 * _ping1Animation.value + 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.2 * (1 - _ping1Animation.value),
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Ping animation 2.
                  Positioned(
                    width: size,
                    height: size,
                    child: Center(
                      child: Transform.scale(
                        scale: 1.5 * _ping2Animation.value + 1,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(
                                alpha: 0.2 * (1 - _ping2Animation.value),
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  // Display the app logo animation.
                  Positioned(
                    width: size,
                    height: size,
                    child: Center(
                      child: Transform.scale(
                        scale: 0.1 * _logoAnimation.value + 0.75,
                        child: ChangeColors(
                          brightness: _logoAnimation.value * 0.3,
                          child: Container(
                            width:
                                2 * (200 / (-_logoAnimation.value * 0.5 + 2.8)),
                            height:
                                2 * (200 / (-_logoAnimation.value * 0.5 + 2.8)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              image: DecorationImage(
                                image: AssetImage(Assets.appLogo),
                                fit: BoxFit.cover,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.3),
                                  offset: Offset(0, 25),
                                  blurRadius: 50,
                                  spreadRadius: -5,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// The build method is responsible for rendering the animation within the widget tree.
  /// It includes a `RepaintBoundary` for performance optimization.
  /// The animation is built using an `AnimatedBuilder` and `Stack` widgets.
}
