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
// lib/screens/order_details_screen.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';

import 'chat/order_chat_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with TickerProviderStateMixin {
  // ---------------------------
  // Map, location & state
  // ---------------------------
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _currentLocation;
  final LatLng dropOffLocation = const LatLng(14.080821, 121.323274);
  final LatLng pickupLocation = const LatLng(14.0589, 121.3265);

  final ValueNotifier<bool> _mapLoaded = ValueNotifier(false);
  final ValueNotifier<Set<Marker>> _markers = ValueNotifier({});
  final ValueNotifier<Set<Polyline>> _polylines = ValueNotifier({});

  StreamSubscription? _notifSub;
  BitmapDescriptor? _truckIcon;
  BitmapDescriptor? _dropOffIcon;

  final String userCode = "DRV-000003";
  final String userType = "driver";

  // map style
  String? _mapStyle;

  // route / ETA
  String distanceKm = "-";
  String estimatedTime = "-";

  // throttling & fetching
  bool _isFetchingRoute = false;
  DateTime _lastRouteUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  static const Duration routeThrottle = Duration(seconds: 10);

  // position stream
  StreamSubscription<Position>? _positionStream;

  // fullscreen
  bool _isFullScreen = false;

  // YOUR API KEY (AS PROVIDED)
  // Replace or rotate keys as needed; consider secure storage for production.
  final String googleApiKey = "AIzaSyA4eJv1jVmJWrTdOO6SOsEGirFKueKRg98";

  // Example receiver info (UI-only)
  final Map<String, String> _receiver = {
    'name': 'Juan Dela Cruz',
    'phone': '+639171234567',
    'note': 'Leave at the guardhouse. Fragile.',
    'address': 'Blk 12 Lot 8, San Pablo City, Laguna',
  };

  @override
  void initState() {
    super.initState();

    _initLocationAndMap();
    _loadMapStyle();
    _loadTruckIcon();
    _loadDropOffIcon();

    // 🔥 GLOBAL LIVE CHAT NOTIFICATION LISTENER
    Future.microtask(() {
      final provider = context.read<ChatProvider>();

      _notifSub = ApiServices()
          .listenNotifications(userCode: userCode, userType: userType)
          .listen((event) {
            _handleRealtimeChat(event, provider);
          });
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _notifSub?.cancel(); // 🔥 IMPORTANT
    _mapLoaded.dispose();
    _markers.dispose();
    _polylines.dispose();
    super.dispose();
  }

  Future<void> _loadTruckIcon() async {
    final ByteData data = await rootBundle.load('assets/images/truck.png');
    final Uint8List bytes = data.buffer.asUint8List();

    // Resize to your preferred width (e.g., 80px)
    final Uint8List resizedBytes = await _resizeImage(bytes, 80);

    setState(() {
      _truckIcon = BitmapDescriptor.fromBytes(resizedBytes);
    });
  }

  Future<void> _loadDropOffIcon() async {
    final ByteData data = await rootBundle.load('assets/images/drop_off.png');
    final Uint8List bytes = data.buffer.asUint8List();

    // Resize the image to a smaller width (e.g., 80px)
    final Uint8List resizedBytes = await _resizeImage(bytes, 80);

    setState(() {
      _dropOffIcon = BitmapDescriptor.fromBytes(resizedBytes);
    });
  }

  Future<Uint8List> _resizeImage(Uint8List data, int targetWidth) async {
    final codec = await instantiateImageCodec(data, targetWidth: targetWidth);
    final frame = await codec.getNextFrame();
    final ByteData? byteData = await frame.image.toByteData(
      format: ImageByteFormat.png,
    );
    return byteData!.buffer.asUint8List();
  }

  // ---------------------------
  // Initialize location & map
  // ---------------------------
  Future<void> _initLocationAndMap() async {
    LocationPermission permission;
    try {
      permission = await Geolocator.requestPermission();
    } catch (_) {
      permission = LocationPermission.denied;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // fallback location
      _currentLocation = const LatLng(14.0580, 121.3240);
      _updateMarkers();
      _mapLoaded.value = true;
      // still try to fetch route for UI completeness
      await _fetchRoute(force: true);
      return;
    }

    try {
      final pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 8),
      );
      _currentLocation = LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      _currentLocation = const LatLng(14.0580, 121.3240);
    }

    _updateMarkers();
    _mapLoaded.value = true;

    // initial route
    await _fetchRoute(force: true);

    // subscribe to position changes (distanceFilter for efficiency)
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen(
          (Position p) {
            _currentLocation = LatLng(p.latitude, p.longitude);
            _updateMarkers();
            _moveCameraSmooth();
            _fetchRoute(); // will be throttled internally
          },
          onError: (e) {
            // ignore silently; can log if needed
          },
        );
  }

  //----------------------------
  // Map style
  //----------------------------
  void _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/konek2move_map_style.json');
  }

  void _handleRealtimeChat(Map<String, dynamic> event, ChatProvider provider) {
    final data = event["data"];
    if (data == null) return;

    // Only react to chat messages
    if (!(data["topic"]?.toString().contains("chat.new_message") ?? false)) {
      return;
    }

    final meta = data["meta"];
    if (meta == null) return;

    // If message is from CUSTOMER → show badge
    if (meta["sender_type"] != "driver") {
      provider.incrementUnread();
    }
  }

  //----------------------------
  // Cancel
  //----------------------------
  void _showCancelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
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
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              const SizedBox(height: 20),

              const Text(
                "Cancel Delivery?",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),

              const SizedBox(height: 10),

              Text(
                "Are you sure you want to cancel this delivery request?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),

              const SizedBox(height: 20),

              // Confirm Button
              CustomButton(
                text: "Yes, Cancel Delivery",
                color: kPrimaryRedColor,
                textColor: kDefaultIconLightColor,
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pop(context); // Go back to previous screen
                },
              ),

              const SizedBox(height: 10),

              // Close Button
              CustomButton(
                text: "No, Keep Delivery",
                color: kLightButtonColor,
                textColor: kPrimaryColor,
                onTap: () => Navigator.pop(context),
              ),

              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  // ---------------------------
  // Update Markers
  // ---------------------------
  void _updateMarkers() {
    if (_currentLocation == null) return;

    final rider = Marker(
      markerId: const MarkerId('rider'),
      position: _currentLocation!,
      icon:
          _truckIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Rider (You)'),
      anchor: const Offset(0.5, 0.5),
      zIndex: 3,
    );

    final pickup = Marker(
      markerId: const MarkerId('pickup'),
      position: pickupLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: const InfoWindow(title: 'Pickup'),
      zIndex: 2,
    );

    final drop = Marker(
      markerId: const MarkerId('dropoff'),
      position: dropOffLocation,
      icon:
          _dropOffIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Drop-off'),
      zIndex: 1,
    );

    _markers.value = {drop, pickup, rider};
  }

  // ---------------------------
  // Camera movement (smooth)
  // ---------------------------
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);
  Future<void> _moveCameraSmooth() async {
    if (_currentLocation == null || !_mapController.isCompleted) return;

    // small debounce to avoid too many camera moves
    if (DateTime.now().difference(_lastCameraMove) <
        const Duration(seconds: 1)) {
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
    } catch (_) {
      // ignore failures silently
    }
  }

  // ---------------------------
  // Fetch route (throttled)
  // ---------------------------
  Future<void> _fetchRoute({bool force = false}) async {
    if (_currentLocation == null) return;
    if (!force && DateTime.now().difference(_lastRouteUpdate) < routeThrottle) {
      return;
    }
    if (_isFetchingRoute) return;

    _isFetchingRoute = true;
    try {
      final origin =
          '${_currentLocation!.latitude},${_currentLocation!.longitude}';
      final dest = '${dropOffLocation.latitude},${dropOffLocation.longitude}';
      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&mode=driving&key=$googleApiKey',
      );

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 12),
            onTimeout: () => http.Response('', 408),
          );

      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      if (data == null ||
          data['routes'] == null ||
          (data['routes'] as List).isEmpty) {
        return;
      }

      final route = data['routes'][0];
      final leg = route['legs'][0];

      // update distance & duration
      try {
        final distMeters = leg['distance']['value'] ?? 0;
        final durSeconds = leg['duration']['value'] ?? 0;
        distanceKm = (distMeters / 1000).toStringAsFixed(1);
        estimatedTime = "${(durSeconds / 60).round()} min";
        if (mounted) setState(() {}); // only for UI strings
      } catch (_) {
        // keep previous values
      }

      final encoded = route['overview_polyline']?['points'] as String?;
      if (encoded == null || encoded.isEmpty) return;
      final points = _decodePolyline(encoded);

      _polylines.value = {
        Polyline(
          polylineId: const PolylineId('route'),
          color: kPrimaryColor,
          width: 6,
          points: points,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      };

      _lastRouteUpdate = DateTime.now();
    } catch (_) {
      // ignore for UX; can add logging
    } finally {
      _isFetchingRoute = false;
    }
  }

  // ---------------------------
  // Polyline decoder
  // ---------------------------
  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return poly;
  }

  // ---------------------------
  // UI helpers
  // ---------------------------
  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
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
      padding: const EdgeInsets.all(12),
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
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            /// Title
            const Text(
              "Order Details",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),

            /// Back button
            Positioned(
              left: 16,
              child: GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.arrow_back,
                    size: 20,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            /// Cancel button
            Positioned(
              right: 16,
              child: GestureDetector(
                onTap: () => _showCancelSheet(),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: kPrimaryRedColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
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
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReceiverCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: kPrimaryColor.withOpacity(0.06),
            child: const Icon(Icons.person, color: Colors.black54),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _receiver['name'] ?? '-',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _receiver['address'] ?? '-',
                  style: const TextStyle(color: Colors.black54),
                ),
                const SizedBox(height: 6),
                Text(
                  _receiver['note'] ?? '',
                  style: const TextStyle(color: Colors.black54, fontSize: 13),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // UI-only icons (no external actions)
              IconButton(
                onPressed: null,
                icon: const Icon(Icons.phone, color: kPrimaryColor),
              ),
              const SizedBox(height: 6),
              // Consumer<ChatProvider>(
              //   builder: (_, provider, __) {
              //     return Stack(
              //       clipBehavior: Clip.none,
              //       children: [
              //         IconButton(
              //           onPressed: () {
              //             provider.clearUnread();
              //
              //             Navigator.push(
              //               context,
              //               MaterialPageRoute(
              //                 builder: (_) => const OrderChatScreen(),
              //               ),
              //             );
              //           },
              //           icon: const Icon(Icons.message, color: kPrimaryColor),
              //         ),
              //
              //         if (provider.unreadCount > 0)
              //           Positioned(
              //             right: 4,
              //             top: 4,
              //             child: Container(
              //               padding: const EdgeInsets.all(4),
              //               decoration: const BoxDecoration(
              //                 color: Colors.red,
              //                 shape: BoxShape.circle,
              //               ),
              //               child: Text(
              //                 provider.unreadCount.toString(),
              //                 style: const TextStyle(
              //                   color: Colors.white,
              //                   fontSize: 10,
              //                   fontWeight: FontWeight.bold,
              //                 ),
              //               ),
              //             ),
              //           ),
              //       ],
              //     );
              //   },
              // ),
              Consumer<ChatProvider>(
                builder: (_, provider, __) {
                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: () {
                          provider.clearUnread();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const OrderChatScreen(),
                            ),
                          );
                        },
                        icon: const Icon(Icons.message, color: kPrimaryColor),
                      ),

                      if (provider.unreadCount > 0)
                        Positioned(
                          right: 4,
                          top: 4,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Text(
                              provider.unreadCount.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------
  // Build
  // ---------------------------
  @override
  Widget build(BuildContext context) {
    final safeTop = MediaQuery.of(context).padding.top;
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    final normalMapHeight = max(220.0, screenHeight * 0.5);
    final fullMapHeight = max(260.0, screenHeight - 80 - safeTop - safeBottom);

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeInOut,
            height: _isFullScreen ? fullMapHeight : normalMapHeight,
            width: double.infinity,
            padding: _isFullScreen
                ? EdgeInsets.zero
                : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 16),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: ValueListenableBuilder<bool>(
                      valueListenable: _mapLoaded,
                      builder: (_, loaded, __) {
                        if (!loaded || _currentLocation == null) {
                          return _mapShimmerPlaceholder();
                        }

                        return ValueListenableBuilder<Set<Marker>>(
                          valueListenable: _markers,
                          builder: (_, markers, __) {
                            return ValueListenableBuilder<Set<Polyline>>(
                              valueListenable: _polylines,
                              builder: (_, polylines, __) {
                                return GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: _currentLocation ?? dropOffLocation,
                                    zoom: 14,
                                  ),
                                  style: 'assets/konek2move_map_style.json',
                                  buildingsEnabled: true,
                                  mapType: MapType.normal,
                                  markers: markers,
                                  polylines: polylines,
                                  myLocationEnabled: false,
                                  zoomControlsEnabled: false,
                                  myLocationButtonEnabled: false,

                                  onMapCreated:
                                      (GoogleMapController controller) async {
                                        if (!_mapController.isCompleted) {
                                          _mapController.complete(controller);
                                        }

                                        if (_mapStyle != null) {
                                          controller.setMapStyle(_mapStyle);
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

                  // Fullscreen toggle
                  Positioned(
                    top: 12,
                    right: 12,
                    child: _circleButton(
                      icon: _isFullScreen
                          ? Icons.fullscreen_exit
                          : Icons.fullscreen,
                      onTap: () {
                        setState(() => _isFullScreen = !_isFullScreen);
                        Future.delayed(
                          const Duration(milliseconds: 360),
                          _moveCameraSmooth,
                        );
                      },
                    ),
                  ),

                  // Zoom in
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

                  // Zoom out
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
                    const Text(
                      "Delivery Details",
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: _mapLoaded,
                      builder: (_, loaded, __) {
                        if (!loaded) return _fancyShimmerSkeleton(context);
                        return _buildReceiverCard();
                      },
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: _mapLoaded,
                      builder: (_, loaded, __) {
                        if (!loaded) return _fancyShimmerSkeleton(context);
                        return _buildDeliveryDetails();
                      },
                    ),
                    const SizedBox(height: 16),
                    CustomButton(
                      text: "Start Delivery",
                      horizontalPadding: 12,
                      color: kPrimaryColor,
                      textColor: Colors.white,
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Start delivery tapped'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
