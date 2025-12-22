import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/model_services.dart';

class NotificationProvider extends ChangeNotifier {
  final ApiServices _api = ApiServices();
  final AudioPlayer _audioPlayer = AudioPlayer();

  final List<NotificationResponse> _notifications = [];
  List<NotificationResponse> get notifications =>
      List.unmodifiable(_notifications);

  final Set<int> _readIds = {};

  // 🔢 SERVER UNREAD COUNT (SOURCE OF TRUTH)
  int _serverUnreadCount = 0;
  int get unreadCount => _serverUnreadCount;

  StreamSubscription<Map<String, dynamic>>? _sseSubscription;

  int _currentPage = 1;
  int _totalPages = 1;

  bool isLoading = false;
  bool isLoadingMore = false;
  bool hasMore = true;

  // -----------------------------------------------------------
  // FETCH UNREAD COUNT (INITIAL SYNC)
  // -----------------------------------------------------------
  Future<void> fetchUnreadCount() async {
    try {
      final count = await _api.getNotifUnreadCount();
      _serverUnreadCount = count;

      debugPrint("🔔 Initial unread count: $_serverUnreadCount");
      notifyListeners();
    } catch (e) {
      debugPrint("❌ Failed to fetch unread count: $e");
    }
  }

  // -----------------------------------------------------------
  // LOAD MORE (PAGINATION)
  // -----------------------------------------------------------
  Future<void> loadMore() async {
    if (isLoading || isLoadingMore || !hasMore) return;

    isLoadingMore = true;
    notifyListeners();

    try {
      _currentPage++;

      final page = await _api.getNotifications(page: _currentPage);
      _totalPages = page.totalPages;

      if (page.records.isEmpty) {
        hasMore = false;
      } else {
        for (final n in page.records) {
          if (_notifications.any((e) => e.id == n.id)) continue;

          final isRead = _readIds.contains(n.id) || n.isRead;
          _notifications.add(n.copyWith(isRead: isRead));
        }

        _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        hasMore = _currentPage < _totalPages;
      }
    } catch (e) {
      _currentPage--; // rollback on failure
      debugPrint("❌ Error loading more notifications: $e");
    } finally {
      isLoadingMore = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------
  // FETCH NOTIFICATIONS
  // -----------------------------------------------------------
  Future<void> fetchNotifications({bool refresh = false}) async {
    if (isLoading) return;

    if (refresh) {
      _currentPage = 1;
      _totalPages = 1;
      hasMore = true;
      _notifications.clear();
      notifyListeners();
    }

    isLoading = true;
    notifyListeners();

    try {
      final page = await _api.getNotifications(page: _currentPage);
      _totalPages = page.totalPages;

      for (final n in page.records) {
        if (_notifications.any((e) => e.id == n.id)) continue;

        final isRead = _readIds.contains(n.id) || n.isRead;
        _notifications.add(n.copyWith(isRead: isRead));
      }

      _notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      hasMore = _currentPage < _totalPages;

      // 🔄 One-time sync after list load
      await fetchUnreadCount();
    } catch (e) {
      debugPrint("❌ Error fetching notifications: $e");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  // -----------------------------------------------------------
  // MARK AS READ (LIVE BADGE UPDATE)
  // -----------------------------------------------------------
  Future<void> markAsRead({required NotificationResponse notif}) async {
    final index = _notifications.indexWhere((n) => n.id == notif.id);
    if (index == -1 || _notifications[index].isRead) return;

    _notifications[index] = _notifications[index].copyWith(isRead: true);
    _readIds.add(notif.id);

    // ⬇️ INSTANT BADGE UPDATE
    if (_serverUnreadCount > 0) {
      _serverUnreadCount--;
    }

    notifyListeners();

    try {
      await _api.markNotificationAsRead(notificationId: notif.id);
    } catch (e) {
      debugPrint("❌ Failed to sync read status: $e");
    }
  }

  // -----------------------------------------------------------
  // LIVE SSE (REAL-TIME)
  // -----------------------------------------------------------
  void listenLiveNotifications() async {
    // 🛑 Prevent multiple listeners
    if (_sseSubscription != null) return;

    debugPrint("📡 Starting SSE listener");

    _sseSubscription = _api.listenNotifications().listen(
      (event) {
        final data = event['data'];
        if (data == null) return;

        final notif = NotificationResponse.fromJson(data);

        // 🛑 Prevent duplicates
        if (_notifications.any((n) => n.id == notif.id)) return;

        debugPrint("📡 SSE received → notif id: ${notif.id}");

        _playNotificationSound();

        // ➕ INSERT AS UNREAD
        _notifications.insert(0, notif.copyWith(isRead: false));

        // 🔔 REAL-TIME BADGE INCREMENT
        _serverUnreadCount++;

        debugPrint("🔔 Badge updated → $_serverUnreadCount");

        notifyListeners();
      },
      onError: (e) {
        debugPrint("❌ SSE error: $e");
        _resetAndReconnect();
      },
      onDone: () {
        debugPrint("⚠️ SSE closed");
        _resetAndReconnect();
      },
    );
  }

  Future<void> _resetAndReconnect() async {
    await _sseSubscription?.cancel();
    _sseSubscription = null;

    await Future.delayed(const Duration(seconds: 5));
    listenLiveNotifications();
  }

  // -----------------------------------------------------------
  // CLEANUP
  // -----------------------------------------------------------
  void stopListening() {
    _sseSubscription?.cancel();
    _sseSubscription = null;
  }

  void _playNotificationSound() async {
    try {
      await _audioPlayer.play(
        AssetSource('sounds/notification.mp3'),
        volume: 1.0,
      );
    } catch (_) {}
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
