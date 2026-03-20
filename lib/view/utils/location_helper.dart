// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:geocoding/geocoding.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:series_2d/game_init_loader.dart';

// class LocationHelper {
//   static Future<void> getLocationPermission(Function callback) async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         await Geolocator.openLocationSettings();
//         return Future.error('❌ Location services are disabled.');
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return Future.error('❌ Location permissions are denied.');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         return Future.error('❌ Location permissions are permanently denied.');
//       }

//       // 🎯 Use platform-specific location settings
//       late LocationSettings locationSettings;

//       if (defaultTargetPlatform == TargetPlatform.android) {
//         locationSettings = AndroidSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 50,
//           forceLocationManager: true,
//           intervalDuration: const Duration(seconds: 10),
//           foregroundNotificationConfig: const ForegroundNotificationConfig(
//             notificationText: "App is getting your location",
//             notificationTitle: "Background Location Enabled",
//             enableWakeLock: true,
//           ),
//         );
//       } else if (defaultTargetPlatform == TargetPlatform.iOS ||
//           defaultTargetPlatform == TargetPlatform.macOS) {
//         locationSettings = AppleSettings(
//           accuracy: LocationAccuracy.high,
//           activityType: ActivityType.fitness,
//           distanceFilter: 50,
//           pauseLocationUpdatesAutomatically: true,
//           showBackgroundLocationIndicator: false,
//         );
//       } else if (kIsWeb) {
//         locationSettings = WebSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 50,
//           maximumAge: Duration(minutes: 5),
//         );
//       } else {
//         locationSettings = const LocationSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 50,
//         );
//       }

//       // 📍 Get the current location using the chosen settings
//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings: locationSettings,
//       );

//       // ✅ Check for accuracy (optional)
//       if (position.accuracy > 1000) {
//         return Future.error('⚠️ Location accuracy is too low.');
//       }

//       // 🧠 Save and use the location
//       await getAddress(position, callback);
//     } catch (e, stack) {
//       log("⚠️ Error in getLocationPermission: $e");
//       log("StackTrace: $stack");
//       callback();
//     }
//   }

//   static Future<void> getAddress(Position position, Function callback) async {
//     log("📍 Coordinates - Latitude: ${position.latitude}, Longitude: ${position.longitude}");

//     try {
//       final List<Placemark> placemarks = await placemarkFromCoordinates(
//         position.latitude,
//         position.longitude,
//       );

//       Map<String, dynamic> addressData = {
//         "Latitude": position.latitude,
//         "Longitude": position.longitude,
//       };

//       if (placemarks.isNotEmpty) {
//         final place = placemarks.first;

//         log("📌 Placemark Info:");
//         log("   🏙️ Name: ${place.name}");
//         log("   🛣️ Street: ${place.street}");
//         log("   📍 Locality: ${place.locality}");
//         log("   🗺️ Admin Area: ${place.administrativeArea}");
//         log("   ✉️ Postal Code: ${place.postalCode}");
//         log("   🌍 Country: ${place.country}");

//         addressData.addAll({
//           "Name": place.name ?? "",
//           "Street": place.street ?? "",
//           "Locality": place.locality ?? "",
//           "AdminArea": place.administrativeArea ?? "",
//           "PostalCode": place.postalCode ?? "",
//           "Country": place.country ?? "",
//         });
//       } else {
//         log("⚠️ No placemark data found, storing only lat/lng.");
//       }

//       final String addressDataJson = jsonEncode(addressData);
//       log("💾 Final Location JSON to Save: $addressDataJson");

//       await SharedPref.instance.setString('locationData', addressDataJson);
//     } catch (e, stack) {
//       log("❗ Error while resolving address: $e");
//       log("StackTrace: $stack");

//       // Fallback to storing just lat/lng
//       final fallbackData = jsonEncode({
//         "Latitude": position.latitude,
//         "Longitude": position.longitude,
//       });

//       await SharedPref.instance.setString('locationData', fallbackData);
//     }

//     callback(); // Always call callback after storing location data
//   }
// }

// import 'dart:convert';
// import 'dart:developer';

// import 'package:flutter/foundation.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:series_2d/game_init_loader.dart';

// class LocationHelper {
//   static Future<void> getLocationPermission(Function callback) async {
//     try {
//       bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//       if (!serviceEnabled) {
//         await Geolocator.openLocationSettings();
//         return Future.error('❌ Location services are disabled.');
//       }

//       LocationPermission permission = await Geolocator.checkPermission();
//       if (permission == LocationPermission.denied) {
//         permission = await Geolocator.requestPermission();
//         if (permission == LocationPermission.denied) {
//           return Future.error('❌ Location permissions are denied.');
//         }
//       }

//       if (permission == LocationPermission.deniedForever) {
//         return Future.error('❌ Location permissions are permanently denied.');
//       }

//       late LocationSettings locationSettings;

//       if (defaultTargetPlatform == TargetPlatform.android) {
//         locationSettings = AndroidSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 50,
//           forceLocationManager: true,
//           intervalDuration: const Duration(seconds: 10),
//           foregroundNotificationConfig: const ForegroundNotificationConfig(
//             notificationText: "App is getting your location",
//             notificationTitle: "Background Location Enabled",
//             enableWakeLock: true,
//           ),
//         );
//       } else if (defaultTargetPlatform == TargetPlatform.iOS ||
//           defaultTargetPlatform == TargetPlatform.macOS) {
//         locationSettings = AppleSettings(
//           accuracy: LocationAccuracy.high,
//           activityType: ActivityType.fitness,
//           distanceFilter: 50,
//           pauseLocationUpdatesAutomatically: true,
//           showBackgroundLocationIndicator: false,
//         );
//       } else if (kIsWeb) {
//         locationSettings = WebSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 50,
//           maximumAge: Duration(minutes: 5),
//         );
//       } else {
//         locationSettings = const LocationSettings(
//           accuracy: LocationAccuracy.high,
//           distanceFilter: 50,
//         );
//       }

//       Position position = await Geolocator.getCurrentPosition(
//         locationSettings: locationSettings,
//       );

//       if (position.accuracy > 1000) {
//         return Future.error('⚠️ Location accuracy is too low.');
//       }

//       await saveLatLongOnly(position, callback);
//     } catch (e, stack) {
//       log("⚠️ Error in getLocationPermission: $e");
//       log("StackTrace: $stack");
//       callback();
//     }
//   }

//   static Future<void> saveLatLongOnly(Position position, Function callback) async {
//     log("📍 Saving Coordinates - Latitude: ${position.latitude}, Longitude: ${position.longitude}");

//     final Map<String, dynamic> locationData = {
//       "Latitude": position.latitude,
//       "Longitude": position.longitude,
//     };

//     final String json = jsonEncode(locationData);
//     await SharedPref.instance.setString('locationData', json);
//     log("💾 Location saved to SharedPref: $json");

//     callback();
//   }
// }
