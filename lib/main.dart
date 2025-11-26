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

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ensure this line is only used if you are targeting older Android versions,
  // otherwise, it might be unnecessary with recent Flutter/Maps plugins.
  AndroidGoogleMapsFlutter.useAndroidViewSurface = true;

  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(
    MultiProvider(
      providers: [
        // Initialize the provider correctly
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// ---

// 📱 MyApp
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Listen to the provider
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
      // The builder wraps the entire application widget tree
      builder: (context, child) {
        // Global connectivity banner using a Stack
        return Stack(
          children: [
            // 1. The main content of the app
            child!,
            // 2. The overlay banner, visible only when not connected
            if (!connectivityProvider.isChecking &&
                !connectivityProvider.isConnected)
              NoInternetScreen(),
          ],
        );
      },
    );
  }
}

// ---
