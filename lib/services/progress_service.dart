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

  // --- Exploration progress (drives the tile progress bars) ---

  Set<String> _viewed(String moduleId) =>
      ((_box.get('viewed_$moduleId', defaultValue: const <dynamic>[]) as List)
          .cast<String>()).toSet();

  int viewedCount(String moduleId) => _viewed(moduleId).length;

  Future<void> markViewed(String moduleId, String itemId) async {
    final viewed = _viewed(moduleId);
    if (viewed.add(itemId)) {
      await _box.put('viewed_$moduleId', viewed.toList());
      notifyListeners();
    }
  }

  // --- Quiz stats & stars ---

  /// Total stars = every correct quiz answer ever. Shown in the home header;
  /// per-module detail lives in the Parent Zone.
  int get stars =>
      _box.keys.whereType<String>().where((k) => k.endsWith('_correct')).fold(
          0, (sum, k) => sum + (_box.get(k, defaultValue: 0) as int));

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
