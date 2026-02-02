part of '../common.dart';

/// Call [dispose] when the provider is no longer used to cancel the
/// connectivity stream subscription.
class NetworkProvider with ChangeNotifier {
  final _connectivity = Connectivity();
  bool _isConnected = false;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool get isConnected => _isConnected;

  Future<void> init() async {
    LoggerService.logTrace('NetworkProvider -> init()');
    final initialConnections = await _connectivity.checkConnectivity();
    if (initialConnections.isContainsAtLeastOne([ConnectivityResult.wifi, ConnectivityResult.ethernet, ConnectivityResult.mobile])) {
      _isConnected = true;
      notifyListeners();
    }

    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((events) {
      final isConnected = events.isContainsAtLeastOne([ConnectivityResult.wifi, ConnectivityResult.ethernet, ConnectivityResult.mobile]);
      if (_isConnected != isConnected) {
        LoggerService.logTrace('NetworkProvider -> onConnectivityChanged(isConnected: $isConnected)');
        _isConnected = isConnected;
        notifyListeners();
      }
    });
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }
}