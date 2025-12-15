import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapView extends StatefulWidget {
  final LatLng initialLocation;
  final Completer<GoogleMapController> mapControllerCompleter;
  final ValueListenable<Set<Marker>> markersListenable;
  final ValueListenable<Set<Polyline>> polylinesListenable;
  final String? mapStyle;
  final void Function(GoogleMapController) onMapCreated;

  const MapView({
    super.key,
    required this.initialLocation,
    required this.mapControllerCompleter,
    required this.markersListenable,
    required this.polylinesListenable,
    required this.onMapCreated,
    this.mapStyle,
  });

  @override
  State<MapView> createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  late GoogleMapController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = null;
  }

  @override
  void dispose() {
    // Do not dispose controller here; GoogleMap owns it. If you keep a reference
    // to controller elsewhere, ensure safe lifecycle management.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<Set<Marker>>(
      valueListenable: widget.markersListenable,
      builder: (_, markers, __) {
        return ValueListenableBuilder<Set<Polyline>>(
          valueListenable: widget.polylinesListenable,
          builder: (_, polylines, __) {
            return GoogleMap(
              initialCameraPosition: CameraPosition(
                target: widget.initialLocation,
                zoom: 14,
              ),
              mapType: MapType.normal,
              markers: markers,
              polylines: polylines,
              buildingsEnabled: true,
              zoomControlsEnabled: false,
              myLocationEnabled: false,
              myLocationButtonEnabled: false,
              compassEnabled: true,
              trafficEnabled: false,
              onMapCreated: (GoogleMapController controller) async {
                _controller = controller;

                if (!widget.mapControllerCompleter.isCompleted) {
                  widget.mapControllerCompleter.complete(controller);
                }

                widget.onMapCreated(controller);
              },
            );
          },
        );
      },
    );
  }
}
