// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:konek2move/core/routes/app_routes.dart';
//
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
//   SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
//   await SystemChrome.setPreferredOrientations([
//     DeviceOrientation.portraitUp,
//     DeviceOrientation.portraitDown,
//   ]);
//   runApp(const MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Konek2Move',
//       theme: ThemeData(
//         colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
//         useMaterial3: false,
//       ),
//       initialRoute: AppRoutes.splash,
//       routes: AppRoutes.routes,
//       // navigatorObservers: [SmoothChucker.navigatorObserver],
//     );
//   }
// }
// Future<void> main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   /// Required for Google Maps Android performance optimization
//   AndroidGoogleMapsFlutter.useAndroidViewSurface = true;

//   // /// Force PORTRAIT only
//   // await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

//   // /// Show only top bar
//   // SystemChrome.setEnabledSystemUIMode(
//   //   SystemUiMode.manual,
//   //   overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
//   // );

//   // await _initAllPermissions();

//   /// ❌ REMOVED heavy permission requests here
//   /// They will run inside SplashScreen AFTER the UI loads.

//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
//         ChangeNotifierProvider(create: (_) => NotificationProvider()),
//         ChangeNotifierProvider(create: (_) => ChatProvider()),
//       ],
//       child: const MyApp(),
//     ),
//   );
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   SystemChrome.setEnabledSystemUIMode(
//     SystemUiMode.manual,
//     overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
//   );
// }

// Future<void> _initAllPermissions() async {
//   // Define all permissions you need
//   final permissions = [
//     Permission.location,
//     //  Permission.locationAlways
//   ];

//   for (final permission in permissions) {
//     final status = await permission.status;

//     if (status.isDenied) {
//       await permission.request();
//     }

//     // If permanently denied, you can prompt to open settings
//     if (await permission.isPermanentlyDenied) {
//       // OPTIONAL – DO NOT FORCE USERS
//       // openAppSettings();
//     }
//   }
// }
///
// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:konek2move/core/routes/app_routes.dart';
// import 'package:konek2move/ui/splash/internet_connection_screen.dart';
// import 'package:provider/provider.dart';
// import 'core/services/api_services.dart';
// import 'core/services/provider_services.dart';
// import 'core/widgets/custom_dialog.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await Secrets.init();
//   // Fast, non-blocking config
//   AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
//
//   // Run UI immediately
//   runApp(
//     MultiProvider(
//       providers: [
//         ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
//         ChangeNotifierProvider(create: (_) => NotificationProvider()),
//         ChangeNotifierProvider(create: (_) => ChatProvider()),
//       ],
//       child: MyApp(),
//     ),
//   );
//
//   // Apply system settings AFTER UI is visible
//   SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
//   SystemChrome.setEnabledSystemUIMode(
//     SystemUiMode.manual,
//     overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
//   );
// }
//
// class MyApp extends StatelessWidget {
//
//   const MyApp({super.key});
//
//   @override
//
// Widget build(BuildContext context) {
//   final connectivityProvider = Provider.of<ConnectivityProvider>(context);
//
//   return MaterialApp(
//     debugShowCheckedModeBanner: false,
//     title: 'Konek2Move',
//     theme: ThemeData(
//       colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
//       useMaterial3: false,
//     ),
//     initialRoute: AppRoutes.splash,
//     routes: AppRoutes.routes,
//     builder: (context, child) {
//       return Stack(
//         children: [
//           child!,
//           if (!connectivityProvider.isChecking &&
//               !connectivityProvider.isConnected)
//             NoInternetScreen(),
//         ],
//       );
//     },
//   );
// }
// }
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:konek2move/core/routes/app_routes.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_colors.dart';
import 'core/services/api_services.dart';
import 'core/services/provider_services.dart';
import 'core/widgets/custom_dialog.dart';

/// 🌍 GLOBAL NAVIGATOR KEY (REQUIRED FOR GLOBAL DIALOGS)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 🔔 DIALOG STATE TYPE (PREVENT DUPLICATES)
enum _InternetDialogType { none, noInternet, limited }

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Secrets.init();

  AndroidGoogleMapsFlutter.useAndroidViewSurface = true;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
      ],
      child: const MyApp(),
    ),
  );

  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setEnabledSystemUIMode(
    SystemUiMode.manual,
    overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'Konek2Move',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: false,
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,

      /// ✅ GLOBAL INTERNET DIALOG LISTENER
      builder: (context, child) {
        return InternetDialogListener(child: child!);
      },
    );
  }
}

/// 🌐 INTERNET DIALOG LISTENER (PRODUCTION SAFE)
class InternetDialogListener extends StatefulWidget {
  final Widget child;

  const InternetDialogListener({super.key, required this.child});

  @override
  State<InternetDialogListener> createState() => _InternetDialogListenerState();
}

class _InternetDialogListenerState extends State<InternetDialogListener> {
  _InternetDialogType _activeDialog = _InternetDialogType.none;

  /// ✅ Close ONLY dialog routes (never pages)
  void _closeInternetDialogs(BuildContext context) {
    final navigator = Navigator.of(context, rootNavigator: true);

    navigator.popUntil((route) {
      return route is! PopupRoute;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (_, connectivity, __) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final ctx = navigatorKey.currentContext;
          if (ctx == null) return;

          // ⛔ Wait until UI + initial connectivity check is done
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
          // 🔴 NO INTERNET (NO SIGNAL)
          // ==========================================================
          if (!connectivity.hasRealInternet &&
              connectivity.hasNoSignal &&
              _activeDialog != _InternetDialogType.noInternet) {
            _closeInternetDialogs(ctx);
            _activeDialog = _InternetDialogType.noInternet;

            showInternetDialog(
              context: ctx,
              title: "No Internet Connection",
              message:
                  "Please turn on your mobile data or Wi-Fi to continue using the app.",
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
          // 🟠 LIMITED INTERNET (SIGNAL BUT NO REAL INTERNET)
          // ==========================================================
          if (!connectivity.hasRealInternet &&
              connectivity.hasSignal &&
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
