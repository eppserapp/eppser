import 'package:flutter/material.dart';

class dataIndexProvider with ChangeNotifier {
  int data = 0;

  void set(int value) {
    data = value;
    notifyListeners();
  }
}
