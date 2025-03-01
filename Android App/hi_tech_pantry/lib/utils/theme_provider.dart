import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadThemeFromSharedPreferences();
  }

  void _loadThemeFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String theme = prefs.getString('theme') ?? 'system';
    switch (theme) {
      case 'light':
        _currentThemeMode = ThemeMode.light;
        break;
      case 'dark':
        _currentThemeMode = ThemeMode.dark;
        break;
      case 'system':
        _currentThemeMode = ThemeMode.system;
        break;
    }
    notifyListeners();
  }

  void _saveThemeToSharedPreferences(String theme) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('theme', theme);
  }

  void changeTheme(String theme) {
    switch (theme) {
      case 'light':
        _currentThemeMode = ThemeMode.light;
        break;
      case 'dark':
        _currentThemeMode = ThemeMode.dark;
        break;
      case 'system':
        _currentThemeMode = ThemeMode.system;
        break;
    }
    _saveThemeToSharedPreferences(theme);
    notifyListeners();
  }

  ThemeMode _currentThemeMode = ThemeMode.system;
  ThemeMode get currentThemeMode => _currentThemeMode;

  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.blue.shade100,
    cardTheme: CardTheme(
      color: Colors.grey.shade200,
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 10,
        textStyle: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.white,
        foregroundColor: const Color.fromARGB(255, 68, 68, 68),
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 46.0,
        color: Colors.blue.shade700,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: const TextStyle(fontSize: 18.0),
      headlineMedium: const TextStyle(
        fontSize: 18.0,
        color: Colors.white,
        fontWeight: FontWeight.bold,
      )
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade50,
      shadowColor: Colors.blue.shade900,
      elevation: 3,
      centerTitle: true,
      titleSpacing: 0.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25)
        ),
      ),
      foregroundColor: Colors.blue.shade700,
      titleTextStyle: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w500,
        color: Colors.blue.shade700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      alignLabelWithHint: false,
      filled: true,
      fillColor: Colors.blue.shade50,
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade700),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
      errorStyle: const TextStyle(color: Colors.red),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: Colors.black,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.black
      ),
      leadingAndTrailingTextStyle: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.black
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.shade700;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.blue.shade50),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: TextStyle(
        fontSize: 15,
        color: Colors.blue.shade700,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      waitDuration: const Duration(milliseconds: 200),
      showDuration: const Duration(seconds: 1),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.blue.shade50),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    ),
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey.shade900,
    cardTheme: CardTheme(
      color: Colors.grey[850],
      elevation: 10,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(25.0),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        elevation: 10,
        textStyle: const TextStyle(
          fontSize: 24.0,
          fontWeight: FontWeight.w600,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        backgroundColor: Colors.grey[850],
        foregroundColor: Colors.blue.shade700,
        minimumSize: const Size(double.infinity, 50),
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(
        fontSize: 46.0,
        color: Colors.blue.shade700,
        fontWeight: FontWeight.w500,
      ),
      bodyLarge: const TextStyle(fontSize: 18.0),
      headlineMedium: TextStyle(
        fontSize: 18.0,
        color: Colors.grey[850],
        fontWeight: FontWeight.bold,
      )
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey[850],
      shadowColor: Colors.white10,
      elevation: 3,
      centerTitle: true,
      titleSpacing: 0.0,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          bottom: Radius.circular(25)
        ),
      ),
      foregroundColor: Colors.blue.shade700,
      titleTextStyle: TextStyle(
        fontSize: 24.0,
        fontWeight: FontWeight.w500,
        color: Colors.blue.shade700,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      alignLabelWithHint: false,
      filled: true,
      fillColor: Colors.grey[850],
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      labelStyle: const TextStyle(color: Color.fromARGB(255, 110, 107, 107)),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade700),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      prefixIconColor: const Color.fromARGB(255, 110, 107, 107),
      suffixIconColor: const Color.fromARGB(255, 110, 107, 107),
      hintStyle: const TextStyle(color: Color.fromARGB(255, 110, 107, 107)),
      floatingLabelStyle: TextStyle(color: Colors.blue.shade700),
      errorStyle: const TextStyle(color: Colors.red),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue.shade700, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      iconColor: Colors.white,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 110, 107, 107)
      ),
      leadingAndTrailingTextStyle: TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Colors.white
      ),
    ),
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith<Color>((Set<WidgetState> states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.blue.shade700;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.grey[850]),
    ),
    tooltipTheme: TooltipThemeData(
      textStyle: TextStyle(
        fontSize: 15,
        color: Colors.blue.shade700,
        fontWeight: FontWeight.w500,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[850],
        borderRadius: BorderRadius.circular(20),
      ),
      waitDuration: const Duration(milliseconds: 200),
      showDuration: const Duration(seconds: 1),
    ),
    menuTheme: MenuThemeData(
      style: MenuStyle(
        backgroundColor: WidgetStatePropertyAll(Colors.grey[850]),
        shape: WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
      ),
    ),
  );
}