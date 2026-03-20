import 'package:flutter/rendering.dart';
import 'package:window_manager/window_manager.dart';

class WindowControls {
  static Future<void> minimize() async {
    final isMinimizable = await windowManager.isMinimizable();
    if (isMinimizable) {
      await windowManager.minimize();
    } else {
      debugPrint('Minimize not supported.');
    }
  }

  static Future<void> close() async {
    await windowManager.close();
  }

  static Future<void> toggleFullScreen() async {
    final isFullScreen = await windowManager.isFullScreen();
    await windowManager.setFullScreen(!isFullScreen);
  }
}
