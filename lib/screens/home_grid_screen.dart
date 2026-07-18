import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_item.dart';
import '../services/content_loader.dart';
import '../services/daily_pick.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/module_marks.dart';
import '../widgets/squish_button.dart';
import 'lesson_screen.dart';
import 'parent_zone_screen.dart';
import 'quiz_screen.dart';

const _tileColor = {
  'abcd': AppColors.primary,
  'numbers': AppColors.amber,
};

/// Main menu: a rotating "Letter of the Day" hero (the daily reason to open
/// the app), star count earned from quizzes, module tiles with exploration
/// progress, and locked "Coming Soon" tiles for V2.
class HomeGridScreen extends StatelessWidget {
  const HomeGridScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Swallow back presses so toddler mashing can't exit the app.
    return PopScope(
      canPop: false,
      child: Scaffold(
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 12, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('BalGyan', style: AppText.display(30)),
                        Text('What shall we learn today?',
                            style: AppText.caption),
                      ],
                    ),
                    const Spacer(),
                    const _StarChip(),
                    IconButton(
                      // Small target on purpose — adult fingers only.
                      iconSize: 20,
                      icon: const Icon(Icons.settings_rounded,
                          color: AppColors.inkSoft),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => const ParentZoneScreen()),
                      ),
                    ),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: PopIn(child: _DailyLetterCard()),
              ),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(24),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  childAspectRatio: 0.95,
                  children: [
                    for (final (i, module) in modules.indexed)
                      PopIn(
                        delay: Duration(milliseconds: 90 * (i + 1)),
                        child: _ModuleTile(module: module),
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

/// Stars earned from correct quiz answers — the child's growing collection.
class _StarChip extends StatelessWidget {
  const _StarChip();

  @override
  Widget build(BuildContext context) {
    final stars = context.watch<ProgressService>().stars;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: AppShapes.clay(AppColors.amber, radius: 18),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text('$stars', style: AppText.display(17, Colors.white)),
        ],
      ),
    );
  }
}

/// The daily hook: one featured letter that changes every day, tap to jump
/// straight into its lesson page.
class _DailyLetterCard extends StatelessWidget {
  const _DailyLetterCard();

  @override
  Widget build(BuildContext context) {
    final abcd = modules.first;
    return FutureBuilder<List<LessonItem>>(
      future: context.read<ContentLoader>().load(abcd),
      builder: (context, snapshot) {
        final items = snapshot.data;
        if (items == null) return const SizedBox(height: 120);
        final index = dailyIndex(DateTime.now(), items.length);
        final item = items[index];
        return SquishButton(
          onTap: () => Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => LessonScreen(module: abcd, initialIndex: index),
            ),
          ),
          child: Container(
            height: 120,
            decoration: AppShapes.clay(AppColors.violet,
                radius: AppShapes.radiusCard),
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LETTER OF THE DAY',
                        style: AppText.label(
                                Colors.white.withValues(alpha: 0.8))
                            .copyWith(fontSize: 12, letterSpacing: 1.4)),
                    const SizedBox(height: 2),
                    Text('Meet the letter ${item.displayText}',
                        style: AppText.display(22, Colors.white)),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        Text('Tap to learn',
                            style: AppText.label(
                                Colors.white.withValues(alpha: 0.85))),
                        const SizedBox(width: 4),
                        Icon(Icons.arrow_forward_rounded,
                            size: 16,
                            color: Colors.white.withValues(alpha: 0.85)),
                      ],
                    ),
                  ],
                ),
                const Spacer(),
                Container(
                  width: 76,
                  height: 76,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Text(item.displayText,
                      style: AppText.display(38, AppColors.violet)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

const _moduleTotals = {'abcd': 26, 'numbers': 10};

class _ModuleTile extends StatelessWidget {
  const _ModuleTile({required this.module});

  final Module module;

  void _open(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (_) => _LearnOrPlaySheet(module: module),
    );
  }

  @override
  Widget build(BuildContext context) {
    final color = _tileColor[module.id];
    return SquishButton(
      enabled: !module.locked,
      onTap: () => _open(context),
      child: Container(
        decoration: module.locked
            ? AppShapes.flat(radius: AppShapes.radiusCard)
            : AppShapes.clay(color!, radius: AppShapes.radiusCard),
        padding: const EdgeInsets.symmetric(horizontal: 18),
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 64,
                    child: Center(
                      child: ModuleMark(
                        moduleId: module.id,
                        size: 64,
                        color: module.locked
                            ? AppColors.lockedInk
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    module.title,
                    style: AppText.display(
                      22,
                      module.locked ? AppColors.lockedInk : Colors.white,
                    ),
                  ),
                  if (module.locked)
                    Text('Coming Soon',
                        style: AppText.caption
                            .copyWith(color: AppColors.lockedInk))
                  else
                    _TileProgress(moduleId: module.id),
                ],
              ),
            ),
            if (module.locked)
              const Positioned(
                top: 14,
                right: 0,
                child: Icon(Icons.lock_rounded,
                    size: 20, color: AppColors.lockedInk),
              ),
          ],
        ),
      ),
    );
  }
}

/// "12 of 26" exploration progress inside a module tile.
class _TileProgress extends StatelessWidget {
  const _TileProgress({required this.moduleId});

  final String moduleId;

  @override
  Widget build(BuildContext context) {
    final total = _moduleTotals[moduleId] ?? 0;
    final viewed =
        context.watch<ProgressService>().viewedCount(moduleId).clamp(0, total);
    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: SizedBox(
              width: 96,
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : viewed / total,
                minHeight: 7,
                backgroundColor: Colors.white.withValues(alpha: 0.3),
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text('$viewed of $total explored',
              style:
                  AppText.label(Colors.white.withValues(alpha: 0.85))
                      .copyWith(fontSize: 12)),
        ],
      ),
    );
  }
}

class _LearnOrPlaySheet extends StatelessWidget {
  const _LearnOrPlaySheet({required this.module});

  final Module module;

  void _go(BuildContext context, Widget screen) {
    Navigator.of(context)
      ..pop()
      ..push(MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.locked,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            Text(module.title, style: AppText.display(24)),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _SheetButton(
                    icon: Icons.auto_stories_rounded,
                    label: 'Learn',
                    color: AppColors.primary,
                    onTap: () => _go(context, LessonScreen(module: module)),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _SheetButton(
                    icon: Icons.star_rounded,
                    label: 'Play',
                    color: AppColors.pink,
                    onTap: () => _go(context, QuizScreen(module: module)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _SheetButton extends StatelessWidget {
  const _SheetButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SquishButton(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24),
        decoration: AppShapes.clay(color, radius: AppShapes.radiusButton),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Colors.white),
            const SizedBox(height: 8),
            Text(label, style: AppText.display(22, Colors.white)),
          ],
        ),
      ),
    );
  }
}
