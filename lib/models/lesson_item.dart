/// One letter or number lesson item, loaded from lib/data/*.json.
///
/// Audio is language-agnostic: the same [audioFile] name exists in every
/// assets/audio/{lang}/ folder, so the real path is resolved at play time.
class LessonItem {
  const LessonItem({
    required this.id,
    required this.type,
    required this.displayText,
    required this.imageAsset,
    required this.audioFile,
    required this.order,
  });

  final String id;
  final String type; // 'letter' | 'number'
  final String displayText;
  final String imageAsset;
  final String audioFile;
  final int order;

  factory LessonItem.fromJson(Map<String, dynamic> json) => LessonItem(
        id: json['id'] as String,
        type: json['type'] as String,
        displayText: json['displayText'] as String,
        imageAsset: json['imageAsset'] as String,
        audioFile: json['audioFile'] as String,
        order: json['order'] as int,
      );
}
