import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:shimmer/shimmer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  bool isLoading = true;

  // Sample notifications
  final List<Map<String, dynamic>> notifications = [
    {
      "title": "Order Delivered",
      "body": "Your order #1234 has been delivered successfully.",
      "time": "2 min ago",
      "isRead": false,
    },
    {
      "title": "Order Picked Up",
      "body": "Your delivery driver has picked up order #5678.",
      "time": "10 min ago",
      "isRead": false,
    },
    {
      "title": "Order Cancelled",
      "body": "Order #4321 has been cancelled by the restaurant.",
      "time": "Yesterday",
      "isRead": false,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
    {
      "title": "New Promo",
      "body": "Get 20% off on your next delivery!",
      "time": "1 hr ago",
      "isRead": true,
    },
  ];

  @override
  void initState() {
    super.initState();
    // Simulate initial loading
    Future.delayed(const Duration(seconds: 2), () {
      setState(() => isLoading = false);
    });
  }

  Future<void> _refreshNotifications() async {
    setState(() => isLoading = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => isLoading = false);
  }

  Future<void> _onNotificationTap(int index) async {
    setState(() {
      isLoading = true; // Show shimmer
    });

    // Simulate API call or processing
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      isLoading = false; // Hide shimmer
      notifications[index]['isRead'] = true; // Mark as read
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Expanded(
            child: RefreshIndicator(
              color: kPrimaryColor,
              onRefresh: _refreshNotifications,
              child: isLoading
                  ? ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: 4,
                      itemBuilder: (context, index) => Padding(
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
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: notifications.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final isRead = notification['isRead'] as bool;

                        return GestureDetector(
                          onTap: () => _onNotificationTap(index),
                          child: MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: isRead
                                    ? Colors.white
                                    : kPrimaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: isRead
                                      ? Colors.grey.shade300
                                      : kPrimaryColor,
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.shade200,
                                    blurRadius: 6,
                                    offset: const Offset(0, 3),
                                  ),
                                ],
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: isRead
                                          ? Colors.grey
                                          : kPrimaryColor,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification['title']!,
                                          style: TextStyle(
                                            fontWeight: isRead
                                                ? FontWeight.normal
                                                : FontWeight.bold,
                                            fontSize: 16,
                                            color: Colors.black87,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          notification['body']!,
                                          style: const TextStyle(
                                            color: Colors.black54,
                                            fontSize: 14,
                                          ),
                                        ),
                                        const SizedBox(height: 6),
                                        Text(
                                          notification['time']!,
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
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
