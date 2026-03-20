import 'package:connectivity_plus/connectivity_plus.dart';

class NetworkCheckHelper {
  static Connectivity connectivity = Connectivity();
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
}
