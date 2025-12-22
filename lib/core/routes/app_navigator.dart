import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppNavigator {
  static bool _isNavigating = false;

  static Future<void> push(
    BuildContext context,
    Widget page, {
    AnimationController? stopController,
    Duration duration = const Duration(milliseconds: 250),
  }) async {
    if (_isNavigating) return;
    _isNavigating = true;

    HapticFeedback.lightImpact();

    // Stop animations safely (optional)
    stopController?.stop();

    // Let current frame finish
    await Future.delayed(const Duration(milliseconds: 16));
    if (!context.mounted) {
      _isNavigating = false;
      return;
    }

    await Navigator.push(
      context,
      PageRouteBuilder(
        transitionDuration: duration,
        pageBuilder: (_, __, ___) => page,
        transitionsBuilder: (_, animation, __, child) {
          return FadeTransition(opacity: animation, child: child);
        },
      ),
    );

    _isNavigating = false;
  }
}
