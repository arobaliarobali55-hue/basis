import 'package:flutter/material.dart';

class EntryAnimation extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final double verticalOffset;

  const EntryAnimation({
    super.key,
    required this.child,
    this.delay = const Duration(milliseconds: 0),
    this.duration = const Duration(milliseconds: 400),
    this.verticalOffset = 50.0,
  });

  @override
  State<EntryAnimation> createState() => _EntryAnimationState();
}

class _EntryAnimationState extends State<EntryAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacity;
  late Animation<double> _translateY;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);

    _opacity = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _translateY = Tween<double>(
      begin: widget.verticalOffset,
      end: 0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutQuad));

    Future.delayed(widget.delay, () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Opacity(
          opacity: _opacity.value,
          child: Transform.translate(
            offset: Offset(0, _translateY.value),
            child: widget.child,
          ),
        );
      },
    );
  }
}
