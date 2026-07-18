import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

import 'package:balgyan/models/language.dart';
import 'package:balgyan/models/lesson_item.dart';

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

  test('language codes round-trip and unknown code falls back to English', () {
    for (final lang in AppLanguage.values) {
      expect(AppLanguage.fromCode(lang.code), lang);
    }
    expect(AppLanguage.fromCode(null), AppLanguage.en);
    expect(AppLanguage.fromCode('xx'), AppLanguage.en);
  });
}
