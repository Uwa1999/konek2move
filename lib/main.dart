// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:konek2move/core/routes/app_routes.dart';

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

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

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
import 'dart:developer' as developer;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:konek2move/core/routes/app_routes.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Connectivity _connectivity = Connectivity();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isDialogShown = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  // Initialize connectivity at startup
  Future<void> _initConnectivity() async {
    List<ConnectivityResult> results;
    try {
      results = await _connectivity.checkConnectivity();
    } on PlatformException catch (e) {
      developer.log('Couldn\'t check connectivity status', error: e);
      return;
    }

    if (!mounted) return;

    if (results.contains(ConnectivityResult.none)) {
      _showNoInternetDialog();
    }
  }

  // Handle connectivity changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    if (results.contains(ConnectivityResult.none)) {
      if (!_isDialogShown) _showNoInternetDialog();
    } else {
      if (_isDialogShown && Navigator.canPop(context)) {
        _isDialogShown = false;
        Navigator.pop(context);
      }
    }
  }

  // Show offline dialog
  void _showNoInternetDialog() {
    _isDialogShown = true;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection.'),
        actions: [
          TextButton(
            onPressed: () async {
              final results = await _connectivity.checkConnectivity();
              if (!results.contains(ConnectivityResult.none) &&
                  Navigator.canPop(context)) {
                _isDialogShown = false;
                Navigator.pop(context);
              }
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Konek2Move',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: false,
      ),
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}
