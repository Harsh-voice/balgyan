import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/language.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/module_marks.dart';
import '../widgets/squish_button.dart';
import 'home_grid_screen.dart';

const _langStyle = {
  AppLanguage.hi: (color: AppColors.amber, monogram: 'अ', subtitle: 'Hindi'),
  AppLanguage.mr: (color: AppColors.green, monogram: 'म', subtitle: 'Marathi'),
  AppLanguage.en: (color: AppColors.violet, monogram: 'A', subtitle: 'English'),
};

/// First-launch language choice: white clay cards, each language in its own
/// script with a colored monogram badge, popping in one after another.
class LanguagePickerScreen extends StatelessWidget {
  const LanguagePickerScreen({super.key});

  Future<void> _pick(BuildContext context, AppLanguage lang) async {
    await context.read<ProgressService>().setLanguage(lang);
    if (!context.mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const HomeGridScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PopIn(
                child: Column(
                  children: [
                    Container(
                      width: 72,
                      height: 72,
                      decoration:
                          AppShapes.clay(AppColors.primary, radius: 36),
                      alignment: Alignment.center,
                      child: const Icon(Icons.translate_rounded,
                          color: Colors.white, size: 34),
                    ),
                    const SizedBox(height: 16),
                    Text('Choose your language',
                        textAlign: TextAlign.center,
                        style: AppText.display(26)),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              for (final (i, lang) in AppLanguage.values.indexed) ...[
                PopIn(
                  delay: Duration(milliseconds: 120 * (i + 1)),
                  child: _LanguageCard(
                    lang: lang,
                    onTap: () => _pick(context, lang),
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 8),
              PopIn(
                delay: const Duration(milliseconds: 520),
                child: Text(
                  'You can change this later in the Parent Zone',
                  textAlign: TextAlign.center,
                  style: AppText.caption,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LanguageCard extends StatelessWidget {
  const _LanguageCard({required this.lang, required this.onTap});

  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final style = _langStyle[lang]!;
    return SquishButton(
      onTap: onTap,
      child: Container(
        height: 92,
        decoration: AppShapes.surfaceClay(radius: AppShapes.radiusCard),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Row(
          children: [
            MonogramBadge(text: style.monogram, color: style.color),
            const SizedBox(width: 18),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lang.nativeName, style: AppText.display(26)),
                Text(style.subtitle, style: AppText.caption),
              ],
            ),
            const Spacer(),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.inkSoft, size: 32),
          ],
        ),
      ),
    );
  }
}
