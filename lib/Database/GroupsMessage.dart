import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GroupMessageBox {
  static const String _boxName = 'groupMessageBox';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<void> saveGroupMessage(var uid, var userData) async {
    await _box.put(uid, userData);
  }

  static getGroupMessage(var data) {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        Hive.openBox(_boxName);
      }
      return _box.get(data);
    } catch (e) {
      print("HiveError: $e");
      return null;
    }
  }

  static Box<dynamic> get _box => Hive.box(_boxName);
}
