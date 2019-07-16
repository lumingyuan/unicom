import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class Setting {
  static const String kAutoClock = 'key_auto_clock';
  static const String kToken = 'key_token';
  static const String kCurrentJobId = 'key_current_job_id'; //当前显示的公司id
  static const String kNumUpdateTime = 'key_num_update_time';

  static bool autoClock = true; //自动打卡开关
  static int currentJobId = 0;
  static String numUpdateTime;

  static void loadAll() async {
    autoClock = await getBool(kAutoClock);
    currentJobId = await getInt(kCurrentJobId);
    numUpdateTime = await getString(kNumUpdateTime);
  }

  static Future<String> getString(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getString(key) ?? "";
    } catch (e) {}
    return "";
  }

  static Future<bool> getBool(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getBool(key) ?? false;
    } catch (e) {}
    return false;
  }

  static Future<int> getInt(String key) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      return prefs.getInt(key) ?? 0;
    } catch (e) {}
    return 0;
  }

  static void saveBool(String key, bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool(key, value);
  }

  static void saveInt(String key, int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt(key, value);
  }

  static void saveString(String key, String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString(key, value);
  }
}
