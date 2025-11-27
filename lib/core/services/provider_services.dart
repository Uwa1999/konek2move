import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiServices _api = ApiServices();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Stored notifications
  final List<NotificationModel> _notifications = [];
  List<NotificationModel> get notifications =>
      List.unmodifiable(_notifications);

  // Only unread notifications
  List<NotificationModel> get unreadNotifications =>
      _notifications.where((n) => !n.isRead).toList();

  int get unreadCount => unreadNotifications.length;

  // Track notifications we've already marked as read
  final Set<int> _readIds = {};

  // SSE subscription
  StreamSubscription<Map<String, dynamic>>? _sseSubscription;

  // Count all incoming notifications for debug
  int totalIncomingNotifications = 0;

  // -----------------------------------------------------------
  // FETCH ALL NOTIFICATIONS (initial load)
  // -----------------------------------------------------------
  Future<void> fetchNotifications({
    required String userCode,
    required String userType,
  }) async {
    try {
      final list = await _api.getNotifications(
        userCode: userCode,
        userType: userType,
      );

      _notifications.clear();
      for (var n in list) {
        final isRead = _readIds.contains(n.id) || n.isRead;
        _notifications.add(n.copyWith(isRead: isRead));
      }

      // Sort by newest
      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      notifyListeners();
    } catch (e) {
      print("❌ Error fetching notifications: $e");
    }
  }

  // -----------------------------------------------------------
  // MARK AS READ
  // -----------------------------------------------------------
  Future<void> markAsRead({
    required NotificationModel notif,
    required String userCode,
    required String userType,
  }) async {
    final index = _notifications.indexWhere((n) => n.id == notif.id);
    if (index != -1 && !_notifications[index].isRead) {
      _notifications[index] = _notifications[index].copyWith(isRead: true);
      _readIds.add(notif.id);
      notifyListeners();

      try {
        await _api.markNotificationAsRead(
          notificationId: notif.id,
          userCode: userCode,
          userType: userType,
        );
      } catch (e) {
        print("❌ Error marking notification as read on server: $e");
      }
    }
  }

  // -----------------------------------------------------------
  // SSE LISTENER (LIVE NOTIFS)
  // -----------------------------------------------------------
  void listenLiveNotifications({
    required String userCode,
    required String userType,
  }) async {
    _sseSubscription?.cancel();
    _sseSubscription = _api
        .listenNotifications(userCode: userCode, userType: userType)
        .listen(
          (event) {
            final data = event["data"];
            if (data == null) {
              print("⚠️ SSE event missing data field");
              return;
            }

            totalIncomingNotifications++;

            final notif = NotificationModel.fromJson(data);

            if (notif.id == 0 || notif.title.isEmpty) return;

            if (_notifications.any((n) => n.id == notif.id)) {
              return;
            }

            final isRead = _readIds.contains(notif.id);

            // Play sounds for unread notifications
            if (!isRead) {
              _playNotificationSound();
            }

            _notifications.insert(0, notif.copyWith(isRead: isRead));
            notifyListeners();
          },
          onError: (error) async {
            await Future.delayed(const Duration(seconds: 5));
            reconnect(userType: userType);
          },
          onDone: () async {
            await Future.delayed(const Duration(seconds: 5));
            reconnect(userType: userType);
          },
          cancelOnError: false,
        );

    // Stop previous subscription
    // _sseSubscription?.cancel();
    //
    // print("🔌 Starting SSE for $userCode");
    //
    // _sseSubscription = _api
    //     .listenNotifications(userCode: userCode, userType: userType)
    //     .listen(
    //       (event) {
    //         // event = Map<String, dynamic>
    //         final data = event["data"];
    //         if (data == null) {
    //           print("⚠️ SSE event missing data field");
    //           return;
    //         }
    //
    //         totalIncomingNotifications++;
    //         print("📩 SSE Notification #$totalIncomingNotifications → $data");
    //
    //         final notif = NotificationModel.fromJson(data);
    //
    //         // Skip empty or invalid notifications
    //         if (notif.id == 0 || notif.title.isEmpty) return;
    //
    //         // Deduplicate
    //         if (_notifications.any((n) => n.id == notif.id)) {
    //           print("⚠️ Duplicate notification ID ${notif.id} ignored");
    //           return;
    //         }
    //
    //         final isRead = _readIds.contains(notif.id);
    //
    //         // Insert newest on top
    //         _notifications.insert(0, notif.copyWith(isRead: isRead));
    //
    //         notifyListeners();
    //       },
    //       onError: (error) async {
    //         print("❌ SSE error: $error");
    //         await Future.delayed(const Duration(seconds: 5));
    //         reconnect(userType: userType);
    //       },
    //       onDone: () async {
    //         print("⚠️ SSE closed. Reconnecting...");
    //         await Future.delayed(const Duration(seconds: 5));
    //         reconnect(userType: userType);
    //       },
    //       cancelOnError: false,
    //     );
  }

  // -----------------------------------------------------------
  // RECONNECT
  // -----------------------------------------------------------
  Future<void> reconnect({required String userType}) async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString("driver_code") ?? "";

    if (code.isNotEmpty) {
      listenLiveNotifications(userCode: code, userType: userType);
    }
  }

  // -----------------------------------------------------------
  // STOP LISTENING
  // -----------------------------------------------------------
  void stopListening() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  // -----------------------------------------------------------
  // NOTIFICATION SOUND
  // -----------------------------------------------------------
  void _playNotificationSound() async {
    try {
      await _audioPlayer.play(
        AssetSource(
          'sounds/notification.mp3',
        ), // place your mp3 in assets/sounds/
        volume: 1.0,
      );
    } catch (e) {
      print('🔊 Failed to play notification sounds: $e');
    }
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

// class ConnectivityProvider extends ChangeNotifier {
//   // Use a Set for more efficient checking of different connection types
//   Set<ConnectivityResult> _connectivityStatus = {ConnectivityResult.none};
//   Set<ConnectivityResult> get connectivityStatus => _connectivityStatus;
//
//   late StreamSubscription<List<ConnectivityResult>> _subscription;
//   final Connectivity _connectivity = Connectivity();
//
//   ConnectivityProvider() {
//     _initConnectivity();
//   }
//
//   void _initConnectivity() async {
//     // Initial check
//     final initialStatus = await _connectivity.checkConnectivity();
//     _connectivityStatus = initialStatus.toSet();
//     notifyListeners();
//
//     // Listen for changes
//     _subscription = _connectivity.onConnectivityChanged.listen((
//       List<ConnectivityResult> results,
//     ) {
//       _connectivityStatus = results.toSet();
//       notifyListeners();
//     });
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
//
//   // Simplified and correct check for connectivity
//   bool get isConnected {
//     // Check if the set contains any status that implies a connection
//     return !_connectivityStatus.contains(ConnectivityResult.none);
//   }
// }
class ConnectivityProvider extends ChangeNotifier {
  Set<ConnectivityResult> _connectivityStatus = {};
  bool _isChecking = true;

  bool get isConnected =>
      !_connectivityStatus.contains(ConnectivityResult.none);

  bool get isChecking => _isChecking;

  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final Connectivity _connectivity = Connectivity();

  ConnectivityProvider() {
    _initConnectivity();
  }

  void _initConnectivity() async {
    // Start checking
    _isChecking = true;
    notifyListeners();

    // Initial check
    final initialStatus = await _connectivity.checkConnectivity();
    _connectivityStatus = initialStatus.toSet();

    // Done checking
    _isChecking = false;
    notifyListeners();

    // Listen for changes
    _subscription = _connectivity.onConnectivityChanged.listen((
      List<ConnectivityResult> results,
    ) {
      _connectivityStatus = results.toSet();
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
