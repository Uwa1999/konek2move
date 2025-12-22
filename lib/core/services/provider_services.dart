import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiServices _api = ApiServices();
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Stored notifications
  final List<NotificationResponse> _notifications = [];
  List<NotificationResponse> get notifications =>
      List.unmodifiable(_notifications);

  // Only unread notifications
  List<NotificationResponse> get unreadNotifications =>
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
  Future<void> fetchNotifications(
    //     {
    //   required String userCode,
    //   required String userType,
    // }
  ) async {
    try {
      final list = await _api.getNotifications(
        // userCode: userCode,
        // userType: userType,
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
    required NotificationResponse notif,
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
          // userCode: userCode,
          // userType: userType,
        );
      } catch (e) {
        print("❌ Error marking notification as read on server: $e");
      }
    }
  }

  // -----------------------------------------------------------
  // SSE LISTENER (LIVE NOTIFS)
  // -----------------------------------------------------------
  // void listenLiveNotifications({
  //   required String userCode,
  //   required String userType,
  // }) async {
  //   _sseSubscription?.cancel();
  //   _sseSubscription = _api.listenNotifications().listen(
  //     (event) {
  //       final data = event["data"];
  //       if (data == null) {
  //         print("⚠️ SSE event missing data field");
  //         return;
  //       }
  //
  //       totalIncomingNotifications++;
  //
  //       final notif = NotificationResponse.fromJson(data);
  //
  //       if (notif.id == 0 || notif.title.isEmpty) return;
  //
  //       if (_notifications.any((n) => n.id == notif.id)) {
  //         return;
  //       }
  //
  //       final isRead = _readIds.contains(notif.id);
  //
  //       // Play sounds for unread notifications
  //       if (!isRead) {
  //         _playNotificationSound();
  //       }
  //
  //       _notifications.insert(0, notif.copyWith(isRead: isRead));
  //       notifyListeners();
  //     },
  //     onError: (error) async {
  //       await Future.delayed(const Duration(seconds: 5));
  //       reconnect(userType: userType);
  //     },
  //     onDone: () async {
  //       await Future.delayed(const Duration(seconds: 5));
  //       reconnect(userType: userType);
  //     },
  //     cancelOnError: false,
  //   );
  //
  //   // Stop previous subscription
  //   // _sseSubscription?.cancel();
  //   //
  //   // print("🔌 Starting SSE for $userCode");
  //   //
  //   // _sseSubscription = _api
  //   //     .listenNotifications(userCode: userCode, userType: userType)
  //   //     .listen(
  //   //       (event) {
  //   //         // event = Map<String, dynamic>
  //   //         final data = event["data"];
  //   //         if (data == null) {
  //   //           print("⚠️ SSE event missing data field");
  //   //           return;
  //   //         }
  //   //
  //   //         totalIncomingNotifications++;
  //   //         print("📩 SSE Notification #$totalIncomingNotifications → $data");
  //   //
  //   //         final notif = NotificationModel.fromJson(data);
  //   //
  //   //         // Skip empty or invalid notifications
  //   //         if (notif.id == 0 || notif.title.isEmpty) return;
  //   //
  //   //         // Deduplicate
  //   //         if (_notifications.any((n) => n.id == notif.id)) {
  //   //           print("⚠️ Duplicate notification ID ${notif.id} ignored");
  //   //           return;
  //   //         }
  //   //
  //   //         final isRead = _readIds.contains(notif.id);
  //   //
  //   //         // Insert newest on top
  //   //         _notifications.insert(0, notif.copyWith(isRead: isRead));
  //   //
  //   //         notifyListeners();
  //   //       },
  //   //       onError: (error) async {
  //   //         print("❌ SSE error: $error");
  //   //         await Future.delayed(const Duration(seconds: 5));
  //   //         reconnect(userType: userType);
  //   //       },
  //   //       onDone: () async {
  //   //         print("⚠️ SSE closed. Reconnecting...");
  //   //         await Future.delayed(const Duration(seconds: 5));
  //   //         reconnect(userType: userType);
  //   //       },
  //   //       cancelOnError: false,
  //   //     );
  // }
  void listenLiveNotifications() async {
    await _sseSubscription?.cancel();

    _sseSubscription = _api.listenNotifications().listen(
      (event) {
        final data = event["data"];
        if (data == null) return;

        final notif = NotificationResponse.fromJson(data);
        if (notif.id == 0 || notif.title.isEmpty) return;

        if (_notifications.any((n) => n.id == notif.id)) return;

        final isRead = _readIds.contains(notif.id);

        if (!isRead) _playNotificationSound();

        _notifications.insert(0, notif.copyWith(isRead: isRead));
        notifyListeners();
      },
      onError: (_) async {
        await Future.delayed(const Duration(seconds: 5));
        listenLiveNotifications(); // reconnect
      },
      onDone: () async {
        await Future.delayed(const Duration(seconds: 5));
        listenLiveNotifications(); // reconnect
      },
    );
  }

  // -----------------------------------------------------------
  // RECONNECT
  // -----------------------------------------------------------
  Future<void> reconnect() async {
    final prefs = await SharedPreferences.getInstance();
    final code = prefs.getString("driver_code") ?? "";

    if (code.isNotEmpty) {
      listenLiveNotifications();
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
//   Set<ConnectivityResult> _status = {};
//   bool _isChecking = true;
//   bool _hasRealInternet = false;
//   bool _uiReady = false;
//
//   // -------------------------
//   // PUBLIC GETTERS
//   // -------------------------
//
//   bool get isChecking => _isChecking;
//   bool get hasRealInternet => _hasRealInternet;
//   bool get uiReady => _uiReady;
//
//   /// 📡 HAS SIGNAL (wifi / mobile / ethernet)
//   /// Used for 🟠 Limited Internet
//   bool get hasSignal => _status.isNotEmpty;
//
//   /// ✈️ NO SIGNAL AT ALL (airplane mode / radios off)
//   /// Used for 🔴 No Internet
//   bool get hasNoSignal =>
//       _status.isEmpty || _status.contains(ConnectivityResult.none);
//
//   /// ⚠️ Backward compatibility (optional)
//   /// You may remove this if not used elsewhere
//   bool get isConnected => hasSignal;
//
//   // -------------------------
//   // INTERNALS
//   // -------------------------
//
//   final Connectivity _connectivity = Connectivity();
//   late final StreamSubscription<List<ConnectivityResult>> _subscription;
//
//   ConnectivityProvider() {
//     retryConnection();
//   }
//
//   /// 🚦 CALLED AFTER LANDING ANIMATION
//   void markUiReady() {
//     if (_uiReady) return;
//     _uiReady = true;
//     notifyListeners();
//   }
//
//   Future<void> retryConnection() async {
//     _isChecking = true;
//     notifyListeners();
//
//     // 🔹 Initial connectivity state (can be multiple results)
//     final results = await _connectivity.checkConnectivity();
//     _status = results.toSet();
//
//     // 🔹 Check real internet once
//     await _checkInternet();
//
//     _isChecking = false;
//     notifyListeners();
//
//     // 🔹 Listen for connectivity changes
//     _subscription = _connectivity.onConnectivityChanged.listen((results) async {
//       _status = results.toSet();
//       await _checkInternet();
//       notifyListeners();
//     });
//   }
//
//   /// 🌍 REAL INTERNET CHECK (SOURCE OF TRUTH)
//   Future<void> _checkInternet() async {
//     try {
//       final res = await http
//           .get(Uri.parse('https://www.google.com'))
//           .timeout(const Duration(seconds: 3));
//
//       _hasRealInternet = res.statusCode == 200;
//     } catch (_) {
//       _hasRealInternet = false;
//     }
//   }
//
//   @override
//   void dispose() {
//     _subscription.cancel();
//     super.dispose();
//   }
// }
class ConnectivityProvider extends ChangeNotifier {
  Set<ConnectivityResult> _status = {};
  bool _isChecking = true;
  bool _hasRealInternet = false;
  bool _uiReady = false;

  /// 🔑 KEY FIX
  bool _hasEverConnected = false;

  bool get isChecking => _isChecking;
  bool get hasRealInternet => _hasRealInternet;
  bool get uiReady => _uiReady;
  bool get hasEverConnected => _hasEverConnected;

  bool get hasSignal => _status.isNotEmpty;
  bool get hasNoSignal =>
      _status.isEmpty || _status.contains(ConnectivityResult.none);

  final Connectivity _connectivity = Connectivity();
  late final StreamSubscription<List<ConnectivityResult>> _subscription;

  ConnectivityProvider() {
    _init();
  }

  void markUiReady() {
    if (_uiReady) return;
    _uiReady = true;
    notifyListeners();
  }

  /// 🔁 RETRY BUTTON
  Future<void> retryConnection() async {
    if (_isChecking) return;

    _isChecking = true;
    notifyListeners();

    final results = await _connectivity.checkConnectivity();
    _status = results.toSet();

    await _checkInternet();

    _isChecking = false;
    notifyListeners();
  }

  Future<void> _init() async {
    _isChecking = true;
    notifyListeners();

    final results = await _connectivity.checkConnectivity();
    _status = results.toSet();

    await _checkInternet();

    _isChecking = false;
    notifyListeners();

    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      _status = results.toSet();
      await _checkInternet();
      notifyListeners();
    });
  }

  /// 🌐 REAL INTERNET CHECK (ANDROID SAFE)
  Future<void> _checkInternet() async {
    try {
      final res = await http
          .get(Uri.parse('https://clients3.google.com/generate_204'))
          .timeout(const Duration(seconds: 5));

      _hasRealInternet = res.statusCode == 204;

      /// 🔑 ONCE SUCCESS → ALLOW FUTURE WARNINGS
      if (_hasRealInternet) {
        _hasEverConnected = true;
      }
    } catch (_) {
      _hasRealInternet = false;
    }
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

class ChatProvider extends ChangeNotifier {
  final ApiServices api = ApiServices();

  List<ChatMessageResponse> messages = [];
  bool initialLoad = true;

  int unreadCount = 0;

  /// Track if chat screen is open
  bool isChatOpen = false;

  List<ChatMessageResponse> get allMessages => messages;

  // =====================================================
  // LOAD / RELOAD MESSAGES
  // =====================================================
  Future<void> loadMessages(int chatId) async {
    try {
      final res = await api.getChatMessages(chatId);

      final loaded = res.data;
      loaded.sort((a, b) => a.createdAt.compareTo(b.createdAt));

      messages = loaded;
      initialLoad = false;

      notifyListeners();
    } catch (e) {
      debugPrint("Chat load error: $e");
    }
  }

  // =====================================================
  // ADD TEMP BUBBLE BEFORE SEND
  // =====================================================
  void addLocal(ChatMessageResponse msg) {
    messages.add(msg);
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    notifyListeners();
  }

  // =====================================================
  // REMOVE TEMP AFTER SEND SUCCESS
  // =====================================================
  void removeLocal(ChatMessageResponse temp) {
    messages.removeWhere(
      (m) =>
          m.id == 0 &&
          m.senderType == temp.senderType &&
          m.messageType == temp.messageType &&
          ((temp.messageType == "text" && m.message == temp.message) ||
              (temp.messageType == "image")),
    );
    notifyListeners();
  }

  // =====================================================
  // 🔥 REAL MESSAGE FROM SSE
  // =====================================================
  void appendFromServer(ChatMessageResponse real) {
    removeTempIfMatched(real);

    if (messages.any((m) => m.id == real.id)) return;

    messages.add(real);
    messages.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    // Increase unread only if chat screen is NOT open
    if (!isChatOpen) {
      unreadCount++;
    }

    notifyListeners();
  }

  // =====================================================
  // REMOVE TEMP WHEN REAL ARRIVES
  // =====================================================
  void removeTempIfMatched(ChatMessageResponse real) {
    messages.removeWhere(
      (m) =>
          m.id == 0 &&
          m.senderType == real.senderType &&
          m.messageType == real.messageType &&
          ((real.messageType == "text" && m.message == real.message) ||
              (real.messageType == "image")),
    );
  }

  // =====================================================
  // 🔥 REFRESH AFTER SEND
  // =====================================================
  Future<void> refreshAfterSend(int chatId) async {
    await loadMessages(chatId);
  }

  // =====================================================
  // 🔥 MARK CHAT AS READ
  // =====================================================
  Future<void> markAsRead(int chatId) async {
    try {
      await api.markChatAsRead(chatId);

      unreadCount = 0;
      notifyListeners();
    } catch (e) {
      debugPrint("Mark as read error: $e");
    }
  }

  // =====================================================
  // CHAT OPEN / CLOSE (🔥 FIXED)
  // =====================================================
  void setChatOpen(bool value, {bool notify = true}) {
    if (isChatOpen == value) return;

    isChatOpen = value;

    if (notify) {
      notifyListeners();
    }
  }

  // =====================================================
  // UNREAD HELPERS
  // =====================================================
  void incrementUnread() {
    unreadCount++;
    notifyListeners();
  }

  void clearUnread() {
    if (unreadCount == 0) return;
    unreadCount = 0;
    notifyListeners();
  }

  void setUnread(int count) {
    unreadCount = count;
    notifyListeners();
  }
}
