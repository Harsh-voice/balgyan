import 'package:flutter/material.dart';

import '../services/content_loader.dart';
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

/// Main menu: clay module tiles that pop in, flat locked "Coming Soon"
/// tiles for V2, and a deliberately small settings gear for the Parent Zone.
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
                padding: const EdgeInsets.fromLTRB(24, 12, 8, 0),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
              Expanded(
                child: GridView.count(
                  crossAxisCount: 2,
                  padding: const EdgeInsets.all(24),
                  mainAxisSpacing: 20,
                  crossAxisSpacing: 20,
                  children: [
                    for (final (i, module) in modules.indexed)
                      PopIn(
                        delay: Duration(milliseconds: 90 * i),
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
        child: Stack(
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    height: 76,
                    child: Center(
                      child: ModuleMark(
                        moduleId: module.id,
                        color: module.locked
                            ? AppColors.lockedInk
                            : Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    module.title,
                    style: AppText.display(
                      24,
                      module.locked ? AppColors.lockedInk : Colors.white,
                    ),
                  ),
                  if (module.locked)
                    Text('Coming Soon',
                        style: AppText.caption
                            .copyWith(color: AppColors.lockedInk)),
                ],
              ),
            ),
            if (module.locked)
              const Positioned(
                top: 14,
                right: 14,
                child: Icon(Icons.lock_rounded,
                    size: 20, color: AppColors.lockedInk),
              ),
          ],
        ),
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
