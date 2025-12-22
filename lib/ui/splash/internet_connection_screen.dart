import 'dart:io';

import 'package:flutter/material.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:konek2move/core/widgets/custom_dialog.dart';
import 'package:provider/provider.dart';

/// 🌍 GLOBAL NAVIGATOR KEY (REQUIRED FOR GLOBAL DIALOGS)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 🔔 DIALOG STATE TYPE (PREVENT DUPLICATES)
enum _InternetDialogType { none, noInternet, limited }

/// 🌐 INTERNET DIALOG LISTENER (PRODUCTION SAFE)
class InternetDialogListener extends StatefulWidget {
  final Widget child;

  const InternetDialogListener({super.key, required this.child});

  @override
  State<InternetDialogListener> createState() => _InternetDialogListenerState();
}

class _InternetDialogListenerState extends State<InternetDialogListener> {
  _InternetDialogType _activeDialog = _InternetDialogType.none;

  /// ❌ CLOSE ONLY DIALOG ROUTES
  void _closeInternetDialogs(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);
    navigator.popUntil((route) => route is! PopupRoute);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (_, connectivity, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = navigatorKey.currentContext;
          if (ctx == null) return;

          /// ⛔ WAIT FOR UI + FIRST CHECK
          if (connectivity.isChecking || !connectivity.uiReady) return;

          // ==========================================================
          // ✅ INTERNET RESTORED
          // ==========================================================
          if (connectivity.hasRealInternet &&
              _activeDialog != _InternetDialogType.none) {
            _closeInternetDialogs(ctx);
            _activeDialog = _InternetDialogType.none;

            ScaffoldMessenger.of(ctx).showSnackBar(
              const SnackBar(
                content: Text("Internet connected"),
                behavior: SnackBarBehavior.floating,
                backgroundColor: kPrimaryColor,
                duration: Duration(seconds: 2),
              ),
            );
            return;
          }

          // ==========================================================
          // 🔴 NO SIGNAL AT ALL
          // ==========================================================
          if (!connectivity.hasRealInternet &&
              connectivity.hasNoSignal &&
              _activeDialog != _InternetDialogType.noInternet) {
            _closeInternetDialogs(ctx);
            _activeDialog = _InternetDialogType.noInternet;

            showInternetDialog(
              context: ctx,
              title: "No Internet Connection",
              message: "Please turn on your mobile data or Wi-Fi to continue.",
              icon: Icons.wifi_off_rounded,
              color: kPrimaryRedColor,
              buttonText: "Close App",
              onRetry: () async {
                exit(0);
              },
            );
            return;
          }

          // ==========================================================
          // 🟠 LIMITED INTERNET (ONLY AFTER EVER CONNECTED)
          // ==========================================================
          if (!connectivity.hasRealInternet &&
              connectivity.hasSignal &&
              connectivity.hasEverConnected && // 🔑 FINAL FIX
              _activeDialog != _InternetDialogType.limited) {
            _closeInternetDialogs(ctx);
            _activeDialog = _InternetDialogType.limited;

            showInternetDialog(
              context: ctx,
              title: "Limited Internet Access",
              message:
                  "You're connected to a network, but the internet is currently unavailable.",
              icon: Icons.signal_wifi_connected_no_internet_4_rounded,
              color: kPrimaryColor,
              buttonText: "Retry",
              onRetry: () async {
                await ctx.read<ConnectivityProvider>().retryConnection();
              },
            );
          }
        });

        return widget.child;
      },
    );
  }
}
