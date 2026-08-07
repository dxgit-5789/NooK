import 'package:flutter/material.dart';

class AppTheme {
  static const String defaultFontFamily = 'Segoe UI';
  static const String defaultEditorFont = 'Consolas';

  static final lightColorScheme = ColorScheme.light(
    primary: const Color(0xFFB4A5D5),
    onPrimary: const Color(0xFFFFFFFF),
    primaryContainer: const Color(0xFFE8DFF5),
    onPrimaryContainer: const Color(0xFF4A4458),
    secondary: const Color(0xFFA8C7E7),
    onSecondary: const Color(0xFFFFFFFF),
    secondaryContainer: const Color(0xFFD9E8F7),
    onSecondaryContainer: const Color(0xFF3D4E5C),
    tertiary: const Color(0xFFB8D8C7),
    onTertiary: const Color(0xFFFFFFFF),
    tertiaryContainer: const Color(0xFFDDF0E5),
    onTertiaryContainer: const Color(0xFF3F5047),
    error: const Color(0xFFE8A4A4),
    onError: const Color(0xFFFFFFFF),
    errorContainer: const Color(0xFFF5DCDC),
    onErrorContainer: const Color(0xFF5C3D3D),
    surface: const Color(0xFFFAF9FC),
    onSurface: const Color(0xFF1C1B1F),
    surfaceContainerHighest: const Color(0xFFE6E1E9),
    surfaceContainerHigh: const Color(0xFFECE8F0),
    surfaceContainer: const Color(0xFFF2EEF6),
    surfaceContainerLow: const Color(0xFFF6F3FA),
    surfaceContainerLowest: const Color(0xFFFFFFFF),
    outline: const Color(0xFFCBC4CF),
    outlineVariant: const Color(0xFFE5DFE7),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: const Color(0xFF313033),
    onInverseSurface: const Color(0xFFF4EFF7),
    inversePrimary: const Color(0xFFD4C4F0),
  );

  static final darkColorScheme = ColorScheme.dark(
    primary: const Color(0xFFD4C4F0),
    onPrimary: const Color(0xFF3A2F4A),
    primaryContainer: const Color(0xFF51455F),
    onPrimaryContainer: const Color(0xFFE8DFF5),
    secondary: const Color(0xFFB8D5F0),
    onSecondary: const Color(0xFF2D3D4D),
    secondaryContainer: const Color(0xFF3F5363),
    onSecondaryContainer: const Color(0xFFD9E8F7),
    tertiary: const Color(0xFFC4E5D4),
    onTertiary: const Color(0xFF2F4238),
    tertiaryContainer: const Color(0xFF3F5649),
    onTertiaryContainer: const Color(0xFFDDF0E5),
    error: const Color(0xFFF0B8B8),
    onError: const Color(0xFF4D2D2D),
    errorContainer: const Color(0xFF633838),
    onErrorContainer: const Color(0xFFF5DCDC),
    surface: const Color(0xFF1C1B1F),
    onSurface: const Color(0xFFE6E1E9),
    surfaceContainerHighest: const Color(0xFF36343B),
    surfaceContainerHigh: const Color(0xFF2B2930),
    surfaceContainer: const Color(0xFF211F26),
    surfaceContainerLow: const Color(0xFF1C1B1F),
    surfaceContainerLowest: const Color(0xFF0F0E11),
    outline: const Color(0xFF49454E),
    outlineVariant: const Color(0xFF2E2A32),
    shadow: const Color(0xFF000000),
    scrim: const Color(0xFF000000),
    inverseSurface: const Color(0xFFE6E1E9),
    onInverseSurface: const Color(0xFF313033),
    inversePrimary: const Color(0xFF6B5B7D),
  );

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: lightColorScheme,
    fontFamily: defaultFontFamily,
    scaffoldBackgroundColor: lightColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: defaultFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: lightColorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: lightColorScheme.onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: lightColorScheme.surfaceContainer,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: lightColorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: lightColorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: lightColorScheme.surfaceContainerHigh,
      selectedColor: lightColorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    colorScheme: darkColorScheme,
    fontFamily: defaultFontFamily,
    scaffoldBackgroundColor: darkColorScheme.surface,
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        fontFamily: defaultFontFamily,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: darkColorScheme.onSurface,
      ),
      iconTheme: IconThemeData(color: darkColorScheme.onSurface),
    ),
    cardTheme: CardThemeData(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: darkColorScheme.surfaceContainer,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: darkColorScheme.surfaceContainer,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: darkColorScheme.primary, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: darkColorScheme.surfaceContainerHigh,
      selectedColor: darkColorScheme.primaryContainer,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
    ),
  );
}
