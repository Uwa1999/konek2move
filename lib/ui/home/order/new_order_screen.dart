// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:konek2move/core/constants/app_colors.dart';
// import 'package:konek2move/core/widgets/custom_button.dart';
//
// class NewOrderScreen extends StatefulWidget {
//   const NewOrderScreen({super.key});
//
//   @override
//   State<NewOrderScreen> createState() => _NewOrderScreenState();
// }
//
// class _NewOrderScreenState extends State<NewOrderScreen> {
//   LatLng? _currentLocation;
//   final LatLng dropOffLocation = const LatLng(14.0611, 121.3270);
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       body: Column(
//         children: [
//           _buildHeader(),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   _buildMap(),
//                   const SizedBox(height: 20),
//                   Text(
//                     "Delivery Details",
//                     style: TextStyle(
//                       fontSize: 15,
//                       color: Colors.grey[500],
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   const SizedBox(height: 15),
//                   _buildDeliveryDetails(),
//                 ],
//               ),
//             ),
//           ),
//
//           // Padding(
//           //   padding: const EdgeInsets.symmetric(horizontal: 24),
//           //   child: Row(
//           //     children: [
//           //       Expanded(
//           //         child: SizedBox(
//           //           height: 50,
//           //           child: Container(
//           //             alignment: Alignment.center,
//           //             decoration: BoxDecoration(
//           //               color: Colors.white,
//           //               borderRadius: BorderRadius.circular(8),
//           //               border: Border.all(color: Colors.black),
//           //             ),
//           //             child: const Text(
//           //               'Total : ₱ 10,000',
//           //               style: TextStyle(
//           //                 fontSize: 24,
//           //                 fontWeight: FontWeight.bold,
//           //               ),
//           //             ),
//           //           ),
//           //         ),
//           //       ),
//           //     ],
//           //   ),
//           // ),
//           Padding(
//             padding: const EdgeInsets.all(24),
//             child: CustomButton(
//               text: "Start Delivery",
//               horizontalPadding: 0,
//               color: kPrimaryColor,
//               textColor: Colors.white,
//               onTap: () {},
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildMap() {
//     final screenHeight = MediaQuery.of(context).size.height;
//     final mapHeight =
//         screenHeight * 0.5; // 40% of screen height, adjust as needed
//
//     return SizedBox(
//       height: mapHeight,
//       child: ClipRRect(
//         borderRadius: BorderRadius.circular(16),
//         child: GoogleMap(
//           initialCameraPosition: CameraPosition(
//             target: _currentLocation ?? dropOffLocation,
//             zoom: 14,
//           ),
//           markers: {
//             Marker(
//               markerId: const MarkerId('dropoff'),
//               position: dropOffLocation,
//               infoWindow: const InfoWindow(title: "Drop-off"),
//             ),
//           },
//           myLocationEnabled: true,
//           zoomControlsEnabled: false,
//         ),
//       ),
//     );
//   }
//
//   Widget _buildDeliveryDetails() {
//     final details = [
//       {
//         'icon': Icons.storefront,
//         'title': "Pickup",
//         'main': "CARD OTTOKONEK OFFICE",
//         'sub': "38C4+PXC, Colago Ave, San Pablo City, Laguna",
//         'distance': "3.4km",
//         'duration': "6min",
//       },
//       {
//         'icon': Icons.info_outline,
//         'title': "Drop-off",
//         'main': "St. Peter Chapels",
//         'sub': "San Pablo City, Laguna",
//         'distance': "4.1km",
//         'duration': "9min",
//       },
//     ];
//
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Column(
//           children: List.generate(details.length * 2 - 1, (i) {
//             if (i.isEven) {
//               return Icon(
//                 details[i ~/ 2]['icon'] as IconData,
//                 color: Colors.grey[400],
//                 size: 24,
//               );
//             } else {
//               return Container(width: 2, height: 70, color: Colors.grey[400]);
//             }
//           }),
//         ),
//         const SizedBox(width: 15),
//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: details.map((d) {
//               return Padding(
//                 padding: const EdgeInsets.only(bottom: 20),
//                 child: _buildDetailRow(
//                   title: d['title'] as String,
//                   mainText: d['main'] as String,
//                   subText: d['sub'] as String,
//                   distance: d['distance'] as String,
//                   duration: d['duration'] as String,
//                 ),
//               );
//             }).toList(),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDetailRow({
//     required String title,
//     required String mainText,
//     required String subText,
//     required String distance,
//     required String duration,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//           children: [
//             Text(
//               title,
//               style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             Text(
//               "$distance ~ $duration",
//               style: TextStyle(fontSize: 14, color: Colors.grey),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           mainText,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         if (subText.isNotEmpty) ...[
//           const SizedBox(height: 2),
//           Text(subText, style: TextStyle(fontSize: 14, color: Colors.grey)),
//         ],
//       ],
//     );
//   }
//
//   Widget _buildHeader() {
//     return Container(
//       height: 80,
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: const BorderRadius.only(
//           bottomLeft: Radius.circular(20),
//           bottomRight: Radius.circular(20),
//         ),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
//         ],
//       ),
//       child: Stack(
//         alignment: Alignment.center,
//         children: [
//           Positioned(
//             left: 16,
//             child: IconButton(
//               icon: const Icon(Icons.arrow_back, color: Colors.black),
//               onPressed: () => Navigator.pop(context),
//             ),
//           ),
//           const Center(
//             child: Text(
//               "New Order",
//               style: TextStyle(
//                 color: Colors.black,
//                 fontSize: 20,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';

import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:shimmer/shimmer.dart';
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen>
    with TickerProviderStateMixin {
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _currentLocation;
  final LatLng dropOffLocation = const LatLng(14.0611, 121.3270);
  final LatLng pickupLocation = const LatLng(14.0589, 121.3265);

  final ValueNotifier<Set<Marker>> _markerNotifier = ValueNotifier({});
  final ValueNotifier<Set<Polyline>> _polylineNotifier = ValueNotifier({});
  final ValueNotifier<bool> _mapLoadedNotifier = ValueNotifier(false);
  final ValueNotifier<bool> _isSearchingRoute = ValueNotifier(false);

  BitmapDescriptor? _iconRider;
  BitmapDescriptor? _iconPickup;
  BitmapDescriptor? _iconDropoff;
  final ValueNotifier<bool> _iconsLoaded = ValueNotifier(false);

  String distanceKm = "-";
  String estimatedTime = "-";

  StreamSubscription<Position>? _positionStream;
  DateTime _lastRouteUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);

  bool _isFetchingRoute = false;

  // Replace with secure storage in production
  final String googleApiKey = "AIzaSyA4eJv1jVmJWrTdOO6SOsEGirFKueKRg98";

  static const Duration routeThrottle = Duration(seconds: 10);

  bool _isFullScreen = false;

  @override
  void initState() {
    super.initState();
    _preloadAssets();
    _startLiveTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _markerNotifier.dispose();
    _polylineNotifier.dispose();
    _mapLoadedNotifier.dispose();
    _isSearchingRoute.dispose();
    _iconsLoaded.dispose();
    super.dispose();
  }

  Future<void> _preloadAssets() async {
    try {
      final ImageConfiguration config = createLocalImageConfiguration(
        context,
        size: const Size(48, 48),
      );
      _iconRider = await BitmapDescriptor.asset(
        config,
        'assets/icons/rider.png',
      );
      _iconPickup = await BitmapDescriptor.asset(
        config,
        'assets/icons/pickup.png',
      );
      _iconDropoff = await BitmapDescriptor.asset(
        config,
        'assets/icons/dropoff.png',
      );
    } catch (e) {
      _iconRider = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueAzure,
      );
      _iconPickup = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueGreen,
      );
      _iconDropoff = BitmapDescriptor.defaultMarkerWithHue(
        BitmapDescriptor.hueRed,
      );
    } finally {
      _iconsLoaded.value = true;
    }
  }

  Future<void> _startLiveTracking() async {
    LocationPermission permission;
    try {
      permission = await Geolocator.requestPermission();
    } catch (_) {
      permission = LocationPermission.denied;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _currentLocation = const LatLng(14.0580, 121.3240);
      _updateMarkers();
      _mapLoadedNotifier.value = true;
      return;
    }

    try {
      Position pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 8),
      );
      _currentLocation = LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      _currentLocation = const LatLng(14.0580, 121.3240);
    }

    _updateMarkers();
    _fetchRoute(force: true);

    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen((Position pos) {
          final newLoc = LatLng(pos.latitude, pos.longitude);
          _currentLocation = newLoc;
          _updateMarkers();
          _moveCameraSmooth();
          _fetchRoute();
        }, onError: (e) {});

    await Future.wait([
      Future.delayed(const Duration(milliseconds: 300)),
      _waitForIconsLoaded(),
    ]);

    _mapLoadedNotifier.value = true;
  }

  Future<void> _waitForIconsLoaded() async {
    if (_iconsLoaded.value == true) return;

    final completer = Completer<void>();

    late VoidCallback listener;
    listener = () {
      if (_iconsLoaded.value == true) {
        _iconsLoaded.removeListener(listener);
        if (!completer.isCompleted) completer.complete();
      }
    };

    _iconsLoaded.addListener(listener);

    await completer.future.timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        _iconsLoaded.removeListener(listener);
      },
    );
  }

  void _updateMarkers() {
    if (_currentLocation == null) return;

    final rider = Marker(
      markerId: const MarkerId("rider"),
      position: _currentLocation!,
      icon:
          _iconRider ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: "Rider (You)"),
      zIndex: 3,
    );

    final pickup = Marker(
      markerId: const MarkerId("pickup"),
      position: pickupLocation,
      icon:
          _iconPickup ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: "Pickup"),
      zIndex: 2,
    );

    final drop = Marker(
      markerId: const MarkerId("dropoff"),
      position: dropOffLocation,
      icon:
          _iconDropoff ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: const InfoWindow(title: "Drop-off"),
      zIndex: 1,
    );

    _markerNotifier.value = {drop, pickup, rider};
  }

  void _showCancelConfirmSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 5,
                width: 50,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                "Are you sure you want to cancel this order?",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text("Order cancelled"),
                        backgroundColor: kPrimaryRedColor,
                        behavior: SnackBarBehavior.floating,
                        margin: const EdgeInsets.all(16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: kPrimaryRedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Confirm",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),

              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey.shade400),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                  child: const Text(
                    "Back",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Future<void> _moveCameraSmooth() async {
    if (_currentLocation == null || !_mapController.isCompleted) return;

    if (DateTime.now().difference(_lastCameraMove) <
        const Duration(seconds: 2)) {
      return;
    }
    _lastCameraMove = DateTime.now();

    try {
      final controller = await _mapController.future;
      await controller.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: _currentLocation!,
            zoom: _isFullScreen ? 16 : 15,
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> _fetchRoute({bool force = false}) async {
    if (_currentLocation == null) return;
    if (!force && DateTime.now().difference(_lastRouteUpdate) < routeThrottle) {
      return;
    }
    if (_isFetchingRoute) return;

    _isFetchingRoute = true;
    _isSearchingRoute.value = true;

    try {
      await _getRoutePolyline();
      _lastRouteUpdate = DateTime.now();
    } catch (e) {
      // ignore
    } finally {
      _isFetchingRoute = false;
      _isSearchingRoute.value = false;
    }
  }

  Future<void> _getRoutePolyline() async {
    if (_currentLocation == null) return;

    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${dropOffLocation.latitude},${dropOffLocation.longitude}&mode=driving&key=$googleApiKey';

    final response = await http
        .get(Uri.parse(url))
        .timeout(
          const Duration(seconds: 12),
          onTimeout: () => http.Response('', 408),
        );

    if (response.statusCode != 200) return;

    final data = json.decode(response.body);

    if (data == null ||
        data["routes"] == null ||
        (data["routes"] as List).isEmpty) {
      return;
    }

    final leg = data["routes"][0]["legs"][0];
    if (leg != null) {
      try {
        final distMeters = leg["distance"]["value"] ?? 0;
        final durSeconds = leg["duration"]["value"] ?? 0;
        distanceKm = (distMeters / 1000).toStringAsFixed(1);
        estimatedTime = "${(durSeconds / 60).round()} min";
      } catch (_) {
        distanceKm = "-";
        estimatedTime = "-";
      }
      if (mounted) setState(() {});
    }

    final encoded = data["routes"][0]["overview_polyline"]["points"] as String?;
    if (encoded == null || encoded.isEmpty) return;

    List<LatLng> points = _decodePolyline(encoded);

    _polylineNotifier.value = {
      Polyline(
        polylineId: const PolylineId("route"),
        color: Colors.blue,
        width: 6,
        points: points,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int result = 0;
      int shift = 0;
      int b;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      result = 0;
      shift = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);

      lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return poly;
  }

  @override
  Widget build(BuildContext context) {
    // safe paddings and screen size
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    final normalMapHeight = max(220.0, screenHeight * 0.5);

    // ensure fullMapHeight doesn't go negative on very small devices
    final fullMapHeight = max(260.0, screenHeight - 80 - safeTop - safeBottom);

    return Scaffold(
      backgroundColor: Colors.white,
      // Use SafeArea to avoid status bar overlaps (header handles its own styling)
      body: Column(
        children: [
          _buildHeader(),

          // Animated map container that expands/collapses smoothly.
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            height: _isFullScreen ? fullMapHeight : normalMapHeight,
            width: double.infinity,

            // ❗ NO padding inside map → prevents overflow
            padding: _isFullScreen
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),

            child: ClipRRect(
              borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 16),
              child: Stack(
                children: [
                  // MAP
                  Positioned.fill(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _mapLoadedNotifier,
                      builder: (_, loaded, __) {
                        if (!loaded || _currentLocation == null) {
                          return _mapShimmerPlaceholder();
                        }

                        return ValueListenableBuilder<Set<Marker>>(
                          valueListenable: _markerNotifier,
                          builder: (_, markers, __) {
                            return ValueListenableBuilder<Set<Polyline>>(
                              valueListenable: _polylineNotifier,
                              builder: (_, polylines, __) {
                                return GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _currentLocation ?? dropOffLocation,
                                    zoom: 14,
                                  ),
                                  markers: markers,
                                  polylines: polylines,
                                  myLocationEnabled: true,
                                  zoomControlsEnabled: false,
                                  myLocationButtonEnabled: false,
                                  onMapCreated: (controller) {
                                    if (!_mapController.isCompleted) {
                                      _mapController.complete(controller);
                                    }
                                  },
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                  ),

                  // ================================
                  // FULL SCREEN BUTTON (TOP RIGHT)
                  // ================================
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _circleButton(
                      icon: _isFullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                      onTap: () {
                        setState(() => _isFullScreen = !_isFullScreen);
                        Future.delayed(const Duration(milliseconds: 360), () {
                          _moveCameraSmooth();
                        });
                      },
                    ),
                  ),

                  // ================================
                  // ZOOM-IN BUTTON
                  // ================================
                  Positioned(
                    right: 12,
                    bottom: 70,
                    child: _circleButton(
                      icon: Icons.add,
                      onTap: () async {
                        final controller = await _mapController.future;
                        controller.animateCamera(CameraUpdate.zoomIn());
                      },
                    ),
                  ),

                  // ================================
                  // ZOOM-OUT BUTTON (MATCH POSITION)
                  // ================================
                  Positioned(
                    right: 12,
                    bottom: 12,
                    child: _circleButton(
                      icon: Icons.remove,
                      onTap: () async {
                        final controller = await _mapController.future;
                        controller.animateCamera(CameraUpdate.zoomOut());
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // hide the rest when full screen
          if (!_isFullScreen)
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),
                    Text(
                      "Delivery Details",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 15),
                    ValueListenableBuilder<bool>(
                      valueListenable: _mapLoadedNotifier,
                      builder: (_, loaded, __) {
                        if (!loaded) {
                          return _fancyShimmerSkeleton(context);
                        }
                        return _buildDeliveryDetails();
                      },
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

          // if (!_isFullScreen)
          //   CustomButton(
          //     text: "Start Delivery",
          //     horizontalPadding: 12,
          //     color: kPrimaryColor,
          //     textColor: Colors.white,
          //     onTap: () {},
          //   ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white,
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.black87, size: 24),
      ),
    );
  }

  Widget _mapShimmerPlaceholder() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(color: Colors.grey[300]),
    );
  }

  Widget _fancyShimmerSkeleton(BuildContext ctx) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                CircleAvatar(radius: 14, backgroundColor: Colors.grey[300]),
                const SizedBox(height: 12),
                Container(width: 2, height: 60, color: Colors.grey[300]),
                const SizedBox(height: 12),
                CircleAvatar(radius: 14, backgroundColor: Colors.grey[300]),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                children: [
                  _skeletonLine(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  _skeletonLine(width: double.infinity, height: 18),
                  const SizedBox(height: 8),
                  _skeletonLine(width: 120, height: 14),
                  const SizedBox(height: 18),
                  _skeletonLine(width: double.infinity, height: 14),
                  const SizedBox(height: 8),
                  _skeletonLine(width: double.infinity, height: 18),
                  const SizedBox(height: 8),
                  _skeletonLine(width: 90, height: 14),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _skeletonLine(width: 80, height: 12),
                const SizedBox(height: 100),
                _skeletonLine(width: 80, height: 12),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _skeletonLine({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _buildDeliveryDetails() {
    final details = [
      {
        'icon': Icons.storefront,
        'title': "Pickup",
        'main': "CARD OTTOKONEK OFFICE",
        'sub': "38C4+PXC",
        'distance': distanceKm,
        'duration': estimatedTime,
      },
      {
        'icon': Icons.info_outline,
        'title': "Drop-off",
        'main': "St. Peter Chapels",
        'sub': "San Pablo City",
        'distance': distanceKm,
        'duration': estimatedTime,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: List.generate(details.length * 2 - 1, (i) {
              if (i.isEven) {
                return Icon(
                  details[i ~/ 2]['icon'] as IconData,
                  color: Colors.grey[400],
                  size: 24,
                );
              } else {
                return Container(width: 2, height: 70, color: Colors.grey[300]);
              }
            }),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              children: details
                  .map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: _buildDetailRow(
                        title: d['title'] as String,
                        mainText: d['main'] as String,
                        subText: d['sub'] as String,
                        distance: d['distance'] as String,
                        duration: d['duration'] as String,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required String title,
    required String mainText,
    required String subText,
    required String distance,
    required String duration,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                "$distance km • $duration",
                key: ValueKey<String>("$distance|$duration|$title"),
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          mainText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (subText.isNotEmpty)
          Text(subText, style: TextStyle(color: Colors.grey[600])),
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            left: 16,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.pop(context),
            ),
          ),

          const Center(
            child: Text(
              "New Order",
              style: TextStyle(
                color: Colors.black,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          Positioned(
            right: 16,
            child: TextButton(
              onPressed: () => _showCancelConfirmSheet(context),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  color: kPrimaryRedColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
