import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/utils/location_utils.dart';
import 'package:guardia_app/features/routing/data/models/route_option_model.dart';
import 'package:guardia_app/features/routing/data/models/route_step_model.dart';
import 'package:dio/dio.dart';
import 'package:latlong2/latlong.dart';

import 'package:guardia_app/core/network/endpoints.dart';
abstract class RoutingRemoteDataSource {
  Future<List<RouteOptionModel>> getSafeRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  });
}

class RoutingRemoteDataSourceImpl implements RoutingRemoteDataSource {
  final ApiClient apiClient;

  RoutingRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<RouteOptionModel>> getSafeRoutes({
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) async {
    try {
      final response = await apiClient.post(
        Endpoints.safeRoute,
        data: {
          'start_lat': originLat,
          'start_lng': originLng,
          'end_lat': destLat,
          'end_lng': destLng,
        },
      );

      final parsedRoutes = _parseServerRoutes(
        response.data,
        originLat: originLat,
        originLng: originLng,
        destLat: destLat,
        destLng: destLng,
      );
      if (parsedRoutes.isNotEmpty) {
        return parsedRoutes;
      }

      throw ServerException(message: 'Safe route response is empty');
    } catch (e) {
      // Catching any exception here (ServerException, NetworkException from ApiClient)
      // Fallback to dummy data if server is offline or fails
      print('Network error fetching routes: $e');

      try {
        final osrmDio = Dio(BaseOptions(
          connectTimeout: const Duration(seconds: 3),
          receiveTimeout: const Duration(seconds: 3),
        ));
        // To simulate "avoiding" a high-risk zone in the middle of a straight line,
        // we will ask OSRM to route via an intermediate waypoint that forces a detour curve.
        // We use the shared mock hazard location so the route visually bends around the red circle.
        final mockHazard = LocationUtils.getMockHazardLocation(originLat, originLng);
        
        // Push the detour slightly further out from the hazard center itself so the route
        // sweeps cleanly around the radius of the circle rather than intersecting its core.
        final detourLat = mockHazard['lat']! + 0.005; 
        final detourLng = mockHazard['lng']! + 0.005;

        // Request a Safe Route (detoured via waypoint)
        final osrmSafeUrl = 'http://router.project-osrm.org/route/v1/driving/$originLng,$originLat;$detourLng,$detourLat;$destLng,$destLat?overview=full&steps=true';
        final osrmSafeResponse = await osrmDio.get(osrmSafeUrl);
        
        // Request a Fast Route (direct)
        final osrmFastUrl = 'http://router.project-osrm.org/route/v1/driving/$originLng,$originLat;$destLng,$destLat?overview=full&steps=true';
        final osrmFastResponse = await osrmDio.get(osrmFastUrl);

        if (osrmSafeResponse.statusCode == 200 && osrmFastResponse.statusCode == 200) {
          final safeRoute = osrmSafeResponse.data['routes'][0];
          final safeGeometry = safeRoute['geometry'] as String;
          final safeDistance = safeRoute['distance'] as num;
          final safeDuration = safeRoute['duration'] as num;
          final List<dynamic> safeSteps = safeRoute['legs'][0]['steps'] ?? [];

          final fastRoute = osrmFastResponse.data['routes'][0];
          final fastGeometry = fastRoute['geometry'] as String;
          final fastDistance = fastRoute['distance'] as num;
          final fastDuration = fastRoute['duration'] as num;
          final List<dynamic> fastSteps = fastRoute['legs'][0]['steps'] ?? [];

          return [
            RouteOptionModel(
              id: 'fallback_safe',
              label: 'safest',
              displayName: 'Safe Guardia (Auto)',
              durationSeconds: safeDuration.toInt(),
              distanceMeters: safeDistance.toInt(),
              safetyScore: 92.5,
              polyline: safeGeometry,
              points: RouteOptionModel.decodePolyline(safeGeometry),
              steps: safeSteps.map((s) => RouteStepModel.fromJson(s as Map<String, dynamic>)).toList(),
            ),
            RouteOptionModel(
              id: 'fallback_fast',
              label: 'fastest',
              displayName: 'Fastest Route (Auto)',
              durationSeconds: fastDuration.toInt(),
              distanceMeters: fastDistance.toInt(),
              safetyScore: 65.0,
              polyline: fastGeometry,
              points: RouteOptionModel.decodePolyline(fastGeometry),
              steps: fastSteps.map((s) => RouteStepModel.fromJson(s as Map<String, dynamic>)).toList(),
            ),
          ];
        }
      } catch (osrmError) {
        print('OSRM fallback failed: $osrmError');
      }

      // If OSRM fails too, fallback to straight line dummy
      return [
        RouteOptionModel(
          id: 'dummy_safe',
          label: 'safest',
          displayName: 'Safe Guardia',
          durationSeconds: 840, // 14 mins
          distanceMeters: 3800, // 3.8 km
          safetyScore: 92.5,
          polyline: '',
          points: _sanitizePoints([
            LatLng(originLat, originLng),
            LatLng(originLat + (destLat - originLat) / 2, originLng + (destLng - originLng) / 2 + 0.005), // simple curve
            LatLng(destLat, destLng)
          ], fallbackOrigin: LatLng(originLat, originLng), fallbackDestination: LatLng(destLat, destLng)),
        ),
        RouteOptionModel(
          id: 'dummy_fast',
          label: 'fastest',
          displayName: 'Fastest Route',
          durationSeconds: 720, // 12 mins
          distanceMeters: 3400, // 3.4 km
          safetyScore: 65.0,
          polyline: '',
          points: _sanitizePoints([
            LatLng(originLat, originLng),
            LatLng(destLat, destLng)
          ], fallbackOrigin: LatLng(originLat, originLng), fallbackDestination: LatLng(destLat, destLng)),
        ),
      ];
    }
  }

  List<RouteOptionModel> _parseServerRoutes(
    dynamic rawResponse, {
    required double originLat,
    required double originLng,
    required double destLat,
    required double destLng,
  }) {
    // Legacy shape: data is already a list of route options.
    if (rawResponse is List) {
      return rawResponse
          .whereType<Map>()
          .map((item) => RouteOptionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    if (rawResponse is! Map<String, dynamic>) {
      return const [];
    }

    final payload = rawResponse['data'];

    if (payload is List) {
      return payload
          .whereType<Map>()
          .map((item) => RouteOptionModel.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    }

    // Current backend shape:
    // { success, message, data: { route: [{lat,lng}], total_distance_meters, ... } }
    if (payload is Map<String, dynamic>) {
      final routeRaw = payload['route'];
      final points = _pointsFromRouteList(routeRaw);
      final safePoints = _sanitizePoints(
        points,
        fallbackOrigin: LatLng(originLat, originLng),
        fallbackDestination: LatLng(destLat, destLng),
      );

      final distanceMeters = (payload['total_distance_meters'] as num?)?.toInt() ?? 0;
      final durationSeconds = (payload['estimated_duration_seconds'] as num?)?.toInt() ?? 0;
      final totalRisk = (payload['total_risk_score'] as num?)?.toDouble() ?? 0.0;

      return [
        RouteOptionModel(
          id: 'server_safe',
          label: 'safest',
          displayName: 'Safe Guardia',
          durationSeconds: durationSeconds,
          distanceMeters: distanceMeters,
          safetyScore: _riskToSafetyScore(totalRisk),
          polyline: '',
          points: safePoints,
          steps: const [],
        ),
      ];
    }

    return const [];
  }

  List<LatLng> _pointsFromRouteList(dynamic routeRaw) {
    if (routeRaw is! List) {
      return const [];
    }

    final points = <LatLng>[];
    for (final item in routeRaw) {
      if (item is! Map) {
        continue;
      }

      final lat = (item['lat'] as num?)?.toDouble();
      final lng = (item['lng'] as num?)?.toDouble();
      if (lat == null || lng == null) {
        continue;
      }

      if (_isValidLatLng(lat, lng)) {
        points.add(LatLng(lat, lng));
      }
    }

    return points;
  }

  List<LatLng> _sanitizePoints(
    List<LatLng> rawPoints, {
    required LatLng fallbackOrigin,
    required LatLng fallbackDestination,
  }) {
    final points = rawPoints
        .where((point) => _isValidLatLng(point.latitude, point.longitude))
        .toList();

    if (points.length >= 2) {
      return points;
    }

    return [fallbackOrigin, fallbackDestination];
  }

  bool _isValidLatLng(double lat, double lng) {
    return lat >= -90 && lat <= 90 && lng >= -180 && lng <= 180;
  }

  double _riskToSafetyScore(double totalRiskScore) {
    final score = (100.0 - totalRiskScore).clamp(0.0, 100.0);
    return score;
  }
}

class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}
