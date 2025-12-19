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
import 'dart:io';
import 'dart:ui' as ui;
import 'package:image/image.dart' as img;
import 'package:another_flushbar/flushbar.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:konek2move/core/widgets/custom_map_screen.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';
import 'package:signature/signature.dart';
import 'package:url_launcher/url_launcher.dart';

import 'package:konek2move/core/constants/app_colors.dart';
import 'package:konek2move/core/services/api_services.dart';
import 'package:konek2move/core/services/model_services.dart';
import 'package:konek2move/core/services/provider_services.dart';
import 'package:konek2move/core/widgets/custom_button.dart';
import 'package:konek2move/core/widgets/custom_home_appbar.dart';
import 'package:konek2move/ui/home/home_screen.dart';
import 'chat/order_chat_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final OrderRecord order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with TickerProviderStateMixin {
  // Throttle route requests
  static const Duration _routeThrottle = Duration(seconds: 10);

  static const double _dropoffRadiusMeters = 50;

  File? _proofImage;
  File? _signatureImage;
  final TextEditingController _photoController = TextEditingController();
  final TextEditingController _signatureController = TextEditingController();

  // Map controller and notifiers
  final Completer<GoogleMapController> _mapController = Completer();

  final ValueNotifier<bool> _mapLoaded = ValueNotifier(false);
  final ValueNotifier<Set<Marker>> _markers = ValueNotifier(const {});
  final ValueNotifier<Set<Polyline>> _polylines = ValueNotifier(const {});

  // Locations
  LatLng? _currentLocation;
  late final LatLng pickupLocation;
  late final LatLng dropOffLocation;

  BitmapDescriptor? _truckIcon;
  BitmapDescriptor? _dropOffIcon;
  BitmapDescriptor? _pickUpIcon;
  String? _mapStyle;

  StreamSubscription<Position>? _positionStream;
  StreamSubscription? _notifSub;

  // State
  bool _isFullScreen = false;
  bool _isFetchingRoute = false;
  bool isLoading = false;
  bool _isSubmitting = false;

  bool _isWithinDropoffRange() {
    if (_currentLocation == null) return false;

    final distance = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      dropOffLocation.latitude,
      dropOffLocation.longitude,
    );

    return distance <= _dropoffRadiusMeters;
  }

  DateTime _lastRouteUpdate = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime _lastCameraMove = DateTime.fromMillisecondsSinceEpoch(0);

  // Delivery state
  String routeTarget = 'pickup';
  late String deliveryStatus;

  // Distances/durations (strings used for UI)
  String pickupDistanceKm = '-';
  String pickupDuration = '-';

  String riderDropoffDistanceKm = '-';
  String riderDropoffDuration = '-';

  String dropoffDistanceKm = '-';
  String dropoffDuration = '-';

  String get uiStatus => deliveryStatus;

  // -------------------------------------------------------------------------
  // Lifecycle
  // -------------------------------------------------------------------------
  @override
  void initState() {
    super.initState();

    deliveryStatus = widget.order.status.toString().toLowerCase();
    _syncRouteTargetWithStatus();

    pickupLocation = LatLng(widget.order.pickupLat, widget.order.pickupLng);
    dropOffLocation = LatLng(
      widget.order.deliveryLat,
      widget.order.deliveryLng,
    );

    deliveryStatus = widget.order.status.toString().toLowerCase();

    // load assets/styles
    _prepareIcons();

    // compute static pickup->drop-off route
    _computePickupToDropoff().ignore();

    // initialize location (async)
    _initLocationAndMap();

    // setup realtime notifications listener (microtask to ensure context available)
    Future.microtask(_listenRealtimeNotifications);
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _notifSub?.cancel();
    _mapLoaded.dispose();
    _markers.dispose();
    _polylines.dispose();
    _photoController.dispose();
    _signatureController.dispose();
    super.dispose();
  }

  // -------------------------------------------------------------------------
  // Helpers
  // -------------------------------------------------------------------------
  Future<void> _listenRealtimeNotifications() async {
    final provider = context.read<ChatProvider>();
    try {
      _notifSub = ApiServices().listenNotifications().listen((event) {
        _handleRealtimeChat(event, provider);
      });
    } catch (e) {
      // silent
    }
  }

  // -------------------------------------------------------------------------
  // Map & location initialization
  // -------------------------------------------------------------------------
  Future<void> _initLocationAndMap() async {
    LocationPermission permission;
    try {
      permission = await Geolocator.requestPermission();
    } catch (_) {
      permission = LocationPermission.denied;
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      // Use fallback coordinates and still show map
      _currentLocation = const LatLng(14.0580, 121.3240);
      _updateMarkers(notify: true);
      _mapLoaded.value = true;
      _fetchRoute(force: true).ignore();
      return;
    }

    // Attempt an initial position with a short timeout to avoid blocking
    try {
      final pos = await Geolocator.getCurrentPosition(
        timeLimit: const Duration(seconds: 8),
      );
      _currentLocation = LatLng(pos.latitude, pos.longitude);
    } catch (_) {
      _currentLocation = const LatLng(14.0580, 121.3240);
    }

    _updateMarkers(notify: true);
    _mapLoaded.value = true;

    // initial route
    _fetchRoute(force: true).ignore();

    // subscribe to position changes with minimal overhead
    _positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 8, // reduce frequency to avoid too many updates
          ),
        ).listen(
          (Position p) {
            _currentLocation = LatLng(p.latitude, p.longitude);

            // update marker only (no full rebuild)
            _updateMarkers(notify: true);

            // smooth camera moves throttled
            _moveCameraSmooth().ignore();

            // auto transitions
            _handleAutoTransitions();

            // throttle route fetches
            _fetchRoute().ignore();
          },
          onError: (e) {
            // ignore silently in production; consider logging to remote service
          },
        );
  }

  void _handleAutoTransitions() {
    if (_currentLocation == null) return;

    final distanceToPickup = Geolocator.distanceBetween(
      _currentLocation!.latitude,
      _currentLocation!.longitude,
      pickupLocation.latitude,
      pickupLocation.longitude,
    );

    if ((deliveryStatus == 'accepted' || deliveryStatus == 'assigned') &&
        distanceToPickup < 50 &&
        deliveryStatus != 'at_pickup') {
      _setDeliveryStatus('at_pickup').ignore();
    }

    if (routeTarget == 'pickup' && distanceToPickup < 50) {
      routeTarget = 'dropoff';
      _fetchRoute(force: true).ignore();
    }
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
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Markers & icons
  // -------------------------------------------------------------------------
  Future<void> _prepareIcons() async {
    // load icons concurrently but don't block init
    _loadTruckIcon().ignore();
    _loadDropOffIcon().ignore();
    _loadPickUpIcon().ignore();
  }

  Future<void> _loadTruckIcon() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/truck.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final Uint8List resized = await _resizeImage(bytes, 70);
      _truckIcon = BitmapDescriptor.fromBytes(resized);
      _updateMarkers();
    } catch (_) {}
  }

  Future<void> _loadDropOffIcon() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/drop_off.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final Uint8List resized = await _resizeImage(bytes, 80);
      _dropOffIcon = BitmapDescriptor.fromBytes(resized);
      _updateMarkers();
    } catch (_) {}
  }

  Future<void> _loadPickUpIcon() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/pick_up.png');
      final Uint8List bytes = data.buffer.asUint8List();
      final Uint8List resized = await _resizeImage(bytes, 80);
      _pickUpIcon = BitmapDescriptor.fromBytes(resized);
      _updateMarkers();
    } catch (_) {}
  }

  Future<Uint8List> _resizeImage(Uint8List data, int targetWidth) async {
    final codec = await ui.instantiateImageCodec(
      data,
      targetWidth: targetWidth,
    );
    final frame = await codec.getNextFrame();
    final byteData = await frame.image.toByteData(
      format: ui.ImageByteFormat.png,
    );

    return byteData!.buffer.asUint8List();
  }

  void _updateMarkers({bool notify = false}) {
    if (_currentLocation == null) return;

    final rider = Marker(
      markerId: const MarkerId('rider'),
      position: _currentLocation!,
      icon:
          _truckIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Rider (You)'),
      anchor: const Offset(0.5, 0.5),
      flat: true,
      zIndex: 3,
    );

    final pickup = Marker(
      markerId: const MarkerId('pickup'),
      position: pickupLocation,
      icon:
          _pickUpIcon ??
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      infoWindow: const InfoWindow(title: 'Pick-up'),
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
    if (notify) {
      // if surrounding UI depends on setState, update there instead
      if (mounted) setState(() {});
    }
  }

  // -------------------------------------------------------------------------
  // Directions API handling (throttled)
  // -------------------------------------------------------------------------
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
      final target = routeTarget == 'pickup' ? pickupLocation : dropOffLocation;
      final dest = '${target.latitude},${target.longitude}';

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=$origin&destination=$dest&mode=driving'
        '&key=${Secrets.googleApiKey}',
      );

      final response = await http
          .get(uri)
          .timeout(
            const Duration(seconds: 12),
            onTimeout: () => http.Response('', 408),
          );

      if (response.statusCode != 200) return;

      /// 🔥 JSON PARSE OFF UI THREAD
      final parsed = await compute(parseDirectionsIsolate, response.body);
      if (parsed.isEmpty) return;

      final int distMeters = parsed['distance'];
      final int durSeconds = parsed['duration'];

      if (routeTarget == 'pickup') {
        pickupDistanceKm = (distMeters / 1000).toStringAsFixed(1);
        pickupDuration = '${(durSeconds / 60).round()} min';
      } else {
        riderDropoffDistanceKm = (distMeters / 1000).toStringAsFixed(1);
        riderDropoffDuration = '${(durSeconds / 60).round()} min';
      }

      /// 🔥 POLYLINE DECODE OFF UI THREAD
      final String encodedPolyline = parsed['polyline'] as String;

      final List<LatLng> points = await compute<String, List<LatLng>>(
        decodePolylineIsolate,
        encodedPolyline,
      );

      _polylines.value = {
        Polyline(
          polylineId: const PolylineId('route'),
          points: points,
          width: 6,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          color: kPrimaryColor,
        ),
      };

      _lastRouteUpdate = DateTime.now();
      if (mounted) setState(() {});
    } catch (_) {
      // silent
    } finally {
      _isFetchingRoute = false;
    }
  }

  Future<void> _computePickupToDropoff() async {
    try {
      final origin = '${pickupLocation.latitude},${pickupLocation.longitude}';
      final dest = '${dropOffLocation.latitude},${dropOffLocation.longitude}';

      final uri = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json?origin=$origin&destination=$dest&mode=driving&key=${Secrets.googleApiKey}',
      );

      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return;

      final data = json.decode(response.body);
      if (data['routes'] == null || (data['routes'] as List).isEmpty) return;

      final leg = data['routes'][0]['legs'][0];

      if (mounted) {
        setState(() {
          dropoffDistanceKm = ((leg['distance']?['value'] ?? 0) / 1000)
              .toStringAsFixed(1);
          dropoffDuration =
              '${((leg['duration']?['value'] ?? 0) / 60).round()} min';
        });
      }
    } catch (_) {}
  }

  // -------------------------------------------------------------------------
  // Delivery lifecycle / API
  // -------------------------------------------------------------------------
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

      if (!mounted) return;

      setState(() {
        deliveryStatus = nextStatus;
      });

      _showApiIndicator(
        title: 'Status Updated',
        message: res.message,
        success: true,
      );
    } catch (e) {
      if (!mounted) return;
      _showApiIndicator(
        title: 'Status Update Failed',
        message: e.toString(),
        success: false,
      );
    }
  }

  // Action flows
  Future<void> _onStartToPickup() async {
    if (isLoading) return;
    setState(() {
      isLoading = true;
      routeTarget = 'pickup';
    });

    await _setDeliveryStatus('accepted');
    await _fetchRoute(force: true);

    if (mounted) setState(() => isLoading = false);
  }

  Future<void> _onPackageCollected() async {
    await _setDeliveryStatus('picked_up');

    setState(() {
      routeTarget = 'dropoff';
      _lastRouteUpdate = DateTime.fromMillisecondsSinceEpoch(0);
    });

    await _fetchRoute(force: true);
  }

  Future<void> _onStartDropoff() async => _setDeliveryStatus('en_route');

  Future<void> _startDelivery() async {
    await _onStartToPickup();
  }

  Future<void> _onCompleteDelivery() async {
    if (!_isWithinDropoffRange()) {
      _showApiIndicator(
        title: "Too Far",
        message: "You must be near the customer location to complete delivery.",
        success: false,
      );
      return;
    }

    _showCompleteDeliverySheet();
  }

  Future<String> _submitCompletedDelivery() async {
    if (_proofImage == null || _signatureImage == null) {
      throw Exception("Please upload photo and signature.");
    }

    final api = ApiServices();

    final response = await api.proof(
      orderNo: widget.order.orderNo,
      recipientName: widget.order.customer!.name,
      photoItem: _proofImage!,
      signature: _signatureImage!,
    );

    if (response.retCode != "200") {
      throw Exception(response.message);
    }

    await _setDeliveryStatus('delivered');

    // ✅ return backend message dynamically
    return response.message;
  }

  // -------------------------------------------------------------------------
  // Chat / notifications
  // -------------------------------------------------------------------------
  void _handleRealtimeChat(Map<String, dynamic> event, ChatProvider provider) {
    final data = event['data'];
    if (data == null) return;

    if (!(data['topic']?.toString().contains('chat.new_message') ?? false)) {
      return;
    }

    final meta = data['meta'];
    if (meta == null) return;

    if (meta['sender_type'] != 'driver') provider.incrementUnread();
  }

  // -------------------------------------------------------------------------
  // Utilities
  // -------------------------------------------------------------------------

  void _showApiIndicator({
    required String title,
    required String message,
    required bool success,
  }) {
    Flushbar(
      title: title,
      message: message,
      duration: const Duration(seconds: 3),
      flushbarPosition: FlushbarPosition.TOP,
      backgroundColor: success ? Colors.green : Colors.red,
      icon: Icon(
        success ? Icons.check_circle : Icons.error,
        color: Colors.white,
      ),
      margin: const EdgeInsets.all(12),
      borderRadius: BorderRadius.circular(12),
    ).show(context);
  }

  void _syncRouteTargetWithStatus() {
    if (deliveryStatus == 'picked_up' || deliveryStatus == 'en_route') {
      routeTarget = 'dropoff';
    } else if (deliveryStatus == 'accepted' ||
        deliveryStatus == 'assigned' ||
        deliveryStatus == 'at_pickup') {
      routeTarget = 'pickup';
    }
  }

  Future<void> _callNumber(String phoneNumber) async {
    final Uri uri = Uri.parse('tel:$phoneNumber');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Dialer failed: $e');
    }
  }

  Future<void> navigateToPickup(double lat, double lng) async {
    final Uri uri = Uri.parse('google.navigation:q=$lat,$lng&mode=d');
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint('Navigation launch failed: $e');
    }
  }

  Future<File?> _pickImageFromCamera(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    final XFile? pickedFile = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 80,
    );

    if (pickedFile == null) return null;

    return File(pickedFile.path);
  }

  Future<File?> _openSignaturePad(BuildContext context) async {
    final SignatureController controller = SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    File? resultFile;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 5,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),

                const Text(
                  "Customer Signature",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 12),

                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Signature(
                    controller: controller,
                    backgroundColor: Colors.white,
                  ),
                ),

                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(
                      child: _dangerBtn(
                        "Clear",
                        onTap: () => controller.clear(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _primaryBtn(
                        "Save",
                        onTap: () async {
                          if (controller.isNotEmpty) {
                            final Uint8List? pngBytes = await controller
                                .toPngBytes();

                            if (pngBytes != null) {
                              final dir = await getTemporaryDirectory();
                              final filePath = path.join(
                                dir.path,
                                'signature_${DateTime.now().millisecondsSinceEpoch}.png',
                              );

                              final file = File(filePath);
                              await file.writeAsBytes(pngBytes);

                              resultFile = file;
                            }
                          }
                          Navigator.pop(context);
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    controller.dispose();
    return resultFile;
  }

  // -------------------------------------------------------------------------
  // UI builders (kept compact & efficient)
  // -------------------------------------------------------------------------

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

  Widget _fancyShimmerSkeleton() {
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

  Widget _buildShimmerButton() {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        child: IgnorePointer(
          ignoring: true, // 🚫 prevents clicking
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              height: 52,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
              ),
            ),
          ),
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
        'title': 'Pickup',
        'main': widget.order.supplierName,
        'sub': widget.order.supplierAddress,
        'distance': routeTarget == 'pickup' ? pickupDistanceKm : '-',
        'duration': routeTarget == 'pickup' ? pickupDuration : '-',
      },
      {
        'icon': Icons.location_on,
        'title': 'Drop-off',
        'main': widget.order.customer?.name ?? 'Unknown Customer',
        'sub': widget.order.deliveryAddress,
        'distance': riderDropoffDistanceKm,
        'duration': riderDropoffDuration,
      },
    ];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// TIMELINE
          Column(
            children: List.generate(details.length * 2 - 1, (i) {
              if (i.isEven) {
                return Icon(
                  details[i ~/ 2]['icon'] as IconData,
                  size: 22,
                  color: kPrimaryColor,
                );
              }
              return Container(
                width: 2,
                height: 56,
                margin: const EdgeInsets.symmetric(vertical: 4),
                color: Colors.grey.shade300,
              );
            }),
          ),

          const SizedBox(width: 16),

          /// DETAILS
          Expanded(
            child: Column(
              children: details.map((d) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 18),
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
              style: const TextStyle(
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '$distance km • $duration',
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
    final receiverName = widget.order.customer?.name ?? 'Unknown Customer';
    final receiverPhone = widget.order.contactPhone.trim();
    final receiverAddress = widget.order.deliveryAddress;
    final totalItem = widget.order.itemsCount.toString();
    final totalAmount = widget.order.totalAmount.toStringAsFixed(2);

    Widget actionIcon({
      required IconData icon,
      required VoidCallback onTap,
      Color? color,
    }) {
      return InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: (color ?? kPrimaryColor).withOpacity(0.12),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(icon, size: 20, color: color ?? kPrimaryColor),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 48,
                width: 48,
                decoration: BoxDecoration(
                  color: kPrimaryColor.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: kPrimaryColor, size: 24),
              ),
              const SizedBox(width: 14),

              /// NAME + DETAILS
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      receiverName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Receiver Details",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      receiverAddress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Delivery Address",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      receiverPhone,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Mobile Number",
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              /// ACTIONS (COLUMN)
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (receiverPhone.isNotEmpty)
                    actionIcon(
                      icon: Icons.phone,
                      onTap: () => _callNumber(receiverPhone),
                    ),

                  const SizedBox(height: 12),

                  Consumer<ChatProvider>(
                    builder: (_, provider, __) {
                      return Stack(
                        clipBehavior: Clip.none,
                        children: [
                          actionIcon(
                            icon: Icons.message,
                            onTap: () async {
                              final prefs =
                                  await SharedPreferences.getInstance();

                              if (!mounted) return; // 🔥 FIX

                              final chatId = widget.order.chat?.id ?? 0;
                              final orderNo = widget.order.orderNo;
                              final userType =
                                  prefs.getString("user_type") ?? "";
                              final driverCode =
                                  prefs.getString("driver_code") ?? "";

                              provider.clearUnread();

                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => OrderChatScreen(
                                    chatId: chatId,
                                    orderNo: orderNo,
                                    userType: userType,
                                    userCode: driverCode,
                                  ),
                                ),
                              );
                            },
                          ),

                          if (provider.unreadCount > 0)
                            Positioned(
                              right: -2,
                              top: -2,
                              child: Container(
                                padding: const EdgeInsets.all(5),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  provider.unreadCount.toString(),
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
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

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          /// TOTAL
          Row(
            children: [
              Text(
                "TOTAL AMOUNT",
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 0.6,
                  fontWeight: FontWeight.w700,
                  color: Colors.grey.shade600,
                ),
              ),
              const Spacer(),
              Text(
                "₱ $totalAmount",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: kPrimaryColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _primaryBtn(String title, {required VoidCallback onTap}) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(title),
      ),
    );
  }

  Widget _dangerBtn(String title, {required VoidCallback onTap}) {
    return SizedBox(
      height: 40,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: kPrimaryRedColor,
          elevation: 1,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: Text(title),
      ),
    );
  }

  void _showCompleteDeliverySheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) {
        return StatefulBuilder(
          builder: (sheetContext, setModalState) {
            final canSubmit =
                _photoController.text.isNotEmpty &&
                _signatureController.text.isNotEmpty;

            return SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  24,
                  16,
                  24,
                  MediaQuery.of(sheetContext).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Drag handle
                    Container(
                      width: 40,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),

                    const SizedBox(height: 16),

                    const Text(
                      "Confirm Delivery",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),

                    const SizedBox(height: 6),
                    Text(
                      "Upload proof and collect customer signature.",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),

                    const SizedBox(height: 20),

                    /// 📸 CAMERA
                    _proofTile(
                      title: "Delivery Photo",
                      hasValue: _photoController.text.isNotEmpty,
                      idleIcon: Icons.camera_alt_rounded,
                      completedIcon: Icons.photo_rounded,
                      onTap: () async {
                        final File? img = await _pickImageFromCamera(
                          sheetContext,
                        );
                        if (img != null) {
                          setModalState(() {
                            _proofImage = img;
                            _photoController.text =
                                img.path; // ✅ APPLY CONTROLLER
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    /// ✍️ SIGNATURE (FIXED TYPE)
                    _proofTile(
                      title: "Customer Signature",
                      hasValue: _signatureController.text.isNotEmpty,
                      idleIcon: Icons.edit_rounded,
                      completedIcon: Icons.draw_rounded,
                      onTap: () async {
                        final File? sigFile = await _openSignaturePad(
                          sheetContext,
                        );
                        if (sigFile != null) {
                          setModalState(() {
                            _signatureImage = sigFile;
                            _signatureController.text =
                                sigFile.path; // ✅ APPLY CONTROLLER
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 24),

                    CustomButton(
                      radius: 24,
                      text: _isSubmitting
                          ? "Submitting delivery…"
                          : "Complete Delivery",
                      color: canSubmit && !_isSubmitting
                          ? kPrimaryColor
                          : Colors.grey.shade400,
                      textColor: Colors.white,
                      onTap: (!canSubmit || _isSubmitting)
                          ? null
                          : () async {
                              setModalState(() => _isSubmitting = true);

                              try {
                                final message =
                                    await _submitCompletedDelivery();

                                if (!mounted) return;

                                // ✅ show dynamic backend message
                                // _showTopMessage(message);
                                _showApiIndicator(
                                  title: 'Status Updated',
                                  message: message,
                                  success: true,
                                );
                              } catch (e) {
                                _showApiIndicator(
                                  message: e.toString().replaceFirst(
                                    'Exception: ',
                                    '',
                                  ),
                                  success: false,
                                  title: 'Error',
                                );
                              } finally {
                                if (mounted) {
                                  setModalState(() => _isSubmitting = false);
                                }
                              }
                            },
                    ),

                    // CustomButton(
                    //   radius: 24,
                    //   text: _isSubmitting
                    //       ? "Submitting delivery…"
                    //       : "Complete Delivery",
                    //   color: canSubmit && !_isSubmitting
                    //       ? kPrimaryColor
                    //       : Colors.grey.shade400,
                    //   textColor: Colors.white,
                    //   onTap: (!canSubmit || _isSubmitting)
                    //       ? null
                    //       : () async {
                    //           setModalState(() => _isSubmitting = true);
                    //
                    //           final success = await _submitCompletedDelivery();
                    //
                    //           if (!mounted) return;
                    //
                    //
                    //           if (mounted) {
                    //             setModalState(() => _isSubmitting = false);
                    //           }
                    //         },
                    // ),
                  ],
                ),
              ),
            );
          },
        );
      },
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
                  'Cancel Delivery?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                Text(
                  'Are you sure you want to cancel this delivery request?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                ),
                const SizedBox(height: 20),
                CustomButton(
                  text: 'Yes, Cancel Delivery',
                  color: kPrimaryRedColor,
                  textColor: kDefaultIconLightColor,
                  onTap: () => Navigator.pop(context),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  text: 'No, Keep Delivery',
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

  void _navigateByStatus() {
    final bool isDropoff =
        deliveryStatus == 'picked_up' || deliveryStatus == 'en_route';

    final double lat = isDropoff
        ? widget.order.deliveryLat
        : widget.order.pickupLat;

    final double lng = isDropoff
        ? widget.order.deliveryLng
        : widget.order.pickupLng;

    navigateToPickup(lat, lng);
  }

  // -------------------------------------------------------------------------
  // Build
  // -------------------------------------------------------------------------
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
        title: 'Order Details',
        showTrailing: ![
          'accepted',
          'at_pickup',
          'picked_up',
          'en_route',
          'delivered',
        ].contains(uiStatus),
        trailingText: 'Cancel',
        onLeadingTap: () => Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(initialIndex: 1)),
        ),
        onTrailingTap: _showCancelSheet,
      ),
      body: Column(
        children: [
          _buildMap(fullMapHeight, normalMapHeight),
          if (!_isFullScreen)
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(16, 16, 16, safeBottom + 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Delivery Details',
                      style: TextStyle(
                        fontSize: 15,
                        color: Colors.black54,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: _mapLoaded,
                      builder: (_, loaded, __) => loaded
                          ? _buildReceiverCard()
                          : _fancyShimmerSkeleton(),
                    ),
                    const SizedBox(height: 12),
                    ValueListenableBuilder<bool>(
                      valueListenable: _mapLoaded,
                      builder: (_, loaded, __) => loaded
                          ? _buildDeliveryDetails()
                          : _fancyShimmerSkeleton(),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
      bottomNavigationBar: _isFullScreen
          ? null
          : ValueListenableBuilder<bool>(
              valueListenable: _mapLoaded,
              builder: (_, loaded, __) {
                return loaded ? _buildStatusButton() : _buildShimmerButton();
              },
            ),
    );
  }

  Widget _buildMap(double fullMapHeight, double normalMapHeight) {
    return Expanded(
      child: Container(
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
                    // Map is its own widget that listens to marker/polyline changes.
                    return MapView(
                      initialLocation: _currentLocation!,
                      mapControllerCompleter: _mapController,
                      markersListenable: _markers,
                      polylinesListenable: _polylines,
                      mapStyle: _mapStyle,
                      onMapCreated: (c) async {
                        if (!_mapController.isCompleted) {
                          _mapController.complete(c);
                        }
                      },
                    );
                  },
                ),
              ),

              // FULLSCREEN
              Positioned(
                top: 12,
                right: 12,
                child: _circleButton(
                  icon: _isFullScreen
                      ? Icons.fullscreen_exit
                      : Icons.fullscreen,
                  onTap: () => setState(() => _isFullScreen = !_isFullScreen),
                ),
              ),

              // ZOOM IN
              Positioned(
                right: 12,
                bottom: _isFullScreen ? 150 : 70,
                child: _circleButton(
                  icon: Icons.add,
                  onTap: () async {
                    if (_mapController.isCompleted) {
                      (await _mapController.future).animateCamera(
                        CameraUpdate.zoomIn(),
                      );
                    }
                  },
                ),
              ),

              // ZOOM OUT
              Positioned(
                right: 12,
                bottom: _isFullScreen ? 90 : 12,
                child: _circleButton(
                  icon: Icons.remove,
                  onTap: () async {
                    if (_mapController.isCompleted) {
                      (await _mapController.future).animateCamera(
                        CameraUpdate.zoomOut(),
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case "accepted":
        return Colors.blue;
      case "at_pickup":
        return Colors.orange;
      case "picked_up":
        return Colors.deepPurple;
      case "en_route":
        return Colors.teal;
      case "failed":
        return Colors.red;
      case "delivered":
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Widget _buildStatusButton() {
    final safeBottom = MediaQuery.of(context).padding.bottom;
    final bool isThreeButtonNav = safeBottom == 0;

    final bool shouldShow =
        deliveryStatus != 'delivered' && deliveryStatus != 'failed';
    if (!shouldShow) return const SizedBox.shrink();

    String label = '';
    VoidCallback? onTap;

    switch (deliveryStatus) {
      case 'assigned':
      case 'accepted':
        label = isLoading ? 'Starting...' : 'Start to Pickup';
        onTap = isLoading ? null : _startDelivery;
        break;
      case 'at_pickup':
        label = 'Package Collected';
        onTap = _onPackageCollected;
        break;
      case 'picked_up':
        label = 'Start Drop-off';
        onTap = _onStartDropoff;
        break;
      case 'en_route':
        label = 'Complete Delivery';
        onTap = _onCompleteDelivery;
        break;
      default:
        label = isLoading ? 'Starting...' : 'Start Delivery';
        onTap = isLoading ? null : _startDelivery;
    }

    return SafeArea(
      bottom: false,
      child: AnimatedSlide(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        offset: Offset.zero,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 250),
          opacity: 1,
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
                  isThreeButtonNav ? 16 : safeBottom + 16,
                ),
                child: Row(
                  children: [
                    if ([
                      'accepted',
                      'at_pickup',
                      'picked_up',
                      'en_route',
                    ].contains(uiStatus))
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
                            color: getStatusColor(
                              deliveryStatus,
                            ).withOpacity(0.9),
                            size: 28,
                          ),
                          onPressed: () => _navigateByStatus(),
                        ),
                      ),
                    if ([
                      'accepted',
                      'at_pickup',
                      'picked_up',
                      'en_route',
                    ].contains(uiStatus))
                      const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        radius: 24,
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
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _proofTile({
    required String title,
    required bool hasValue,
    required VoidCallback onTap,
    required IconData idleIcon,
    required IconData completedIcon,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            width: 1.5,
            color: hasValue ? kPrimaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              hasValue ? completedIcon : idleIcon,
              color: hasValue ? kPrimaryColor : Colors.grey,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            if (hasValue)
              const Icon(Icons.check_circle, color: kPrimaryColor, size: 20),
          ],
        ),
      ),
    );
  }
}

// ================================
// ISOLATE HELPERS (TOP LEVEL ONLY)
// ================================

List<LatLng> decodePolylineIsolate(String encoded) {
  final List<LatLng> poly = [];
  int index = 0, lat = 0, lng = 0;

  while (index < encoded.length) {
    int b, shift = 0, result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lat += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    shift = 0;
    result = 0;
    do {
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20);
    lng += (result & 1) != 0 ? ~(result >> 1) : (result >> 1);

    poly.add(LatLng(lat / 1e5, lng / 1e5));
  }

  return poly;
}

Map<String, dynamic> parseDirectionsIsolate(String body) {
  final data = json.decode(body);
  if (data == null || data['routes'] == null || data['routes'].isEmpty) {
    return {};
  }

  final route = data['routes'][0];
  final leg = route['legs'][0];

  return {
    'distance': leg['distance']['value'],
    'duration': leg['duration']['value'],
    'polyline': route['overview_polyline']['points'],
  };
}
