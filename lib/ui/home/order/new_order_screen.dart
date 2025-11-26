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
import 'package:http/http.dart' as http;
import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';

class NewOrderScreen extends StatefulWidget {
  const NewOrderScreen({super.key});

  @override
  State<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends State<NewOrderScreen> {
  LatLng? _currentLocation;
  final LatLng dropOffLocation = const LatLng(14.0611, 121.3270);

  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];

  String distanceKm = '';
  String estimatedTime = '';

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    // For testing, set current location manually
    _currentLocation = const LatLng(14.0580, 121.3240);

    // Add markers
    _markers.add(
      Marker(
        markerId: const MarkerId('pickup'),
        position: _currentLocation!,
        infoWindow: const InfoWindow(title: "Pickup"),
      ),
    );
    _markers.add(
      Marker(
        markerId: const MarkerId('dropoff'),
        position: dropOffLocation,
        infoWindow: const InfoWindow(title: "Drop-off"),
      ),
    );

    // Fetch route from Google Directions API
    await _getRoutePolyline();

    setState(() {});
  }

  Future<void> _getRoutePolyline() async {
    final String googleApiKey = 'AIzaSyA4eJv1jVmJWrTdOO6SOsEGirFKueKRg98';
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_currentLocation!.latitude},${_currentLocation!.longitude}&destination=${dropOffLocation.latitude},${dropOffLocation.longitude}&mode=driving&key=$googleApiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK' && data['routes'].isNotEmpty) {
      final route = data['routes'][0];

      distanceKm = (route['legs'][0]['distance']['value'] / 1000)
          .toStringAsFixed(1);
      estimatedTime =
          "${(route['legs'][0]['duration']['value'] / 60).round()} min";

      final polylinePoints = route['overview_polyline']['points'];
      _polylineCoordinates = _decodePolyline(polylinePoints);

      _polylines.clear(); // clear previous polylines if any
      _polylines.add(
        Polyline(
          polylineId: const PolylineId("route"),
          color: Colors.blue, // Food Panda style
          width: 5,
          points: _polylineCoordinates,
          jointType: JointType.round,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );

      setState(() {});
    } else {
      print("Error fetching directions: ${data['status']}");
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return poly;
  }

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
        child: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentLocation ?? dropOffLocation,
            zoom: 14,
          ),
          markers: _markers,
          polylines: _polylines,
          myLocationEnabled: true,
          zoomControlsEnabled: false,
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
        'sub': "38C4+PXC, Colago Ave, San Pablo City, Laguna",
        'distance': distanceKm.isNotEmpty ? "$distanceKm km" : "-",
        'duration': estimatedTime.isNotEmpty ? estimatedTime : "-",
      },
      {
        'icon': Icons.info_outline,
        'title': "Drop-off",
        'main': "St. Peter Chapels",
        'sub': "San Pablo City, Laguna",
        'distance': distanceKm.isNotEmpty ? "$distanceKm km" : "-",
        'duration': estimatedTime.isNotEmpty ? estimatedTime : "-",
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: details.map((d) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: _buildDetailRow(
                  title: d['title'] as String,
                  mainText: d['main'] as String,
                  subText: d['sub'] as String,
                  distance: d['distance'] as String,
                  duration: d['duration'] as String,
                ),
              );
            }).toList(),
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
              "$distance ~ $duration",
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          mainText,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
        if (subText.isNotEmpty) ...[
          const SizedBox(height: 2),
          Text(subText, style: TextStyle(fontSize: 14, color: Colors.grey)),
        ],
      ],
    );
  }

  Widget _buildHeader() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
        boxShadow: const [
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
