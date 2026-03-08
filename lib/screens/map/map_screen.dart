import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../utils/app_theme.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late GoogleMapController mapController;
  final TextEditingController _searchController = TextEditingController();
  
  // Sri Lanka center coordinates
  static const LatLng _sriLankaCenter = LatLng(7.8731, 80.7718);
  static const double _initialZoom = 6.5;

  // Travel locations in Sri Lanka
  final List<TravelLocation> travelLocations = [
    TravelLocation(
      id: '1',
      name: 'Sigiriya Rock',
      latitude: 7.9569,
      longitude: 80.7597,
      description: 'Ancient rock fortress with stunning views',
      category: 'Historical',
      shortName: 'Sigiriya Rock',
    ),
    TravelLocation(
      id: '2',
      name: 'Temple of the Tooth',
      latitude: 6.9271,
      longitude: 80.6314,
      description: 'Sacred Buddhist temple in Kandy',
      category: 'Religious',
      shortName: 'Temple of the Tooth',
    ),
    TravelLocation(
      id: '3',
      name: 'Mirissa Beach',
      latitude: 5.9425,
      longitude: 80.4730,
      description: 'Popular beach for whale watching',
      category: 'Beach',
      shortName: 'Mirissa',
    ),
    TravelLocation(
      id: '4',
      name: 'Ella Rock',
      latitude: 6.8568,
      longitude: 81.0486,
      description: 'Scenic hiking destination with panoramic views',
      category: 'Nature',
      shortName: 'Ella Rock',
    ),
    TravelLocation(
      id: '5',
      name: 'Galle Fort',
      latitude: 6.0329,
      longitude: 80.2168,
      description: 'Historic coastal fort with colonial architecture',
      category: 'Historical',
      shortName: 'Galle Fort',
    ),
    TravelLocation(
      id: '6',
      name: 'Adam\'s Peak',
      latitude: 6.8095,
      longitude: 80.8009,
      description: 'Sacred mountain with pilgrimage site',
      category: 'Religious',
      shortName: 'Adam\'s Peak',
    ),
    TravelLocation(
      id: '7',
      name: 'Nuwara Eliya',
      latitude: 6.9497,
      longitude: 80.7850,
      description: 'Hill station in central highlands',
      category: 'Hill Station',
      shortName: 'Nuwara Eliya',
    ),
    TravelLocation(
      id: '8',
      name: 'Colombo City',
      latitude: 6.9271,
      longitude: 79.8612,
      description: 'Capital city with modern attractions',
      category: 'City',
      shortName: 'Colombo',
    ),
  ];

  late Set<Marker> markers;
  TravelLocation? selectedLocation;

  @override
  void initState() {
    super.initState();
    _initializeMarkers();
  }

  void _initializeMarkers() {
    markers = travelLocations.map((location) {
      return Marker(
        markerId: MarkerId(location.id),
        position: LatLng(location.latitude, location.longitude),
        infoWindow: InfoWindow(
          title: location.name,
          snippet: location.description,
        ),
        onTap: () {
          _zoomToLocation(location);
        },
      );
    }).toSet();
  }

  void _zoomToLocation(TravelLocation location) {
    setState(() {
      selectedLocation = location;
    });

    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(
          target: LatLng(location.latitude, location.longitude),
          zoom: 14.5,
          bearing: 0,
          tilt: 0,
        ),
      ),
    );
  }

  void _searchLocation(String query) {
    if (query.isEmpty) {
      setState(() {
        selectedLocation = null;
      });
      mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          const CameraPosition(
            target: _sriLankaCenter,
            zoom: _initialZoom,
          ),
        ),
      );
      return;
    }

    final location = travelLocations.firstWhere(
      (loc) => loc.name.toLowerCase().contains(query.toLowerCase()) ||
          loc.shortName.toLowerCase().contains(query.toLowerCase()),
      orElse: () => TravelLocation(
        id: '0',
        name: 'Not Found',
        latitude: 0,
        longitude: 0,
        description: '',
        category: '',
        shortName: '',
      ),
    );

    if (location.id != '0') {
      _zoomToLocation(location);
      _searchController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Location not found'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      selectedLocation = null;
    });
    mapController.animateCamera(
      CameraUpdate.newCameraPosition(
        const CameraPosition(
          target: _sriLankaCenter,
          zoom: _initialZoom,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // Header with Map Title
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Map',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.layers, color: AppTheme.primary),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.location_on,
                            color: AppTheme.primary),
                        onPressed: () {
                          mapController.animateCamera(
                            CameraUpdate.newCameraPosition(
                              const CameraPosition(
                                target: _sriLankaCenter,
                                zoom: _initialZoom,
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    hintStyle: const TextStyle(color: AppTheme.textHint),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppTheme.primary,
                    ),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              Icons.clear,
                              color: AppTheme.textSecondary,
                            ),
                            onPressed: _clearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                  ),
                  onChanged: (value) {
                    setState(() {});
                  },
                  onSubmitted: _searchLocation,
                ),
              ),
            ),
            // Google Map
            Expanded(
              flex: 2,
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.cardShadow,
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: GoogleMap(
                    onMapCreated: (controller) {
                      mapController = controller;
                    },
                    initialCameraPosition: const CameraPosition(
                      target: _sriLankaCenter,
                      zoom: _initialZoom,
                    ),
                    markers: markers,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: false,
                    compassEnabled: true,
                    zoomControlsEnabled: false,
                    mapType: MapType.normal,
                  ),
                ),
              ),
            ),
            // Top Places Section
            Container(
              color: AppTheme.background,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Top Places',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 100,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: travelLocations.length,
                      itemBuilder: (context, index) {
                        final location = travelLocations[index];
                        final isSelected = selectedLocation?.id == location.id;
                        return GestureDetector(
                          onTap: () {
                            _zoomToLocation(location);
                          },
                          child: Container(
                            margin: const EdgeInsets.only(right: 12),
                            width: 120,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? AppTheme.primary
                                  : AppTheme.surface,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.cardShadow,
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  location.shortName,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textPrimary,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? Colors.white24
                                        : AppTheme.primarySurface,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    location.category,
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : AppTheme.primary,
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
            ),
          ],
        ),
      ),
    );
  }
}

// Travel Location Model
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
