import 'package:flutter/foundation.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PreferencesServices {
  Future saveSettings(Settings settings) async {
    final preferences = await SharedPreferences.getInstance();

    await preferences.setInt('paperSelect', settings.paperSelect.index);
    await preferences.setBool('isBarcode', settings.isBarcode);

    if (kDebugMode) {
      print("Save Settings${settings.paperSelect.index}");
    }
  }

  Future<Settings> getSettings() async {
    final preferences = await SharedPreferences.getInstance();
    debugPrint(
        "preference value ====> : ${preferences.getInt('paperSelect')}   : ${preferences.getBool('isBarcode')}");
    final isBarcode = preferences.getBool('isBarcode');
    final paperSelect =
        PaperSelect.values[preferences.getInt('paperSelect') ?? 0];
    return Settings(paperSelect: paperSelect, isBarcode: isBarcode ?? false);
  }
}
