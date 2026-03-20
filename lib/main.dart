import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/key_blocker.dart';
import 'package:psglotto/view/preload_view.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/theme.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:window_manager/window_manager.dart';
import 'dart:io';

void main() async {
  currentName = "PLAY SUPER JACKPOT";
  if (currentName == "PLAY SUPER JACKPOT") {
    logoPath = logoPathSet[0];
    //logoPath = "assets/images/logo.png";
    kPrimarySeedColor = gameName[0]['color'];
  } else if (currentName == "PLAY LOTTO") {
    logoPath = logoPathSet[1];
    //logoPath = "assets/images/logoPlay.png";
    kPrimarySeedColor = gameName[1]['color'];
  } else {
    logoPath = logoPathSet[2];
    // logoPath = "assets/images/jackpot.png";
    kPrimarySeedColor = gameName[2]['color'];
  }
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {}
  if (!kIsWeb && (Platform.isWindows || Platform.isMacOS || Platform.isLinux)) {
    await windowManager.ensureInitialized();

    const windowOptions = WindowOptions(
      size: Size(1280, 720),
      center: true,
      backgroundColor: Colors.transparent,
      titleBarStyle: TitleBarStyle.hidden, // 👈 hides top native bar
      skipTaskbar: false,
      fullScreen: false,
    );

    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.setFullScreen(true); // Forces full screen
      // await windowManager.setAlwaysOnTop(true); // Optional: locks window on top
      // await windowManager
      //     .setPreventClose(true); // Optional: blocks close button

      await windowManager.maximize(); // 👈 just maximize, not fullScreen
      await windowManager.focus();
    });
  }

  // Update the app icons based on currentName
  //updateWindowsAppIcons();

  SharedPref.instance = await SharedPreferences.getInstance();
  debugPrint(
      "checking initiall shared pref ${SharedPref.instance.getInt("paperSelect")}");
  tz.initializeTimeZones();
  updateAndroidManifestAppName(); // Update app name in the AndroidManifest.xml file
  updateWebManifestAppName();
  runApp(const ProviderScope(child: KeyBlocker(child: MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(mySystemTheme);
    return MaterialApp(
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        scrollbars: false,
        dragDevices: {
          PointerDeviceKind.mouse,
          PointerDeviceKind.touch,
          PointerDeviceKind.stylus,
          PointerDeviceKind.unknown,
          PointerDeviceKind.trackpad,
        },
      ),
      debugShowCheckedModeBanner: false,
      title: titile,
      theme: appTheme,
      home: PreloadView(), // 👈 Add this line
    );
  }
}

//for mobile
void updateAndroidManifestAppName() async {
  final manifestFile = File('android/app/src/main/AndroidManifest.xml');
  if (await manifestFile.exists()) {
    var manifestContent = await manifestFile.readAsString();
    if (currentName == "PSG LOTTO") {
      manifestContent = manifestContent.replaceAll('PLAY LOTTO', 'PSG LOTTO');
      manifestContent = manifestContent.replaceAll(
          'android:name="psglotto"', 'android:name="playlotto"');
    } else {
      manifestContent = manifestContent.replaceAll('PSG LOTTO', 'PLAY LOTTO');
      manifestContent = manifestContent.replaceAll(
          'android:name="playlotto"', 'android:name="psglotto"');
    }
    await manifestFile.writeAsString(manifestContent);
  }
}

//web
void updateWebManifestAppName() async {
  var manifestPath = 'web/manifest.json';
  var mainIndexPath = 'web/index.html';
  final manifestFile = File(manifestPath);
  final mainIndexFile = File(mainIndexPath);
  if (await manifestFile.exists() && await mainIndexFile.exists()) {
    final manifestContent = await manifestFile.readAsString();
    final mainIndexContent = await mainIndexFile.readAsString();
    final manifestJson = json.decode(manifestContent);
    var mainIndexHtml = mainIndexContent.replaceAll(
        'path/to/your/favicon.png', 'assets/icons/favicon.png');

    if (currentName == "PSG LOTTO") {
      manifestJson['name'] = 'PSG LOTTO';
      manifestJson['icons'] = [
        {'src': 'assets/icons/logo.png', 'sizes': '192x192'}
      ];
      mainIndexHtml = mainIndexHtml.replaceAll(
          'path/to/your/logo.png', 'assets/images/logo.png');
    } else {
      manifestJson['name'] = 'PLAY LOTTO';
      manifestJson['icons'] = [
        {'src': 'assets/icons/logoPlay.png', 'sizes': '192x192'}
      ];
      mainIndexHtml = mainIndexHtml.replaceAll(
          'path/to/your/logo.png', 'assets/images/logoPlay.png');
    }

    await manifestFile.writeAsString(json.encode(manifestJson));

    final updatedIndexContent = mainIndexContent.replaceAll(
        '<link rel="icon" type="image/png" href="favicon.png"/>',
        '<link rel="icon" type="image/png" href="assets/icons/favicon.png"/>');

    await mainIndexFile.writeAsString(updatedIndexContent);
  }
}

void updateWindowsAppIcons() async {
  final resourceFile = File('windows/runner/Runner.rc'); // Correct file name

  if (await resourceFile.exists()) {
    var resourceContent = await resourceFile.readAsString();

    String iconSet;
    if (currentName == "PSG LOTTO") {
      iconSet = 'psg_lotto';
    } else if (currentName == "PLAY LOTTO") {
      iconSet = 'play_lotto';
    } else {
      iconSet = 'default';
    }

    // Update all icon paths in the .rc file
    resourceContent = resourceContent.replaceAllMapped(
        RegExp(r'resources//app_icon(?:_\d+)?\.ico'),
        (match) => 'resources/$iconSet/${match[0]!.split('/').last}');

    await resourceFile.writeAsString(resourceContent);
  }
}



/*

    series_2d:
    git:
      url: https://bitbucket.org/trirope-flutter/2d-series.git
      ref: develop    


*/