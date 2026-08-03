import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import '../../../../core/utils/gis_calculator.dart';
import '../../domain/models/farm_gis_entity.dart';
import '../providers/multi_farm_provider.dart';

enum MapStyle { satellite, normal, terrain, hybrid }
enum GisInteractionMode { pointPin, drawPolygon, walkFarm }

class FarmLocationData {
  final double latitude;
  final double longitude;
  final String village;
  final String mandal;
  final String district;
  final String state;
  final String country;
  final String pincode;
  final String geoHash;
  final String timezone;
  final String landmark;

  const FarmLocationData({
    required this.latitude,
    required this.longitude,
    required this.village,
    this.mandal = 'Mandal',
    required this.district,
    required this.state,
    required this.country,
    this.pincode = '',
    this.geoHash = '',
    this.timezone = 'Asia/Kolkata',
    this.landmark = '',
  });

  bool get isWithinIndia {
    final c = country.trim().toLowerCase();
    return c == 'india' || c == 'in' || (latitude >= 6.0 && latitude <= 37.5 && longitude >= 68.0 && longitude <= 97.5);
  }
}

final farmLocationProvider = StateProvider<FarmLocationData>((ref) {
  final multiState = ref.watch(multiFarmProvider);
  final active = multiState.activeFarm;
  if (active != null) {
    return FarmLocationData(
      latitude: active.latitude,
      longitude: active.longitude,
      village: active.village,
      mandal: active.mandal,
      district: active.district,
      state: active.state,
      country: active.country,
      pincode: active.pincode,
      landmark: active.landmark,
    );
  }
  return const FarmLocationData(
    latitude: 16.3067,
    longitude: 80.4365,
    village: 'Guntur Rural',
    mandal: 'Guntur Mandal',
    district: 'Guntur',
    state: 'Andhra Pradesh',
    country: 'India',
    pincode: '522002',
  );
});

class FarmLocationSelectorModal extends ConsumerStatefulWidget {
  const FarmLocationSelectorModal({super.key});

  @override
  ConsumerState<FarmLocationSelectorModal> createState() => _FarmLocationSelectorModalState();
}

class _FarmLocationSelectorModalState extends ConsumerState<FarmLocationSelectorModal> {
  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _farmNameController = TextEditingController();
  final TextEditingController _surveyNumberController = TextEditingController();
  final TextEditingController _landmarkController = TextEditingController();

  Timer? _debounceTimer;
  StreamSubscription<Position>? _positionStreamSub;

  MapStyle _currentMapStyle = MapStyle.satellite;
  GisInteractionMode _mode = GisInteractionMode.pointPin;

  late LatLng _currentCenter;
  late String _village;
  late String _mandal;
  late String _district;
  late String _state;
  late String _country;
  late String _pincode;
  late String _selectedCrop;

  List<LatLng> _polygonPoints = [];
  List<LatLng> _walkTrackPoints = [];

  bool _isLocatingGPS = false;
  bool _isSearching = false;
  bool _isWalking = false;
  List<FarmLocationData> _searchResults = [];

  // Live Weather & APMC Market Previews
  String _previewWeather = '29°C • Partly Cloudy (Humidity: 62%)';
  String _previewMandi = 'Guntur APMC • Cotton ₹7,250/qtl';

  final List<String> _cropOptions = const [
    'Cotton',
    'Paddy (Rice)',
    'Red Chilli',
    'Maize (Corn)',
    'Sugarcane',
    'Wheat',
    'Groundnut',
    'Pulses',
    'Turmeric',
  ];

  @override
  void initState() {
    super.initState();
    final activeFarm = ref.read(multiFarmProvider).activeFarm;

    if (activeFarm != null) {
      _currentCenter = LatLng(activeFarm.latitude, activeFarm.longitude);
      _village = activeFarm.village;
      _mandal = activeFarm.mandal;
      _district = activeFarm.district;
      _state = activeFarm.state;
      _country = activeFarm.country;
      _pincode = activeFarm.pincode;
      _selectedCrop = activeFarm.cropType;
      _polygonPoints = List.from(activeFarm.boundaryPolygon);
      _farmNameController.text = activeFarm.name;
      _surveyNumberController.text = activeFarm.surveyNumber;
      _landmarkController.text = activeFarm.landmark;
    } else {
      _currentCenter = const LatLng(16.3067, 80.4365);
      _village = 'Guntur Rural';
      _mandal = 'Guntur Mandal';
      _district = 'Guntur';
      _state = 'Andhra Pradesh';
      _country = 'India';
      _pincode = '522002';
      _selectedCrop = 'Cotton';
      _farmNameController.text = 'Main Farm Field';
    }

    _searchController.addListener(_onSearchChanged);
    _fetchLivePreviews(_currentCenter.latitude, _currentCenter.longitude);
  }

  @override
  void dispose() {
    _positionStreamSub?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _farmNameController.dispose();
    _surveyNumberController.dispose();
    _landmarkController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    final query = _searchController.text.trim();
    if (query.length < 3) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 400), () {
      _performLiveSearch(query);
    });
  }

  Future<void> _performLiveSearch(String query) async {
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=${Uri.encodeComponent(query)}&format=json&addressdetails=1&countrycodes=in&limit=8',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'AgriPilotAI/1.0 (agripilot.app@gmail.com)',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final List data = json.decode(response.body);
        final results = <FarmLocationData>[];

        for (var item in data) {
          final lat = double.tryParse(item['lat'].toString()) ?? 0.0;
          final lon = double.tryParse(item['lon'].toString()) ?? 0.0;
          final addr = item['address'] ?? {};

          final village = addr['village'] ?? addr['suburb'] ?? addr['neighbourhood'] ?? addr['town'] ?? addr['city'] ?? item['display_name'].toString().split(',').first;
          final mandal = addr['subdistrict'] ?? addr['tehsil'] ?? addr['county'] ?? addr['taluk'] ?? 'Mandal';
          final district = addr['state_district'] ?? addr['district'] ?? addr['city'] ?? 'District';
          final state = addr['state'] ?? 'State';
          final country = addr['country'] ?? 'India';
          final pincode = addr['postcode'] ?? '';

          results.add(FarmLocationData(
            latitude: lat,
            longitude: lon,
            village: village.toString(),
            mandal: mandal.toString(),
            district: district.toString(),
            state: state.toString(),
            country: country.toString(),
            pincode: pincode.toString(),
          ));
        }

        if (mounted) {
          setState(() {
            _searchResults = results;
            _isSearching = false;
          });
        }
      }
    } catch (_) {
      if (mounted) setState(() => _isSearching = false);
    }
  }

  Future<void> _fetchLivePreviews(double lat, double lon) async {
    try {
      // Simulate live weather & mandi preview based on location coordinates
      final isNorth = lat > 20.0;
      setState(() {
        _previewWeather = isNorth
            ? '31°C • Clear Sky (Humidity: 48%, Rain: 5%)'
            : '28.5°C • Moderate Clouds (Humidity: 65%, Rain: 20%)';
        _previewMandi = 'Nearest APMC: ${_district} Mandi • ${_selectedCrop} ₹${(6800 + (lat * 10).toInt())}/qtl';
      });
    } catch (_) {}
  }

  Future<void> _fetchRealGPSLocation() async {
    setState(() => _isLocatingGPS = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) setState(() => _isLocatingGPS = false);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          if (mounted) setState(() => _isLocatingGPS = false);
          return;
        }
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 10)),
      );

      final newPos = LatLng(position.latitude, position.longitude);
      _mapController.move(newPos, 17.5);
      await _reverseGeocodeCoordinates(newPos.latitude, newPos.longitude);
    } catch (e) {
      if (mounted) setState(() => _isLocatingGPS = false);
    }
  }

  Future<void> _reverseGeocodeCoordinates(double lat, double lon) async {
    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json&addressdetails=1',
      );
      final response = await http.get(url, headers: {
        'User-Agent': 'AgriPilotAI/1.0 (agripilot.app@gmail.com)',
        'Accept-Language': 'en',
      }).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final item = json.decode(response.body);
        final addr = item['address'] ?? {};

        final village = addr['village'] ?? addr['suburb'] ?? addr['neighbourhood'] ?? addr['town'] ?? addr['city'] ?? 'Farm Location';
        final mandal = addr['subdistrict'] ?? addr['tehsil'] ?? addr['county'] ?? addr['taluk'] ?? 'Mandal';
        final district = addr['state_district'] ?? addr['district'] ?? addr['city'] ?? 'District';
        final state = addr['state'] ?? 'State';
        final country = addr['country'] ?? 'India';
        final pincode = addr['postcode'] ?? '';

        if (mounted) {
          setState(() {
            _currentCenter = LatLng(lat, lon);
            _village = village.toString();
            _mandal = mandal.toString();
            _district = district.toString();
            _state = state.toString();
            _country = country.toString();
            _pincode = pincode.toString();
            _isLocatingGPS = false;
          });
          _fetchLivePreviews(lat, lon);
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _currentCenter = LatLng(lat, lon);
          _isLocatingGPS = false;
        });
      }
    }
  }

  void _onMapTap(TapPosition tapPos, LatLng point) {
    if (_mode == GisInteractionMode.pointPin) {
      setState(() => _currentCenter = point);
      _reverseGeocodeCoordinates(point.latitude, point.longitude);
    } else if (_mode == GisInteractionMode.drawPolygon) {
      setState(() {
        _polygonPoints.add(point);
      });
    }
  }

  void _toggleWalkFarmMode() async {
    if (_isWalking) {
      // Stop Walk Mode and finalize polygon
      await _positionStreamSub?.cancel();
      setState(() {
        _isWalking = false;
        if (_walkTrackPoints.length >= 3) {
          _polygonPoints = GisCalculator.filterGpsNoise(_walkTrackPoints);
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('✅ Walk boundary completed! Captured ${_polygonPoints.length} GPS vertices.'),
          backgroundColor: Colors.green.shade800,
        ),
      );
    } else {
      // Start Walk Mode
      setState(() {
        _mode = GisInteractionMode.walkFarm;
        _isWalking = true;
        _walkTrackPoints = [];
      });

      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 2, // Capture point every 2 meters
      );

      _positionStreamSub = Geolocator.getPositionStream(locationSettings: locationSettings).listen((pos) {
        final newPt = LatLng(pos.latitude, pos.longitude);
        if (mounted) {
          setState(() {
            _walkTrackPoints.add(newPt);
            _currentCenter = newPt;
          });
          _mapController.move(newPt, 18.0);
        }
      });
    }
  }

  void _selectSearchResult(FarmLocationData loc) {
    final target = LatLng(loc.latitude, loc.longitude);
    setState(() {
      _currentCenter = target;
      _village = loc.village;
      _mandal = loc.mandal;
      _district = loc.district;
      _state = loc.state;
      _country = loc.country;
      _pincode = loc.pincode;
      _searchResults = [];
      _searchController.clear();
    });

    _mapController.move(target, 17.0);
    _fetchLivePreviews(loc.latitude, loc.longitude);
  }

  void _saveFarmGis() {
    final sqMeters = _polygonPoints.length >= 3
        ? GisCalculator.calculatePolygonAreaSqMeters(_polygonPoints)
        : 10117.0; // Default 2.5 Acres if point pin mode

    final perimeter = _polygonPoints.length >= 2
        ? GisCalculator.calculatePerimeterMeters(_polygonPoints)
        : 400.0;

    final centroid = _polygonPoints.isNotEmpty
        ? GisCalculator.calculateCentroid(_polygonPoints)
        : _currentCenter;

    final activeFarm = ref.read(multiFarmProvider).activeFarm;

    final farmEntity = FarmGisEntity(
      id: activeFarm?.id ?? '',
      name: _farmNameController.text.trim().isEmpty ? 'My Farm Field' : _farmNameController.text.trim(),
      surveyNumber: _surveyNumberController.text.trim(),
      village: _village,
      mandal: _mandal,
      district: _district,
      state: _state,
      country: _country,
      pincode: _pincode,
      latitude: centroid.latitude,
      longitude: centroid.longitude,
      elevationMeters: 35.0,
      areaSqMeters: sqMeters,
      perimeterMeters: perimeter,
      boundaryPolygon: _polygonPoints,
      cropType: _selectedCrop,
      landmark: _landmarkController.text.trim(),
      createdAt: activeFarm?.createdAt ?? DateTime.now(),
      updatedAt: DateTime.now(),
    );

    if (!farmEntity.isWithinIndia) {
      _showIndiaRejectionDialog();
      return;
    }

    if (activeFarm != null) {
      ref.read(multiFarmProvider.notifier).updateFarm(farmEntity);
    } else {
      ref.read(multiFarmProvider.notifier).addFarm(farmEntity);
    }

    ref.read(farmLocationProvider.notifier).state = FarmLocationData(
      latitude: farmEntity.latitude,
      longitude: farmEntity.longitude,
      village: farmEntity.village,
      mandal: farmEntity.mandal,
      district: farmEntity.district,
      state: farmEntity.state,
      country: farmEntity.country,
      pincode: farmEntity.pincode,
      landmark: farmEntity.landmark,
    );

    Navigator.of(context).pop();
  }

  void _showIndiaRejectionDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        icon: const Icon(Icons.public_off_rounded, color: Colors.red, size: 48),
        title: const Text('Location Restricted to India'),
        content: const Text(
          'AgriPilot GIS models & weather intelligence are strictly configured for agricultural land within India.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('OK')),
        ],
      ),
    );
  }

  void _showMultiFarmManagerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        final multiState = ref.watch(multiFarmProvider);
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const Icon(Icons.agriculture_rounded, color: Colors.green, size: 28),
                  const SizedBox(width: 8),
                  const Text('Manage My Farms', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.add_circle, color: Colors.green, size: 28),
                    onPressed: () {
                      Navigator.of(ctx).pop();
                      _addNewFarmPrompt();
                    },
                    tooltip: 'Add New Farm',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                itemCount: multiState.allFarms.length,
                itemBuilder: (context, idx) {
                  final farm = multiState.allFarms[idx];
                  final isSelected = farm.id == multiState.activeFarm?.id;

                  return Card(
                    color: isSelected ? Colors.green.shade50 : null,
                    child: ListTile(
                      leading: Icon(Icons.landscape, color: isSelected ? Colors.green : Colors.grey),
                      title: Text('${farm.name} (${farm.cropType})', style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('${farm.village}, ${farm.district} • ${farm.areaAcres.toStringAsFixed(2)} Acres'),
                      trailing: isSelected ? const Icon(Icons.check_circle, color: Colors.green) : null,
                      onTap: () {
                        ref.read(multiFarmProvider.notifier).switchActiveFarm(farm.id);
                        Navigator.of(ctx).pop();
                        setState(() {
                          _currentCenter = LatLng(farm.latitude, farm.longitude);
                          _village = farm.village;
                          _mandal = farm.mandal;
                          _district = farm.district;
                          _state = farm.state;
                          _country = farm.country;
                          _pincode = farm.pincode;
                          _selectedCrop = farm.cropType;
                          _polygonPoints = List.from(farm.boundaryPolygon);
                          _farmNameController.text = farm.name;
                        });
                        _mapController.move(_currentCenter, 17.5);
                      },
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _addNewFarmPrompt() {
    final nameCtrl = TextEditingController(text: 'Farm Field ${ref.read(multiFarmProvider).allFarms.length + 1}');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Add New Farm Field'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(labelText: 'Farm Name', hintText: 'e.g. Rice Field North'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              final newFarm = FarmGisEntity(
                id: '',
                name: nameCtrl.text.trim(),
                village: _village,
                mandal: _mandal,
                district: _district,
                state: _state,
                country: _country,
                pincode: _pincode,
                latitude: _currentCenter.latitude,
                longitude: _currentCenter.longitude,
                cropType: _selectedCrop,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              );
              ref.read(multiFarmProvider.notifier).addFarm(newFarm);
              Navigator.of(ctx).pop();
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  TileLayer _getTileLayer() {
    switch (_currentMapStyle) {
      case MapStyle.satellite:
        return TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.agripilot.ai',
        );
      case MapStyle.terrain:
        return TileLayer(
          urlTemplate: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
          subdomains: const ['a', 'b', 'c'],
          userAgentPackageName: 'com.agripilot.ai',
        );
      case MapStyle.hybrid:
        return TileLayer(
          urlTemplate: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
          userAgentPackageName: 'com.agripilot.ai',
        );
      case MapStyle.normal:
      default:
        return TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.agripilot.ai',
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final multiState = ref.watch(multiFarmProvider);
    final isIndia = _country.trim().toLowerCase() == 'india' ||
        _country.trim().toLowerCase() == 'in' ||
        (_currentCenter.latitude >= 6.0 && _currentCenter.latitude <= 37.5 && _currentCenter.longitude >= 68.0 && _currentCenter.longitude <= 97.5);

    final areaSqM = _polygonPoints.length >= 3
        ? GisCalculator.calculatePolygonAreaSqMeters(_polygonPoints)
        : 10117.0;
    final acres = GisCalculator.sqMetersToAcres(areaSqM);
    final hectares = GisCalculator.sqMetersToHectares(areaSqM);

    return Scaffold(
      body: Stack(
        children: [
          // 1. Fullscreen Interactive Map Engine (flutter_map)
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentCenter,
              initialZoom: 17.0,
              minZoom: 4.0,
              maxZoom: 19.0,
              onTap: _onMapTap,
            ),
            children: [
              _getTileLayer(),

              // Polygon Overlay Layer
              if (_polygonPoints.length >= 3)
                PolygonLayer(
                  polygons: [
                    Polygon(
                      points: _polygonPoints,
                      color: Colors.green.withValues(alpha: 0.35),
                      borderColor: Colors.greenAccent,
                      borderStrokeWidth: 3.5,
                      isFilled: true,
                    ),
                  ],
                ),

              // Polyline Layer for Draw / Walk Mode
              if (_polygonPoints.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _polygonPoints,
                      color: Colors.yellow,
                      strokeWidth: 3.0,
                    ),
                  ],
                ),

              if (_isWalking && _walkTrackPoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _walkTrackPoints,
                      color: Colors.cyanAccent,
                      strokeWidth: 4.0,
                    ),
                  ],
                ),

              // Interactive Pinned Location Marker
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentCenter,
                    width: 50,
                    height: 50,
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.black87, shape: BoxShape.circle),
                          child: const Icon(Icons.location_on, color: Colors.redAccent, size: 28),
                        ),
                      ],
                    ),
                  ),
                  ..._polygonPoints.asMap().entries.map((entry) {
                    return Marker(
                      point: entry.value,
                      width: 24,
                      height: 24,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.yellow,
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.black, width: 2),
                        ),
                        child: Center(
                          child: Text('${entry.key + 1}', style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.black)),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ],
          ),

          // 2. Top Bar Controls & Autocomplete Search Overlay
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, shape: BoxShape.circle),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Multi-farm Selector Dropdown Pill
                      Expanded(
                        child: InkWell(
                          onTap: _showMultiFarmManagerSheet,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            decoration: BoxDecoration(
                              color: theme.scaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(30),
                              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.15), blurRadius: 6)],
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.landscape_rounded, color: Colors.green, size: 20),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    multiState.activeFarm?.name ?? 'My Farm',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const Icon(Icons.keyboard_arrow_down, size: 18),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),

                      // Map Layer Toggle Menu Button
                      PopupMenuButton<MapStyle>(
                        icon: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(color: theme.scaffoldBackgroundColor, shape: BoxShape.circle),
                          child: const Icon(Icons.layers_rounded, color: Colors.green),
                        ),
                        onSelected: (style) => setState(() => _currentMapStyle = style),
                        itemBuilder: (ctx) => [
                          const PopupMenuItem(value: MapStyle.satellite, child: Text('🛰️ Satellite View')),
                          const PopupMenuItem(value: MapStyle.normal, child: Text('🗺️ Normal View')),
                          const PopupMenuItem(value: MapStyle.terrain, child: Text('⛰️ Terrain View')),
                          const PopupMenuItem(value: MapStyle.hybrid, child: Text('🌐 Hybrid View')),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Search Field
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search village, mandal, district, pincode in India...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _isSearching
                          ? const Padding(padding: EdgeInsets.all(12), child: SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)))
                          : null,
                      filled: true,
                      fillColor: theme.scaffoldBackgroundColor.withValues(alpha: 0.95),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(30), borderSide: BorderSide.none),
                      contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    ),
                  ),

                  // Autocomplete Search Results
                  if (_searchResults.isNotEmpty)
                    Container(
                      margin: const EdgeInsets.only(top: 6),
                      constraints: const BoxConstraints(maxHeight: 180),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 10)],
                      ),
                      child: ListView.separated(
                        shrinkWrap: true,
                        itemCount: _searchResults.length,
                        separatorBuilder: (ctx, i) => const Divider(height: 1),
                        itemBuilder: (ctx, idx) {
                          final loc = _searchResults[idx];
                          return ListTile(
                            dense: true,
                            leading: const Icon(Icons.location_on, color: Colors.green),
                            title: Text('${loc.village}, ${loc.mandal}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            subtitle: Text('${loc.district}, ${loc.state} ${loc.pincode}'),
                            onTap: () => _selectSearchResult(loc),
                          );
                        },
                      ),
                    ),
                ],
              ),
            ),
          ),

          // 3. Floating Action GIS Mode Buttons (Right Side Toolbar)
          Positioned(
            right: 14,
            top: MediaQuery.of(context).size.height * 0.28,
            child: Column(
              children: [
                // GPS Hardware Button
                FloatingActionButton.small(
                  heroTag: 'btn_gps',
                  backgroundColor: theme.scaffoldBackgroundColor,
                  child: _isLocatingGPS
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.green))
                      : const Icon(Icons.my_location, color: Colors.green),
                  onPressed: _fetchRealGPSLocation,
                ),
                const SizedBox(height: 10),

                // Draw Boundary Polygon Mode Button
                FloatingActionButton.small(
                  heroTag: 'btn_polygon',
                  backgroundColor: _mode == GisInteractionMode.drawPolygon ? Colors.green : theme.scaffoldBackgroundColor,
                  child: Icon(Icons.format_shapes_rounded, color: _mode == GisInteractionMode.drawPolygon ? Colors.white : Colors.black87),
                  onPressed: () {
                    setState(() {
                      _mode = _mode == GisInteractionMode.drawPolygon ? GisInteractionMode.pointPin : GisInteractionMode.drawPolygon;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(_mode == GisInteractionMode.drawPolygon ? '✏️ Tap corners on the map to draw boundary!' : '📍 Point Pin Mode')),
                    );
                  },
                ),
                const SizedBox(height: 10),

                // Walk Around Farm Mode Button
                FloatingActionButton.small(
                  heroTag: 'btn_walk',
                  backgroundColor: _isWalking ? Colors.redAccent : theme.scaffoldBackgroundColor,
                  child: Icon(_isWalking ? Icons.stop_rounded : Icons.directions_walk_rounded, color: _isWalking ? Colors.white : Colors.green),
                  onPressed: _toggleWalkFarmMode,
                ),
                const SizedBox(height: 10),

                if (_polygonPoints.isNotEmpty)
                  FloatingActionButton.small(
                    heroTag: 'btn_clear',
                    backgroundColor: Colors.red.shade100,
                    child: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => setState(() => _polygonPoints.clear()),
                  ),
              ],
            ),
          ),

          // 4. Bottom Sheet Details & Confirmation Box
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: theme.scaffoldBackgroundColor,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.2), blurRadius: 16)],
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // GIS Mode Status Header & Calculated Acreage Banner
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(color: Colors.green.shade100, borderRadius: BorderRadius.circular(20)),
                          child: Row(
                            children: [
                              const Icon(Icons.square_foot_rounded, color: Colors.green, size: 18),
                              const SizedBox(width: 4),
                              Text(
                                '${acres.toStringAsFixed(2)} Acres (${hectares.toStringAsFixed(2)} Ha)',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _polygonPoints.length >= 3
                              ? '${_polygonPoints.length} Points Pinned'
                              : 'Single Pin Centroid',
                          style: TextStyle(fontSize: 12, color: Colors.grey.shade700, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    // Pinned Address Summary
                    Text('$_village, $_mandal', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    Text('$_district, $_state $_pincode • [$_country]', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(height: 8),

                    // Live Weather & APMC Mandi Previews
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(12)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.wb_sunny_rounded, color: Colors.amber, size: 16),
                              const SizedBox(width: 6),
                              Expanded(child: Text(_previewWeather, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.storefront_rounded, color: Colors.green, size: 16),
                              const SizedBox(width: 6),
                              Expanded(child: Text(_previewMandi, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600))),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),

                    // Form Fields: Farm Name, Crop Selection & Survey No.
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _farmNameController,
                            decoration: const InputDecoration(labelText: 'Farm Name', isDense: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: _selectedCrop,
                            decoration: const InputDecoration(labelText: 'Crop', isDense: true),
                            items: _cropOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                            onChanged: (val) {
                              if (val != null) setState(() => _selectedCrop = val);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _surveyNumberController,
                            decoration: const InputDecoration(labelText: 'Survey No. (Optional)', isDense: true),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _landmarkController,
                            decoration: const InputDecoration(labelText: 'Landmark / Field Name', isDense: true),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),

                    // Save Farm Confirmation Button
                    ElevatedButton.icon(
                      onPressed: isIndia ? _saveFarmGis : null,
                      icon: const Icon(Icons.check_circle),
                      label: const Text('Confirm & Save Farm GIS Location', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
