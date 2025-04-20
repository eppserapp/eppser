import 'package:eppser/Theme/Theme.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeData _themeData = lightMode;

  ThemeProvider() {
    loadTheme();
  }

  ThemeData get themeData => _themeData;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightMode) {
      themeData = darkMode;
    } else {
      themeData = lightMode;
    }
    _saveTheme();
  }

  void loadTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = prefs.getBool('isDarkMode') ?? false;
    themeData = isDarkMode ? darkMode : lightMode;
  }

  void _saveTheme() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isDarkMode = _themeData == darkMode;
    await prefs.setBool('isDarkMode', isDarkMode);
  }
}
