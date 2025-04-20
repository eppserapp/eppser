import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class GroupBox {
  static const String _boxName = 'groupBox';

  static Future<void> initHive() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Future<void> saveGroupData(var id, var groupData) async {
    await _box.put(id, groupData);
  }

  static getGroupData(var data) {
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
