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

      final List<dynamic> data = response.data['data'] ?? [];
      return data.map((json) => RouteOptionModel.fromJson(json)).toList();
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
          points: [
            LatLng(originLat, originLng),
            LatLng(originLat + (destLat - originLat) / 2, originLng + (destLng - originLng) / 2 + 0.005), // simple curve
            LatLng(destLat, destLng)
          ],
        ),
        RouteOptionModel(
          id: 'dummy_fast',
          label: 'fastest',
          displayName: 'Fastest Route',
          durationSeconds: 720, // 12 mins
          distanceMeters: 3400, // 3.4 km
          safetyScore: 65.0,
          polyline: '',
          points: [
            LatLng(originLat, originLng),
            LatLng(destLat, destLng)
          ],
        ),
      ];
    }
  }
}

class ServerException implements Exception {
  final String message;
  ServerException({required this.message});
}
