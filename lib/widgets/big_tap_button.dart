import 'package:flutter/material.dart';

/// A large, rounded, toddler-friendly button. Minimum 64dp tall — well past
/// the 48dp accessibility floor, sized for toddler motor skills.
class BigTapButton extends StatelessWidget {
  const BigTapButton({
    super.key,
    required this.label,
    required this.onTap,
    this.color,
    this.fontSize = 28,
  });

  final String label;
  final VoidCallback onTap;
  final Color? color;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    final bg = color ?? Theme.of(context).colorScheme.primaryContainer;
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(24),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: onTap,
        child: Container(
          constraints: const BoxConstraints(minHeight: 64),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          alignment: Alignment.center,
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}
