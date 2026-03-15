import 'package:guardia_app/features/routing/data/models/route_step_model.dart';
import 'package:guardia_app/features/routing/domain/entities/route_option_entity.dart';
import 'package:latlong2/latlong.dart';

class RouteOptionModel extends RouteOptionEntity {
  const RouteOptionModel({
    required super.id,
    required super.label,
    required super.displayName,
    required super.durationSeconds,
    required super.distanceMeters,
    required super.safetyScore,
    required super.polyline,
    required super.points,
    super.steps = const [],
  });

  factory RouteOptionModel.fromJson(Map<String, dynamic> json) {
    // Generate the original model fields from partial generation if present, 
    // or manually to inject points.
    final id = json['id'] as String? ?? '';
    final label = json['label'] as String? ?? '';
    final displayName = json['displayName'] as String? ?? '';
    final durationSeconds = (json['durationSeconds'] as num?)?.toInt() ?? 0;
    final distanceMeters = (json['distanceMeters'] as num?)?.toInt() ?? 0;
    final safetyScore = (json['safetyScore'] as num?)?.toDouble() ?? 0.0;
    final polylineStr = json['polyline'] as String? ?? '';

    final List<dynamic> stepsJson = json['steps'] as List<dynamic>? ?? [];
    final steps = stepsJson.map((s) => RouteStepModel.fromJson(s as Map<String, dynamic>)).toList();

    return RouteOptionModel(
      id: id,
      label: label,
      displayName: displayName,
      durationSeconds: durationSeconds,
      distanceMeters: distanceMeters,
      safetyScore: safetyScore,
      polyline: polylineStr,
      points: decodePolyline(polylineStr),
      steps: steps,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'label': label,
    'displayName': displayName,
    'durationSeconds': durationSeconds,
    'distanceMeters': distanceMeters,
    'safetyScore': safetyScore,
    'polyline': polyline,
    'steps': steps.map((s) => (s as RouteStepModel).toJson()).toList(),
  };

  factory RouteOptionModel.fromEntity(RouteOptionEntity entity) {
    return RouteOptionModel(
      id: entity.id,
      label: entity.label,
      displayName: entity.displayName,
      durationSeconds: entity.durationSeconds,
      distanceMeters: entity.distanceMeters,
      safetyScore: entity.safetyScore,
      polyline: entity.polyline,
      points: entity.points,
    );
  }

  static List<LatLng> decodePolyline(String encodedPolyline) {
    List<LatLng> polylineCoords = [];
    int index = 0, len = encodedPolyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      try {
        int b, shift = 0, result = 0;
        do {
          b = encodedPolyline.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);
        int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lat += dlat;

        shift = 0;
        result = 0;
        do {
          if (index >= len) break;
          b = encodedPolyline.codeUnitAt(index++) - 63;
          result |= (b & 0x1f) << shift;
          shift += 5;
        } while (b >= 0x20 && index < len);
        int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
        lng += dlng;

        polylineCoords.add(LatLng((lat / 1E5).toDouble(), (lng / 1E5).toDouble()));
      } catch (e) {
        break;
      }
    }
    return polylineCoords;
  }
}
