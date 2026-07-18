import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_item.dart';
import '../services/audio_service.dart';
import '../services/content_loader.dart';
import '../theme/app_theme.dart';
import '../widgets/lesson_card.dart';
import '../widgets/squish_button.dart';

/// One letter/number per page: auto-plays audio on entry, tap the card to
/// replay, swipe or use the chunky arrows to move.
class LessonScreen extends StatefulWidget {
  const LessonScreen({super.key, required this.module});

  final Module module;

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final _pageController = PageController(viewportFraction: 0.92);
  List<LessonItem>? _items;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await context.read<ContentLoader>().load(widget.module);
    if (!mounted) return;
    setState(() => _items = items);
    _playCurrent();
  }

  void _playCurrent() {
    final items = _items;
    if (items == null) return;
    context.read<AudioService>().playLesson(items[_index].audioFile);
  }

  void _goTo(int page) {
    _pageController.animateToPage(
      page,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutBack,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    final tint = items == null
        ? AppColors.background
        : AppColors.tints[(_index + 3) % AppColors.tints.length];
    return Scaffold(
      body: AnimatedContainer(
        duration: const Duration(milliseconds: 400),
        color: tint,
        child: SafeArea(
          child: items == null
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          _RoundIconButton(
                            icon: Icons.home_rounded,
                            onTap: () => Navigator.of(context).pop(),
                          ),
                          const Spacer(),
                          _ProgressPill(
                              current: _index + 1, total: items.length),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: items.length,
                        onPageChanged: (i) {
                          setState(() => _index = i);
                          _playCurrent();
                        },
                        itemBuilder: (_, i) => Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 20),
                          child: LessonCard(
                            item: items[i],
                            onTap: _playCurrent,
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _ArrowButton(
                            icon: Icons.arrow_back_rounded,
                            enabled: _index > 0,
                            onTap: () => _goTo(_index - 1),
                          ),
                          _ArrowButton(
                            icon: Icons.arrow_forward_rounded,
                            enabled: _index < items.length - 1,
                            onTap: () => _goTo(_index + 1),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SquishButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
                color: Color(0x1A000000), offset: Offset(0, 4), blurRadius: 8),
          ],
        ),
        child: Icon(icon, size: 28, color: AppColors.ink),
      ),
    );
  }
}

class _ProgressPill extends StatelessWidget {
  const _ProgressPill({required this.current, required this.total});

  final int current;
  final int total;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: TweenAnimationBuilder<double>(
                tween: Tween(end: current / total),
                duration: const Duration(milliseconds: 350),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 8,
                  backgroundColor: AppColors.muted,
                  color: AppColors.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text('$current / $total', style: AppText.body),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  const _ArrowButton({
    required this.icon,
    required this.enabled,
    required this.onTap,
  });

  final IconData icon;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SquishButton(
      enabled: enabled,
      onTap: onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 200),
        opacity: enabled ? 1 : 0.35,
        child: Container(
          width: 84,
          height: 84,
          decoration: AppShapes.clay(AppColors.primary, radius: 42),
          child: Icon(icon, size: 40, color: Colors.white),
        ),
      ),
    );
  }
}
