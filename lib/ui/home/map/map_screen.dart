// import 'dart:async';
// import 'dart:convert';
// import 'dart:ui' as ui;
// import 'package:flutter/material.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:geolocator/geolocator.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:http/http.dart' as http;
// import 'package:flutter/services.dart';
// import 'package:shimmer/shimmer.dart';

// class MapScreen extends StatefulWidget {
//   const MapScreen({super.key});

//   @override
//   State<MapScreen> createState() => _MapScreenState();
// }

// class _MapScreenState extends State<MapScreen> {
//   GoogleMapController? mapController;
//   LatLng? _currentPosition;
//   final Set<Marker> _markers = {};
//   final Set<Polyline> _polylines = {};
//   bool _locationGranted = false;
//   BitmapDescriptor? riderIcon;
//   Timer? _debounce;

//   double distanceKm = 0.0;
//   String estimatedTime = "";
//   String _mapStyle = '';

//   // Search
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> _suggestions = [];

//   @override
//   void initState() {
//     super.initState();
//     _checkPermissions();
//     _loadRiderIcon();
//     _loadMapStyle();
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     _debounce?.cancel();
//     super.dispose();
//   }

//   Future<void> _loadMapStyle() async {
//     _mapStyle = await rootBundle.loadString('assets/konek2move_map_style.json');
//   }

//   Future<void> _loadRiderIcon() async {
//     try {
//       final ByteData data = await rootBundle.load('assets/images/rider.png');
//       final codec = await ui.instantiateImageCodec(
//         data.buffer.asUint8List(),
//         targetWidth: 150,
//       );
//       final frame = await codec.getNextFrame();
//       final resizedImage = await frame.image.toByteData(
//         format: ui.ImageByteFormat.png,
//       );

//       setState(() {
//         riderIcon = BitmapDescriptor.fromBytes(
//           resizedImage!.buffer.asUint8List(),
//         );
//       });
//     } catch (e) {
//       debugPrint("Failed to load rider icon: $e");
//     }
//   }

//   Future<void> _checkPermissions() async {
//     final status = await Permission.locationWhenInUse.request();
//     if (status.isGranted) {
//       setState(() => _locationGranted = true);
//       await _getCurrentLocation();
//     } else {
//       openAppSettings();
//     }
//   }

//   Future<void> _getCurrentLocation() async {
//     try {
//       final position = await Geolocator.getCurrentPosition(
//         desiredAccuracy: LocationAccuracy.high,
//       );

//       setState(() {
//         _currentPosition = LatLng(position.latitude, position.longitude);
//       });

//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(_currentPosition!, 14),
//       );

//       _markers.add(
//         Marker(
//           markerId: const MarkerId('rider'),
//           position: _currentPosition!,
//           icon: riderIcon ?? BitmapDescriptor.defaultMarker,
//           infoWindow: const InfoWindow(title: "Your Location"),
//         ),
//       );
//       setState(() {});
//     } catch (e) {
//       debugPrint("Get location error: $e");
//     }
//   }

//   Future<void> _getSuggestions(String query) async {
//     if (query.length < 3) {
//       setState(() => _suggestions = []);
//       return;
//     }

//     final url =
//         'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&components=country:ph&key=AIzaSyA4eJv1jVmJWrTdOO6SOsEGirFKueKRg98';

//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'OK') {
//           setState(() {
//             _suggestions = (data['predictions'] as List).map((p) {
//               return {
//                 'description': p['description']?.toString() ?? '',
//                 'place_id': p['place_id']?.toString() ?? '',
//               };
//             }).toList();
//           });
//         } else {
//           setState(() => _suggestions = []);
//         }
//       } else {
//         setState(() => _suggestions = []);
//       }
//     } catch (e) {
//       debugPrint('Error fetching suggestions: $e');
//       setState(() => _suggestions = []);
//     }
//   }

//   Future<void> _searchLocation(Map<String, dynamic> place) async {
//     _suggestions.clear();
//     FocusScope.of(context).unfocus();

//     final lat = double.parse(place['lat']);
//     final lon = double.parse(place['lon']);
//     final target = LatLng(lat, lon);

//     mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 15));

//     _markers.removeWhere((m) => m.markerId.value == 'search_place');
//     _markers.add(
//       Marker(
//         markerId: const MarkerId('search_place'),
//         position: target,
//         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
//         infoWindow: InfoWindow(title: place['display_name'] ?? ''),
//       ),
//     );

//     if (_currentPosition != null) {
//       final routePoints = await _getRoutePoints(_currentPosition!, target);
//       _polylines.clear();
//       if (routePoints.isNotEmpty) {
//         _polylines.add(
//           Polyline(
//             polylineId: const PolylineId('route'),
//             color: Colors.green,
//             width: 6,
//             points: routePoints,
//           ),
//         );
//       }
//       setState(() {});
//     }
//   }

//   Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
//     final url =
//         'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,name&key=AIzaSyA4eJv1jVmJWrTdOO6SOsEGirFKueKRg98';

//     try {
//       final response = await http.get(Uri.parse(url));
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         if (data['status'] == 'OK') {
//           final location = data['result']['geometry']['location'];
//           return {
//             'lat': location['lat'].toString(),
//             'lon': location['lng'].toString(),
//             'display_name': data['result']['name'] ?? '',
//           };
//         }
//       }
//     } catch (e) {
//       debugPrint('Error fetching place details: $e');
//     }
//     return null;
//   }

//   Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng dest) async {
//     final url = Uri.parse(
//       'https://router.project-osrm.org/route/v1/driving/'
//       '${origin.longitude},${origin.latitude};${dest.longitude},${dest.latitude}'
//       '?overview=full&geometries=geojson',
//     );

//     final response = await http.get(url);
//     final data = jsonDecode(response.body);

//     final route = data['routes'][0];
//     distanceKm = route['distance'] / 1000;
//     estimatedTime = "${(route['duration'] / 60).round()} min";

//     final coords = route['geometry']['coordinates'];
//     return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
//   }

//   void _onSearchChanged(String query) {
//     if (_debounce?.isActive ?? false) _debounce!.cancel();

//     _debounce = Timer(const Duration(milliseconds: 500), () {
//       if (query.isNotEmpty) _getSuggestions(query);
//     });
//   }

//   void _centerToCurrentLocation() {
//     if (_currentPosition != null) {
//       mapController?.animateCamera(
//         CameraUpdate.newLatLngZoom(_currentPosition!, 16),
//       );
//     }
//   }

//   void _onMapCreated(GoogleMapController controller) {
//     mapController = controller;
//     mapController!.setMapStyle(_mapStyle);
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       body: !_locationGranted || _currentPosition == null
//           ? Center(child: _buildMapShimmer())
//           : Stack(
//               children: [
//                 // ----------------------------
//                 // 1. GOOGLE MAP (FULLSCREEN)
//                 // ----------------------------
//                 GoogleMap(
//                   onMapCreated: _onMapCreated,
//                   initialCameraPosition: CameraPosition(
//                     target: _currentPosition!,
//                     zoom: 14,
//                   ),
//                   markers: _markers,
//                   polylines: _polylines,
//                   myLocationEnabled: true,
//                   myLocationButtonEnabled: false,
//                   zoomControlsEnabled: true,
//                 ),

//                 // ----------------------------
//                 // 2. SEARCH BAR (WITH CLEAR FUNCTION & AUTO-CLOSE)
//                 // ----------------------------
//                 Positioned(
//                   top: 16,
//                   left: 16,
//                   right: 16,
//                   child: Material(
//                     elevation: 4,
//                     borderRadius: BorderRadius.circular(12),
//                     child: Container(
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: TextField(
//                         controller: _searchController,
//                         onChanged: (value) {
//                           _onSearchChanged(value);
//                           setState(() {
//                             if (value.isEmpty) _suggestions = [];
//                           });
//                         },
//                         decoration: InputDecoration(
//                           hintText: "Search destination...",
//                           prefixIcon: const Icon(Icons.search),
//                           suffixIcon: _searchController.text.isNotEmpty
//                               ? IconButton(
//                                   icon: const Icon(Icons.clear),
//                                   onPressed: () {
//                                     _searchController.clear();
//                                     setState(() => _suggestions = []);
//                                   },
//                                 )
//                               : null,
//                           border: InputBorder.none,
//                           contentPadding: const EdgeInsets.symmetric(
//                             vertical: 15,
//                             horizontal: 16,
//                           ),
//                         ),
//                         style: const TextStyle(fontSize: 16),
//                       ),
//                     ),
//                   ),
//                 ),

//                 // ----------------------------
//                 // 3. SUGGESTIONS DROPDOWN
//                 // ----------------------------
//                 if (_suggestions.isNotEmpty)
//                   Positioned(
//                     top: 80,
//                     left: 16,
//                     right: 16,
//                     child: Material(
//                       elevation: 4,
//                       borderRadius: BorderRadius.circular(12),
//                       color: Colors.white,
//                       child: ConstrainedBox(
//                         constraints: BoxConstraints(
//                           maxHeight: MediaQuery.of(context).size.height * 0.4,
//                         ),
//                         child: ListView.builder(
//                           padding: EdgeInsets.zero,
//                           itemCount: _suggestions.length,
//                           itemBuilder: (context, index) {
//                             final place = _suggestions[index];
//                             final name = place['description'] ?? 'Unknown';

//                             return ListTile(
//                               title: Text(name),
//                               onTap: () async {
//                                 final details = await _getPlaceDetails(
//                                   place['place_id'],
//                                 );
//                                 if (details != null) {
//                                   _searchLocation(details);

//                                   // Update TextField and move cursor to end
//                                   _searchController.text =
//                                       details['display_name'] ?? '';
//                                   _searchController.selection =
//                                       TextSelection.fromPosition(
//                                         TextPosition(
//                                           offset: _searchController.text.length,
//                                         ),
//                                       );

//                                   // Clear suggestions to close dropdown
//                                   setState(() => _suggestions = []);
//                                 }
//                               },
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ),

//                 // ----------------------------
//                 // 4. MY LOCATION BUTTON
//                 // ----------------------------
//                 Positioned(
//                   top: _suggestions.isEmpty ? 80 : -200,
//                   right: 16,
//                   child: _suggestions.isNotEmpty
//                       ? const SizedBox.shrink()
//                       : FloatingActionButton(
//                           mini: true,
//                           backgroundColor: Colors.white,
//                           onPressed: _centerToCurrentLocation,
//                           child: Icon(
//                             Icons.my_location,
//                             color: Colors.green[800],
//                           ),
//                         ),
//                 ),

//                 // ----------------------------
//                 // 5. DISTANCE & TIME CARD
//                 // ----------------------------
//                 if (distanceKm > 0)
//                   Positioned(
//                     bottom: 25,
//                     left: 16,
//                     right: 16,
//                     child: Container(
//                       padding: const EdgeInsets.symmetric(
//                         vertical: 12,
//                         horizontal: 18,
//                       ),
//                       decoration: BoxDecoration(
//                         color: Colors.white,
//                         borderRadius: BorderRadius.circular(16),
//                         boxShadow: const [
//                           BoxShadow(
//                             color: Colors.black26,
//                             blurRadius: 8,
//                             offset: Offset(0, 3),
//                           ),
//                         ],
//                       ),
//                       child: Row(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           Icon(Icons.route, color: Colors.green[700], size: 22),
//                           const SizedBox(width: 8),
//                           Text("${distanceKm.toStringAsFixed(2)} km"),
//                           const SizedBox(width: 16),
//                           Icon(Icons.timer, color: Colors.green[700], size: 22),
//                           const SizedBox(width: 8),
//                           Text(estimatedTime),
//                         ],
//                       ),
//                     ),
//                   ),
//               ],
//             ),
//     );
//   }

//   Widget _buildMapShimmer() {
//     return Shimmer.fromColors(
//       baseColor: Colors.grey.shade300,
//       highlightColor: Colors.grey.shade100,
//       child: Container(
//         width: double.infinity,
//         height: double.infinity,
//         color: Colors.grey.shade300,
//         child: const Center(
//           child: Icon(Icons.map, size: 80, color: Colors.white70),
//         ),
//       ),
//     );
//   }
// }

import 'dart:async';
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng? _currentPosition;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  bool _locationGranted = false;
  BitmapDescriptor? riderIcon;
  Timer? _debounce;

  double distanceKm = 0.0;
  String estimatedTime = "";
  String _mapStyle = '';

  // Search
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _suggestions = [];

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _loadRiderIcon();
    _loadMapStyle();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  Future<void> _loadMapStyle() async {
    _mapStyle = await rootBundle.loadString('assets/konek2move_map_style.json');
  }

  Future<void> _loadRiderIcon() async {
    try {
      final ByteData data = await rootBundle.load('assets/images/rider.png');
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(),
        targetWidth: 150,
      );
      final frame = await codec.getNextFrame();
      final resizedImage = await frame.image.toByteData(
        format: ui.ImageByteFormat.png,
      );

      setState(() {
        riderIcon = BitmapDescriptor.fromBytes(
          resizedImage!.buffer.asUint8List(),
        );
      });
    } catch (e) {
      debugPrint("Failed to load rider icon: $e");
    }
  }

  Future<void> _checkPermissions() async {
    final status = await Permission.locationWhenInUse.request();
    if (status.isGranted) {
      setState(() => _locationGranted = true);
      await _getCurrentLocation();
    } else {
      openAppSettings();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });

      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 14),
      );

      _markers.add(
        Marker(
          markerId: const MarkerId('rider'),
          position: _currentPosition!,
          icon: riderIcon ?? BitmapDescriptor.defaultMarker,
          infoWindow: const InfoWindow(title: "Your Location"),
        ),
      );
      setState(() {});
    } catch (e) {
      debugPrint("Get location error: $e");
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (query.isNotEmpty) _getSuggestions(query);
    });
  }

  Future<void> _getSuggestions(String query) async {
    if (query.length < 3) {
      setState(() => _suggestions = []);
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&components=country:ph&key=AIzaSyA4eJv1jVmJWrTdOO6SOsEGirFKueKRg98';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          setState(() {
            _suggestions = (data['predictions'] as List).map((p) {
              return {
                'description': p['description'] ?? '',
                'place_id': p['place_id'] ?? '',
              };
            }).toList();
          });
        } else {
          setState(() => _suggestions = []);
        }
      } else {
        setState(() => _suggestions = []);
      }
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      setState(() => _suggestions = []);
    }
  }

  Future<Map<String, dynamic>?> _getPlaceDetails(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&fields=geometry,name&key=AIzaSyA4eJv1jVmJWrTdOO6SOsEGirFKueKRg98';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final location = data['result']['geometry']['location'];
          return {
            'lat': location['lat'].toString(),
            'lon': location['lng'].toString(),
            'display_name': data['result']['name'] ?? '',
          };
        }
      }
    } catch (e) {
      debugPrint('Error fetching place details: $e');
    }
    return null;
  }

  Future<List<LatLng>> _getRoutePoints(LatLng origin, LatLng dest) async {
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};${dest.longitude},${dest.latitude}'
      '?overview=full&geometries=geojson',
    );

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    final route = data['routes'][0];
    distanceKm = route['distance'] / 1000;
    estimatedTime = "${(route['duration'] / 60).round()} min";

    final coords = route['geometry']['coordinates'];
    return coords.map<LatLng>((c) => LatLng(c[1], c[0])).toList();
  }

  Future<void> _searchLocation(Map<String, dynamic> place) async {
    FocusScope.of(context).unfocus();
    _suggestions.clear();

    final lat = double.tryParse(place['lat'] ?? '');
    final lon = double.tryParse(place['lon'] ?? '');
    if (lat == null || lon == null) return;

    final target = LatLng(lat, lon);

    mapController?.animateCamera(CameraUpdate.newLatLngZoom(target, 15));

    _markers.removeWhere((m) => m.markerId.value == 'search_place');
    _markers.add(
      Marker(
        markerId: const MarkerId('search_place'),
        position: target,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        infoWindow: InfoWindow(title: place['display_name'] ?? ''),
      ),
    );

    if (_currentPosition != null) {
      final routePoints = await _getRoutePoints(_currentPosition!, target);
      _polylines.clear();
      if (routePoints.isNotEmpty) {
        _polylines.add(
          Polyline(
            polylineId: const PolylineId('route'),
            color: Colors.green,
            width: 6,
            points: routePoints,
          ),
        );
      }
    }

    setState(() {
      _searchController.text = place['display_name'] ?? '';
      _searchController.selection = TextSelection.fromPosition(
        TextPosition(offset: _searchController.text.length),
      );
    });
  }

  void _centerToCurrentLocation() {
    if (_currentPosition != null) {
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_currentPosition!, 16),
      );
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    mapController!.setMapStyle(_mapStyle);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: !_locationGranted || _currentPosition == null
          ? _buildMapShimmer()
          : Stack(
              children: [
                // GOOGLE MAP
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition!,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: true,
                ),

                // SEARCH BAR
                Positioned(
                  top: 16,
                  left: 16,
                  right: 16,
                  child: Material(
                    elevation: 4,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        controller: _searchController,
                        onChanged: _onSearchChanged,
                        decoration: InputDecoration(
                          hintText: "Search destination...",
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    setState(() => _suggestions = []);
                                  },
                                )
                              : null,
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 15,
                            horizontal: 16,
                          ),
                        ),
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ),

                // SUGGESTIONS DROPDOWN
                if (_suggestions.isNotEmpty)
                  Positioned(
                    top: 72,
                    left: 16,
                    right: 16,
                    child: Material(
                      elevation: 4,
                      borderRadius: BorderRadius.circular(12),
                      color: Colors.white,
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxHeight: MediaQuery.of(context).size.height * 0.4,
                        ),
                        child: ListView.builder(
                          padding: EdgeInsets.zero,
                          itemCount: _suggestions.length,
                          itemBuilder: (context, index) {
                            final place = _suggestions[index];
                            final name = place['description'] ?? 'Unknown';

                            return ListTile(
                              title: Text(name),
                              onTap: () async {
                                final details = await _getPlaceDetails(
                                  place['place_id'],
                                );
                                if (details != null) {
                                  await _searchLocation(details);
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                // MY LOCATION BUTTON
                Positioned(
                  top: _suggestions.isEmpty ? 80 : -200,
                  right: 16,
                  child: FloatingActionButton(
                    mini: true,
                    backgroundColor: Colors.white,
                    onPressed: _centerToCurrentLocation,
                    child: Icon(Icons.my_location, color: Colors.green[800]),
                  ),
                ),

                // DISTANCE & TIME CARD
                if (distanceKm > 0)
                  Positioned(
                    bottom: 25,
                    left: 16,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 8,
                            offset: Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.route, color: Colors.green[700], size: 22),
                          const SizedBox(width: 8),
                          Text("${distanceKm.toStringAsFixed(2)} km"),
                          const SizedBox(width: 16),
                          Icon(Icons.timer, color: Colors.green[700], size: 22),
                          const SizedBox(width: 8),
                          Text(estimatedTime),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
    );
  }

  Widget _buildMapShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.grey.shade300,
        child: const Center(
          child: Icon(Icons.map, size: 80, color: Colors.white70),
        ),
      ),
    );
  }
}
