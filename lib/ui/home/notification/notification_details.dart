import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:konek2move/core/widgets/custom_appbar.dart';
import 'package:konek2move/ui/home/home_screen.dart';
import 'package:konek2move/ui/home/order/order_screen.dart';

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

  void _onSeeMore(BuildContext context) {
    // 🔁 CHANGE THIS to your target screen
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen(initialIndex: 1)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bool isThreeButtonNav = safeBottom == 0;

    return Scaffold(
      backgroundColor: Colors.white,

      // ---------- APP BAR ----------
      appBar: const CustomAppBar(
        title: "Notification",
        leadingIcon: Icons.arrow_back,
      ),

      // ---------- BODY ----------
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// 🏷 TITLE
            Text(
              notification.title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),

            const SizedBox(height: 8),

            /// 🕒 DATE
            Text(
              _formatDate(notification.createdAt.toString()),
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),

            const SizedBox(height: 16),
            Divider(color: Colors.grey.shade300, height: 1),
            const SizedBox(height: 16),

            /// 📄 MESSAGE
            Text(
              notification.body,
              style: const TextStyle(
                fontSize: 15.5,
                height: 1.65,
                color: Colors.black87,
              ),
            ),

            const SizedBox(height: 12),

            /// 👀 SEE MORE BUTTON (TEXT ONLY)
            Align(
              alignment: Alignment.centerLeft,
              child: TextButton(
                onPressed: () => _onSeeMore(context),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  "See the orders...",
                  style: TextStyle(
                    color: kPrimaryColor,
                    fontSize: 14.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),

      // ---------- SAFE AREA ----------
      bottomNavigationBar: SafeArea(
        bottom: false,
        child: SizedBox(height: isThreeButtonNav ? 16 : safeBottom + 8),
      ),
    );
  }
}
