import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/lesson_item.dart';

/// A learning module (ABCD, Numbers, and later Colors/Fruits).
class Module {
  const Module({
    required this.id,
    required this.title,
    required this.contentPath,
    this.locked = false,
  });

  final String id;
  final String title;
  final String contentPath; // empty for locked "Coming Soon" modules
  final bool locked;
}

const modules = [
  Module(
    id: 'abcd',
    title: 'Letters',
    contentPath: 'lib/data/abcd_content.json',
  ),
  Module(
    id: 'numbers',
    title: 'Numbers',
    contentPath: 'lib/data/numbers_content.json',
  ),
  Module(id: 'colors', title: 'Colors', contentPath: '', locked: true),
  Module(id: 'fruits', title: 'Fruits', contentPath: '', locked: true),
];

/// Loads lesson content from bundled JSON. Results are cached per module.
class ContentLoader {
  final Map<String, List<LessonItem>> _cache = {};

  Future<List<LessonItem>> load(Module module) async {
    final cached = _cache[module.id];
    if (cached != null) return cached;

    final raw = await rootBundle.loadString(module.contentPath);
    final items = (jsonDecode(raw) as List)
        .map((e) => LessonItem.fromJson(e as Map<String, dynamic>))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    _cache[module.id] = items;
    return items;
  }
}
