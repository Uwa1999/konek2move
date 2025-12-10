// import 'package:flutter/material.dart';
// import 'package:intl/intl.dart';
// import 'package:konek2move/core/services/model_services.dart';

// class NotificationDetailScreen extends StatelessWidget {
//   final NotificationModel notification;

//   const NotificationDetailScreen({super.key, required this.notification});

//   String _formatDate(String createdAt) {
//     try {
//       final dt = DateTime.parse(createdAt).toLocal();
//       return DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
//     } catch (_) {
//       return createdAt;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],

//       body: Column(
//         children: [
//           _buildHeader(context),

//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(20),
//               child: Container(
//                 padding: const EdgeInsets.all(20),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(24),
//                   border: Border.all(color: Colors.grey.shade300),
//                   boxShadow: [
//                     BoxShadow(
//                       color: Colors.black12,
//                       blurRadius: 6,
//                       offset: const Offset(0, 3),
//                     ),
//                   ],
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       notification.title,
//                       style: const TextStyle(
//                         fontSize: 20,
//                         fontWeight: FontWeight.bold,
//                         height: 1.2,
//                       ),
//                     ),

//                     const SizedBox(height: 20),

//                     // DATE & TIME
//                     Text(
//                       _formatDate(notification.createdAt.toString()),
//                       style: TextStyle(
//                         fontSize: 14,
//                         color: Colors.grey.shade600,
//                       ),
//                     ),

//                     const SizedBox(height: 20),
//                     Divider(color: Colors.grey[200], thickness: 1.5),
//                     const SizedBox(height: 20),

//                     // BODY TEXT
//                     Text(
//                       notification.body,
//                       style: const TextStyle(
//                         fontSize: 16,
//                         height: 1.5,
//                         color: Colors.black87,
//                       ),
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(BuildContext context) {
//     return Container(
//       height: 80,
//       width: double.infinity,
//       decoration: const BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.only(
//           bottomLeft: Radius.circular(24),
//           bottomRight: Radius.circular(24),
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black12,
//             blurRadius: 10,
//             offset: Offset(0, 3),
//           ),
//         ],
//       ),
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 12),
//         child: Stack(
//           alignment: Alignment.bottomCenter,
//           children: [
//             const Text(
//               "Notification Details",
//               style: TextStyle(
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black,
//               ),
//             ),

//             Positioned(
//               left: 16,
//               child: GestureDetector(
//                 onTap: () => Navigator.pop(context),
//                 child: Container(
//                   width: 32,
//                   height: 32,
//                   decoration: BoxDecoration(
//                     color: Colors.black.withOpacity(0.06),
//                     borderRadius: BorderRadius.circular(12),
//                   ),
//                   child: const Icon(
//                     Icons.arrow_back,
//                     size: 20,
//                     color: Colors.black,
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:konek2move/core/widgets/custom_appbar.dart';

class NotificationDetailScreen extends StatelessWidget {
  final NotificationResponse notification;

  const NotificationDetailScreen({super.key, required this.notification});

  String _formatDate(String createdAt) {
    try {
      final dt = DateTime.parse(createdAt).toLocal();
      return DateFormat('MMM dd, yyyy • hh:mm a').format(dt);
    } catch (_) {
      return createdAt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bool isThreeButtonNav = safeBottom == 0;

    return Scaffold(
      backgroundColor: Colors.white,

      // ---------- APP BAR ----------
      appBar: const CustomAppBar(
        title: "Notification Details",
        leadingIcon: Icons.arrow_back,
      ),

      // ---------- BODY ----------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.shade300),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ------ TITLE ------
                  Text(
                    notification.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // ------ DATE ------
                  Text(
                    _formatDate(notification.createdAt.toString()),
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 20),
                  Divider(color: Colors.grey.shade300, thickness: 1),
                  const SizedBox(height: 20),

                  // ------ BODY ------
                  Text(
                    notification.body,
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.6,
                      color: Colors.black87,
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // ---------- BOTTOM SAFE AREA FIX ----------
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: Container(
          height: 0, // Keep structure consistent
          padding: EdgeInsets.only(
            bottom: isThreeButtonNav ? 16 : safeBottom + 8,
          ),
        ),
      ),
    );
  }
}
