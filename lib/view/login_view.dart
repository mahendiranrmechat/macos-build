import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:geolocator/geolocator.dart';
import 'package:package_info_plus/package_info_plus.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:permission_handler/permission_handler.dart';
import 'package:psglotto/services/api_service.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
// import 'package:psglotto/view/utils/location_helper.dart';
import 'package:psglotto/view/utils/url.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/snackbar.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:series_2d/utils/game_data_constant.dart';
import 'package:window_manager/window_manager.dart';
import 'navigation_view.dart';
import 'package:http/http.dart' as http;

class LoginView extends StatefulWidget {
  const LoginView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with WindowListener {
  TextEditingController userIDController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  FocusNode? userNameFocusNode;

  String username = '', password = '';
  bool enableLoginButton = true;
  final loginFormKey = GlobalKey<FormState>();
  bool disableUserNameTextField = false;
  bool obscurePassword = true;
  String appVersion = "";
  int refreshTokenReqTime = 0;
  // PermissionStatus? permission;
  Map<String, dynamic> location = {};
// Define a variable to hold the previous timer instance
  Timer? periodicTimer;
  String? refTime;
  bool serviceEnabled = false;
  bool callLoginNeed = false;
  // Position? position;
  @override
  void initState() {
    super.initState();
    Helper.getDeviceModel();
    Helper.initPlatformState();
    getRefreshTime();
    getVersion();

    userNameFocusNode = FocusNode();
    // Delay requestFocus to ensure the widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      userNameFocusNode!.requestFocus();
    });
  }

  // Future<void> getLocationPermissionAndPosition() async {
  //   try {
  //     serviceEnabled = await Geolocator.isLocationServiceEnabled();
  //     if (!serviceEnabled) {
  //       debugPrint("Location services are disabled.");
  //       callLogin(); // fallback
  //       return;
  //     }

  //     LocationPermission permission = await Geolocator.checkPermission();

  //     if (permission == LocationPermission.denied) {
  //       permission = await Geolocator.requestPermission();
  //     }

  //     if (permission == LocationPermission.deniedForever) {
  //       debugPrint("Location permission is permanently denied.");
  //       callLogin(); // fallback
  //       return;
  //     }

  //     if (permission == LocationPermission.whileInUse ||
  //         permission == LocationPermission.always) {
  //       // ignore: deprecated_member_use
  //       Position position = await Geolocator.getCurrentPosition(
  //           desiredAccuracy: LocationAccuracy.high);

  //       location = {
  //         "lat": position.latitude,
  //         "lon": position.longitude,
  //       };

  //       SharedPref.instance.setString('locationData', location.toString());
  //       debugPrint("Location obtained: $location");
  //     }
  //   } catch (e) {
  //     debugPrint("Location error: $e");
  //   }

  //   callLogin(); // Proceed with login whether location is successful or not
  // }

  callLogin() {
    if (callLoginNeed) {
      callLoginNeed = false;
      validateAndLogin();
    }
  }

  void getVersion() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      appVersion = packageInfo.version;
    });
  }

  Future<void> getRefreshTime() async {
    final response = await http.get(
      Uri.parse(UrlSet.configurl),
    );
    Map<String, dynamic> parsed = jsonDecode(response.body);
    setState(() {
      refTime = parsed["refreshTokenReqTime"];
      debugPrint("This is refresh timer :$refTime ");
      refreshTokenReqTime = int.parse(refTime!);
    });
  }

  /// validates form fields and navigates to loading screen
  Future<void> validateAndLogin() async {
    if (loginFormKey.currentState!.validate()) {
      loginFormKey.currentState!.save();
      setState(() {
        disableUserNameTextField = true;
        enableLoginButton = false;
      });
      bool networkStatus = await Helper.checkNetworkConnection();
      if (networkStatus) {
        String? response = await ApiService().signIn(username, password);
        if (kDebugMode) {
          print("this is repose: $response");
        }
        if (response == "Success") {
          if (!mounted) return;
          refreshTokenUpdated();
          Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(
                builder: (context) => const NavigationView(),
              ),
              (route) => false);
        } else {
          setState(() {
            disableUserNameTextField = false;
            enableLoginButton = true;
          });
          if (!mounted) return;
          Flushbar(
            message: response.toString(),
            duration: const Duration(seconds: 2),
            flushbarPosition: FlushbarPosition.TOP,
            flushbarStyle: FlushbarStyle.FLOATING,
            maxWidth: 300,
            messageColor: Colors.white,
            borderColor: kPrimarySeedColor!,
            borderRadius: BorderRadius.circular(20),
            forwardAnimationCurve: Curves.easeOutQuint,
            icon: const Icon(
              Icons.error,
              color: Colors.white,
            ),
          ).show(context);
        }
      } else {
        setState(() {
          disableUserNameTextField = false;
          enableLoginButton = true;
        });
        if (!mounted) return;
        showSnackBar(context, "Check your internet connection");
      }
    }
  }

  void refreshTokenUpdated() {
    debugPrint("refreshTokenUpdated method called"); // Debug: Method entry

    // Ensure that refreshTokenReqTime is valid
    if (refreshTokenReqTime <= 0) {
      debugPrint(
          "Invalid refreshTokenReqTime: $refreshTokenReqTime"); // Debug: Invalid time
      return;
    }

    // Schedule a new timer
    debugPrint(
        "Scheduling a new timer for token refresh every $refreshTokenReqTime minutes"); // Debug: Timer scheduling

    Timer.periodic(Duration(minutes: refreshTokenReqTime), (timer) {
      debugPrint("Refresh timer triggered"); // Debug: Timer triggered

      // Call the API service to refresh the token
      ApiService().getRefreshToken().then((value) {
        // Debug: API call success
        debugPrint("API call to refresh token successful");

        // Update token in the app
        token2dSeries = value.token!;
        SharedPref.instance.setString("token", value.token!);
        SharedPref.instance.setString("refreshToken", value.refreshToken!);

        debugPrint(
            "Token updated successfully in shared preferences"); // Debug: Token update success
      }).catchError((error) {
        // Debug: API call failure
        debugPrint("Token refresh failed: $error");

        // Handle token refresh failure (e.g., stop the timer, prompt user to log in, etc.)
        debugPrint("Stopping timer due to failed token refresh");
        timer.cancel(); // Stop the periodic timer if refresh fails
      });
    });

    debugPrint("New timer scheduled successfully"); // Debug: Timer scheduled
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return WillPopScope(
      onWillPop: _onPop,
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0.0,
          automaticallyImplyLeading: false,
          actions: [
            Center(
              child: Align(
                  alignment: Alignment.topCenter,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Padding(
                      //   padding: const EdgeInsets.only(bottom: 20),
                      //   child: IconButton(
                      //       tooltip: "Minimize",
                      //       onPressed: () async {
                      //         try {
                      //           debugPrint("calling minimize");
                      //           await WindowControls.minimize();
                      //           debugPrint(
                      //               "minimize called successfully");
                      //         } catch (e) {
                      //           debugPrint("Minimize failed: $e");
                      //         }
                      //       },
                      //       icon: const Icon(
                      //         Icons.minimize,
                      //         color: Colors.black,
                      //       )),
                      // ),
                      CustomCloseButton(
                        iconColor: Colors.black,
                      )
                    ],
                  )),
            )
          ],
        ),
        body: Stack(
          children: [
            Center(
              child: Container(
                height: 600,
                width: 400,
                padding: const EdgeInsets.all(kDefaultPadding),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                    12.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Form(
                  key: loginFormKey,
                  child: Column(
                    children: [
                      Image.asset(
                        logoPath,
                        height: 100,
                        width: 100,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        focusNode: userNameFocusNode,
                        decoration: InputDecoration(
                          filled: true,
                          // ignore: deprecated_member_use
                          fillColor: Colors.grey.withOpacity(0.12),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: const Icon(
                            Icons.person,
                            size: 22.0,
                          ),
                          hintText: "User name",
                          hintStyle: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(
                            kDefaultPadding * 2,
                            kDefaultPadding * 0.8,
                            0,
                            kDefaultPadding * 0.8,
                          ),
                        ),
                        autofocus: false,
                        onSaved: (value) {
                          username = value!.trim();
                        },
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        controller: userIDController,
                        validator: (value) {
                          value = value!.trim();
                          if (value.isEmpty) {
                            return "Invalid username";
                          }
                          return null;
                        },
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 20.0),
                      TextFormField(
                        readOnly: disableUserNameTextField,
                        autocorrect: false,
                        obscureText: obscurePassword,
                        style: const TextStyle(
                          fontSize: 16.0,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.deny(RegExp(r'\s')),
                        ],
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey.withOpacity(0.12),
                          border: OutlineInputBorder(
                            borderSide: BorderSide.none,
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          prefixIcon: const Icon(
                            Icons.lock,
                            size: 22.0,
                          ),
                          hintText: "Password",
                          hintStyle: const TextStyle(
                            fontSize: 12.0,
                            fontWeight: FontWeight.w500,
                          ),
                          suffixIcon: IconButton(
                            iconSize: 20.0,
                            onPressed: () => setState(() {
                              obscurePassword = !obscurePassword;
                            }),
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                          contentPadding: const EdgeInsetsDirectional.fromSTEB(
                            kDefaultPadding * 2,
                            kDefaultPadding * 0.8,
                            0,
                            kDefaultPadding * 0.8,
                          ),
                        ),
                        controller: passwordController,
                        onFieldSubmitted: (value) {
                          validateAndLogin();
                        },
                        onSaved: (value) =>
                            {value = value!.trim(), password = value},
                        autofocus: false,
                        autovalidateMode: AutovalidateMode.onUserInteraction,
                        validator: (value) {
                          value = value!.trim();
                          if (value.isEmpty) {
                            return "Invalid password";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      // SizedBox(
                      //   height: 45.0,
                      //   child: ElevatedButton(
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: enableLoginButton
                      //           ? kPrimarySeedColor!
                      //           : Colors.grey,
                      //       fixedSize: Size.fromWidth(
                      //         MediaQuery.of(context).size.width,
                      //       ),
                      //     ),
                      //     onPressed: enableLoginButton
                      //         ? () async {
                      //             FocusManager.instance.primaryFocus?.unfocus();
                      //             //check and valitation
                      //             // permission =
                      //             //     await Permission.location.request();
                      //             // if (permission ==
                      //             //         PermissionStatus.permanentlyDenied ||
                      //             //     permission == PermissionStatus.denied) {
                      //             //   openAppSettings();
                      //             // } else {
                      //             //   if (SharedPref.instance
                      //             //           .getString("locationData") !=
                      //             //       null) {
                      //             //     if (!mounted) return;
                      //             //     if (kDebugMode) {
                      //             //       print(
                      //             //           "This is before validatain:${SharedPref.instance.getString("locationData")} ");
                      //             //     }
                      //             //     validateAndLogin();
                      //             //   } else {
                      //             //     callLoginNeed = true;
                      //             //     getLocationPermission();
                      //             //   }
                      //             // }

                      //             //added new
                      //             // if (SharedPref.instance
                      //             //         .getString("locationData") !=
                      //             //     null) {
                      //             //   if (!mounted) return;
                      //             //   if (kDebugMode) {
                      //             //     print(
                      //             //         "This is before validatain:${SharedPref.instance.getString("locationData")} ");
                      //             //   }
                      //             //   validateAndLogin();
                      //             // }
                      //             validateAndLogin();
                      //           }
                      //         : null,
                      //     child: Text(
                      //       enableLoginButton ? "Login" : "Logging in",
                      //       style: const TextStyle(
                      //         fontSize: 20.0,
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      SizedBox(
                        height: 45.0,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: enableLoginButton
                                ? kPrimarySeedColor!
                                : Colors.grey,
                            fixedSize: Size.fromWidth(
                              MediaQuery.of(context).size.width,
                            ),
                          ),
                          onPressed: enableLoginButton
                              ? () async {
                                  FocusManager.instance.primaryFocus?.unfocus();

                                  // // Step 1: Request location permission
                                  // final permission =
                                  //     await Permission.location.request();

                                  // // Step 2: Check permission status
                                  // if (permission.isGranted) {
                                  //   // Step 3: Check if locationData is already stored
                                  //   final locationData = SharedPref.instance
                                  //       .getString("locationData");

                                  //   if (locationData != null &&
                                  //       locationData.isNotEmpty) {
                                  //     if (!mounted) return;
                                  //     if (kDebugMode) {
                                  //       print(
                                  //           "This is before validation: $locationData");
                                  //     }

                                  //     // Proceed to login
                                  //     validateAndLogin();
                                  //   } else {
                                  //     // If location data is not available, request to fetch it
                                  //     callLoginNeed = true;

                                  //     // Custom method to request and save location
                                  //     await LocationHelper
                                  //         .getLocationPermission(() {
                                  //       if (!mounted) return;
                                  //       validateAndLogin();
                                  //     });
                                  //   }
                                  // } else {
                                  //   // Step 4: Permission denied
                                  //   if (permission.isPermanentlyDenied) {
                                  //     await openAppSettings();
                                  //   } else {
                                  //     if (!mounted) return;
                                  //     // ignore: use_build_context_synchronously
                                  //     ScaffoldMessenger.of(context)
                                  //         .showSnackBar(
                                  //       const SnackBar(
                                  //         content: Text(
                                  //             "Location permission is required to login."),
                                  //       ),
                                  //     );
                                  //   }
                                  // }
                                   validateAndLogin();
                                }
                              : null,
                          child: Text(
                            enableLoginButton ? "Login" : "Logging in",
                            style: const TextStyle(fontSize: 20.0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 10, left: 10),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  "Version:$appVersion",
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 10, right: 10),
              child: Align(
                alignment: Alignment.bottomRight,
                child: Text(
                  '18+ Amusement Purpose Only',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Future<bool> _onPop() async {
    return (await showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Are you sure?'),
            content: const Text('Want to Exit the App'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                //<-- SEE HERE
                child: const Text('No'),
              ),
              TextButton(
                onPressed: () {
                  exit(0);
                  // Navigator.of(context).pop(true);
                  // Navigator.of(context).pop(true);
                },

                // <-- SEE HERE
                child: const Text('Yes'),
              ),
            ],
          ),
        )) ??
        false;
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    periodicTimer?.cancel();
    windowManager.removeListener(this);
    super.dispose();
    userNameFocusNode!.dispose();
  }
}
