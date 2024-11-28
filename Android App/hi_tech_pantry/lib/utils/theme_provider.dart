import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeProvider() {
    _loadThemeFromSharedPreferences();
  }

  void _loadThemeFromSharedPreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String theme = prefs.getString('theme') ?? 'light';
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

  ThemeMode _currentThemeMode = ThemeMode.light;
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
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.blue.shade50,
      shadowColor: Colors.blue.shade900,
      elevation: 3,
      centerTitle: true,
      titleSpacing: 0.0,
      toolbarHeight: 50,
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
    ),
    listTileTheme: ListTileThemeData(
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
  );

  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue, brightness: Brightness.dark),
    primarySwatch: Colors.blue,
    scaffoldBackgroundColor: Colors.grey.shade900,
    cardTheme: CardTheme(
      color: Colors.grey.shade900,
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
        backgroundColor: Colors.grey.shade900,
        foregroundColor: const Color.fromARGB(255, 110, 107, 107),
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
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.grey.shade900,
      shadowColor: Colors.white10,
      elevation: 3,
      centerTitle: true,
      titleSpacing: 0.0,
      toolbarHeight: 50,
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
      fillColor: Colors.grey.shade900,
      border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      labelStyle: const TextStyle(color: Color.fromARGB(255, 110, 107, 107)),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      prefixIconColor: const Color.fromARGB(255, 110, 107, 107),
      suffixIconColor: const Color.fromARGB(255, 110, 107, 107),
      hintStyle: const TextStyle(color: Color.fromARGB(255, 110, 107, 107)),
      floatingLabelStyle: const TextStyle(color: Colors.blue),
      errorStyle: const TextStyle(color: Colors.red),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.red),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
      focusedErrorBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
        borderRadius: BorderRadius.all(Radius.circular(20)),
      ),
    ),
    listTileTheme: ListTileThemeData(
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 110, 107, 107)
      ),
      leadingAndTrailingTextStyle: const TextStyle(
        fontSize: 25,
        fontWeight: FontWeight.bold,
        color: Color.fromARGB(255, 110, 107, 107)
      ),
    ),
  );
}