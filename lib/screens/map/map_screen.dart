import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();

  static const LatLng _sriLankaCenter = LatLng(7.8731, 80.7718);

  final List<_MapDestination> _destinations = const [
    _MapDestination(
      name: 'Sigiriya Rock',
      location: 'Matale District',
      position: LatLng(7.9570, 80.7603),
    ),
    _MapDestination(
      name: 'Temple of the Tooth',
      location: 'Kandy',
      position: LatLng(7.2936, 80.6413),
    ),
    _MapDestination(
      name: 'Mirissa Beach',
      location: 'Southern Province',
      position: LatLng(5.9460, 80.4580),
    ),
    _MapDestination(
      name: 'Ella Rock',
      location: 'Badulla District',
      position: LatLng(6.8583, 81.0460),
    ),
  ];

  late final Set<Marker> _markers;
  MapType _mapType = MapType.normal;

  @override
  void initState() {
    super.initState();
    _markers = _destinations
        .map(
          (destination) => Marker(
            markerId: MarkerId(destination.name),
            position: destination.position,
            infoWindow: InfoWindow(
              title: destination.name,
              snippet: destination.location,
            ),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueAzure,
            ),
          ),
        )
        .toSet();
  }

  Future<void> _focusOnDestination(_MapDestination destination) async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: destination.position, zoom: 13.5),
      ),
    );
  }

  Future<void> _resetView() async {
    final controller = await _mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _sriLankaCenter, zoom: 7),
      ),
    );
  }

  void _toggleMapType() {
    setState(() {
      _mapType = _mapType == MapType.normal ? MapType.satellite : MapType.normal;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Map', style: AppTheme.headingSmall),
        actions: [
          IconButton(
            tooltip: _mapType == MapType.normal ? 'Satellite view' : 'Normal view',
            icon: Icon(
              _mapType == MapType.normal
                  ? Icons.satellite_alt_rounded
                  : Icons.map_rounded,
              color: AppTheme.textPrimary,
            ),
            onPressed: _toggleMapType,
          ),
          IconButton(
            tooltip: 'Reset view',
            icon: const Icon(Icons.my_location_rounded, color: AppTheme.textPrimary),
            onPressed: _resetView,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppTheme.radiusLarge),
              ),
              child: GoogleMap(
                initialCameraPosition: const CameraPosition(
                  target: _sriLankaCenter,
                  zoom: 7,
                ),
                markers: _markers,
                mapType: _mapType,
                zoomControlsEnabled: false,
                myLocationButtonEnabled: false,
                onMapCreated: (controller) {
                  if (!_mapController.isCompleted) {
                    _mapController.complete(controller);
                  }
                },
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: AppTheme.surface,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Top Places', style: AppTheme.labelBold),
                const SizedBox(height: 10),
                SizedBox(
                  height: 42,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: _destinations.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final destination = _destinations[index];
                      return ActionChip(
                        label: Text(destination.name),
                        backgroundColor: AppTheme.primarySurface,
                        side: const BorderSide(color: AppTheme.divider),
                        labelStyle: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        onPressed: () => _focusOnDestination(destination),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapDestination {
  final String name;
  final String location;
  final LatLng position;

  const _MapDestination({
    required this.name,
    required this.location,
    required this.position,
  });
}
