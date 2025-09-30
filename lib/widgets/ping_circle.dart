import 'package:flutter/material.dart';

class PingCircle extends StatefulWidget {
  final double size;
  final Color color;
  final Duration delay;

  const PingCircle({
    super.key,
    required this.size,
    this.color = Colors.white,
    this.delay = Duration.zero,
  });

  @override
  State<PingCircle> createState() => _PingCircleState();
}

class _PingCircleState extends State<PingCircle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _animation;

  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOut);

    if (widget.delay > Duration.zero) {
      Future.delayed(
        widget.delay,
        () => !_isDisposed ? _controller.repeat() : null,
      );
    } else {
      _controller.repeat();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          double scale = 1 + _animation.value;
          double opacity = 1 - _animation.value;

          if (!_controller.isForwardOrCompleted) {
            opacity = 0.0;
          }

          return Opacity(
            opacity: opacity,
            child: Transform.scale(
              scale: scale,
              child: Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.color.withValues(alpha: 0.5),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
