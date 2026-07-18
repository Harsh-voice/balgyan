import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/language.dart';

/// Wraps the single Hive box holding all persisted state:
/// language choice, mute flag, and per-module quiz stats for the Parent Zone.
class ProgressService extends ChangeNotifier {
  static const _boxName = 'balgyan';
  static const _kLanguage = 'language';
  static const _kMuted = 'muted';

  late final Box _box;

  Future<void> init() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(_boxName);
  }

  /// null on first launch — the splash screen uses this to decide whether
  /// to show the language picker.
  AppLanguage? get savedLanguage {
    final code = _box.get(_kLanguage) as String?;
    return code == null ? null : AppLanguage.fromCode(code);
  }

  AppLanguage get language => savedLanguage ?? AppLanguage.en;

  Future<void> setLanguage(AppLanguage lang) async {
    await _box.put(_kLanguage, lang.code);
    notifyListeners();
  }

  bool get muted => _box.get(_kMuted, defaultValue: false) as bool;

  Future<void> setMuted(bool value) async {
    await _box.put(_kMuted, value);
    notifyListeners();
  }

  // --- Parent-facing quiz stats (never shown to the child) ---

  int quizCorrect(String moduleId) =>
      _box.get('quiz_${moduleId}_correct', defaultValue: 0) as int;

  int quizAttempts(String moduleId) =>
      _box.get('quiz_${moduleId}_attempts', defaultValue: 0) as int;

  Future<void> recordQuizAnswer(String moduleId, bool correct) async {
    await _box.put('quiz_${moduleId}_attempts', quizAttempts(moduleId) + 1);
    if (correct) {
      await _box.put('quiz_${moduleId}_correct', quizCorrect(moduleId) + 1);
    }
    notifyListeners();
  }
}
