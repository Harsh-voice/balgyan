import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Wraps any child in the app's signature press feel: a quick squish to 92%
/// with a springy release, plus light haptics. Toddlers get unmistakable
/// "I pressed it" feedback even with the sound muted.
class SquishButton extends StatefulWidget {
  const SquishButton({
    super.key,
    required this.child,
    this.onTap,
    this.enabled = true,
  });

  final Widget child;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  State<SquishButton> createState() => _SquishButtonState();
}

class _SquishButtonState extends State<SquishButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 90),
    reverseDuration: const Duration(milliseconds: 220),
  );

  late final Animation<double> _scale = Tween(begin: 1.0, end: 0.92).animate(
    CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.elasticOut,
    ),
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _down(_) {
    if (!widget.enabled) return;
    _controller.forward();
    HapticFeedback.lightImpact();
  }

  void _up(_) => _controller.reverse();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: _down,
      onTapUp: _up,
      onTapCancel: () => _controller.reverse(),
      onTap: widget.enabled ? widget.onTap : null,
      child: ScaleTransition(scale: _scale, child: widget.child),
    );
  }
}

/// Staggered pop-in used for list/grid entrances: fade + rise + overshoot.
class PopIn extends StatelessWidget {
  const PopIn({super.key, required this.child, this.delay = Duration.zero});

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 450 + delay.inMilliseconds),
      curve: Interval(
        delay.inMilliseconds / (450 + delay.inMilliseconds),
        1,
        curve: Curves.easeOutBack,
      ),
      builder: (context, t, child) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - t)),
          child: Transform.scale(scale: 0.9 + 0.1 * t, child: child),
        ),
      ),
      child: child,
    );
  }
}
