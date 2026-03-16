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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Mataram city center as default/initial location
  static const LatLng _initialCenter = LatLng(-8.5830695, 116.1155455);
  static const double _riskRadiusMeters = 5000;
  final MapController _mapController = MapController();

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
    });
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
        clusters.map(
          (cluster) {
            final color = _colorForIntensity(cluster.intensity);
            return CircleMarker(
              point: LatLng(cluster.centerLatBlurred, cluster.centerLngBlurred),
              radius: cluster.radiusMeters.toDouble(),
              useRadiusInMeter: true,
              color: color.withValues(alpha: 0.22),
              borderColor: color.withValues(alpha: 0.45),
              borderStrokeWidth: 1,
            );
          },
        ),
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
                _riskScoreCount = (state.summary['risk_score_count'] as num?)?.toInt() ?? 0;
                _maxRiskScore = (state.summary['max_risk_score'] as num?)?.toDouble() ?? 0.0;
                _clusterCount = (state.summary['heatmap_cluster_count'] as num?)?.toInt() ?? _clusterCount;
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
                ModalRoute.of(context)?.isCurrent == true) { // check if sheet is already open
                 
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
                SnackBar(content: Text(state.errorMessage!), backgroundColor: AppColors.error),
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
            options: const MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 14,
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
                            strokeWidth: 6.0, // Thicker blue line as requested
                            color: Colors.blueAccent,
                          ),
                        ],
                      )
                    : const SizedBox.shrink();
                },
              ),
              CircleLayer(
                circles: _riskZones,
              ),
              // Current Location and Destination Markers
              BlocBuilder<RoutingBloc, RoutingState>(
                builder: (context, routingState) {
                  final markers = <Marker>[
                    // Current Location Marker
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
                  ];

                  // Add Destination Marker if available
                  if (routingState.destinationLat != null && routingState.destinationLng != null) {
                    markers.add(
                      Marker(
                        point: LatLng(routingState.destinationLat!, routingState.destinationLng!),
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
                        List<Location> locations = await locationFromAddress(value);
                        if (locations.isNotEmpty) {
                          final loc = locations.first;
                          // 1. Set Origin
                          if (context.mounted) {
                            context.read<RoutingBloc>().add(RoutingOriginChanged(
                               _initialCenter.latitude,
                               _initialCenter.longitude,
                            ));
                            
                            // 2. Set Real Destination
                            context.read<RoutingBloc>().add(RoutingDestinationChanged(
                              query: value,
                              lat: loc.latitude, 
                              lng: loc.longitude,
                            ));

                            // 3. Request Routes
                            context.read<RoutingBloc>().add(const RoutingRequested());
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
                          unreadCount = state.notifications.where((n) => !n.isSent).length; // Using isSent as a proxy for unread in this mock/early stage
                        }

                        return GestureDetector(
                          onTap: () => context.pushNamed('notifications'),
                          child: Container(
                            margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
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
                    context.read<RoutingBloc>().add(const NavigationStopped());
                  },
                );
              },
            ),
          if (!_isNavigationActive)
            Positioned(
              left: 16,
              right: 16,
              bottom: 110,
              child: _RiskSummaryCard(
              clusterCount: _clusterCount,
              riskScoreCount: _riskScoreCount,
              maxRiskScore: _maxRiskScore,
              errorMessage: _riskError,
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
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.insights, color: AppColors.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              errorMessage ??
                  'Risk: ${maxRiskScore.toStringAsFixed(1)} | Zones: $clusterCount | Segments: $riskScoreCount',
              style: TextStyle(
                color: errorMessage != null ? AppColors.error : const Color(0xFF1E293B),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
