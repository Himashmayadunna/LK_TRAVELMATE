import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import '../../models/ai_suggestion_model.dart';
import '../../utils/app_theme.dart';

class DestinationMapScreen extends StatefulWidget {
  final AISuggestion suggestion;

  const DestinationMapScreen({super.key, required this.suggestion});

  @override
  State<DestinationMapScreen> createState() => _DestinationMapScreenState();
}

class _DestinationMapScreenState extends State<DestinationMapScreen> {
  final Completer<GoogleMapController> _mapController = Completer();
  MapType _currentMapType = MapType.normal;
  bool _showInfo = true;
  bool _showingDirections = false;
  bool _loadingDirections = false;
  String? _directionError;

  // Route info
  String _distance = '';
  String _duration = '';
  String _travelMode = 'driving';

  late LatLng _destination;
  LatLng? _origin;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};

  static const String _mapsApiKey = 'AIzaSyCEzqNZBE-U_xGwm1gqogbmmoU5zc3VL48';

  @override
  void initState() {
    super.initState();
    _destination = LatLng(
      widget.suggestion.latitude,
      widget.suggestion.longitude,
    );
    _markers = {
      Marker(
        markerId: const MarkerId('destination'),
        position: _destination,
        infoWindow: InfoWindow(
          title: widget.suggestion.name,
          snippet: widget.suggestion.location,
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
      ),
    };
  }

  // ─── GET USER LOCATION ──────────────────────────────────────────────
  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _directionError = 'Location services are disabled');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() => _directionError = 'Location permission denied');
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      setState(() =>
          _directionError = 'Location permission permanently denied. '
              'Enable it in Settings.');
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  // ─── FETCH DIRECTIONS FROM GOOGLE DIRECTIONS API ────────────────────
  Future<void> _getDirections() async {
    setState(() {
      _loadingDirections = true;
      _directionError = null;
    });

    try {
      final position = await _getCurrentLocation();
      if (position == null) {
        setState(() => _loadingDirections = false);
        return;
      }

      _origin = LatLng(position.latitude, position.longitude);

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
        '?origin=${_origin!.latitude},${_origin!.longitude}'
        '&destination=${_destination.latitude},${_destination.longitude}'
        '&mode=$_travelMode'
        '&key=$_mapsApiKey',
      );

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final leg = route['legs'][0];

          // Decode polyline
          final polylinePoints = PolylinePoints();
          final points = polylinePoints
              .decodePolyline(route['overview_polyline']['points']);

          final polylineCoords =
              points.map((p) => LatLng(p.latitude, p.longitude)).toList();

          setState(() {
            _distance = leg['distance']['text'];
            _duration = leg['duration']['text'];
            _showingDirections = true;

            // Add origin marker
            _markers = {
              Marker(
                markerId: const MarkerId('origin'),
                position: _origin!,
                infoWindow: const InfoWindow(title: 'Your Location'),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueGreen),
              ),
              Marker(
                markerId: const MarkerId('destination'),
                position: _destination,
                infoWindow: InfoWindow(
                  title: widget.suggestion.name,
                  snippet: widget.suggestion.location,
                ),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueAzure),
              ),
            };

            // Draw route polyline
            _polylines = {
              Polyline(
                polylineId: const PolylineId('route'),
                points: polylineCoords,
                color: AppTheme.primary,
                width: 5,
                patterns: [PatternItem.dot, PatternItem.gap(10)],
              ),
              // Shadow polyline for depth effect
              Polyline(
                polylineId: const PolylineId('route_shadow'),
                points: polylineCoords,
                color: AppTheme.primaryDark.withValues(alpha: 0.3),
                width: 8,
              ),
            };
          });

          // Fit camera to show full route
          _fitBounds();
        } else {
          setState(() => _directionError =
              'Could not find route: ${data['status']}');
        }
      } else {
        setState(
            () => _directionError = 'Failed to fetch directions');
      }
    } catch (e) {
      debugPrint('Directions error: $e');
      setState(() => _directionError = 'Error getting directions: $e');
    }

    setState(() => _loadingDirections = false);
  }

  // ─── FIT MAP TO SHOW FULL ROUTE ─────────────────────────────────────
  Future<void> _fitBounds() async {
    if (_origin == null) return;
    final controller = await _mapController.future;

    final bounds = LatLngBounds(
      southwest: LatLng(
        _origin!.latitude < _destination.latitude
            ? _origin!.latitude
            : _destination.latitude,
        _origin!.longitude < _destination.longitude
            ? _origin!.longitude
            : _destination.longitude,
      ),
      northeast: LatLng(
        _origin!.latitude > _destination.latitude
            ? _origin!.latitude
            : _destination.latitude,
        _origin!.longitude > _destination.longitude
            ? _origin!.longitude
            : _destination.longitude,
      ),
    );

    controller.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  // ─── OPEN GOOGLE MAPS FOR TURN‑BY‑TURN NAV ─────────────────────────
  Future<void> _openInGoogleMaps() async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1'
      '&destination=${_destination.latitude},${_destination.longitude}'
      '&destination_place_id=${Uri.encodeComponent(widget.suggestion.name)}'
      '&travelmode=$_travelMode',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  // ─── CLEAR DIRECTIONS ───────────────────────────────────────────────
  void _clearDirections() {
    setState(() {
      _showingDirections = false;
      _polylines = {};
      _markers = {
        Marker(
          markerId: const MarkerId('destination'),
          position: _destination,
          infoWindow: InfoWindow(
            title: widget.suggestion.name,
            snippet: widget.suggestion.location,
          ),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        ),
      };
      _distance = '';
      _duration = '';
      _directionError = null;
    });
    _goToDestination();
  }

  void _toggleMapType() {
    setState(() {
      _currentMapType = _currentMapType == MapType.normal
          ? MapType.satellite
          : _currentMapType == MapType.satellite
              ? MapType.terrain
              : MapType.normal;
    });
  }

  Future<void> _goToDestination() async {
    final controller = await _mapController.future;
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _destination, zoom: 14, tilt: 45, bearing: 30),
      ),
    );
  }

  String get _mapTypeLabel {
    switch (_currentMapType) {
      case MapType.normal:
        return 'Normal';
      case MapType.satellite:
        return 'Satellite';
      case MapType.terrain:
        return 'Terrain';
      default:
        return 'Normal';
    }
  }

  IconData get _mapTypeIcon {
    switch (_currentMapType) {
      case MapType.normal:
        return Icons.map_rounded;
      case MapType.satellite:
        return Icons.satellite_alt_rounded;
      case MapType.terrain:
        return Icons.terrain_rounded;
      default:
        return Icons.map_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // ─── Google Map ─────────────────────────────────────────────
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _destination,
              zoom: 13,
            ),
            markers: _markers,
            polylines: _polylines,
            mapType: _currentMapType,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            compassEnabled: true,
            mapToolbarEnabled: false,
            onMapCreated: (controller) {
              _mapController.complete(controller);
            },
          ),

          // ─── Top Bar ────────────────────────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).padding.top + 8,
                left: 12,
                right: 12,
                bottom: 12,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.6),
                    Colors.transparent,
                  ],
                ),
              ),
              child: Row(
                children: [
                  _circleButton(
                    icon: Icons.arrow_back_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.suggestion.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            shadows: [
                              Shadow(blurRadius: 8, color: Colors.black54),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          widget.suggestion.location,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            shadows: const [
                              Shadow(blurRadius: 8, color: Colors.black54),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                    ),
                    child: Text(
                      widget.suggestion.category,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ─── Right Side Controls ────────────────────────────────────
          Positioned(
            right: 14,
            top: MediaQuery.of(context).padding.top + 80,
            child: Column(
              children: [
                _controlButton(
                  icon: _mapTypeIcon,
                  label: _mapTypeLabel,
                  onTap: _toggleMapType,
                ),
                const SizedBox(height: 10),
                _controlButton(
                  icon: Icons.my_location_rounded,
                  label: 'Center',
                  onTap: _showingDirections ? _fitBounds : _goToDestination,
                ),
                const SizedBox(height: 10),
                _controlButton(
                  icon: _showInfo
                      ? Icons.info_rounded
                      : Icons.info_outline_rounded,
                  label: 'Info',
                  onTap: () => setState(() => _showInfo = !_showInfo),
                ),
                const SizedBox(height: 10),
                // Directions button
                _controlButton(
                  icon: _showingDirections
                      ? Icons.close_rounded
                      : Icons.directions_rounded,
                  label: _showingDirections ? 'Clear' : 'Route',
                  onTap: _showingDirections ? _clearDirections : _getDirections,
                  highlight: !_showingDirections,
                ),
              ],
            ),
          ),

          // ─── Directions Loading Overlay ──────────────────────────────
          if (_loadingDirections)
            Positioned.fill(
              child: Container(
                color: Colors.black26,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 28, vertical: 20),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusLarge),
                      boxShadow: AppTheme.softShadow,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const CircularProgressIndicator(strokeWidth: 3),
                        const SizedBox(height: 14),
                        Text(
                          'Finding route...',
                          style: AppTheme.bodyMedium
                              .copyWith(fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

          // ─── Direction Error Snackbar ────────────────────────────────
          if (_directionError != null)
            Positioned(
              top: MediaQuery.of(context).padding.top + 80,
              left: 20,
              right: 80,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.error,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
                  boxShadow: AppTheme.softShadow,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.error_outline,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _directionError!,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () =>
                          setState(() => _directionError = null),
                      child: const Icon(Icons.close,
                          color: Colors.white70, size: 18),
                    ),
                  ],
                ),
              ),
            ),

          // ─── Route Info Banner (when showing directions) ────────────
          if (_showingDirections && _distance.isNotEmpty)
            Positioned(
              top: MediaQuery.of(context).padding.top + 75,
              left: 14,
              child: _buildRouteInfoBanner(),
            ),

          // ─── Bottom Info Panel ──────────────────────────────────────
          if (_showInfo)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildInfoPanel(),
            ),
        ],
      ),
    );
  }

  // ─── ROUTE INFO BANNER ──────────────────────────────────────────────
  Widget _buildRouteInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        boxShadow: AppTheme.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.directions_rounded,
                    color: Colors.white, size: 16),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _duration,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Text(
                    _distance,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Travel mode selector
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              _travelModeChip('driving', Icons.directions_car_rounded),
              const SizedBox(width: 6),
              _travelModeChip('transit', Icons.directions_bus_rounded),
              const SizedBox(width: 6),
              _travelModeChip('walking', Icons.directions_walk_rounded),
            ],
          ),
          const SizedBox(height: 8),
          // Open in Google Maps button
          GestureDetector(
            onTap: _openInGoogleMaps,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.navigation_rounded,
                      color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text(
                    'Start Navigation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _travelModeChip(String mode, IconData icon) {
    final isActive = _travelMode == mode;
    return GestureDetector(
      onTap: () {
        setState(() => _travelMode = mode);
        _getDirections();
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive
              ? AppTheme.primary
              : AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          size: 18,
          color: isActive ? Colors.white : AppTheme.textSecondary,
        ),
      ),
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white24),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }

  Widget _controlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool highlight = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: highlight ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
          boxShadow: AppTheme.softShadow,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: highlight ? Colors.white : AppTheme.primary, size: 22),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w600,
                color: highlight ? Colors.white : AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoPanel() {
    final suggestion = widget.suggestion;
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppTheme.radiusXLarge),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.divider,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name + Location row
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: AppTheme.primaryGradient,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMedium),
                      ),
                      child: const Icon(Icons.place_rounded,
                          color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            suggestion.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.location_on,
                                  size: 13, color: AppTheme.primaryLight),
                              const SizedBox(width: 3),
                              Text(
                                suggestion.location,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Description
                Text(
                  suggestion.description,
                  style: AppTheme.bodyMedium.copyWith(height: 1.4),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 14),

                // Info badges row
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _infoBadge(
                        Icons.attach_money_rounded,
                        '\$${suggestion.estimatedCostPerDay.toInt()}/day',
                        AppTheme.success,
                      ),
                      const SizedBox(width: 8),
                      _infoBadge(
                        Icons.calendar_today_rounded,
                        suggestion.bestTimeToVisit,
                        AppTheme.primary,
                      ),
                      const SizedBox(width: 8),
                      _infoBadge(
                        Icons.category_rounded,
                        suggestion.category,
                        AppTheme.gold,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Directions button row
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: _showingDirections
                            ? _clearDirections
                            : _getDirections,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          decoration: BoxDecoration(
                            gradient: _showingDirections
                                ? null
                                : AppTheme.primaryGradient,
                            color: _showingDirections
                                ? AppTheme.primarySurface
                                : null,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusMedium),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                _showingDirections
                                    ? Icons.close_rounded
                                    : Icons.directions_rounded,
                                color: _showingDirections
                                    ? AppTheme.primary
                                    : Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                _showingDirections
                                    ? 'Clear Route'
                                    : 'Get Directions',
                                style: TextStyle(
                                  color: _showingDirections
                                      ? AppTheme.primary
                                      : Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: _openInGoogleMaps,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          color: AppTheme.success,
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMedium),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.navigation_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 6),
                            Text(
                              'Navigate',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                // Coordinates
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.gps_fixed_rounded,
                          size: 12, color: AppTheme.textHint),
                      const SizedBox(width: 4),
                      Text(
                        '${suggestion.latitude.toStringAsFixed(4)}, ${suggestion.longitude.toStringAsFixed(4)}',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppTheme.textHint,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
        ],
      ),
    );
  }

  Widget _infoBadge(IconData icon, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
