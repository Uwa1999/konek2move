import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api_services.dart';

class DriverLocationService {
  final ApiServices _api = ApiServices();

  Timer? _idleTimer;
  Timer? _recurringTimer;
  Timer? _debounceTimer;

  final Duration idleDuration = Duration(seconds: 15);
  final Duration recurringDuration = Duration(seconds: 5);

  /// Start monitoring driver activity
  void startMonitoring() {
    _startRecurringUpdates();
  }

  /// Detect user activity BUT debounce it to avoid spam
  void userActivityDetected() {
    // Prevent firing many times per second
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(seconds: 5), () {
      _resetIdleTimer();
    });
  }

  void _resetIdleTimer() {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleDuration, () async {
      await _sendLocation(); // send location after idle
    });
  }

  /// Recurring updates every 5 seconds
  void _startRecurringUpdates() {
    _recurringTimer = Timer.periodic(recurringDuration, (_) async {
      await _sendLocation();
    });
  }

  /// Fetch current GPS location and call API
  Future<void> _sendLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      await _api.updateLocation(
        lng: position.longitude.toString(),
        lat: position.latitude.toString(),
      );
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  /// Clear everything
  void dispose() {
    _idleTimer?.cancel();
    _recurringTimer?.cancel();
    _debounceTimer?.cancel();
  }
}
