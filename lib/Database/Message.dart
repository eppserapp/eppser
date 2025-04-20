import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MessageBox {
  static const String _boxName = 'messageBox';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<void> saveMessageData(var uid, var message) async {
    await _box.put(uid, message);
  }

  static getMessage(var data) {
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

  static Map<dynamic, dynamic>? getAllMessages() {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        Hive.openBox(_boxName);
      }
      return _box.toMap();
    } catch (e) {
      print("HiveError: $e");
      return null;
    }
  }

  static Box<dynamic> get _box => Hive.box(_boxName);
}
