import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/domain/entities/heatmap_cluster.dart';
import 'package:guardia_app/presentation/bloc/risk/risk_bloc.dart';
import 'package:guardia_app/presentation/bloc/risk/risk_event.dart';
import 'package:guardia_app/presentation/bloc/risk/risk_state.dart';
import 'package:guardia_app/presentation/widgets/journey/active_navigation_overlay.dart';
import 'package:guardia_app/presentation/widgets/journey/routing_options_sheet.dart';
import 'package:guardia_app/features/notifications/presentation/bloc/notification_bloc.dart';
import 'package:guardia_app/features/notifications/presentation/bloc/notification_event.dart';
import 'package:guardia_app/features/notifications/presentation/bloc/notification_state.dart';
import 'package:guardia_app/features/routing/presentation/bloc/routing/routing_bloc.dart';
import 'package:guardia_app/features/routing/presentation/bloc/routing/routing_event.dart';
import 'package:guardia_app/features/routing/presentation/bloc/routing/routing_state.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:guardia_app/core/utils/location_utils.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static const LatLng _initialCenter = LatLng(-8.5830695, 116.1155455);
  static const double _riskRadiusMeters = 5000;
  final MapController _mapController = MapController();

  LatLng _currentCenter = _initialCenter;

  final List<CircleMarker> _riskZones = [];
  bool _isNavigationActive = false;
  // Route polyline decoding is now handled by the data layer (RouteOptionModel).
  int _clusterCount = 0;
  int _riskScoreCount = 0;
  double _maxRiskScore = 0.0;
  String? _riskError;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      final riskBloc = context.read<RiskBloc>();
      riskBloc.add(
        LoadHeatmapRequested(
          latitude: _initialCenter.latitude,
          longitude: _initialCenter.longitude,
          radiusMeters: _riskRadiusMeters,
        ),
      );
      riskBloc.add(
        LoadAreaRiskSummaryRequested(
          _initialCenter.latitude,
          _initialCenter.longitude,
          radiusMeters: _riskRadiusMeters,
        ),
      );

      // Load notifications for the badge
      context.read<NotificationBloc>().add(LoadNotificationsRequested());

      // Fetch actual location
      _getCurrentLocation();
    });
  }

  Future<void> _getCurrentLocation() async {
    final granted = await LocationUtils.checkAndRequestPermission();
    if (!granted) return;

    try {
      final position = await LocationUtils.getCurrentPosition();
      if (!mounted) return;

      final newCenter = LatLng(position.latitude, position.longitude);
      setState(() {
        _currentCenter = newCenter;
      });

      _mapController.move(newCenter, 13.0);

      // Refresh risk data for the actual location
      if (context.mounted) {
        final riskBloc = context.read<RiskBloc>();
        riskBloc.add(
          LoadHeatmapRequested(
            latitude: newCenter.latitude,
            longitude: newCenter.longitude,
            radiusMeters: _riskRadiusMeters,
          ),
        );
        riskBloc.add(
          LoadAreaRiskSummaryRequested(
            newCenter.latitude,
            newCenter.longitude,
            radiusMeters: _riskRadiusMeters,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _setHeatmapClusters(List<HeatmapCluster> clusters) {
    _riskZones
      ..clear()
      ..addAll(
        clusters.map((cluster) {
          final color = _colorForIntensity(cluster.intensity);
          return CircleMarker(
            point: LatLng(cluster.centerLatBlurred, cluster.centerLngBlurred),
            radius: cluster.radiusMeters.toDouble(),
            useRadiusInMeter: true,
            color: color.withValues(alpha: 0.22),
            borderColor: color.withValues(alpha: 0.45),
            borderStrokeWidth: 1,
          );
        }),
      );
    _clusterCount = clusters.length;
  }

  Color _colorForIntensity(String intensity) {
    switch (intensity.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'medium':
        return Colors.yellow.shade700;
      case 'low':
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return MultiBlocListener(
      listeners: [
        BlocListener<RiskBloc, RiskState>(
          listener: (context, state) {
            if (state is HeatmapLoaded) {
              setState(() {
                _riskError = null;
                _setHeatmapClusters(state.clusters);
              });
            } else if (state is AreaRiskSummaryLoaded) {
              setState(() {
                _riskError = null;
                _riskScoreCount =
                    (state.summary['risk_score_count'] as num?)?.toInt() ?? 0;
                _maxRiskScore =
                    (state.summary['max_risk_score'] as num?)?.toDouble() ??
                    0.0;
                _clusterCount =
                    (state.summary['heatmap_cluster_count'] as num?)?.toInt() ??
                    _clusterCount;
              });
            } else if (state is RiskError) {
              setState(() {
                _riskError = state.message;
              });
            }
          },
        ),
        BlocListener<RoutingBloc, RoutingState>(
          listener: (context, state) {
            // Show options sheet when routes are loaded and not already navigating
            if (!state.isRequestingRoutes &&
                state.routes.isNotEmpty &&
                !state.isNavigating &&
                ModalRoute.of(context)?.isCurrent == true) {
              // check if sheet is already open

              // Only show if we just finished requesting (and error is null)
              // This prevents it from re-opening on hot reloads or state rebuilds
              // To be safe we should check if bottom sheet is shown, but for simplicity:
              showModalBottomSheet<void>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => RoutingOptionsSheet(
                  onStart: () {
                    context.read<RoutingBloc>().add(const NavigationStarted());
                  },
                ),
              );
            }

            if (state.isNavigating && state.selectedRoute != null) {
              setState(() {
                _isNavigationActive = true;
              });
            } else if (!state.isNavigating && !state.isRequestingRoutes) {
              setState(() {
                _isNavigationActive = false;
                _searchController.clear();
              });
            }

            // Handle Errors
            if (state.errorMessage != null) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.errorMessage!),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
        ),
      ],
      child: Scaffold(
        body: Stack(
          children: [
            // 1. OpenStreetMap Background
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _currentCenter,
                initialZoom: 13.0,
                onTap: (tapPosition, point) {
                  // Handle tap event if needed
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.guardia_app',
                ),
                BlocBuilder<RoutingBloc, RoutingState>(
                  builder: (context, routingState) {
                    return routingState.selectedRoute != null
                        ? PolylineLayer(
                            polylines: [
                              Polyline(
                                points: routingState.selectedRoute!.points,
                                strokeWidth:
                                    6.0, // Thicker blue line as requested
                                color: Colors.blueAccent,
                              ),
                            ],
                          )
                        : const SizedBox.shrink();
                  },
                ),
                CircleLayer(circles: _riskZones),
                // Current Location and Destination Markers
                BlocBuilder<RoutingBloc, RoutingState>(
                  builder: (context, routingState) {
                    final markers = <Marker>[
                      // Current Location Marker
                      Marker(
                        point: _currentCenter,
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
                    ];

                    // Add Destination Marker if available
                    if (routingState.destinationLat != null &&
                        routingState.destinationLng != null) {
                      markers.add(
                        Marker(
                          point: LatLng(
                            routingState.destinationLat!,
                            routingState.destinationLng!,
                          ),
                          alignment: Alignment.topCenter,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      );
                    }

                    return MarkerLayer(markers: markers);
                  },
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
                    onSubmitted: (value) async {
                      if (value.isNotEmpty) {
                        try {
                          List<Location> locations = await locationFromAddress(
                            value,
                          );
                          if (locations.isNotEmpty) {
                            final loc = locations.first;
                            // 1. Set Origin
                            if (context.mounted) {
                              context.read<RoutingBloc>().add(
                                RoutingOriginChanged(
                                  _currentCenter.latitude,
                                  _currentCenter.longitude,
                                ),
                              );

                              // 2. Set Real Destination
                              context.read<RoutingBloc>().add(
                                RoutingDestinationChanged(
                                  query: value,
                                  lat: loc.latitude,
                                  lng: loc.longitude,
                                ),
                              );

                              // 3. Request Routes
                              context.read<RoutingBloc>().add(
                                const RoutingRequested(),
                              );
                            }
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Location not found')),
                            );
                          }
                        }
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
                      suffixIcon: BlocBuilder<NotificationBloc, NotificationState>(
                        builder: (context, state) {
                          int unreadCount = 0;
                          if (state is NotificationsLoaded) {
                            unreadCount = state.notifications
                                .where((n) => !n.isSent)
                                .length; // Using isSent as a proxy for unread in this mock/early stage
                          }

                          return GestureDetector(
                            onTap: () => context.pushNamed('notifications'),
                            child: Container(
                              margin: const EdgeInsets.only(
                                right: 8,
                                top: 8,
                                bottom: 8,
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(
                                    Icons.notifications_outlined,
                                    color: AppColors.textSecondary,
                                    size: 28,
                                  ),
                                  if (unreadCount > 0)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(
                                          color: Colors.red,
                                          shape: BoxShape.circle,
                                        ),
                                        constraints: const BoxConstraints(
                                          minWidth: 16,
                                          minHeight: 16,
                                        ),
                                        child: Text(
                                          '$unreadCount',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 10,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18),
                    ),
                  ),
                ),
              ),

            if (_isNavigationActive)
              BlocBuilder<RoutingBloc, RoutingState>(
                builder: (context, state) {
                  return ActiveNavigationOverlay(
                    route: state.selectedRoute,
                    onFinish: () {
                      context.read<RoutingBloc>().add(
                        const NavigationStopped(),
                      );
                    },
                  );
                },
              ),
            if (!_isNavigationActive)
              Positioned(
                left: 24,
                right: 24,
                // Keep card just above the SOS FAB and system gesture bar
                // without floating too high on tall devices.
                bottom: 40 + bottomInset,
                child: _RiskSummaryCard(
                  clusterCount: _clusterCount,
                  riskScoreCount: _riskScoreCount,
                  maxRiskScore: _maxRiskScore,
                  errorMessage: _riskError,
                ),
              ),

            // 3. Map Header
            if (!_isNavigationActive)
              Positioned(
                top: 124,
                left: 24,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Local Security Overview',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF1E293B),
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      'Real-time data from community reports',
                      style: TextStyle(
                        fontSize: 12,
                        color: const Color(0xFF64748B),
                        shadows: [
                          Shadow(
                            color: Colors.white.withValues(alpha: 0.8),
                            blurRadius: 4,
                          ),
                        ],
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

class _RiskSummaryCard extends StatelessWidget {
  const _RiskSummaryCard({
    required this.clusterCount,
    required this.riskScoreCount,
    required this.maxRiskScore,
    this.errorMessage,
  });

  final int clusterCount;
  final int riskScoreCount;
  final double maxRiskScore;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    if (errorMessage != null) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Row(
          children: [
            const Icon(Icons.error_outline, color: AppColors.error),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                errorMessage!,
                style: const TextStyle(
                  color: AppColors.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.security,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Area Security Status',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const Spacer(),
              _buildRiskBadge(maxRiskScore),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildIndicator(Icons.radar, 'Monitoring', '$clusterCount Zones'),
              _buildIndicator(
                Icons.analytics_outlined,
                'Precision',
                '$riskScoreCount Segments',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRiskBadge(double score) {
    Color color = score > 7
        ? AppColors.error
        : (score > 4 ? Colors.orange : AppColors.success);
    String label = score > 7
        ? 'HIGH RISK'
        : (score > 4 ? 'MODERATE' : 'SAFE ARCH');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildIndicator(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF94A3B8), size: 16),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Color(0xFF334155),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
