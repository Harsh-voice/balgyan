import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/progress_service.dart';
import '../theme/app_theme.dart';
import 'home_grid_screen.dart';
import 'language_picker_screen.dart';

/// Brand mark bounces in, wordmark rises, then routes: first launch →
/// language picker, otherwise straight to the home grid.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..forward();

  late final Animation<double> _logoScale = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0, 0.6, curve: Curves.elasticOut),
  );

  late final Animation<double> _nameRise = CurvedAnimation(
    parent: _controller,
    curve: const Interval(0.35, 1, curve: Curves.easeOutBack),
  );

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 1600), _navigate);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate() {
    if (!mounted) return;
    final hasLanguage = context.read<ProgressService>().savedLanguage != null;
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, animation, _) => FadeTransition(
          opacity: animation,
          child: hasLanguage
              ? const HomeGridScreen()
              : const LanguagePickerScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [AppColors.primary, AppColors.primaryDeep],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _logoScale,
                child: Container(
                  width: 132,
                  height: 132,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.25),
                        offset: const Offset(0, 12),
                        blurRadius: 28,
                        spreadRadius: -6,
                      ),
                    ],
                  ),
                  alignment: Alignment.center,
                  child: Text('ब', style: AppText.display(64, AppColors.primary)),
                ),
              ),
              const SizedBox(height: 28),
              FadeTransition(
                opacity: _nameRise,
                child: SlideTransition(
                  position:
                      Tween(begin: const Offset(0, 0.6), end: Offset.zero)
                          .animate(_nameRise),
                  child: Column(
                    children: [
                      Text('BalGyan', style: AppText.display(46, Colors.white)),
                      const SizedBox(height: 4),
                      Text(
                        'Learn  ·  Play  ·  Grow',
                        style: AppText.label(
                            Colors.white.withValues(alpha: 0.75)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
