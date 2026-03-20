import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:psglotto/services/api_service.dart';

class MyAppLifecycleObserver with WidgetsBindingObserver {
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      // App is going into the background or being closed
      if (kDebugMode) {
        print('App is going into the background or being closed');
      }
      // Call your sign-out function here
      ApiService.signOut();
    } else if (state == AppLifecycleState.resumed) {
      // App is returning from the background
      if (kDebugMode) {
        print('App is returning from the background');
      }
    }
  }
}
