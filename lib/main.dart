import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/content_loader.dart';
import 'services/progress_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  final progress = ProgressService();
  await progress.init();

  runApp(BalGyanApp(progress: progress));
}

class BalGyanApp extends StatelessWidget {
  const BalGyanApp({super.key, required this.progress});

  final ProgressService progress;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: progress),
        Provider(
          create: (_) => AudioService(progress),
          dispose: (_, AudioService a) => a.dispose(),
        ),
        Provider(create: (_) => ContentLoader()),
      ],
      child: MaterialApp(
        title: 'BalGyan',
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
