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
  void listenLiveNotifications({
    required String userCode,
    required String userType,
  }) async {
    _sseSubscription?.cancel();
    _sseSubscription = _api.listenNotifications().listen(
      (event) {
        final data = event["data"];
        if (data == null) {
          print("⚠️ SSE event missing data field");
          return;
        }

        totalIncomingNotifications++;

        final notif = NotificationResponse.fromJson(data);

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

class ConnectivityProvider extends ChangeNotifier {
  Set<ConnectivityResult> _connectivityStatus = {};
  bool _isChecking = true;
  bool _hasRealInternet = false;
  bool _canReachServer = false;

  bool get isConnected =>
      !_connectivityStatus.contains(ConnectivityResult.none);

  bool get hasRealInternet => _hasRealInternet;
  bool get canReachServer => _canReachServer;

  bool get isRestrictedInternet =>
      isConnected && !_hasRealInternet; // EXAMPLE: TikTok-only data

  bool get isChecking => _isChecking;

  late StreamSubscription<List<ConnectivityResult>> _subscription;
  final Connectivity _connectivity = Connectivity();

  ConnectivityProvider() {
    _initConnectivity();
  }

  void _initConnectivity() async {
    _isChecking = true;
    notifyListeners();

    final initialStatus = await _connectivity.checkConnectivity();
    _connectivityStatus = initialStatus.toSet();

    await _runFullCheck();

    _isChecking = false;
    notifyListeners();

    _subscription = _connectivity.onConnectivityChanged.listen((results) async {
      _connectivityStatus = results.toSet();
      notifyListeners();

      await _runFullCheck();
    });
  }

  /// 🔍 Step 1: Check if internet is real (Google)
  Future<bool> _checkRealInternet() async {
    try {
      final res = await http
          .get(Uri.parse("https://www.google.com"))
          .timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// 🔍 Step 2: Check if your API is reachable
  Future<bool> _checkServer() async {
    try {
      final res = await http
          .get(Uri.parse("https://dev-hestia-p1.fortress-asya.com"))
          .timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// Run both checks and update UI
  Future<void> _runFullCheck() async {
    if (!isConnected) {
      _hasRealInternet = false;
      _canReachServer = false;
      notifyListeners();
      return;
    }

    _hasRealInternet = await _checkRealInternet();
    _canReachServer = _hasRealInternet ? await _checkServer() : false;

    notifyListeners();
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

  // Track if chat screen is open
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
      print("Chat load error: $e");
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
    notifyListeners();
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

      unreadCount = 0; // Reset badge
      notifyListeners();
    } catch (e) {
      print("Mark as read error: $e");
    }
  }

  // =====================================================
  // CHAT OPEN / CLOSE
  // =====================================================
  void setChatOpen(bool value) {
    isChatOpen = value;
    notifyListeners();
  }

  // Legacy (still useful)
  void incrementUnread() {
    unreadCount++;
    notifyListeners();
  }

  void clearUnread() {
    unreadCount = 0;
    notifyListeners();
  }

  void setUnread(int count) {
    unreadCount = count;
    notifyListeners();
  }
}

class OrderProvider extends ChangeNotifier {
  bool isLoading = false;
  OrderResponse? orderResponse;

  // ==== FETCH ALL ORDERS ====
  Future<void> fetchOrders() async {
    await _loadOrders(orderNo: "");
  }

  // ==== SEARCH USING BACKEND ====
  Future<void> searchOrders(String orderNo) async {
    await _loadOrders(orderNo: orderNo);
  }

  // ==== PRIVATE LOADER ====
  Future<void> _loadOrders({String orderNo = ""}) async {
    isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final driverIdString = prefs.getString("id") ?? "0";
      final driverId = int.tryParse(driverIdString) ?? 0;

      // CALL API WITH order_no
      final res = await ApiServices().getOrder(driverId, orderNo: orderNo);

      // LOCAL FILTER: assigned + unassigned
      final filteredRecords = res.data.records.where((order) {
        final isAssignedToDriver =
            order.assignedDriverId.toString() == driverIdString;
        final isUnassigned = order.assignedDriverId == null;

        return isAssignedToDriver || isUnassigned;
      }).toList();

      orderResponse = OrderResponse(
        responseTime: res.responseTime,
        device: res.device,
        retCode: res.retCode,
        message: res.message,
        data: OrderData(
          currentPage: res.data.currentPage,
          totalPages: res.data.totalPages,
          totalCount: filteredRecords.length,
          records: filteredRecords,
        ),
      );
    } catch (e) {
      print("ORDER ERROR: $e");
    }

    isLoading = false;
    notifyListeners();
  }

  void resetSearch() => fetchOrders();
}
