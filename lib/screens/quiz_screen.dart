import 'dart:math';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson_item.dart';
import '../services/audio_service.dart';
import '../services/content_loader.dart';
import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import '../widgets/confetti_burst.dart';
import '../widgets/squish_button.dart';

/// "Where is ___?" — 3 options, 1 correct. A wrong tap never shows an error;
/// the correct answer just glows and the prompt replays. A right tap earns
/// confetti. No score is shown to the child (stats go to the Parent Zone).
class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key, required this.module});

  final Module module;

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  final _random = Random();
  List<LessonItem>? _items;
  LessonItem? _target;
  List<LessonItem> _options = [];
  bool _revealed = false; // wrong tap: highlight the correct answer
  bool _celebrating = false;
  int _round = 0; // keys option entrance animations per question

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final items = await context.read<ContentLoader>().load(widget.module);
    if (!mounted) return;
    _items = items;
    _nextQuestion();
  }

  void _nextQuestion() {
    final items = _items!;
    final pool = [...items]..shuffle(_random);
    // Never repeat the same target back-to-back.
    var next = pool.first;
    if (next.id == _target?.id && pool.length > 1) next = pool[1];
    _target = next;
    final distractors =
        pool.where((i) => i.id != next.id).take(2).toList();
    _options = [next, ...distractors]..shuffle(_random);
    setState(() {
      _revealed = false;
      _celebrating = false;
      _round++;
    });
    _playPrompt();
  }

  void _playPrompt() =>
      context.read<AudioService>().playLesson(_target!.audioFile);

  Future<void> _onTap(LessonItem tapped) async {
    if (_celebrating) return;
    final audio = context.read<AudioService>();
    final progress = context.read<ProgressService>();
    final correct = tapped.id == _target!.id;
    await progress.recordQuizAnswer(widget.module.id, correct);

    if (correct) {
      setState(() => _celebrating = true);
      audio.playCorrect();
      await Future.delayed(const Duration(milliseconds: 1500));
      if (mounted) _nextQuestion();
    } else {
      // No error sound, no red X — gently show where the answer is.
      setState(() => _revealed = true);
      audio.playTryAgain();
    }
  }

  @override
  Widget build(BuildContext context) {
    final items = _items;
    return Scaffold(
      body: Container(
        color: AppColors.background,
        child: SafeArea(
          child: items == null || _target == null
              ? const Center(child: CircularProgressIndicator())
              : Stack(
                  children: [
                    Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                          child: Align(
                            alignment: Alignment.centerLeft,
                            child: SquishButton(
                              onTap: () => Navigator.of(context).pop(),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: const BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Color(0x1A000000),
                                        offset: Offset(0, 4),
                                        blurRadius: 8),
                                  ],
                                ),
                                child: const Icon(Icons.home_rounded,
                                    size: 28, color: AppColors.ink),
                              ),
                            ),
                          ),
                        ),
                        const Spacer(),
                        _PromptBubble(
                          text: 'Where is ${_target!.displayText}?',
                          celebrating: _celebrating,
                          onTap: _playPrompt,
                        ),
                        const Spacer(),
                        Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              for (final (i, option) in _options.indexed) ...[
                                Expanded(
                                  child: PopIn(
                                    key: ValueKey('$_round-${option.id}'),
                                    delay: Duration(milliseconds: 100 * i),
                                    child: _OptionCard(
                                      text: option.displayText,
                                      state: _stateFor(option),
                                      onTap: () => _onTap(option),
                                    ),
                                  ),
                                ),
                                if (i < _options.length - 1)
                                  const SizedBox(width: 16),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                    Positioned.fill(
                      child: ConfettiBurst(play: _celebrating),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  _OptionState _stateFor(LessonItem option) {
    final isTarget = option.id == _target!.id;
    if (_celebrating && isTarget) return _OptionState.celebrated;
    if (_revealed && isTarget) return _OptionState.hinted;
    return _OptionState.idle;
  }
}

enum _OptionState { idle, hinted, celebrated }

class _PromptBubble extends StatefulWidget {
  const _PromptBubble({
    required this.text,
    required this.celebrating,
    required this.onTap,
  });

  final String text;
  final bool celebrating;
  final VoidCallback onTap;

  @override
  State<_PromptBubble> createState() => _PromptBubbleState();
}

class _PromptBubbleState extends State<_PromptBubble>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SquishButton(
      onTap: widget.onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 32),
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        decoration: AppShapes.surfaceClay(),
        child: Column(
          children: [
            ScaleTransition(
              scale: Tween(begin: 1.0, end: 1.15).animate(
                CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
              ),
              child: Container(
                width: 68,
                height: 68,
                decoration: AppShapes.clay(
                  widget.celebrating ? AppColors.amber : AppColors.primary,
                  radius: 34,
                ),
                child: Icon(
                  widget.celebrating
                      ? Icons.celebration_rounded
                      : Icons.volume_up_rounded,
                  color: Colors.white,
                  size: 36,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.text, style: AppText.display(30)),
          ],
        ),
      ),
    );
  }
}

class _OptionCard extends StatelessWidget {
  const _OptionCard({
    required this.text,
    required this.state,
    required this.onTap,
  });

  final String text;
  final _OptionState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final highlighted = state != _OptionState.idle;
    return SquishButton(
      onTap: onTap,
      child: AnimatedScale(
        scale: state == _OptionState.celebrated ? 1.12 : 1,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOutBack,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          height: 116,
          decoration: BoxDecoration(
            color: highlighted ? const Color(0xFFFEF3C7) : AppColors.surface,
            borderRadius: BorderRadius.circular(AppShapes.radiusButton),
            border: Border.all(
              color: highlighted ? AppColors.amber : AppColors.border,
              width: highlighted ? 4 : 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: (highlighted ? AppColors.amber : AppColors.ink)
                    .withValues(alpha: highlighted ? 0.35 : 0.07),
                offset: const Offset(0, 10),
                blurRadius: 20,
                spreadRadius: -4,
              ),
            ],
          ),
          alignment: Alignment.center,
          child: Text(text, style: AppText.display(48)),
        ),
      ),
    );
  }
}
