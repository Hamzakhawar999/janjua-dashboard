import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class AnimatedCardWidget extends StatefulWidget {
  final String cardNumber;
  final String expiryDate;

  const AnimatedCardWidget({
    super.key,
    required this.cardNumber,
    required this.expiryDate,
  });

  @override
  State<AnimatedCardWidget> createState() => _AnimatedCardWidgetState();
}

class _AnimatedCardWidgetState extends State<AnimatedCardWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this);
  }

  void _playAnimation() {
    _controller.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      // Works for web/desktop hover
      onEnter: (_) {
        setState(() => _isHovered = true);
        _playAnimation();
      },
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        // Works for mobile tap
        onTap: _playAnimation,
        child: AnimatedScale(
          scale: _isHovered ? 1.05 : 1.0,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          child: Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.shade700,
              boxShadow: _isHovered
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    ]
                  : [],
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                Lottie.asset(
                  "assets/animations/Credit Card Blue.json",
                  controller: _controller,
                  onLoaded: (composition) {
                    _controller.duration = composition.duration;
                  },
                  fit: BoxFit.cover,
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Text(
                    widget.cardNumber.isEmpty
                        ? "**** **** **** ****"
                        : widget.cardNumber,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      letterSpacing: 2,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: Text(
                    widget.expiryDate.isEmpty ? "MM/YY" : widget.expiryDate,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
