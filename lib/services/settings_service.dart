import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static const String _themeModeKey = 'theme_mode';
  static const String _accentColorKey = 'accent_color';
  static const String _fontFamilyKey = 'font_family';
  static const String _fontSizeKey = 'font_size';
  static const String _editorFontFamilyKey = 'editor_font_family';
  static const String _editorFontSizeKey = 'editor_font_size';
  static const String _autosaveIntervalKey = 'autosave_interval';
  static const String _editorLineHeightKey = 'editor_line_height';
  static const String _editorShowLineNumbersKey = 'editor_show_line_numbers';

  static Future<ThemeMode> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(_themeModeKey) ?? 'system';
    switch (value) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      default:
        return ThemeMode.system;
    }
  }

  static Future<void> setThemeMode(ThemeMode mode) async {
    final prefs = await SharedPreferences.getInstance();
    String value;
    switch (mode) {
      case ThemeMode.light:
        value = 'light';
        break;
      case ThemeMode.dark:
        value = 'dark';
        break;
      default:
        value = 'system';
    }
    await prefs.setString(_themeModeKey, value);
  }

  static Future<Color> getAccentColor() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getInt(_accentColorKey) ?? 0xFFB4A5D5;
    return Color(value);
  }

  static Future<void> setAccentColor(Color color) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_accentColorKey, color.toARGB32());
  }

  static Future<String> getFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_fontFamilyKey) ?? 'Segoe UI';
  }

  static Future<void> setFontFamily(String fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_fontFamilyKey, fontFamily);
  }

  static Future<double> getFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_fontSizeKey) ?? 14.0;
  }

  static Future<void> setFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_fontSizeKey, fontSize);
  }

  static Future<String> getEditorFontFamily() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_editorFontFamilyKey) ?? 'Consolas';
  }

  static Future<void> setEditorFontFamily(String fontFamily) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_editorFontFamilyKey, fontFamily);
  }

  static Future<double> getEditorFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_editorFontSizeKey) ?? 16.0;
  }

  static Future<void> setEditorFontSize(double fontSize) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_editorFontSizeKey, fontSize);
  }

  static Future<int> getAutosaveInterval() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_autosaveIntervalKey) ?? 30;
  }

  static Future<void> setAutosaveInterval(int seconds) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_autosaveIntervalKey, seconds);
  }

  static Future<double> getEditorLineHeight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble(_editorLineHeightKey) ?? 1.6;
  }

  static Future<void> setEditorLineHeight(double lineHeight) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_editorLineHeightKey, lineHeight);
  }

  static Future<bool> getEditorShowLineNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_editorShowLineNumbersKey) ?? false;
  }

  static Future<void> setEditorShowLineNumbers(bool show) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_editorShowLineNumbersKey, show);
  }

  static Future<void> resetToDefaults() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_themeModeKey);
    await prefs.remove(_accentColorKey);
    await prefs.remove(_fontFamilyKey);
    await prefs.remove(_fontSizeKey);
    await prefs.remove(_editorFontFamilyKey);
    await prefs.remove(_editorFontSizeKey);
    await prefs.remove(_autosaveIntervalKey);
    await prefs.remove(_editorLineHeightKey);
    await prefs.remove(_editorShowLineNumbersKey);
  }
}
