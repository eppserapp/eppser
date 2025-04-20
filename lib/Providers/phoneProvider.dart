import 'package:flutter/material.dart';

class phoneProvider with ChangeNotifier {
  var phn = "";

  get Myphone => phn;
  void set(String value) {
    phn = value;
    notifyListeners();
  }

  void reset(String value) {
    phn = "";
    notifyListeners();
  }
}
