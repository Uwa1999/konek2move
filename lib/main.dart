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
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:konek2move/core/routes/app_routes.dart';
import 'package:konek2move/ui/splash/internet_connection_screen.dart';
import 'package:provider/provider.dart';

import 'core/services/provider_services.dart';

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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Fast, non-blocking config
  AndroidGoogleMapsFlutter.useAndroidViewSurface = true;

  // Run UI immediately
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: const MyApp(),
    ),
  );

  // Apply system settings AFTER UI is visible
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
    final connectivityProvider = Provider.of<ConnectivityProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Konek2Move',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: false,
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      builder: (context, child) {
        return Stack(
          children: [
            child!,
            if (!connectivityProvider.isChecking &&
                !connectivityProvider.isConnected)
              NoInternetScreen(),
          ],
        );
      },
    );
  }
}
