import 'package:flutter/material.dart';

class LoginButton extends StatefulWidget {
  final VoidCallback? onPressed;
  final String label;

  const LoginButton({super.key, required this.label, this.onPressed});

  @override
  State<LoginButton> createState() => _LoginButtonState();
}

class _LoginButtonState extends State<LoginButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _animation = CurvedAnimation(parent: _controller, curve: Curves.ease);
  }

  void _startAnimation(_) {
    if (widget.onPressed == null) return _controller.stop();
    _controller.forward(from: 0); // restart animation
  }

  void _stopAnimation(_) {
    if (widget.onPressed == null) return _controller.stop();
    _controller.reverse(from: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _startAnimation,
      onTapUp: _stopAnimation,
      onTapCancel: () => _stopAnimation(null),
      onTap: widget.onPressed,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _animation.value;
          return Transform.scale(
            scale: 1 + progress * 0.05,
            child: Container(
              height: 48,
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                boxShadow: widget.onPressed == null
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: widget.onPressed == null
                            ? null
                            : LinearGradient(
                                colors: [
                                  Color.lerp(
                                    Color(0xff2b7fff),
                                    Color(0xff155dfc),
                                    progress,
                                  )!,
                                  Color(0xff155dfc),
                                ],
                              ),
                      ),
                    ),
                    Positioned(
                      left: (progress * 650) - 300,
                      top: 0,
                      child: Container(
                        height: 48,
                        width: 300,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.white.withValues(alpha: 0.0),
                              Colors.white.withValues(alpha: 0.2),
                              Colors.white.withValues(alpha: 0.0),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                        ),
                      ),
                    ),
                    Center(
                      child: Text(
                        widget.label,
                        style: TextStyle(
                          color: widget.onPressed == null
                              ? Colors.grey.shade400
                              : Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
