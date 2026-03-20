import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:psglotto/utils/api_constants.dart';
import 'package:psglotto/view/login_view.dart';
import 'package:psglotto/view/utils/download_helper.dart';
import 'package:psglotto/view/utils/url.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/utils/window_controls.dart';
import 'package:psglotto/view/widgets/snackbar.dart';
import 'package:series_2d/utils/game_data_constant.dart';

import 'package:url_launcher/url_launcher.dart';
import 'package:window_manager/window_manager.dart';

class PreloadView extends StatefulWidget {
  const PreloadView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PreloadViewState createState() => _PreloadViewState();
}

class _PreloadViewState extends State<PreloadView> {
  StreamSubscription<ConnectivityResult>? subscription;
  Stream<ConnectivityResult>? connectivityStream;

  @override
  void initState() {
    super.initState();
    Helper.initPlatformState();
    if (kIsWeb) {
      checkForUpdate();
    } else {
      subscription = Connectivity().onConnectivityChanged.listen((event) {
        if (event == ConnectivityResult.wifi ||
            event == ConnectivityResult.ethernet ||
            event == ConnectivityResult.mobile) {
          checkForUpdate();
          Helper.initPlatformState();
        }
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (kIsWeb) {
      connectivityStream = Connectivity().onConnectivityChanged;
      connectivityStream!.listen((event) {
        if (event == ConnectivityResult.wifi ||
            event == ConnectivityResult.ethernet ||
            event == ConnectivityResult.mobile) {
          checkForUpdate();
        }
      });
    }
  }

  Future<void> _launchInBrowser(String url) async {
    // ignore: deprecated_member_use
    if (!await launch(url)) {
      throw 'Could not launch $url';
    }
  }

Future<void> _showUpdateDialog(String url, String title, String message) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: <Widget>[
          ElevatedButton(
            child: url == "maintenanceMode"
                ? const Text("OK")
                : const Text("Update"),
            onPressed: () async {
              if (url == "maintenanceMode") {
                await WindowControls.close();
              } else {
                if (Platform.isAndroid || Platform.isWindows || Platform.isMacOS) {
                  await downloadAndInstall(url,context);
                } else {
                  _launchInBrowser(url);
                }
              }
            },
          ),
          if (url != "maintenanceMode")
            TextButton(
              child: const Text("Close"),
              onPressed: () async {
                await WindowControls.close();
              },
            ),
        ],
      );
    },
  );
}

  void checkForUpdate() async {
    bool networkStatus = await Helper.checkNetworkConnection();
    if (networkStatus) {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();

      String version = packageInfo.version;
      if (kDebugMode) {
        print("This is my version: $version");
      }

      final response = await http.get(
        Uri.parse(UrlSet.configurl),
      );
      if (kDebugMode) {
        print("This is response url from Pre Loading scree: ${response.body}");
      }

      Map<String, dynamic> parsed = jsonDecode(response.body);
      debugPrint(parsed.toString());

      if (parsed["apiUrl"] != null) {
        ApiConstants.baseUrl = "${parsed["apiUrl"]}/api/";
      }

      // String webUpdateUrl = parsed["web"] ?? "";
      String androidUpdateUrl = parsed["android"] ?? "";
      String windowsUpdateUrl = parsed["windows"] ?? "";
      String macUpdateUrl = parsed["mac"] ?? "";
      gameTypeSelection3dConfig = parsed["gameTypeSelection3d"];
      debugPrint("checking selection list =============> $gameTypeSelection3dConfig");
      
      gameLowPrizeIsSelection = parsed["gameLowPrizeIsSelection"];
      lottoMaxCountTicketBuy = parsed["lottoMaxCountTicketBuy"];
      if (parsed["setting"]["maintenanceMode"] == "true") {
        //
        _showUpdateDialog(
            "maintenanceMode",
            parsed["setting"]["maintenanceTitle"],
            parsed["setting"]["maintenanceMsg"]);
      } else {
        if (kIsWeb) {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginView(),
            ),
          );
        } else if (Platform.isAndroid &&
            androidUpdateUrl.isNotEmpty &&
            androidUpdateUrl != version) {
          _showUpdateDialog(parsed["apk"], parsed["setting"]["updateTitle"],
              parsed["setting"]["updateMsg"]);
        } else if (Platform.isWindows &&
            windowsUpdateUrl.isNotEmpty &&
            windowsUpdateUrl != version) {
          _showUpdateDialog(parsed["exe"], parsed["setting"]["updateTitle"],
              parsed["setting"]["updateMsg"]);
        } else if (Platform.isMacOS &&
            macUpdateUrl.isNotEmpty &&
            macUpdateUrl != version) {
          _showUpdateDialog(parsed["dmg"], parsed["setting"]["updateTitle"],
              parsed["setting"]["updateMsg"]);
        } else {
          if (!mounted) return;
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginView(),
            ),
          );
        }
      }
    } else {
      if (!mounted) return;
      showSnackBar(context, "Check your internet connection");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kPrimarySeedColor,
      body: StreamBuilder<ConnectivityResult>(
        stream:
            kIsWeb ? connectivityStream : Connectivity().onConnectivityChanged,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data == ConnectivityResult.mobile ||
                snapshot.data == ConnectivityResult.wifi ||
                snapshot.data == ConnectivityResult.ethernet ||
                kIsWeb) {
              // If internet is available, navigate to login page
              WidgetsBinding.instance.addPostFrameCallback((_) {
                checkForUpdate();
              });
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset(
                      logoPath,
                      height: 150.0,
                      width: 150.0,
                    ),
                    const SizedBox(
                      height: 40.0,
                    ),
                    const SizedBox(
                      width: 130.0,
                      child: LinearProgressIndicator(),
                    ),
                  ],
                ),
              );
            } else {
              // Show alert dialog when no internet
              WidgetsBinding.instance.addPostFrameCallback((_) {
                showDialog(
                  context: context,
                  barrierDismissible:
                      false, // 👈 Prevent outside tap to dismiss
                  builder: (context) => AlertDialog(
                    backgroundColor: Colors.black,
                    title: const Text(
                      "Connection Error",
                      style: TextStyle(color: Colors.white),
                    ),
                    content: const Text(
                      "No internet connection.",
                      style: TextStyle(color: Colors.white70),
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          windowManager.close();
                        },
                        child: const Text(
                          "OK",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                );
              });

              return const SizedBox
                  .shrink(); // or show a loader/empty UI while dialog shows
            }
          } else {
            // If initial connectivity state is not determined yet, show a loading indicator
            return const Center(
              child:
                  CircularProgressIndicator(), // You can use a different loading indicator here if desired
            );
          }
        },
      ),
    );
  }

  @override
  void dispose() {
    subscription?.cancel();
    super.dispose();
  }
}
