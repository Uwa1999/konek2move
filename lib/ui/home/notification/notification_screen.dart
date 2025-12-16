// import 'package:flutter/material.dart';
// import 'package:flutter_svg/svg.dart';
// import 'package:intl/intl.dart';
// import 'package:konek2move/core/widgets/custom_appbar.dart';
// import 'package:konek2move/ui/home/home_screen.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:konek2move/core/constants/app_colors.dart';
// import 'package:konek2move/core/services/model_services.dart';
// import 'package:konek2move/core/services/provider_services.dart';
// import 'package:konek2move/ui/home/notification/notification_details.dart';
//
// class NotificationScreen extends StatefulWidget {
//   const NotificationScreen({super.key});
//
//   @override
//   State<NotificationScreen> createState() => _NotificationScreenState();
// }
//
// class _NotificationScreenState extends State<NotificationScreen> {
//   bool isLoading = true;
//   String? driverCode;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) => _initNotifications());
//   }
//
//   Future<void> _initNotifications() async {
//     final prefs = await SharedPreferences.getInstance();
//     driverCode = prefs.getString('driver_code');
//
//     if (!mounted) return;
//
//     if (driverCode == null) {
//       setState(() => isLoading = false);
//       return;
//     }
//
//     final provider = context.read<NotificationProvider>();
//
//     setState(() => isLoading = true);
//
//     // FETCH EXISTING NOTIFICATIONS
//     await provider.fetchNotifications();
//
//     // START SSE (no params needed)
//     provider.listenLiveNotifications();
//
//     if (!mounted) return;
//     setState(() => isLoading = false);
//   }
//
//   Future<void> _refresh() async {
//     await context.read<NotificationProvider>().fetchNotifications();
//   }
//
//   // -------------------- TIME AGO FORMATTER --------------------
//   String _timeAgo(String? rawTime) {
//     if (rawTime == null || rawTime.isEmpty) return "";
//
//     try {
//       final dateTime = DateTime.parse(rawTime).toLocal();
//       final now = DateTime.now();
//       final diff = now.difference(dateTime);
//
//       if (diff.inSeconds < 60) return 'Just now';
//       if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
//       if (diff.inHours < 24) return '${diff.inHours} h ago';
//       if (diff.inDays == 1) return 'Yesterday';
//       if (diff.inDays < 7) return '${diff.inDays} days ago';
//
//       return DateFormat('MMM d, yyyy').format(dateTime);
//     } catch (_) {
//       return rawTime;
//     }
//   }
//
//   // ------------------------ BUILD UI -------------------------
//   @override
//   Widget build(BuildContext context) {
//     final provider = context.watch<NotificationProvider>();
//     final notifications = provider.notifications;
//
//     return Scaffold(
//       backgroundColor: Colors.white,
//
//       appBar: CustomAppBar(
//         title: "Notifications",
//         leadingIcon: Icons.arrow_back,
//         onLeadingTap: () => Navigator.push(
//           context,
//           MaterialPageRoute(builder: (_) => HomeScreen()),
//         ),
//       ),
//
//       body: RefreshIndicator(
//         onRefresh: _refresh,
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (isLoading) _buildShimmerList(),
//
//               if (!isLoading && notifications.isEmpty) _buildEmptyState(),
//
//               if (!isLoading && notifications.isNotEmpty)
//                 _buildNotificationList(notifications, provider),
//
//               const SizedBox(height: 24),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
//
//   // ------------------------ SHIMMER -------------------------
//   Widget _buildShimmerList() {
//     return Column(
//       children: List.generate(6, (index) {
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: Shimmer.fromColors(
//             baseColor: Colors.grey.shade300,
//             highlightColor: Colors.grey.shade100,
//             child: Container(
//               height: 90,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(24),
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
//
//   // ------------------------ EMPTY STATE -------------------------
//   Widget _buildEmptyState() {
//     return Center(
//       child: Column(
//         children: [
//           SvgPicture.asset(
//             "assets/icons/notification.svg",
//             height: 90,
//             color: Colors.grey.shade400,
//           ),
//           const SizedBox(height: 20),
//           const Text(
//             "No Notification Yet",
//             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
//           ),
//           const SizedBox(height: 6),
//           Text(
//             "You have no notification right now.\nCome back later",
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 14, color: Colors.grey),
//           ),
//         ],
//       ),
//     );
//   }
//
//   // --------------------- NOTIFICATION LIST ---------------------
//   Widget _buildNotificationList(
//     List<NotificationResponse> items,
//     NotificationProvider provider,
//   ) {
//     return Column(
//       children: List.generate(items.length, (index) {
//         final n = items[index];
//         final isRead = n.isRead;
//
//         return Padding(
//           padding: const EdgeInsets.only(bottom: 16),
//           child: GestureDetector(
//             onTap: () async {
//               if (!isRead && driverCode != null) {
//                 await provider.markAsRead(
//                   notif: n,
//                   userCode: driverCode!,
//                   userType: "driver",
//                 );
//               }
//
//               Navigator.push(
//                 context,
//                 MaterialPageRoute(
//                   builder: (_) => NotificationDetailScreen(notification: n),
//                 ),
//               );
//             },
//             child: AnimatedContainer(
//               duration: const Duration(milliseconds: 200),
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: isRead ? Colors.white : kPrimaryColor.withOpacity(0.10),
//                 borderRadius: BorderRadius.circular(24),
//                 border: Border.all(
//                   color: isRead ? Colors.grey.shade300 : kPrimaryColor,
//                 ),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withOpacity(0.04),
//                     blurRadius: 8,
//                     offset: const Offset(0, 2),
//                   ),
//                 ],
//               ),
//               child: Row(
//                 children: [
//                   CircleAvatar(
//                     backgroundColor: isRead
//                         ? Colors.grey.shade500
//                         : kPrimaryColor,
//                     child: const Icon(Icons.notifications, color: Colors.white),
//                   ),
//                   const SizedBox(width: 16),
//
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           n.title,
//                           style: TextStyle(
//                             fontWeight: isRead
//                                 ? FontWeight.w400
//                                 : FontWeight.w600,
//                             fontSize: 16,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//
//                         Text(
//                           n.body.split(' ').take(8).join(' ') +
//                               (n.body.split(' ').length > 8 ? '...' : ''),
//                           style: const TextStyle(
//                             color: Colors.black54,
//                             fontSize: 14,
//                           ),
//                         ),
//
//                         const SizedBox(height: 6),
//                         Text(
//                           _timeAgo(n.createdAt.toString()),
//                           style: TextStyle(
//                             color: Colors.grey.shade500,
//                             fontSize: 12,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         );
//       }),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:konek2move/core/widgets/custom_appbar.dart';
import 'package:konek2move/ui/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:konek2move/ui/home/notification/notification_details.dart';

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _initNotifications());
  }

  Future<void> _initNotifications() async {
    final prefs = await SharedPreferences.getInstance();
    driverCode = prefs.getString('driver_code');

    if (!mounted) return;

    if (driverCode == null) {
      setState(() => isLoading = false);
      return;
    }

    final provider = context.read<NotificationProvider>();

    setState(() => isLoading = true);

    // FETCH EXISTING NOTIFICATIONS
    await provider.fetchNotifications();

    // START SSE (no params needed)
    provider.listenLiveNotifications();

    if (!mounted) return;
    setState(() => isLoading = false);
  }

  Future<void> _refresh() async {
    await context.read<NotificationProvider>().fetchNotifications();
  }

  // -------------------- TIME AGO FORMATTER --------------------
  String _timeAgo(String? rawTime) {
    if (rawTime == null || rawTime.isEmpty) return "";

    try {
      final dateTime = DateTime.parse(rawTime).toLocal();
      final now = DateTime.now();
      final diff = now.difference(dateTime);

      if (diff.inSeconds < 60) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
      if (diff.inHours < 24) return '${diff.inHours} h ago';
      if (diff.inDays == 1) return 'Yesterday';
      if (diff.inDays < 7) return '${diff.inDays} days ago';

      return DateFormat('MMM d, yyyy').format(dateTime);
    } catch (_) {
      return rawTime;
    }
  }

  // ------------------------ BUILD UI -------------------------
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<NotificationProvider>();
    final notifications = provider.notifications;

    return Scaffold(
      backgroundColor: Colors.white,

      appBar: CustomAppBar(
        title: "Notifications",
        leadingIcon: Icons.arrow_back,
        onLeadingTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen()),
        ),
      ),

      body: RefreshIndicator(
        onRefresh: _refresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLoading) _buildShimmerList(),

              if (!isLoading && notifications.isEmpty) _buildEmptyState(),

              if (!isLoading && notifications.isNotEmpty)
                _buildNotificationList(notifications, provider),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // ------------------------ SHIMMER -------------------------
  Widget _buildShimmerList() {
    return Column(
      children: List.generate(6, (index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
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
        );
      }),
    );
  }

  // ------------------------ EMPTY STATE -------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          SvgPicture.asset(
            "assets/icons/notification.svg",
            height: 90,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 20),
          const Text(
            "No Notification Yet",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 6),
          Text(
            "You have no notification right now.\nCome back later",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 14, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  // --------------------- NOTIFICATION LIST ---------------------
  Widget _buildNotificationList(
    List<NotificationResponse> items,
    NotificationProvider provider,
  ) {
    return Column(
      children: List.generate(items.length, (index) {
        final n = items[index];
        final isRead = n.isRead;

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () async {
              if (!isRead && driverCode != null) {
                await provider.markAsRead(
                  notif: n,
                  userCode: driverCode!,
                  userType: "driver",
                );
              }

              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => NotificationDetailScreen(notification: n),
                ),
              );
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRead ? Colors.white : kPrimaryColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: isRead ? Colors.grey.shade300 : kPrimaryColor,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: isRead
                        ? Colors.grey.shade500
                        : kPrimaryColor,
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
                                ? FontWeight.w400
                                : FontWeight.w600,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),

                        Text(
                          n.body.split(' ').take(8).join(' ') +
                              (n.body.split(' ').length > 8 ? '...' : ''),
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
          ),
        );
      }),
    );
  }
}
