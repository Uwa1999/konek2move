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
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import 'core/services/provider_services.dart';

Future<void> _initializePermissions() async {
  // 1. Camera
  if (await Permission.location.request().isDenied) {
    debugPrint("Location permission denied");
  }

  // 2. Location (foreground)
  if (await Permission.camera.request().isDenied) {
    // Optionally show rationale
    debugPrint("Camera permission denied");
  }

  // // 3. Location (background)
  // if (await Permission.locationAlways.request().isDenied) {
  //   debugPrint("Background location permission denied");
  // }

  // 4. Notifications (Android 13+)
  if (await Permission.notification.request().isDenied) {
    debugPrint("Notification permission denied");
  }

  // 5. Storage / Photos
  if (await Permission.photos.request().isDenied) {
    debugPrint("Photos permission denied");
  }

  if (await Permission.storage.request().isDenied) {
    debugPrint("Storage permission denied");
  }

  // 6. Microphone
  if (await Permission.microphone.request().isDenied) {
    debugPrint("Microphone permission denied");
  }

  // 7. Bluetooth
  if (await Permission.bluetooth.request().isDenied) {
    debugPrint("Bluetooth permission denied");
  }

  // 8. Sensors
  if (await Permission.sensors.request().isDenied) {
    debugPrint("Sensors permission denied");
  }
}

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

  await _initializePermissions();

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
