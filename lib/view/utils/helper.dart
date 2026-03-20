import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:process_run/process_run.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:http/http.dart' as http;

enum LoginType { android, windows, unknown }

class Helper {
  static Connectivity connectivity = Connectivity();

  static String epocToMMddYYYYhhMMaa(int epocTime) {
    // DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
    // var format = DateFormat("hh-mm-ss");
    // var dateString = format.format(date);

    return DateFormat('dd-MM-yyyy hh:mm a')
        .format(DateTime.fromMillisecondsSinceEpoch(epocTime));
  }

  static String epocToMMddYYYY(epocTime) {
    return DateFormat('dd/MM/yyyy')
        .format(DateTime.fromMillisecondsSinceEpoch(epocTime));
  }

  static String epocToYYYYMMddhms(epocTime) {
    return DateFormat('yyyy-MM-dd hh:mm:ss a')
        .format(DateTime.fromMillisecondsSinceEpoch(epocTime));
  }

  static Future<bool> checkNetworkConnection() async {
    bool networkStatus = false;
    ConnectivityResult connectionStatus =
        await connectivity.checkConnectivity();
    if (connectionStatus == ConnectivityResult.mobile) {
      networkStatus = true;
    } else if (connectionStatus == ConnectivityResult.wifi) {
      networkStatus = true;
    } else if (connectionStatus == ConnectivityResult.ethernet) {
      networkStatus = true;
    } else {
      networkStatus = false;
    }
    return networkStatus;
  }

  static String getIndianCurrencyInShorthand({required double amount}) {
    final inrShortCutFormatInstance =
        NumberFormat.compactSimpleCurrency(locale: 'en_IN', name: "");
    var inrShortCutFormat = inrShortCutFormatInstance.format(amount);
    if (inrShortCutFormat.contains('T')) {
      return inrShortCutFormat.replaceAll(RegExp(r'T'), 'k');
    } else if (inrShortCutFormat.contains('L')) {
      return inrShortCutFormat.replaceAll(RegExp(r'L'), 'Lakhs');
    }
    return inrShortCutFormat;
  }

  static String getDeviceType() {
    if (kIsWeb) {
      return "mobile";
    } else {
      return Platform.isAndroid ? "Mobile" : "Desktop";
    }
  }

  static Future<String?> getWindowsUUID() async {
    final shell = Shell();
    try {
      final result = await shell.run('wmic csproduct get UUID');
      final output = result.first.stdout.toString().split('\n');
      debugPrint("checking UUID: $output");
      if (output.length > 1) {
        return output[1].trim(); // This should be the UUID
      }
    } catch (e) {
      debugPrint("Error reading UUID: $e");
    }
    return null;
  }

  static void getDeviceModel() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (kIsWeb) {
      if (kDebugMode) {
        print("log coming from get device model : ========>$kIsWeb");
      }
      String webInfo = "Chrome";
      SharedPref.instance.setString("devicemodel", webInfo);
    } else if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      SharedPref.instance
          .setString("devicemodel", androidInfo.model.toString());
    } else if (Platform.isIOS) {
      IosDeviceInfo iosDeviceInfo = await deviceInfo.iosInfo;
      String iosModelInfo = "${iosDeviceInfo.name} iOS";
      SharedPref.instance.setString("devicemodel", iosModelInfo);
    } else if (Platform.isMacOS) {
      MacOsDeviceInfo macOsDeviceInfo = await deviceInfo.macOsInfo;
      String macosModelInfo = "${macOsDeviceInfo.computerName} MacOs";
      SharedPref.instance.setString("devicemodel", macosModelInfo);
    } else {
      WindowsDeviceInfo windowsInfo = await deviceInfo.windowsInfo;
      String windowsModel = "${windowsInfo.computerName} Windows";
      SharedPref.instance.setString("devicemodel", windowsModel);
    }
  }

  static final DeviceInfoPlugin deviceInfoPlugin = DeviceInfoPlugin();

  //Device hardware info

  static Future<void> initPlatformState() async {
    var deviceData = <String, dynamic>{};

    String loginType = "";
    try {
      if (kIsWeb) {
        deviceData = _readWebBrowserInfo(await deviceInfoPlugin.webBrowserInfo);
        String deviceId = deviceData["browserName"];
        SharedPref.instance.setString("deviceId", deviceId);
        loginType = deviceData["platform"];
        SharedPref.instance.setString("deviceName", loginType);
        if (kDebugMode) {
          print("=====>>>>>>>>>>>>>>>>>>>>>$deviceId   : $loginType");
        }
      } else {
        if (Platform.isAndroid) {
          deviceData =
              _readAndroidBuildData(await deviceInfoPlugin.androidInfo);

          String deviceName = deviceData["model"] + deviceData["brand"];
          SharedPref.instance.setString("deviceName", deviceName.toString());
          String deviceId = deviceData["id"];
          SharedPref.instance.setString("deviceId", deviceId.toString());
          loginType = deviceData["product"];
          SharedPref.instance.setString("loginType", loginType.toString());
        } else if (Platform.isIOS) {
          deviceData = _readIosDeviceInfo(await deviceInfoPlugin.iosInfo);
          String deviceId = deviceData["id"];
          SharedPref.instance.setString("deviceId", deviceId.toString());
          loginType = deviceData["systemName"];
          SharedPref.instance.setString("loginType", loginType.toString());
        } else if (Platform.isLinux) {
          deviceData = _readLinuxDeviceInfo(await deviceInfoPlugin.linuxInfo);
          String deviceId = deviceData["id"];
          SharedPref.instance.setString("deviceId", deviceId.toString());
          loginType = deviceData["name"];
          SharedPref.instance.setString("loginType", loginType.toString());
        } else if (Platform.isMacOS) {
          deviceData = _readMacOsDeviceInfo(await deviceInfoPlugin.macOsInfo);
          String deviceId = deviceData["systemGUID"];
          SharedPref.instance.setString("deviceId", deviceId.toString());
          loginType = deviceData["hostName"];
          SharedPref.instance.setString("loginType", loginType.toString());

          String deviceName = deviceData["computerName"];
          SharedPref.instance
              .setString("deviceReference", deviceName.toString());
        } else if (Platform.isWindows) {
          deviceData =
              _readWindowsDeviceInfo(await deviceInfoPlugin.windowsInfo);
          // String? deviceId =
          //     deviceData["deviceId"]?.replaceAll(RegExp(r"[{}]"), "");

          // SharedPref.instance.setString("deviceId", deviceId.toString());

          // ✅ Get UUID properly
          String? deviceId = await getWindowsUUID();
          if (deviceId != null && deviceId.isNotEmpty) {
            await SharedPref.instance.setString("deviceId", deviceId);
          }

          loginType = deviceData["platformId"].toString();

          SharedPref.instance.setString("loginType", loginType.toString());

          String deviceName = deviceData["computerName"];
          SharedPref.instance
              .setString("deviceReference", deviceName.toString());
        }
      }
    } on PlatformException {
      deviceData = <String, dynamic>{
        'Error:': 'Failed to get platform version.'
      };
    }
  }

//  static Future<String?> getLocalIp() async {
//   try {
//     final NetworkInfo networkInfo = NetworkInfo();
//     String? ip = await networkInfo.getWifiIP();
//     debugPrint("checking IP Address: $ip");
//     return ip;
//   } catch (e) {
//     debugPrint("Failed to get local IP: $e");
//     return null;
//   }
// }

   static Future<String?> getDeviceIp() async {
    final urls = [
      'https://icanhazip.com',
      'https://ifconfig.me/ip',
      'https://ipinfo.io/ip',
    ];

    for (final url in urls) {
      try {
        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final ip = response.body.trim();
          if (ip.isNotEmpty) {
            debugPrint("✅ Public IP fetched from $url: $ip");
            return ip;
          }
        }
      } catch (e) {
        debugPrint("⚠️ Failed to fetch IP from $url: $e");
      }
    }

    debugPrint("❌ Could not retrieve public IP from any source.");
    return null;
  }

//WebBrowser
  static Map<String, dynamic> _readWebBrowserInfo(WebBrowserInfo data) {
    return <String, dynamic>{
      // ignore: deprecated_member_use
      'browserName': describeEnum(data.browserName),
      'appCodeName': data.appCodeName,
      'appName': data.appName,
      'appVersion': data.appVersion,
      'platform': data.platform,
      'product': data.product,
      'userAgent': data.userAgent,
      'vendor': data.vendor,
    };
  }

  //android
  static Map<String, dynamic> _readAndroidBuildData(AndroidDeviceInfo build) {
    return <String, dynamic>{
      'version.securityPatch': build.version.securityPatch,
      'version.sdkInt': build.version.sdkInt,
      'version.release': build.version.release,
      'board': build.board,
      'brand': build.brand,
      'device': build.device,
      'display': build.display,
      'id': build.id,
      'manufacturer': build.manufacturer,
      'model': build.model,
      'product': build.product,
    };
  }

  //ios
  static Map<String, dynamic> _readIosDeviceInfo(IosDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'systemName': data.systemName,
      'systemVersion': data.systemVersion,
      'model': data.model,
      'localizedModel': data.localizedModel,
      'isPhysicalDevice': data.isPhysicalDevice,
      'utsname.sysname:': data.utsname.sysname,
      'utsname.nodename:': data.utsname.nodename,
      'utsname.release:': data.utsname.release,
    };
  }

//Linux
  static Map<String, dynamic> _readLinuxDeviceInfo(LinuxDeviceInfo data) {
    return <String, dynamic>{
      'name': data.name,
      'version': data.version,
      'id': data.id,
      'idLike': data.idLike,
      'versionCodename': data.versionCodename,
      'versionId': data.versionId,
      'prettyName': data.prettyName,
      'buildId': data.buildId,
      'variant': data.variant,
      'variantId': data.variantId,
      'machineId': data.machineId,
    };
  }

  //Windows

  static Map<String, dynamic> _readWindowsDeviceInfo(WindowsDeviceInfo data) {
    return <String, dynamic>{
      'numberOfCores': data.numberOfCores,
      'computerName': data.computerName,
      'systemMemoryInMegabytes': data.systemMemoryInMegabytes,
      'userName': data.userName,
      'majorVersion': data.majorVersion,
      'minorVersion': data.minorVersion,
      'buildNumber': data.buildNumber,
      'platformId': data.platformId,
      'productType': data.productType,
      'productId': data.productId,
      'productName': data.productName,
      'releaseId': data.releaseId,
      'deviceId': data.deviceId,
    };
  }

  //Mac os
  static Map<String, dynamic> _readMacOsDeviceInfo(MacOsDeviceInfo data) {
    return <String, dynamic>{
      'computerName': data.computerName,
      'hostName': data.hostName,
      'arch': data.arch,
      'model': data.model,
      'kernelVersion': data.kernelVersion,
      'osRelease': data.osRelease,
      'activeCPUs': data.activeCPUs,
      'memorySize': data.memorySize,
      'cpuFrequency': data.cpuFrequency,
      'systemGUID': data.systemGUID,
    };
  }
}
