import 'package:connectivity_plus/connectivity_plus.dart';

enum NetworkStatus { online, offline }

class ConnectivityMonitor {
  final Connectivity _connectivity = Connectivity();

  NetworkStatus get currentStatus => NetworkStatus.online;

  Stream<NetworkStatus> get onStatusChanged {
    return _connectivity.onConnectivityChanged.map((results) {
      if (results.contains(ConnectivityResult.none)) {
        return NetworkStatus.offline;
      }
      return NetworkStatus.online;
    });
  }
}
