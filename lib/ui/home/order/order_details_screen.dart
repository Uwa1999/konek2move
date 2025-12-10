// import 'dart:async';
// import 'dart:convert';
// import 'dart:math';
// import 'dart:ui';
//
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:http/http.dart' as http;
// import 'package:konek2move/core/services/api_services.dart';
// import 'package:konek2move/core/services/provider_services.dart';
// import 'package:konek2move/core/widgets/custom_home_appbar.dart';
// import 'package:provider/provider.dart';
// import 'package:shimmer/shimmer.dart';
//
// import 'package:konek2move/core/constants/app_colors.dart';
// import 'package:konek2move/core/widgets/custom_button.dart';
//
// import 'chat/order_chat_screen.dart';
//
// class OrderDetailScreen extends StatefulWidget {
//   const OrderDetailScreen({super.key, required order});
//
//   @override
//   State<OrderDetailScreen> createState() => _OrderDetailScreenState();
// }
//
// class _OrderDetailScreenState extends State<OrderDetailScreen>
//     with TickerProviderStateMixin {
//   // ---------------------------
//   // Map, location & state
//   // ---------------------------
//   final Completer<GoogleMapController> _mapController = Completer();
//
//   LatLng? _currentLocation;
//   final LatLng dropOffLocation = const LatLng(14.080821, 121.323274);
//   final LatLng pickupLocation = const LatLng(14.0589, 121.3265);
//
//   final ValueNotifier<bool> _mapLoaded = ValueNotifier(false);
//   final ValueNotifier<Set<Marker>> _markers = ValueNotifier({});
//   final ValueNotifier<Set<Polyline>> _polylines = ValueNotifier({});
//
//   StreamSubscription? _notifSub;
//   BitmapDescriptor? _truckIcon;
//   BitmapDescriptor? _dropOffIcon;
//
//   // map style
//   String? _mapStyle;
//
//   // route / ETA
//   String distanceKm = "-";
//   String estimatedTime = "-";
//
//   // throttling & fetching
//   bool _isFetchingRoute = false;
//   DateTime _lastRouteUpdate = DateTime.fromMillisecondsSinceEpoch(0);
//   static const Duration routeThrottle = Duration(seconds: 10);
//
//   // position stream
//   StreamSubscription<Position>? _positionStream;
//
//   // fullscreen
//   bool _isFullScreen = false;
//
//   // YOUR API KEY (AS PROVIDED)
//   final String googleApiKey = "AIzaSyA4eJv1jVmJWrTdOO6SOsEGirFKueKRg98";
//
//   // Example receiver info (UI-only)
//   final Map<String, String> _receiver = {
//     'name': 'Juan Dela Cruz',
//     'phone': '+639171234567',
//     'note': 'Leave at the guardhouse. Fragile.',
//     'address': 'Blk 12 Lot 8, San Pablo City, Laguna',
//   };
//
//   @override
//   void initState() {
//     super.initState();
//
//     _initLocationAndMap();
//     _loadMapStyle();
//     _loadTruckIcon();
//     _loadDropOffIcon();
//
//     // 🔥 GLOBAL LIVE CHAT NOTIFICATION LISTENER
//     Future.microtask(() {
//       final provider = context.read<ChatProvider>();
//
//       _notifSub = ApiServices().listenNotifications().listen((event) {
//         _handleRealtimeChat(event, provider);
//       });
//     });
//   }
//
//   @override
//   void dispose() {
//     _positionStream?.cancel();
//     _notifSub?.cancel(); // 🔥 IMPORTANT
//     _mapLoaded.dispose();
//     _markers.dispose();
//     _polylines.dispose();
//     super.dispose();
//   }
//
//   Future<void> _loadTruckIcon() async {
//     final ByteData data = await rootBundle.load('assets/images/truck.png');
//     final Uint8List bytes = data.buffer.asUint8List();
//
//     // Resize to your preferred width (e.g., 80px)
//     final Uint8List resizedBytes = await _resizeImage(bytes, 70);
//
//     setState(() {
//       _truckIcon = BitmapDescriptor.fromBytes(resizedBytes);
//     });
//   }
//
//   Future<void> _loadDropOffIcon() async {
//     final ByteData data = await rootBundle.load('assets/images/drop_off.png');
//     final Uint8List bytes = data.buffer.asUint8List();
//
//     // Resize the image to a smaller width (e.g., 80px)
//     final Uint8List resizedBytes = await _resizeImage(bytes, 80);
//
//     setState(() {
//       _dropOffIcon = BitmapDescriptor.fromBytes(resizedBytes);
//     });
//   }
//
//   Future<Uint8List> _resizeImage(Uint8List data, int targetWidth) async {
//     final codec = await instantiateImageCodec(data, targetWidth: targetWidth);
//     final frame = await codec.getNextFrame();
//     final ByteData? byteData = await frame.image.toByteData(
//       format: ImageByteFormat.png,
//     );
//     return byteData!.buffer.asUint8List();
//   }
//
//   // ---------------------------
//   // Initialize location & map
//   // ---------------------------
//   Future<void> _initLocationAndMap() async {
//     LocationPermission permission;
//     try {
//       permission = await Geolocator.requestPermission();
//     } catch (_) {
//       permission = LocationPermission.denied;
//     }
//
//     if (permission == LocationPermission.denied ||
//         permission == LocationPermission.deniedForever) {
//       // fallback location
//       _currentLocation = const LatLng(14.0580, 121.3240);
//       _updateMarkers();
//       _mapLoaded.value = true;
//       // still try to fetch route for UI completeness
//       await _fetchRoute(force: true);
//       return;
//     }
//
//     try {
//       final pos = await Geolocator.getCurrentPosition(
//         timeLimit: const Duration(seconds: 8),
//       );
//       _currentLocation = LatLng(pos.latitude, pos.longitude);
//     } catch (_) {
//       _currentLocation = const LatLng(14.0580, 121.3240);
//     }
//
//     _updateMarkers();
//     _mapLoaded.value = true;
//
//     // initial route
//     await _fetchRoute(force: true);
//
//     // subscribe to position changes (distanceFilter for efficiency)
//     _positionStream =
//         Geolocator.getPositionStream(
//           locationSettings: const LocationSettings(
//             accuracy: LocationAccuracy.bestForNavigation,
//             distanceFilter: 5,
//           ),
//         ).listen(
//           (Position p) {
//             _currentLocation = LatLng(p.latitude, p.longitude);
//             _updateMarkers();
//             _moveCameraSmooth();
//             _fetchRoute(); // will be throttled internally
//           },
//           onError: (e) {
//             // ignore silently; can log if needed
//           },
//         );
//   }
//
//   //----------------------------
//   // Map style
//   //----------------------------
//   void _loadMapStyle() async {
//     _mapStyle = await rootBundle.loadString('assets/konek2move_map_style.json');
//   }
//
//   void _handleRealtimeChat(Map<String, dynamic> event, ChatProvider provider) {
//     final data = event["data"];
//     if (data == null) return;
//
//     // Only react to chat messages
//     if (!(data["topic"]?.toString().contains("chat.new_message") ?? false)) {
//       return;
//     }
//
//     final meta = data["meta"];
//     if (meta == null) return;
//
//     // If message is from CUSTOMER → show badge
//     if (meta["sender_type"] != "driver") {
//       provider.incrementUnread();
//     }
//   }
//
//   //----------------------------
//   // Cancel
//   //----------------------------
//   void _showCancelSheet() {
//     showModalBottomSheet(
//       context: context,
//       isScrollControlled: true,
//       backgroundColor: Colors.white,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
//       ),
//       builder: (_) {
//         return Padding(
//           padding: const EdgeInsets.all(20),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Container(
//                 width: 40,
//                 height: 5,
//                 decoration: BoxDecoration(
//                   color: Colors.grey.shade300,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//               ),
//               const SizedBox(height: 20),
//               const Text(
//                 "Cancel Delivery?",
//                 style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
//               ),
//               const SizedBox(height: 10),
//               Text(
//                 "Are you sure you want to cancel this delivery request?",
//                 textAlign: TextAlign.center,
//                 style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
//               ),
//               const SizedBox(height: 20),
//               CustomButton(
//                 text: "Yes, Cancel Delivery",
//                 color: kPrimaryRedColor,
//                 textColor: kDefaultIconLightColor,
//                 onTap: () {
//                   Navigator.pop(context);
//                   Navigator.pop(context); // Go back to previous screen
//                 },
//               ),
//               const SizedBox(height: 10),
//               CustomButton(
//                 text: "No, Keep Delivery",
//                 color: kLightButtonColor,
//                 textColor: kPrimaryColor,
//                 onTap: () => Navigator.pop(context),
//               ),
//               const SizedBox(height: 10),
//             ],
//           ),
//         );
//       },
//     );
//   }
//
//   // ---------------------------
//   // Update Markers
//   // ---------------------------
//   void _updateMarkers() {
//     if (_currentLocation == null) return;
//
//     final rider = Marker(
//       markerId: const MarkerId('rider'),
//       position: _currentLocation!,
//       icon:
//           _truckIcon ??
//           BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//       infoWindow: const InfoWindow(title: 'Rider (You)'),
//       anchor: const Offset(0.5, 0.5),
//       zIndex: 3,
//     );
//
//     final pickup = Marker(
//       markerId: const MarkerId('pickup'),
//       position: pickupLocation,
//       icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
//       infoWindow: const InfoWindow(title: 'Pickup'),
//       zIndex: 2,
//     );
//
//     final drop = Marker(
//       markerId: const MarkerId('dropoff'),
//       position: dropOffLocation,
//       icon:
//           _dropOffIcon ??
//           BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
//       infoWindow: const InfoWindow(title: 'Drop-off'),
//       zIndex: 1,
//     );
//
//     _markers.value = {drop, pickup, rider};
//   }
//
//   // ---------------------------
//   // Camera movement (smooth)
//   // ---------------------------
//   DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);
//   Future<void> _moveCameraSmooth() async {
//     if (_currentLocation == null || !_mapController.isCompleted) return;
//
//     // small debounce to avoid too many camera moves
//     if (DateTime.now().difference(_lastCameraMove) <
//         const Duration(seconds: 1)) {
//       return;
//     }
//     _lastCameraMove = DateTime.now();
//
//     try {
//       final controller = await _mapController.future;
//       await controller.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             target: _currentLocation!,
//             zoom: _isFullScreen ? 16 : 15,
//           ),
//         ),
//       );
//     } catch (_) {
//       // ignore failures silently
//     }
//   }
//
//   // ---------------------------
//   // Fetch route (throttled)
//   // ---------------------------
//   Future<void> _fetchRoute({bool force = false}) async {
//     if (_currentLocation == null) return;
//     if (!force && DateTime.now().difference(_lastRouteUpdate) < routeThrottle) {
//       return;
//     }
//     if (_isFetchingRoute) return;
//
//     _isFetchingRoute = true;
//     try {
//       final origin =
//           '${_currentLocation!.latitude},${_currentLocation!.longitude}';
//       final dest = '${dropOffLocation.latitude},${dropOffLocation.longitude}';
//       final uri = Uri.parse(
//         'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&mode=driving&key=$googleApiKey',
//       );
//
//       final response = await http
//           .get(uri)
//           .timeout(
//             const Duration(seconds: 12),
//             onTimeout: () => http.Response('', 408),
//           );
//
//       if (response.statusCode != 200) return;
//
//       final data = json.decode(response.body);
//       if (data == null ||
//           data['routes'] == null ||
//           (data['routes'] as List).isEmpty) {
//         return;
//       }
//
//       final route = data['routes'][0];
//       final leg = route['legs'][0];
//
//       // update distance & duration
//       try {
//         final distMeters = leg['distance']['value'] ?? 0;
//         final durSeconds = leg['duration']['value'] ?? 0;
//         distanceKm = (distMeters / 1000).toStringAsFixed(1);
//         estimatedTime = "${(durSeconds / 60).round()} min";
//         if (mounted) setState(() {}); // only for UI strings
//       } catch (_) {
//         // keep previous values
//       }
//
//       final encoded = route['overview_polyline']?['points'] as String?;
//       if (encoded == null || encoded.isEmpty) return;
//       final points = _decodePolyline(encoded);
//
//       _polylines.value = {
//         Polyline(
//           polylineId: const PolylineId('route'),
//           color: kPrimaryColor,
//           width: 6,
//           points: points,
//           startCap: Cap.roundCap,
//           endCap: Cap.roundCap,
//         ),
//       };
//
//       _lastRouteUpdate = DateTime.now();
//     } catch (_) {
//       // ignore for UX; can add logging
//     } finally {
//       _isFetchingRoute = false;
//     }
//   }
//
//   // ---------------------------
//   // Polyline decoder
//   // ---------------------------
//   List<LatLng> _decodePolyline(String encoded) {
//     List<LatLng> poly = [];
//     int index = 0, len = encoded.length;
//     int lat = 0, lng = 0;
//
//     while (index < len) {
//       int b, shift = 0, result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       final dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lat += dlat;
//
//       shift = 0;
//       result = 0;
//       do {
//         b = encoded.codeUnitAt(index++) - 63;
//         result |= (b & 0x1f) << shift;
//         shift += 5;
//       } while (b >= 0x20);
//       final dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
//       lng += dlng;
//
//       poly.add(LatLng(lat / 1e5, lng / 1e5));
//     }
//     return poly;
//   }
//
//   // ---------------------------
//   // UI helpers
//   // ---------------------------
//   Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         height: 48,
//         width: 48,
//         decoration: BoxDecoration(
//           color: Colors.white,
//           shape: BoxShape.circle,
//           boxShadow: const [
//             BoxShadow(
//               color: Colors.black26,
//               blurRadius: 8,
//               offset: Offset(0, 2),
//             ),
//           ],
//         ),
//         child: Icon(icon, color: Colors.black87, size: 24),
//       ),
//     );
//   }
//
//   Widget _mapShimmerPlaceholder() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: Container(color: Colors.grey[300]),
//     );
//   }
//
//   Widget _fancyShimmerSkeleton(BuildContext ctx) {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: Container(
//         padding: const EdgeInsets.all(16),
//         decoration: BoxDecoration(
//           color: Colors.white,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Column(
//               children: [
//                 CircleAvatar(radius: 14, backgroundColor: Colors.grey[300]),
//                 const SizedBox(height: 12),
//                 Container(width: 2, height: 60, color: Colors.grey[300]),
//                 const SizedBox(height: 12),
//                 CircleAvatar(radius: 14, backgroundColor: Colors.grey[300]),
//               ],
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 children: [
//                   _skeletonLine(width: double.infinity, height: 14),
//                   const SizedBox(height: 8),
//                   _skeletonLine(width: double.infinity, height: 18),
//                   const SizedBox(height: 8),
//                   _skeletonLine(width: 120, height: 14),
//                   const SizedBox(height: 18),
//                   _skeletonLine(width: double.infinity, height: 14),
//                   const SizedBox(height: 8),
//                   _skeletonLine(width: double.infinity, height: 18),
//                   const SizedBox(height: 8),
//                   _skeletonLine(width: 90, height: 14),
//                 ],
//               ),
//             ),
//             const SizedBox(width: 12),
//             Column(
//               crossAxisAlignment: CrossAxisAlignment.end,
//               children: [
//                 _skeletonLine(width: 80, height: 12),
//                 const SizedBox(height: 100),
//                 _skeletonLine(width: 80, height: 12),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _skeletonLine({required double width, required double height}) {
//     return Container(
//       width: width,
//       height: height,
//       decoration: BoxDecoration(
//         color: Colors.grey[300],
//         borderRadius: BorderRadius.circular(6),
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
//         'sub': "38C4+PXC",
//         'distance': distanceKm,
//         'duration': estimatedTime,
//       },
//       {
//         'icon': Icons.info_outline,
//         'title': "Drop-off",
//         'main': "St. Peter Chapels",
//         'sub': "San Pablo City",
//         'distance': distanceKm,
//         'duration': estimatedTime,
//       },
//     ];
//
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
//         ],
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Column(
//             children: List.generate(details.length * 2 - 1, (i) {
//               if (i.isEven) {
//                 return Icon(
//                   details[i ~/ 2]['icon'] as IconData,
//                   color: Colors.grey[400],
//                   size: 24,
//                 );
//               } else {
//                 return Container(width: 2, height: 70, color: Colors.grey[300]);
//               }
//             }),
//           ),
//           const SizedBox(width: 15),
//           Expanded(
//             child: Column(
//               children: details
//                   .map(
//                     (d) => Padding(
//                       padding: const EdgeInsets.only(bottom: 20),
//                       child: _buildDetailRow(
//                         title: d['title'] as String,
//                         mainText: d['main'] as String,
//                         subText: d['sub'] as String,
//                         distance: d['distance'] as String,
//                         duration: d['duration'] as String,
//                       ),
//                     ),
//                   )
//                   .toList(),
//             ),
//           ),
//         ],
//       ),
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
//             AnimatedSwitcher(
//               duration: const Duration(milliseconds: 300),
//               child: Text(
//                 "$distance km • $duration",
//                 key: ValueKey<String>("$distance|$duration|$title"),
//                 style: TextStyle(color: Colors.grey[600]),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 4),
//         Text(
//           mainText,
//           style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
//         ),
//         if (subText.isNotEmpty)
//           Text(subText, style: TextStyle(color: Colors.grey[600])),
//       ],
//     );
//   }
//
//   Widget _buildReceiverCard() {
//     return Container(
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12),
//         boxShadow: const [
//           BoxShadow(color: Colors.black12, blurRadius: 8, offset: Offset(0, 3)),
//         ],
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             radius: 26,
//             backgroundColor: kPrimaryColor.withOpacity(0.06),
//             child: const Icon(Icons.person, color: Colors.black54),
//           ),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   _receiver['name'] ?? '-',
//                   style: const TextStyle(
//                     fontSize: 16,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   _receiver['address'] ?? '-',
//                   style: const TextStyle(color: Colors.black54),
//                 ),
//                 const SizedBox(height: 6),
//                 Text(
//                   _receiver['note'] ?? '',
//                   style: const TextStyle(color: Colors.black54, fontSize: 13),
//                 ),
//               ],
//             ),
//           ),
//           const SizedBox(width: 8),
//           Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               IconButton(
//                 onPressed: null,
//                 icon: const Icon(Icons.phone, color: kPrimaryColor),
//               ),
//               const SizedBox(height: 6),
//               Consumer<ChatProvider>(
//                 builder: (_, provider, __) {
//                   return Stack(
//                     clipBehavior: Clip.none,
//                     children: [
//                       IconButton(
//                         onPressed: () {
//                           provider.clearUnread();
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(
//                               builder: (_) => const OrderChatScreen(),
//                             ),
//                           );
//                         },
//                         icon: const Icon(Icons.message, color: kPrimaryColor),
//                       ),
//                       if (provider.unreadCount > 0)
//                         Positioned(
//                           right: 4,
//                           top: 4,
//                           child: Container(
//                             padding: const EdgeInsets.all(4),
//                             decoration: const BoxDecoration(
//                               color: Colors.red,
//                               shape: BoxShape.circle,
//                             ),
//                             child: Text(
//                               provider.unreadCount.toString(),
//                               style: const TextStyle(
//                                 color: Colors.white,
//                                 fontSize: 10,
//                                 fontWeight: FontWeight.bold,
//                               ),
//                             ),
//                           ),
//                         ),
//                     ],
//                   );
//                 },
//               ),
//             ],
//           ),
//         ],
//       ),
//     );
//   }
//
//   // ---------------------------
//   // Build
//   // ---------------------------
//
//   @override
//   Widget build(BuildContext context) {
//     final safeTop = MediaQuery.of(context).padding.top;
//     final safeBottom = MediaQuery.of(context).padding.bottom;
//     final screenHeight = MediaQuery.of(context).size.height;
//
//     final headerHeight = 80.0 + safeTop;
//
//     final normalMapHeight = max(220.0, screenHeight * 0.5);
//     // 🔧 FULLSCREEN: fill everything under header, no bottom gap
//     final fullMapHeight = max(260.0, screenHeight - headerHeight);
//
//     return Scaffold(
//       appBar: CustomHomeAppBar(
//         title: "Order Details",
//         showTrailing: true,
//         trailingText: "Cancel",
//         onTrailingTap: () {
//           _showCancelSheet();
//         },
//       ),
//       body: Column(
//         children: [
//           AnimatedContainer(
//             duration: const Duration(milliseconds: 350),
//             curve: Curves.easeInOut,
//             height: _isFullScreen ? fullMapHeight : normalMapHeight,
//             width: double.infinity,
//             padding: _isFullScreen
//                 ? EdgeInsets.zero
//                 : const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
//             child: ClipRRect(
//               borderRadius: BorderRadius.circular(_isFullScreen ? 0 : 16),
//               child: Stack(
//                 children: [
//                   Positioned.fill(
//                     child: ValueListenableBuilder<bool>(
//                       valueListenable: _mapLoaded,
//                       builder: (_, loaded, __) {
//                         if (!loaded || _currentLocation == null) {
//                           return _mapShimmerPlaceholder();
//                         }
//
//                         return ValueListenableBuilder<Set<Marker>>(
//                           valueListenable: _markers,
//                           builder: (_, markers, __) {
//                             return ValueListenableBuilder<Set<Polyline>>(
//                               valueListenable: _polylines,
//                               builder: (_, polylines, __) {
//                                 return GoogleMap(
//                                   initialCameraPosition: CameraPosition(
//                                     target: _currentLocation ?? dropOffLocation,
//                                     zoom: 14,
//                                   ),
//                                   buildingsEnabled: true,
//                                   mapType: MapType.normal,
//                                   markers: markers,
//                                   polylines: polylines,
//                                   myLocationEnabled: false,
//                                   zoomControlsEnabled: false,
//                                   myLocationButtonEnabled: false,
//                                   compassEnabled: true,
//                                   trafficEnabled: false,
//                                   onMapCreated:
//                                       (GoogleMapController controller) async {
//                                         if (!_mapController.isCompleted) {
//                                           _mapController.complete(controller);
//                                         }
//
//                                         if (_mapStyle != null) {
//                                           controller.setMapStyle(_mapStyle);
//                                         }
//                                       },
//                                 );
//                               },
//                             );
//                           },
//                         );
//                       },
//                     ),
//                   ),
//
//                   // Fullscreen toggle
//                   Positioned(
//                     top: 12,
//                     right: 12,
//                     child: _circleButton(
//                       icon: _isFullScreen
//                           ? Icons.fullscreen_exit
//                           : Icons.fullscreen,
//                       onTap: () {
//                         setState(() => _isFullScreen = !_isFullScreen);
//                         Future.delayed(
//                           const Duration(milliseconds: 360),
//                           _moveCameraSmooth,
//                         );
//                       },
//                     ),
//                   ),
//
//                   // Zoom in
//                   Positioned(
//                     right: 12,
//                     bottom: 70,
//                     child: _circleButton(
//                       icon: Icons.add,
//                       onTap: () async {
//                         final controller = await _mapController.future;
//                         controller.animateCamera(CameraUpdate.zoomIn());
//                       },
//                     ),
//                   ),
//
//                   // Zoom out
//                   Positioned(
//                     right: 12,
//                     bottom: 12 + safeBottom * 0,
//                     child: _circleButton(
//                       icon: Icons.remove,
//                       onTap: () async {
//                         final controller = await _mapController.future;
//                         controller.animateCamera(CameraUpdate.zoomOut());
//                       },
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//
//           if (!_isFullScreen)
//             Expanded(
//               child: SingleChildScrollView(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 0,
//                 ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const SizedBox(height: 10),
//                     const Text(
//                       "Delivery Details",
//                       style: TextStyle(
//                         fontSize: 15,
//                         color: Colors.black54,
//                         fontWeight: FontWeight.bold,
//                       ),
//                     ),
//                     const SizedBox(height: 12),
//                     ValueListenableBuilder<bool>(
//                       valueListenable: _mapLoaded,
//                       builder: (_, loaded, __) {
//                         if (!loaded) return _fancyShimmerSkeleton(context);
//                         return _buildReceiverCard();
//                       },
//                     ),
//                     const SizedBox(height: 12),
//                     ValueListenableBuilder<bool>(
//                       valueListenable: _mapLoaded,
//                       builder: (_, loaded, __) {
//                         if (!loaded) return _fancyShimmerSkeleton(context);
//                         return _buildDeliveryDetails();
//                       },
//                     ),
//                     const SizedBox(height: 16),
//                     CustomButton(
//                       text: "Start Delivery",
//                       horizontalPadding: 12,
//                       color: kPrimaryColor,
//                       textColor: Colors.white,
//                       onTap: () {
//                         ScaffoldMessenger.of(context).showSnackBar(
//                           const SnackBar(
//                             content: Text('Start delivery tapped'),
//                           ),
//                         );
//                       },
//                     ),
//                     const SizedBox(height: 20),
//                   ],
//                 ),
//               ),
//             ),
//         ],
//       ),
//     );
//   }
// }
import 'dart:async';
import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_compass/flutter_compass.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:konek2move/core/widgets/custom_home_appbar.dart';
import 'package:konek2move/ui/home/home_screen.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';

import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:url_launcher/url_launcher.dart';

import 'chat/order_chat_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderRecord order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with TickerProviderStateMixin {
  // ---------------------------------------------------------------------------
  // Constants
  // ---------------------------------------------------------------------------
  static const Duration _routeThrottle = Duration(seconds: 10);
  static const String _googleApiKey = "AIzaSyA4eJv1jVmJWrTdOO6SOsEGirFKueKRg98";

  // ---------------------------------------------------------------------------
  // Map, location & state
  // ---------------------------------------------------------------------------
  final Completer<GoogleMapController> _mapController = Completer();

  LatLng? _currentLocation;
  late LatLng dropOffLocation;
  late LatLng pickupLocation;

  final ValueNotifier<bool> _mapLoaded = ValueNotifier(false);
  final ValueNotifier<Set<Marker>> _markers = ValueNotifier({});
  final ValueNotifier<Set<Polyline>> _polylines = ValueNotifier({});

  StreamSubscription<Position>? _positionStream;
  StreamSubscription? _notifSub;

  BitmapDescriptor? _truckIcon;
  BitmapDescriptor? _dropOffIcon;

  String? _mapStyle;

  bool _isFullScreen = false;
  bool _isFetchingRoute = false;
  bool _isMoving = false;
  bool isLoading = false;
  bool showDriveButton = false;

  double _finalBearing = 0;
  DateTime _lastRouteUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);

  // ---------------------------------------------------------------------------
  // Delivery state
  // ---------------------------------------------------------------------------
  String routeTarget = "pickup"; // pickup → dropoff
  late String deliveryStatus;

  bool hasPhotoProof = false;
  bool hasSignature = false;

  // Rider → Pickup (dynamic)
  String pickupDistanceKm = "-";
  String pickupDuration = "-";

  // Rider → Drop-off (dynamic)
  String riderDropoffDistanceKm = "-";
  String riderDropoffDuration = "-";

  // Pickup → Drop-off (static)
  String dropoffDistanceKm = "-";
  String dropoffDuration = "-";

  // Route / ETA (extra, if needed in UI later)
  String distanceKm = "-";
  String estimatedTime = "-";

  final bool _showStatusButton = true;

  // ---------------------------------------------------------------------------
  // Convenience getters
  // ---------------------------------------------------------------------------
  String get receiverName {
    final name = widget.order.customer?.name ?? '';
    if (name.trim().isEmpty) return "Unknown Customer";
    return name;
  }

  String get receiverPhone {
    final phone = widget.order.customer?.phone ?? widget.order.contactPhone;
    if (phone.trim().isEmpty) return "-";
    return phone;
  }

  String get receiverAddress => widget.order.deliveryAddress;
  String get status => widget.order.status;

  String get receiverNote => widget.order.contactPhone.isNotEmpty
      ? "Mobile No: ${widget.order.contactPhone}"
      : "";

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    _initLocationAndMap();
    _loadMapStyle();
    _loadTruckIcon();
    _loadDropOffIcon();
    _computePickupToDropoff();
    // Coordinates from order
    pickupLocation = LatLng(widget.order.pickupLat, widget.order.pickupLng);
    dropOffLocation = LatLng(
      widget.order.deliveryLat,
      widget.order.deliveryLng,
    );

    // Delivery status (fallback to "assigned")
    deliveryStatus = (widget.order.status).toString().toLowerCase();

    // Live chat notifications
    Future.microtask(() {
      final provider = context.read<ChatProvider>();

      _notifSub = ApiServices().listenNotifications().listen((event) {
        _handleRealtimeChat(event, provider);
      });
    });
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _notifSub?.cancel();
    _mapLoaded.dispose();
    _markers.dispose();
    _polylines.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Map helpers
  // ---------------------------------------------------------------------------
  double _smoothRotate(double oldAngle, double newAngle) {
    double diff = newAngle - oldAngle;
    if (diff.abs() > 180) {
      if (diff > 0) {
        diff -= 360;
      } else {
        diff += 360;
      }
    }
    return oldAngle + diff * 0.2;
  }

  Future<void> _initLocationAndMap() async {
    LocationPermission permission;
    try {
      permission = await Geolocator.requestPermission();
    } catch (_) {
      permission = LocationPermission.denied;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Fallback location
      _currentLocation = const LatLng(14.0580, 121.3240);
      _updateMarkers();
      _mapLoaded.value = true;
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

    // Initial route
    await _fetchRoute(force: true);

    // Subscribe to position changes
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

            // Auto set status to "at_pickup"
            if (deliveryStatus == "accepted" || deliveryStatus == "assigned") {
              final distanceToPickup = Geolocator.distanceBetween(
                _currentLocation!.latitude,
                _currentLocation!.longitude,
                pickupLocation.latitude,
                pickupLocation.longitude,
              );

              if (distanceToPickup < 50 && deliveryStatus != "at_pickup") {
                _setDeliveryStatus("at_pickup");
              }
            }

            // Auto switch route target pickup → dropoff
            if (routeTarget == "pickup") {
              final distanceToPickup = Geolocator.distanceBetween(
                _currentLocation!.latitude,
                _currentLocation!.longitude,
                pickupLocation.latitude,
                pickupLocation.longitude,
              );

              if (distanceToPickup < 50) {
                setState(() {
                  routeTarget = "dropoff";
                });
                _fetchRoute(force: true);
              }
            }

            // Normal throttled updates
            _fetchRoute();
          },
          onError: (e) {
            // Optionally log
          },
        );
  }

  Future<void> _moveCameraSmooth() async {
    if (_currentLocation == null || !_mapController.isCompleted) return;

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
      // Ignore failures
    }
  }

  Future<void> _fetchRoute({bool force = false}) async {
    if (_currentLocation == null) return;
    if (!force &&
        DateTime.now().difference(_lastRouteUpdate) < _routeThrottle) {
      return;
    }
    if (_isFetchingRoute) return;

    _isFetchingRoute = true;
    try {
      final origin =
          '${_currentLocation!.latitude},${_currentLocation!.longitude}';
      final LatLng currentTarget = (routeTarget == "pickup")
          ? pickupLocation
          : dropOffLocation;

      final dest = '${currentTarget.latitude},${currentTarget.longitude}';

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin&destination=$dest&mode=driving&key=$_googleApiKey',
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

      // Distance & duration per target
      try {
        final int distMeters = leg['distance']['value'] ?? 0;
        final int durSeconds = leg['duration']['value'] ?? 0;

        if (routeTarget == "pickup") {
          pickupDistanceKm = (distMeters / 1000).toStringAsFixed(1);
          pickupDuration = "${(durSeconds / 60).round()} min";
        } else {
          riderDropoffDistanceKm = (distMeters / 1000).toStringAsFixed(1);
          riderDropoffDuration = "${(durSeconds / 60).round()} min";
        }

        if (mounted) {
          setState(() {});
        }
      } catch (_) {
        // Keep previous values
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
      // Optionally log
    } finally {
      _isFetchingRoute = false;
    }
  }

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
      rotation: _finalBearing,
      flat: true,
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

  // Optional smoother tracking (not auto-started)
  void startSmoothMapTracking() {
    _positionStream = Geolocator.getPositionStream().listen((pos) {
      _currentLocation = LatLng(pos.latitude, pos.longitude);
      _isMoving = pos.speed > 1.2; // ≈ 4 km/h

      if (_isMoving && pos.heading != 0) {
        _finalBearing = _smoothRotate(_finalBearing, pos.heading);
        _updateMarkers();
      }
    });
  }

  // ---------------------------------------------------------------------------
  // Directions: Pickup → Dropoff (static)
  // ---------------------------------------------------------------------------
  Future<void> _computePickupToDropoff() async {
    final origin = '${pickupLocation.latitude},${pickupLocation.longitude}';
    final dest = '${dropOffLocation.latitude},${dropOffLocation.longitude}';

    final uri = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=$origin&destination=$dest&mode=driving&key=$_googleApiKey',
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) return;

    final data = json.decode(response.body);
    if (data['routes'] == null || data['routes'].isEmpty) return;

    final leg = data['routes'][0]['legs'][0];

    setState(() {
      dropoffDistanceKm = ((leg['distance']['value'] ?? 0) / 1000)
          .toStringAsFixed(1);
      dropoffDuration = "${((leg['duration']['value'] ?? 0) / 60).round()} min";
    });
  }

  // ---------------------------------------------------------------------------
  // Assets & styles
  // ---------------------------------------------------------------------------
  Future<void> _loadTruckIcon() async {
    final ByteData data = await rootBundle.load('assets/images/truck.png');
    final Uint8List bytes = data.buffer.asUint8List();
    final Uint8List resizedBytes = await _resizeImage(bytes, 70);

    setState(() {
      _truckIcon = BitmapDescriptor.fromBytes(resizedBytes);
    });
  }

  Future<void> _loadDropOffIcon() async {
    final ByteData data = await rootBundle.load('assets/images/drop_off.png');
    final Uint8List bytes = data.buffer.asUint8List();
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

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/konek2move_map_style.json');
  }

  // ---------------------------------------------------------------------------
  // Delivery status transitions
  // ---------------------------------------------------------------------------
  Future<void> _setDeliveryStatus(String nextStatus) async {
    if (deliveryStatus == nextStatus) return;
    if (_currentLocation == null) return;

    try {
      final res = await ApiServices().updateStatus(
        orderId: widget.order.id,
        status: nextStatus,
        lng: _currentLocation!.longitude.toString(),
        lat: _currentLocation!.latitude.toString(),
      );

      if (mounted) {
        setState(() {
          deliveryStatus = nextStatus;
        });
      }

      debugPrint("✅ Status updated to $nextStatus: ${res.message}");
    } catch (e) {
      debugPrint("❌ Failed to update status to $nextStatus: $e");
    }
  }

  Future<void> _onStartToPickup() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
      routeTarget = "pickup";
    });

    await _setDeliveryStatus("accepted");
    await _fetchRoute(force: true);

    if (mounted) {
      setState(() => isLoading = false);
    }
  }

  Future<void> _onPackageCollected() async {
    await _setDeliveryStatus("picked_up");

    setState(() {
      routeTarget = "dropoff";
    });

    await _fetchRoute(force: true);
  }

  Future<void> _onStartDropoff() async {
    await _setDeliveryStatus("en_route");
  }

  Future<void> _onCompleteDelivery() async {
    // TODO: photo + signature, then delivered
    await _setDeliveryStatus("delivered");
  }

  Future<void> _startDelivery() async {
    await _onStartToPickup();
    setState(() {
      showDriveButton = true;
    });

    setState(() => isLoading = false);
  }

  // ---------------------------------------------------------------------------
  // Chat / notifications
  // ---------------------------------------------------------------------------
  void _handleRealtimeChat(Map<String, dynamic> event, ChatProvider provider) {
    final data = event["data"];
    if (data == null) return;

    if (!(data["topic"]?.toString().contains("chat.new_message") ?? false)) {
      return;
    }

    final meta = data["meta"];
    if (meta == null) return;

    if (meta["sender_type"] != "driver") {
      provider.incrementUnread();
    }
  }

  Future<void> _callNumber(String phoneNumber) async {
    final Uri uri = Uri.parse("tel:$phoneNumber");

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Dialer failed: $e");
    }
  }

  Future<void> navigateToPickup(double lat, double lng) async {
    final Uri uri = Uri.parse("google.navigation:q=$lat,$lng&mode=d");

    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  // ---------------------------------------------------------------------------
  // Polyline decoding
  // ---------------------------------------------------------------------------
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> poly = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return poly;
  }

  // ---------------------------------------------------------------------------
  // UI helpers
  // ---------------------------------------------------------------------------
  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 48,
        width: 48,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
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
        'main': widget.order.supplierName,
        'sub': widget.order.supplierAddress,
        'distance': routeTarget == "pickup" ? pickupDistanceKm : "-",
        'duration': routeTarget == "pickup" ? pickupDuration : "-",
      },
      {
        'icon': Icons.location_on,
        'title': "Drop-off",
        'main': receiverName,
        'sub': widget.order.deliveryAddress,
        'distance': riderDropoffDistanceKm,
        'duration': riderDropoffDuration,
      },
    ];

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline icons
          Column(
            children: List.generate(details.length * 2 - 1, (i) {
              if (i.isEven) {
                return Icon(
                  details[i ~/ 2]['icon'] as IconData,
                  color: Colors.grey.shade500,
                  size: 22,
                );
              } else {
                return Container(
                  width: 2,
                  height: 60,
                  color: Colors.grey.shade300,
                );
              }
            }),
          ),
          const SizedBox(width: 14),
          // Text Section
          Expanded(
            child: Column(
              children: details
                  .map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(bottom: 16),
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
        // Title + ETA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              "$distance km • $duration",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          mainText,
          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600),
        ),
        if (subText.isNotEmpty)
          Text(
            subText,
            style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
          ),
      ],
    );
  }

  Widget _buildReceiverCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Avatar
          CircleAvatar(
            radius: 22,
            backgroundColor: kPrimaryColor.withOpacity(0.10),
            child: const Icon(Icons.person, color: Colors.black54, size: 20),
          ),
          const SizedBox(width: 12),
          // Text Section
          Expanded(
            child: Align(
              alignment: Alignment.centerLeft,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    receiverName,
                    style: const TextStyle(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    receiverAddress,
                    style: TextStyle(
                      fontSize: 13.5,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  if (receiverNote.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      receiverNote,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(width: 6),
          // Actions
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  onPressed: () {
                    _callNumber(receiverPhone);
                  },
                  icon: const Icon(Icons.phone, color: kPrimaryColor),
                  tooltip: receiverPhone,
                ),
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
                            right: 2,
                            top: 2,
                            child: Container(
                              padding: const EdgeInsets.all(4),
                              decoration: const BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                provider.unreadCount.toString(),
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
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
          ),
        ],
      ),
    );
  }

  void _showCancelSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
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
                CustomButton(
                  text: "Yes, Cancel Delivery",
                  color: kPrimaryRedColor,
                  textColor: kDefaultIconLightColor,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: "No, Keep Delivery",
                  color: kLightButtonColor,
                  textColor: kPrimaryColor,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
              ],
            ),
          ),
        );
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    final safeTop = padding.top;
    final safeBottom = padding.bottom;
    final screenHeight = MediaQuery.of(context).size.height;

    final headerHeight = safeBottom + safeTop + 24;
    final normalMapHeight = screenHeight * 0.40;
    final fullMapHeight = screenHeight - headerHeight - safeBottom;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomHomeAppBar(
        title: "Order Details",
        showTrailing: status != "delivered",
        trailingText: "Cancel",
        onLeadingTap: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: 1)),
          );
        },
        onTrailingTap: _showCancelSheet,
      ),
      body: Column(
        children: [
          Expanded(
            child: AnimatedContainer(
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
                                      target:
                                          _currentLocation ?? dropOffLocation,
                                      zoom: 14,
                                    ),
                                    buildingsEnabled: true,
                                    mapType: MapType.normal,
                                    markers: markers,
                                    polylines: polylines,
                                    myLocationEnabled: false,
                                    zoomControlsEnabled: false,
                                    myLocationButtonEnabled: false,
                                    compassEnabled: true,
                                    trafficEnabled: false,
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
                      bottom: _isFullScreen ? 150 : 70,
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
                      bottom: _isFullScreen ? 90 : 12,
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
          ),
          if (!_isFullScreen)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, safeBottom + 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isFullScreen ? null : _buildStatusButton(),
    );
  }

  // ---------------------------------------------------------------------------
  // Bottom action button
  // ---------------------------------------------------------------------------
  Widget _buildStatusButton() {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bool isThreeButtonNav = safeBottom == 0;

    if (deliveryStatus == "delivered" || deliveryStatus == "failed") {
      return const SizedBox.shrink();
    }

    String label;
    VoidCallback? onTap;
    final bool loading = isLoading;

    switch (deliveryStatus) {
      case "assigned":
      case "accepted":
        label = loading ? "Starting..." : "Start to Pickup";
        onTap = loading ? null : _startDelivery;
        break;
      case "at_pickup":
        label = "Package Collected";
        onTap = _onPackageCollected;
        break;
      case "picked_up":
        label = "Start Drop-off";
        onTap = _onStartDropoff;
        break;
      case "en_route":
        label = "Complete Delivery";
        onTap = _onCompleteDelivery;
        break;
      default:
        label = loading ? "Starting..." : "Start Delivery";
        onTap = loading ? null : _startDelivery;
    }

    return SafeArea(
      bottom: false,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        offset: _showStatusButton ? Offset.zero : const Offset(0, 1.2),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: _showStatusButton ? 1 : 0,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.10),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24),
              ),
              child: Container(
                color: Colors.white,
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  isThreeButtonNav ? 16 : safeBottom + 24,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        // Google Maps Navigation Button
                        if (showDriveButton)
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  blurRadius: 6,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            child: IconButton(
                              icon: Icon(
                                Icons.navigation,
                                color: kPrimaryColor,
                                size: 28,
                              ),
                              onPressed: () {
                                navigateToPickup(
                                  widget.order.pickupLat,
                                  widget.order.pickupLng,
                                );
                              },
                            ),
                          ),
                        // Space between buttons
                        if (showDriveButton) const SizedBox(width: 12),
                        Expanded(
                          child: CustomButton(
                            radius: 30,
                            text: label,
                            horizontalPadding: 0,
                            textColor: Colors.white,
                            color: onTap != null
                                ? kPrimaryColor
                                : Colors.grey.shade400,
                            onTap: onTap,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
