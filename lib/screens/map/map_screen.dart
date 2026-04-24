import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/app_theme.dart';

const String _googleApiKey = 'AIzaSyDi5dcWP-ZQYSoO8S0j3Nq0rM0YK6i-KkU';

class MapScreen extends StatefulWidget {
  final String? initialQuery;

  const MapScreen({super.key, this.initialQuery});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  final TextEditingController _searchController = TextEditingController();

  // Sri Lanka center coordinates
  static const LatLng _sriLankaCenter = LatLng(7.8731, 80.7718);
  static const double _initialZoom = 6.5;

  // ─── Travel Locations ─────
  final List<TravelLocation> travelLocations = [
    TravelLocation(id: '1', name: 'Sigiriya Rock', latitude: 7.9569, longitude: 80.7597, description: 'Ancient rock fortress and UNESCO World Heritage Site with stunning frescoes and panoramic views over the jungle.', category: 'Historical', shortName: 'Sigiriya Rock'),
    TravelLocation(id: '2', name: 'Temple of the Tooth', latitude: 6.9271, longitude: 80.6314, description: 'Sacred Buddhist temple in Kandy housing the relic of the tooth of the Buddha. A major pilgrimage site.', category: 'Religious', shortName: 'Temple of Tooth'),
    TravelLocation(id: '3', name: 'Mirissa Beach', latitude: 5.9425, longitude: 80.4730, description: 'Popular beach town on the southern coast, famous for whale watching and stunning sunsets.', category: 'Beach', shortName: 'Mirissa'),
    TravelLocation(id: '4', name: 'Ella Rock', latitude: 6.8568, longitude: 81.0486, description: 'Scenic hiking destination in the hill country with panoramic views over tea plantations and valleys.', category: 'Nature', shortName: 'Ella Rock'),
    TravelLocation(id: '5', name: 'Galle Fort', latitude: 6.0329, longitude: 80.2168, description: 'Historic coastal fort built by the Portuguese in the 16th century with charming colonial architecture.', category: 'Historical', shortName: 'Galle Fort'),
    TravelLocation(id: '6', name: "Adam's Peak", latitude: 6.8095, longitude: 80.8009, description: 'Sacred mountain with a pilgrimage trail to Sri Pada. A site of worship for Buddhists, Hindus, Muslims and Christians.', category: 'Religious', shortName: "Adam's Peak"),
    TravelLocation(id: '7', name: 'Nuwara Eliya', latitude: 6.9497, longitude: 80.7850, description: 'Charming hill station in the central highlands known for its cool climate, tea estates and colonial buildings.', category: 'Hill Station', shortName: 'Nuwara Eliya'),
    TravelLocation(id: '8', name: 'Colombo City', latitude: 6.9271, longitude: 79.8612, description: 'The vibrant capital city blending colonial heritage with modern attractions, markets and waterfront promenades.', category: 'City', shortName: 'Colombo'),
  ];

  // All unique categories for filter chips
  List<String> get _categories {
    final cats = travelLocations.map((l) => l.category).toSet().toList();
    cats.sort();
    return cats;
  }

  String? _selectedCategory; // null = show all

  List<TravelLocation> get _filteredLocations {
    if (_selectedCategory == null) return travelLocations;
    return travelLocations.where((l) => l.category == _selectedCategory).toList();
  }

  // ─── Map State ─────
  late Set<Marker> markers;
  TravelLocation? selectedLocation;

  // ─── Navigation State ───
  Set<Polyline> _polylines = {};
  List<NavigationStep> _navigationSteps = [];
  bool _isLoadingRoute = false;
  bool _showNavigationPanel = false;
  TravelLocation? _originLocation;
  String _travelMode = 'driving';
  String _routeSummary = '';
  int _currentStepIndex = 0;
  String _originMode = 'gps'; // 'gps' | 'location'

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // ─── Markers ──────

  void _initializeMarkers() {
    markers = travelLocations.map((location) {
      return Marker(
        markerId: MarkerId(location.id),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(title: location.name, snippet: location.description),
        onTap: () => _zoomToLocation(location),
      );
    }).toSet();
  }

  // ─── Camera ─────

  void _zoomToLocation(TravelLocation location) {
    setState(() => selectedLocation = location);
    if (kIsWeb) {
      _showLocationDetails(location);
      return;
    }
    final controller = mapController;
    if (controller == null) return;
    // Matches guide: zooms to 15.5x on selection
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: LatLng(location.latitude, location.longitude), zoom: 15.5),
      ),
    );
    _showLocationDetails(location);
  }

  void _resetToSriLanka() {
    final controller = mapController;
    if (controller == null) {
      setState(() => selectedLocation = null);
      return;
    }
    controller.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(target: _sriLankaCenter, zoom: _initialZoom),
      ),
    );
    setState(() => selectedLocation = null);
  }

  // ─── Location Details Bottom Sheet ─────
  // Listed as a feature in the guide: "Bottom sheet with information and coordinates"

  void _showLocationDetails(TravelLocation location) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle bar
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppTheme.textHint, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),

            // Name + Category badge
            Row(
              children: [
                Expanded(
                  child: Text(
                    location.name,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(color: AppTheme.primarySurface, borderRadius: BorderRadius.circular(20)),
                  child: Text(location.category,
                      style: const TextStyle(fontSize: 11, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Description
            Text(location.description,
                style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary, height: 1.5)),
            const SizedBox(height: 12),

            // Coordinates — as mentioned in the guide
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(color: AppTheme.background, borderRadius: BorderRadius.circular(8)),
              child: Row(
                children: [
                  const Icon(Icons.pin_drop, size: 16, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Text(
                    '${location.latitude.toStringAsFixed(4)}°N, ${location.longitude.toStringAsFixed(4)}°E',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Navigate button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                icon: const Icon(Icons.navigation),
                label: const Text('Navigate Here', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                onPressed: () {
                  Navigator.pop(ctx);
                  _showNavigateDialog(location);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Search ────

  TravelLocation? _findLocationByQuery(String query) {
    if (query.trim().isEmpty) return null;
    final normalized = query.toLowerCase();
    for (final loc in travelLocations) {
      if (loc.name.toLowerCase().contains(normalized) ||
          loc.shortName.toLowerCase().contains(normalized)) {
        return loc;
      }
    }
    return null;
  }

  void _searchLocation(String query) {
    if (query.isEmpty) {
      _clearSearch();
      return;
    }

    final location = _findLocationByQuery(query);

    if (location != null) {
      _zoomToLocation(location);
      _searchController.clear();
      setState(() {});
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Location not found'), duration: Duration(seconds: 2)),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() => selectedLocation = null);
    _resetToSriLanka();
  }

  // ─── GPS ────

  Future<LatLng?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled. Please enable GPS.');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permission denied.');
        return null;
      }
    }
    if (permission == LocationPermission.deniedForever) {
      _showError('Location permission permanently denied. Enable in app settings.');
      return null;
    }

    final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    return LatLng(pos.latitude, pos.longitude);
  }

  // ─── Directions API ────

  Future<void> _fetchDirections({required LatLng origin, required LatLng destination}) async {
    setState(() {
      _isLoadingRoute = true;
      _polylines = {};
      _navigationSteps = [];
      _showNavigationPanel = false;
    });

    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json'
      '?origin=${origin.latitude},${origin.longitude}'
      '&destination=${destination.latitude},${destination.longitude}'
      '&mode=$_travelMode'
      '&key=$_googleApiKey',
    );

    try {
      final response = await http.get(url);
      final data = jsonDecode(response.body);

      if (data['status'] != 'OK') {
        _showError('Directions unavailable: ${data['status']}');
        setState(() => _isLoadingRoute = false);
        return;
      }

      final route = data['routes'][0];
      final leg = route['legs'][0];

      // Decode polyline
      final polylinePoints = PolylinePoints();
      final decoded = polylinePoints.decodePolyline(route['overview_polyline']['points']);
      final polylineCoords = decoded.map((p) => LatLng(p.latitude, p.longitude)).toList();

      // Parse steps
      final steps = (leg['steps'] as List).map((step) {
        return NavigationStep(
          instruction: _stripHtml(step['html_instructions']),
          distance: step['distance']['text'],
          duration: step['duration']['text'],
          maneuver: step['maneuver'] ?? '',
          startLocation: LatLng(step['start_location']['lat'], step['start_location']['lng']),
        );
      }).toList();

      final summary = '${leg['distance']['text']} · ${leg['duration']['text']} via ${route['summary']}';

      // Add green origin marker
      final updatedMarkers = Set<Marker>.from(markers);
      updatedMarkers.add(Marker(
        markerId: const MarkerId('origin'),
        position: origin,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        infoWindow: const InfoWindow(title: 'Start'),
      ));

      setState(() {
        _polylines = {
          Polyline(
            polylineId: const PolylineId('route'),
            points: polylineCoords,
            color: AppTheme.primary,
            width: 5,
            startCap: Cap.roundCap,
            endCap: Cap.roundCap,
          ),
        };
        _navigationSteps = steps;
        _routeSummary = summary;
        _showNavigationPanel = true;
        _currentStepIndex = 0;
        _isLoadingRoute = false;
        markers = updatedMarkers;
      });

      // Fit camera to show full route
      final bounds = _boundsFromLatLngList([origin, destination, ...polylineCoords]);
      mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
    } catch (e) {
      _showError('Failed to fetch directions. Check your internet connection.');
      setState(() => _isLoadingRoute = false);
    }
  }

  LatLngBounds _boundsFromLatLngList(List<LatLng> list) {
    double minLat = list.first.latitude, maxLat = list.first.latitude;
    double minLng = list.first.longitude, maxLng = list.first.longitude;
    for (final p in list) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }
    return LatLngBounds(southwest: LatLng(minLat, minLng), northeast: LatLng(maxLat, maxLng));
  }

  String _stripHtml(String html) =>
      html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll('&nbsp;', ' ').trim();

  // ─── Start Navigation ───

  Future<void> _startNavigation(TravelLocation destination) async {
    LatLng? origin;

    if (_originMode == 'gps') {
      origin = await _getCurrentLocation();
      if (origin == null) return;
    } else {
      if (_originLocation == null) {
        _showError('Please select an origin place.');
        return;
      }
      origin = LatLng(_originLocation!.latitude, _originLocation!.longitude);
    }

<<<<<<< HEAD
    await _fetchDirections(origin: origin, destination: LatLng(destination.latitude, destination.longitude));
=======
    await _fetchDirections(
      origin: origin,
      destination: LatLng(destination.latitude, destination.longitude),
    );
>>>>>>> 18c1d99d77c0c65af30acd08dd8bf636086c289d
  }

  void _clearNavigation() {
    setState(() {
      _polylines = {};
      _navigationSteps = [];
      _showNavigationPanel = false;
      _originLocation = null;
      _routeSummary = '';
      _currentStepIndex = 0;
    });
    _initializeMarkers();
    _resetToSriLanka();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: Colors.red),
    );
  }

  // ─── Navigate Dialog ───

  void _showNavigateDialog(TravelLocation destination) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.surface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setModalState) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20, right: 20, top: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(color: AppTheme.textHint, borderRadius: BorderRadius.circular(2)),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.navigation, color: AppTheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Navigate to ${destination.name}',
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Origin mode toggle
              const Text('Start from:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _modeChip(label: '📍 My Location', selected: _originMode == 'gps',
                      onTap: () => setModalState(() => _originMode = 'gps')),
                  const SizedBox(width: 8),
                  _modeChip(label: '🗺 Choose Place', selected: _originMode == 'location',
                      onTap: () => setModalState(() => _originMode = 'location')),
                ],
              ),

              // Origin place picker
              if (_originMode == 'location') ...[
                const SizedBox(height: 12),
                const Text('Select origin place:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
                const SizedBox(height: 6),
                SizedBox(
                  height: 40,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    children: travelLocations
                        .where((l) => l.id != destination.id)
                        .map((loc) {
                      final sel = _originLocation?.id == loc.id;
                      return GestureDetector(
                        onTap: () => setModalState(() => _originLocation = loc),
                        child: Container(
                          margin: const EdgeInsets.only(right: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: sel ? AppTheme.primary : AppTheme.primarySurface,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(loc.shortName,
                              style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppTheme.primary, fontWeight: FontWeight.w600)),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],

              const SizedBox(height: 16),

              // Travel mode
              const Text('Travel mode:', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
              const SizedBox(height: 8),
              Row(
                children: [
                  _travelModeChip('driving', Icons.directions_car, setModalState),
                  const SizedBox(width: 8),
                  _travelModeChip('walking', Icons.directions_walk, setModalState),
                  const SizedBox(width: 8),
                  _travelModeChip('bicycling', Icons.directions_bike, setModalState),
                  const SizedBox(width: 8),
                  _travelModeChip('transit', Icons.directions_transit, setModalState),
                ],
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.navigation),
                  label: const Text('Get Directions', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  onPressed: () {
                    Navigator.pop(ctx);
                    if (kIsWeb) {
                      _openExternalDirections(destination, _originMode == 'location' ? _originLocation : null);
                    } else {
                      _startNavigation(destination);
                    }
                  },
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  Widget _modeChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(label,
            style: TextStyle(fontSize: 13, color: selected ? Colors.white : AppTheme.primary, fontWeight: FontWeight.w600)),
      ),
    );
  }

  Widget _travelModeChip(String mode, IconData icon, StateSetter setModalState) {
    final selected = _travelMode == mode;
    return GestureDetector(
      onTap: () => setModalState(() => _travelMode = mode),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.primarySurface,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: selected ? Colors.white : AppTheme.primary, size: 20),
      ),
    );
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearchBar(),
            if (!_showNavigationPanel) _buildCategoryFilter(),
            Expanded(
              flex: _showNavigationPanel ? 3 : 2,
              child: _buildMap(),
            ),
            if (_isLoadingRoute) _buildLoadingIndicator(),
            if (_showNavigationPanel) _buildNavigationPanel(),
            if (!_showNavigationPanel) _buildTopPlaces(),
          ],
        ),
      ),
    );
  }

  // ─── Header ────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text('Map',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
          Row(
            children: [
              if (_showNavigationPanel)
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.red),
                  tooltip: 'Clear route',
                  onPressed: _clearNavigation,
                ),
              IconButton(icon: const Icon(Icons.layers, color: AppTheme.primary), onPressed: () {}),
              // Matches guide: "Current Location Button — Reset to Sri Lanka overview"
              IconButton(
                icon: const Icon(Icons.my_location, color: AppTheme.primary),
                tooltip: 'Reset to Sri Lanka',
                onPressed: _resetToSriLanka,
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Search Bar ────

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search location...',
            hintStyle: const TextStyle(color: AppTheme.textHint),
            prefixIcon: const Icon(Icons.search, color: AppTheme.primary),
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear, color: AppTheme.textSecondary),
                    onPressed: _clearSearch,
                  )
                : null,
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          style: const TextStyle(color: AppTheme.textPrimary, fontSize: 14),
          onChanged: (_) => setState(() {}),
          onSubmitted: _searchLocation,
        ),
      ),
    );
  }

  // ─── Category Filter ────
  // Implements "Add filtering by category" from guide Next Steps

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 38,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _filterChip(label: 'All', selected: _selectedCategory == null,
              onTap: () => setState(() => _selectedCategory = null)),
          ...(_categories.map((cat) => Padding(
            padding: const EdgeInsets.only(left: 8),
            child: _filterChip(
              label: cat,
              selected: _selectedCategory == cat,
              onTap: () => setState(() => _selectedCategory = _selectedCategory == cat ? null : cat),
            ),
          ))),
        ],
      ),
    );
  }

  Widget _filterChip({required String label, required bool selected, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.textHint.withOpacity(0.3)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: selected ? Colors.white : AppTheme.textSecondary,
            fontWeight: selected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  // ─── Map ──────

  Widget _buildMap() {
    if (kIsWeb) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: AppTheme.surface,
          boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.map_outlined, size: 42, color: AppTheme.textSecondary),
                const SizedBox(height: 10),
                const Text(
                  'Interactive map is unavailable in web preview.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: AppTheme.textPrimary),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Use Navigate to open Google Maps directions for the selected place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 14),
                ElevatedButton.icon(
                  onPressed: () {
                    if (selectedLocation != null) {
                      _openExternalPlaceMap(selectedLocation!);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Open Selected Place in Maps'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GoogleMap(
          onMapCreated: (controller) {
            mapController = controller;
            final initialQuery = widget.initialQuery?.trim() ?? '';
            if (initialQuery.isNotEmpty) {
              final match = _findLocationByQuery(initialQuery);
              if (match != null) {
                _zoomToLocation(match);
              }
            }
          },
          initialCameraPosition: const CameraPosition(target: _sriLankaCenter, zoom: _initialZoom),
          markers: markers,
          polylines: _polylines,
          myLocationEnabled: true,
          myLocationButtonEnabled: false,
          compassEnabled: true,
          zoomControlsEnabled: false,
          mapType: MapType.normal,
        ),
      ),
    );
  }

  Future<void> _openExternalPlaceMap(TravelLocation location) async {
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=${location.latitude},${location.longitude}',
    );
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  Future<void> _openExternalDirections(
    TravelLocation destination,
    TravelLocation? origin,
  ) async {
    final destinationParam = '${destination.latitude},${destination.longitude}';
    final url = origin == null
        ? 'https://www.google.com/maps/dir/?api=1&destination=$destinationParam&travelmode=$_travelMode'
        : 'https://www.google.com/maps/dir/?api=1&origin=${origin.latitude},${origin.longitude}&destination=$destinationParam&travelmode=$_travelMode';
    await launchUrl(Uri.parse(url), mode: LaunchMode.platformDefault);
  }

  // ─── Loading ─────

  Widget _buildLoadingIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          SizedBox(width: 18, height: 18,
              child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primary)),
          SizedBox(width: 10),
          Text('Fetching directions...', style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        ],
      ),
    );
  }

  // ─── Navigation Panel ──────

  Widget _buildNavigationPanel() {
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Route summary
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(10)),
            child: Row(
              children: [
                const Icon(Icons.route, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(_routeSummary,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600))),
              ],
            ),
          ),
          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Turn-by-Turn Directions',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
              Text('${_currentStepIndex + 1} / ${_navigationSteps.length}',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 8),

          // Steps list
          SizedBox(
            height: 130,
            child: ListView.builder(
              itemCount: _navigationSteps.length,
              itemBuilder: (context, index) {
                final step = _navigationSteps[index];
                final isActive = index == _currentStepIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() => _currentStepIndex = index);
                    mapController?.animateCamera(CameraUpdate.newCameraPosition(
                      CameraPosition(target: step.startLocation, zoom: 16),
                    ));
                  },
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isActive ? AppTheme.primarySurface : AppTheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: isActive ? Border.all(color: AppTheme.primary, width: 1.5) : null,
                      boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 4, offset: const Offset(0, 1))],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 28, height: 28,
                          decoration: BoxDecoration(
                            color: isActive ? AppTheme.primary : AppTheme.primarySurface,
                            shape: BoxShape.circle,
                          ),
                          child: Center(child: Text('${index + 1}',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold,
                                  color: isActive ? Colors.white : AppTheme.primary))),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(step.instruction,
                                  style: TextStyle(fontSize: 12, color: AppTheme.textPrimary,
                                      fontWeight: isActive ? FontWeight.w600 : FontWeight.normal),
                                  maxLines: 2, overflow: TextOverflow.ellipsis),
                              const SizedBox(height: 2),
                              Text('${step.distance} · ${step.duration}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ),
                        Icon(_maneuverIcon(step.maneuver),
                            color: isActive ? AppTheme.primary : AppTheme.textSecondary, size: 20),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // Prev / Next controls
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton.icon(
                onPressed: _currentStepIndex > 0
                    ? () {
                        setState(() => _currentStepIndex--);
                        mapController?.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(target: _navigationSteps[_currentStepIndex].startLocation, zoom: 16),
                        ));
                      }
                    : null,
                icon: const Icon(Icons.arrow_back_ios, size: 14),
                label: const Text('Prev'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              ),
              TextButton.icon(
                onPressed: _currentStepIndex < _navigationSteps.length - 1
                    ? () {
                        setState(() => _currentStepIndex++);
                        mapController?.animateCamera(CameraUpdate.newCameraPosition(
                          CameraPosition(target: _navigationSteps[_currentStepIndex].startLocation, zoom: 16),
                        ));
                      }
                    : null,
                icon: const Icon(Icons.arrow_forward_ios, size: 14),
                label: const Text('Next'),
                style: TextButton.styleFrom(foregroundColor: AppTheme.primary),
              ),
            ],
          ),
        ],
      ),
    );
  }

  IconData _maneuverIcon(String maneuver) {
    switch (maneuver) {
      case 'turn-left': return Icons.turn_left;
      case 'turn-right': return Icons.turn_right;
      case 'turn-slight-left': return Icons.turn_slight_left;
      case 'turn-slight-right': return Icons.turn_slight_right;
      case 'turn-sharp-left': return Icons.turn_sharp_left;
      case 'turn-sharp-right': return Icons.turn_sharp_right;
      case 'uturn-left': return Icons.u_turn_left;
      case 'uturn-right': return Icons.u_turn_right;
      case 'roundabout-left':
      case 'roundabout-right': return Icons.roundabout_right;
      case 'merge': return Icons.merge;
      case 'fork-left': return Icons.fork_left;
      case 'fork-right': return Icons.fork_right;
      case 'ferry': return Icons.directions_boat;
      case 'straight': return Icons.straight;
      default: return Icons.navigation;
    }
  }

  // ─── Top Places ────

  Widget _buildTopPlaces() {
    final visibleLocations = _filteredLocations;
    return Container(
      color: AppTheme.background,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _selectedCategory != null ? '$_selectedCategory Places' : 'Top Places',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              Text('${visibleLocations.length} locations',
                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 108,
            child: visibleLocations.isEmpty
                ? const Center(
                    child: Text('No locations in this category',
                        style: TextStyle(color: AppTheme.textSecondary)))
                : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: visibleLocations.length,
                    itemBuilder: (context, index) {
                      final location = visibleLocations[index];
                      final isSelected = selectedLocation?.id == location.id;
                      return GestureDetector(
                        onTap: () => _zoomToLocation(location),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          width: 120,
                          decoration: BoxDecoration(
                            color: isSelected ? AppTheme.primary : AppTheme.surface,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [BoxShadow(color: AppTheme.cardShadow, blurRadius: 6, offset: const Offset(0, 2))],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8),
                                child: Text(location.shortName,
                                    textAlign: TextAlign.center, maxLines: 2, overflow: TextOverflow.ellipsis,
                                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold,
                                        color: isSelected ? Colors.white : AppTheme.textPrimary)),
                              ),
                              const SizedBox(height: 5),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isSelected ? Colors.white24 : AppTheme.primarySurface,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(location.category,
                                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                        color: isSelected ? Colors.white : AppTheme.primary)),
                              ),
                              const SizedBox(height: 5),
                              GestureDetector(
                                onTap: () => _showNavigateDialog(location),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isSelected ? Colors.white24 : AppTheme.primary.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.navigation, size: 11,
                                          color: isSelected ? Colors.white : AppTheme.primary),
                                      const SizedBox(width: 3),
                                      Text('Navigate',
                                          style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                                              color: isSelected ? Colors.white : AppTheme.primary)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ─── Models ───

class TravelLocation {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final String description;
  final String category;
  final String shortName;

  TravelLocation({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.description,
    required this.category,
    required this.shortName,
  });
}

class NavigationStep {
  final String instruction;
  final String distance;
  final String duration;
  final String maneuver;
  final LatLng startLocation;

  NavigationStep({
    required this.instruction,
    required this.distance,
    required this.duration,
    required this.maneuver,
    required this.startLocation,
  });
}
