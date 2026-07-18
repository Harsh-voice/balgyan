import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/language.dart';
import '../services/content_loader.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/module_marks.dart';

/// Adults-only settings, behind a math gate ("What is 7 + 3?") — more
/// toddler-proof than a PIN a toddler can mash, and it doubles as the
/// parental gate Google Play requires for purchase flows in V2.
class ParentZoneScreen extends StatefulWidget {
  const ParentZoneScreen({super.key});

  @override
  State<ParentZoneScreen> createState() => _ParentZoneScreenState();
}

class _ParentZoneScreenState extends State<ParentZoneScreen> {
  bool _unlocked = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Parent Zone')),
      body: _unlocked
          ? const _ParentSettings()
          : _MathGate(onPassed: () => setState(() => _unlocked = true)),
    );
  }
}

class _MathGate extends StatefulWidget {
  const _MathGate({required this.onPassed});

  final VoidCallback onPassed;

  @override
  State<_MathGate> createState() => _MathGateState();
}

class _MathGateState extends State<_MathGate> {
  final _random = Random();
  late int _a;
  late int _b;
  late List<int> _choices;

  @override
  void initState() {
    super.initState();
    _newQuestion();
  }

  void _newQuestion() {
    _a = _random.nextInt(8) + 2; // 2..9
    _b = _random.nextInt(8) + 2;
    final answer = _a + _b;
    final wrong = <int>{};
    while (wrong.length < 2) {
      final w = answer + _random.nextInt(7) - 3;
      if (w != answer && w > 0) wrong.add(w);
    }
    _choices = [answer, ...wrong]..shuffle(_random);
    setState(() {});
  }

  void _pick(int value) {
    if (value == _a + _b) {
      widget.onPassed();
    } else {
      _newQuestion(); // silently re-roll; no feedback a toddler could learn from
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.family_restroom,
                size: 56, color: AppColors.inkSoft),
            const SizedBox(height: 16),
            Text('For grown-ups', style: AppText.title),
            const SizedBox(height: 8),
            Text('What is $_a + $_b?', style: AppText.display(30)),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (final c in _choices)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: OutlinedButton(
                      onPressed: () => _pick(c),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size(72, 56),
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.inkSoft),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text('$c', style: AppText.body.copyWith(fontSize: 22)),
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

class _ParentSettings extends StatelessWidget {
  const _ParentSettings();

  @override
  Widget build(BuildContext context) {
    final progress = context.watch<ProgressService>();
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const _SectionLabel('Language'),
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: RadioGroup<AppLanguage>(
            groupValue: progress.language,
            onChanged: (v) {
              if (v != null) progress.setLanguage(v);
            },
            child: Column(
              children: [
                for (final lang in AppLanguage.values)
                  RadioListTile<AppLanguage>(
                    title: Text(lang.nativeName, style: AppText.body),
                    value: lang,
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Sound'),
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: SwitchListTile(
            title: Text('Mute all audio', style: AppText.body),
            value: progress.muted,
            onChanged: progress.setMuted,
          ),
        ),
        const SizedBox(height: 16),
        const _SectionLabel('Practice stats'),
        Card(
          color: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          child: Column(
            children: [
              for (final (i, m) in modules.where((m) => !m.locked).indexed)
                ListTile(
                  leading: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: (i == 0 ? AppColors.primary : AppColors.amber)
                          .withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Center(
                      child: ModuleMark(
                        moduleId: m.id,
                        size: 36,
                        color: i == 0 ? AppColors.primary : AppColors.amber,
                      ),
                    ),
                  ),
                  title: Text(m.title, style: AppText.body),
                  trailing: Text(
                    '${progress.quizCorrect(m.id)} / ${progress.quizAttempts(m.id)} correct',
                    style: AppText.caption,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'BalGyan stores everything on this device only. '
          'No account, no ads, no data collection.',
          textAlign: TextAlign.center,
          style: AppText.caption,
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8),
      child: Text(text,
          style: AppText.caption.copyWith(fontWeight: FontWeight.bold)),
    );
  }
}
