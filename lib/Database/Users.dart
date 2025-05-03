import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class UserBox {
  static const String _boxName = 'userBox';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<void> saveUserData(var uid, var userData) async {
    await _box.put(uid, userData);
  }

  static getUserData(var data) {
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

  static Map<dynamic, dynamic>? getAllUserData() {
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

  static Future<void> deleteUser(var uid) async {
    try {
      if (!Hive.isBoxOpen(_boxName)) {
        Hive.openBox(_boxName);
      }
      await _box.delete(uid);
    } catch (e) {
      print("HiveError: $e");
    }
  }

  static Box<dynamic> get _box => Hive.box(_boxName);
}
