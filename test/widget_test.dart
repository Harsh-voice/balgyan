import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:balgyan/models/language.dart';
import 'package:balgyan/models/lesson_item.dart';
import 'package:balgyan/services/daily_pick.dart';

void main() {
  List<LessonItem> loadContent(String path) {
    final raw = File(path).readAsStringSync();
    return (jsonDecode(raw) as List)
        .map((e) => LessonItem.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  test('abcd content has 26 valid letters with bundled assets', () {
    final items = loadContent('lib/data/abcd_content.json');
    expect(items.length, 26);
    for (final item in items) {
      expect(item.type, 'letter');
      expect(File(item.imageAsset).existsSync(), isTrue,
          reason: '${item.imageAsset} missing');
      for (final lang in AppLanguage.values) {
        expect(
          File('assets/audio/${lang.code}/${item.audioFile}').existsSync(),
          isTrue,
          reason: '${lang.code}/${item.audioFile} missing',
        );
      }
    }
  });

  test('numbers content has 10 valid numbers with bundled assets', () {
    final items = loadContent('lib/data/numbers_content.json');
    expect(items.length, 10);
    for (final item in items) {
      expect(item.type, 'number');
      expect(File(item.imageAsset).existsSync(), isTrue);
      for (final lang in AppLanguage.values) {
        expect(
          File('assets/audio/${lang.code}/${item.audioFile}').existsSync(),
          isTrue,
        );
      }
    }
  });

  test('letter of the day is stable within a day and rotates daily', () {
    final morning = DateTime(2026, 7, 18, 6);
    final night = DateTime(2026, 7, 18, 23, 59);
    final tomorrow = DateTime(2026, 7, 19, 0, 1);

    expect(dailyIndex(morning, 26), dailyIndex(night, 26));
    expect(dailyIndex(tomorrow, 26), (dailyIndex(morning, 26) + 1) % 26);
    expect(dailyIndex(morning, 26), inInclusiveRange(0, 25));
    expect(dailyIndex(morning, 0), 0); // never crashes on empty content
  });

  test('language codes round-trip and unknown code falls back to English', () {
    for (final lang in AppLanguage.values) {
      expect(AppLanguage.fromCode(lang.code), lang);
    }
    expect(AppLanguage.fromCode(null), AppLanguage.en);
    expect(AppLanguage.fromCode('xx'), AppLanguage.en);
  });
}
