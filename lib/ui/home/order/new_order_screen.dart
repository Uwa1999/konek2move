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
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _currentLocation;
  final LatLng dropOffLocation = const LatLng(14.0611, 121.3270);

  // FAST & SMOOTH NOTIFIERS (no rebuild of whole screen)
  final ValueNotifier<Set<Marker>> _markerNotifier = ValueNotifier({});
  final ValueNotifier<Set<Polyline>> _polylineNotifier = ValueNotifier({});

  String distanceKm = "-";
  String estimatedTime = "-";

  StreamSubscription<Position>? _positionStream;
  DateTime _lastRouteUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);

  bool _isFetchingRoute = false;

  final String googleApiKey = "AIzaSyAhRp_J8GBH7RBH3XNCOsX3dkm_G8CBs6U";

  static const Duration routeThrottle = Duration(seconds: 10);

  @override
  void initState() {
    super.initState();
    _startLiveTracking();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    super.dispose();
  }

  // ============================================================
  // START TRACKING
  // ============================================================
  Future<void> _startLiveTracking() async {
    // Permission
    LocationPermission permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      _currentLocation = const LatLng(14.0580, 121.3240);
      _updateMarkers();
      return;
    }

    // Initial location
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

    // Live updates
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            distanceFilter: 5,
          ),
        ).listen((Position pos) {
          _currentLocation = LatLng(pos.latitude, pos.longitude);
          _updateMarkers();
          _moveCameraSmooth();
          _fetchRoute();
        });
  }

  // ============================================================
  // UPDATE MARKERS (FAST)
  // ============================================================
  void _updateMarkers() {
    if (_currentLocation == null) return;

    _markerNotifier.value = {
      Marker(
        markerId: const MarkerId("rider"),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
      Marker(markerId: const MarkerId("dropoff"), position: dropOffLocation),
    };
  }

  // ============================================================
  // CAMERA FOLLOW (SMOOTH)
  // ============================================================
  Future<void> _moveCameraSmooth() async {
    if (_currentLocation == null || !_mapController.isCompleted) return;

    if (DateTime.now().difference(_lastCameraMove) < const Duration(seconds: 2))
      return;

    _lastCameraMove = DateTime.now();

    final controller = await _mapController.future;
    controller.animateCamera(CameraUpdate.newLatLng(_currentLocation!));
  }

  // ============================================================
  // ROUTE FETCHING (THROTTLED)
  // ============================================================
  Future<void> _fetchRoute({bool force = false}) async {
    if (_currentLocation == null) return;

    if (!force && DateTime.now().difference(_lastRouteUpdate) < routeThrottle)
      return;

    if (_isFetchingRoute) return;
    _isFetchingRoute = true;

    try {
      await _getRoutePolyline();
      _lastRouteUpdate = DateTime.now();
    } catch (_) {}
    _isFetchingRoute = false;
  }

  // ============================================================
  // GET POLYLINE DATA (GOOGLE DIRECTIONS)
  // ============================================================
  Future<void> _getRoutePolyline() async {
    final url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${dropOffLocation.latitude},${dropOffLocation.longitude}&mode=driving&key=$googleApiKey';

    final response = await http
        .get(Uri.parse(url))
        .timeout(const Duration(seconds: 12));

    if (response.statusCode != 200) return;

    final data = json.decode(response.body);

    if (data["routes"] == null || data["routes"].isEmpty) return;

    final leg = data["routes"][0]["legs"][0];

    distanceKm = (leg["distance"]["value"] / 1000).toStringAsFixed(1);
    estimatedTime = "${(leg["duration"]["value"] / 60).round()} min";
    if (mounted) setState(() {});

    final encoded = data["routes"][0]["overview_polyline"]["points"];

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

  // ============================================================
  // FAST POLYLINE DECODER (optimized)
  // ============================================================
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

  // ============================================================
  // UI
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildMap(),
                  const SizedBox(height: 20),
                  Text(
                    "Delivery Details",
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey[500],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  _buildDeliveryDetails(),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(24),
            child: CustomButton(
              text: "Start Delivery",
              horizontalPadding: 0,
              color: kPrimaryColor,
              textColor: Colors.white,
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    final screenHeight = MediaQuery.of(context).size.height;
    final mapHeight = screenHeight * 0.5;

    return SizedBox(
      height: mapHeight,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ValueListenableBuilder(
          valueListenable: _markerNotifier,
          builder: (_, markers, __) {
            return ValueListenableBuilder(
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
                  onMapCreated: (controller) {
                    if (!_mapController.isCompleted) {
                      _mapController.complete(controller);
                    }
                  },
                );
              },
            );
          },
        ),
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

    return Row(
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
              return Container(width: 2, height: 70, color: Colors.grey[400]);
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
            Text(
              "$distance km • $duration",
              style: TextStyle(color: Colors.grey[600]),
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
        ],
      ),
    );
  }
}
