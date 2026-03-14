import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/presentation/widgets/journey/active_navigation_overlay.dart';
import 'package:guardia_app/presentation/widgets/journey/routing_options_sheet.dart';
import 'package:latlong2/latlong.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mataram city center as default/initial location
  static const LatLng _initialCenter = LatLng(-8.5830695, 116.1155455);
  final MapController _mapController = MapController();

  final List<CircleMarker> _riskZones = [];
  bool _isNavigationActive = false;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _setupMockRiskZones();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Sets up mock heatmap zones to simulate the design.
  void _setupMockRiskZones() {
    _riskZones.addAll([
      CircleMarker(
        point: const LatLng(-8.5830695, 116.1155455),
        radius: 300,
        useRadiusInMeter: true,
        color: Colors.orange.withValues(alpha: 0.25),
        borderColor: Colors.orange.withValues(alpha: 0.4),
        borderStrokeWidth: 1,
      ),
      CircleMarker(
        point: const LatLng(-8.5700, 116.1200),
        radius: 600,
        useRadiusInMeter: true,
        color: Colors.red.withValues(alpha: 0.20),
        borderColor: Colors.red.withValues(alpha: 0.4),
        borderStrokeWidth: 1,
      ),
      CircleMarker(
        point: const LatLng(-8.5900, 116.1000),
        radius: 400,
        useRadiusInMeter: true,
        color: Colors.yellow.withValues(alpha: 0.22),
        borderColor: Colors.yellow.withValues(alpha: 0.45),
        borderStrokeWidth: 1,
      ),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 1. OpenStreetMap Background
          FlutterMap(
            mapController: _mapController,
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 14,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.guardia_app',
              ),
              CircleLayer(
                circles: _riskZones,
              ),
              // Current Location Marker placeholder
              MarkerLayer(
                markers: [
                  Marker(
                    point: _initialCenter,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.blue.withAlpha(50),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                      ),
                      child: Center(
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          
          // 2. Conditional Overlays (Search or Active Navigation)
          if (!_isNavigationActive)
            Positioned(
              top: 56, // Safe area + padding
              left: 24,
              right: 24,
              child: Container(
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(20),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    // Handle search suggestions here if needed
                  },
                  onTap: () {
                    // Interaction logic
                  },
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      showModalBottomSheet<void>(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (context) => RoutingOptionsSheet(
                          onStart: () {
                            setState(() {
                              _isNavigationActive = true;
                            });
                          },
                        ),
                      );
                    }
                  },
                  decoration: InputDecoration(
                    hintText: 'Where to safely today?',
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    prefixIcon: const Icon(
                      Icons.search,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => context.push('/profile'),
                      child: Container(
                        width: 40,
                        height: 40,
                        margin: const EdgeInsets.only(right: 8, top: 4, bottom: 4),
                        decoration: const BoxDecoration(
                          color: Color(0xFFC4C4C4),
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            'US',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 18),
                  ),
                ),
              ),
            ),

          if (_isNavigationActive)
            ActiveNavigationOverlay(
              onFinish: () {
                setState(() {
                  _isNavigationActive = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
