import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'api_services.dart';

class DriverLocationService {
  final ApiServices _api = ApiServices();

  Timer? _idleTimer;
  Timer? _recurringTimer;

  final Duration idleDuration = Duration(seconds: 15);
  final Duration recurringDuration = Duration(seconds: 2);

  /// Start monitoring driver activity
  void startMonitoring() {
    _startRecurringUpdates();
  }

  /// Reset idle timer on any user activity
  void userActivityDetected() {
    _idleTimer?.cancel();
    _idleTimer = Timer(idleDuration, () async {
      await _sendLocation();
    });
  }

  /// Recurring updates every 2-3 minutes
  void _startRecurringUpdates() {
    _recurringTimer = Timer.periodic(recurringDuration, (_) async {
      await _sendLocation();
    });
  }

  /// Fetch current location and call API
  Future<void> _sendLocation() async {
    try {
      // Get current GPS location
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      String lat = position.latitude.toString();
      String lng = position.longitude.toString();

      // Call your API
      final response = await _api.updateLocation(lng: lng, lat: lat);
    } catch (e) {
      print('Error sending location: $e');
    }
  }

  /// Dispose timers when screen/app closes
  void dispose() {
    _idleTimer?.cancel();
    _recurringTimer?.cancel();
  }
}
