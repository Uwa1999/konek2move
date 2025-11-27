import 'package:flutter/material.dart';
import 'package:konek2move/ui/home/notification/notification_details.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:konek2move/core/services/model_services.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  bool isLoading = true;
  String? driverCode;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initNotifications();
    });
  }

  Future<void> _initNotifications() async {
    // Load driver code from SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    driverCode = prefs.getString('driver_code');

    if (driverCode == null) return;

    final provider = context.read<NotificationProvider>();

    setState(() => isLoading = true);

    // Fetch notifications
    await provider.fetchNotifications(
      userCode: driverCode!,
      userType: "driver",
    );

    // Listen for live SSE updates
    provider.listenLiveNotifications(userCode: driverCode!, userType: "driver");

    setState(() => isLoading = false);
  }

  Future<void> _refresh() async {
    if (driverCode == null) return;

    final provider = context.read<NotificationProvider>();
    await provider.fetchNotifications(
      userCode: driverCode!,
      userType: "driver",
    );
  }

  String _timeAgo(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return "";

    try {
      final dateTime = DateTime.parse(rawTime).toLocal();
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inSeconds < 60) return 'Just now';
      if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
      if (difference.inHours < 24) return '${difference.inHours} h ago';
      if (difference.inDays == 1) return 'Yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';

      return DateFormat('MMM d, yyyy').format(dateTime);
    } catch (e) {
      return rawTime;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _refresh,
              child: isLoading
                  ? _buildShimmerList()
                  : Consumer<NotificationProvider>(
                      builder: (_, provider, __) {
                        final notifications = provider.notifications;
                        if (notifications.isEmpty) return _buildEmptyState();
                        return _buildNotificationList(notifications, provider);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pushReplacementNamed(context, '/home'),
            ),
          ),
          const Center(
            child: Text(
              "Notifications",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShimmerList() {
    final provider = context.read<NotificationProvider>();
    // Use unread count if available, else default to 4
    final shimmerCount = provider.unreadCount > 0 ? provider.unreadCount : 4;

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: shimmerCount,
      itemBuilder: (_, __) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Shimmer.fromColors(
          baseColor: Colors.grey.shade300,
          highlightColor: Colors.grey.shade100,
          child: Container(
            height: 90,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        "No available notifications",
        style: TextStyle(color: Colors.grey, fontSize: 16),
      ),
    );
  }

  Widget _buildNotificationList(
    List<NotificationModel> notifications,
    NotificationProvider provider,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final n = notifications[index];
        final isRead = n.isRead;

        return GestureDetector(
          // onTap: () async {
          //   if (!isRead && driverCode != null) {
          //     // Mark notification as read locally and on server
          //     await provider.markAsRead(
          //       notif: n,
          //       userCode: driverCode!,
          //       userType: "driver",
          //     );
          //   }
          // },
          onTap: () async {
            if (!isRead && driverCode != null) {
              await provider.markAsRead(
                notif: n,
                userCode: driverCode!,
                userType: "driver",
              );
            }

            // Go to Notification Details Screen
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => NotificationDetailScreen(notification: n),
              ),
            );
          },

          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isRead ? Colors.white : kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isRead ? Colors.grey.shade300 : kPrimaryColor,
              ),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: isRead ? Colors.grey : kPrimaryColor,
                  child: const Icon(Icons.notifications, color: Colors.white),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        n.title,
                        style: TextStyle(
                          fontWeight: isRead
                              ? FontWeight.normal
                              : FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        n.body,
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _timeAgo(n.createdAt.toString()),
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
