import 'package:flutter/material.dart';

import '../models/lesson_item.dart';
import '../theme/app_theme.dart';

/// Big illustration sticker for one lesson item, with a gentle breathing
/// float so the screen never feels frozen. Falls back to rendering the
/// letter/number as huge text if the illustration asset is missing.
class LessonCard extends StatefulWidget {
  const LessonCard({super.key, required this.item, this.onTap});

  final LessonItem item;
  final VoidCallback? onTap;

  @override
  State<LessonCard> createState() => _LessonCardState();
}

class _LessonCardState extends State<LessonCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _breath = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 3),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _breath.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final accent = AppColors.tints[widget.item.order % AppColors.tints.length];
    return AnimatedBuilder(
      animation: _breath,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, -6 * Curves.easeInOut.transform(_breath.value)),
        child: child,
      ),
      child: GestureDetector(
        onTap: widget.onTap,
        child: Container(
          decoration: AppShapes.surfaceClay(radius: AppShapes.radiusCard + 8),
          padding: const EdgeInsets.all(28),
          child: Column(
            children: [
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(AppShapes.radiusCard),
                  ),
                  padding: const EdgeInsets.all(20),
                  child: Image.asset(
                    widget.item.imageAsset,
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => FittedBox(
                      child: Text(
                        widget.item.displayText,
                        style: AppText.display(200),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(widget.item.displayText, style: AppText.display(64)),
                  const SizedBox(width: 16),
                  Container(
                    width: 46,
                    height: 46,
                    decoration: AppShapes.clay(AppColors.amber, radius: 23),
                    child: const Icon(Icons.volume_up_rounded,
                        color: Colors.white, size: 24),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
