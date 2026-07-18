/// The three supported voiceover languages.
///
/// [code] doubles as the audio asset folder name (assets/audio/{code}/),
/// so adding a language later means adding one enum value + one folder.
enum AppLanguage {
  hi('hi', 'हिंदी'),
  mr('mr', 'मराठी'),
  en('en', 'English');

  const AppLanguage(this.code, this.nativeName);

  final String code;

  /// Shown in the picker in its own script so a parent recognizes it instantly.
  final String nativeName;

  static AppLanguage fromCode(String? code) => AppLanguage.values.firstWhere(
        (l) => l.code == code,
        orElse: () => AppLanguage.en,
      );
}
