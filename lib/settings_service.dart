import 'app_settings.dart';

export 'app_settings.dart';

// Thin wrapper kept for compatibility — delegates to AppSettings directly.
class SettingsService {
  static Future<AppSettings> load() => AppSettings.load();
  static Future<void> save(AppSettings s) => s.save();
}
