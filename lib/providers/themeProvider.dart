import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class themeProvider with ChangeNotifier {
  var theme;
  void addItemsToLocalStorage() async {
    final prefs = await SharedPreferences.getInstance();
    theme = prefs.getBool('bool');
    if (prefs.getBool('bool') == null) {
      prefs.setBool('bool', true);
      theme = true;
    }
    notifyListeners();
  }

  get myTheme => theme;
  void set(value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('bool', value);
    theme = prefs.get('bool');
    notifyListeners();
  }
}
