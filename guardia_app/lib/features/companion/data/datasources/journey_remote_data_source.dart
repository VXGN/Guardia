import 'package:guardia_app/core/network/api_client.dart';
import 'package:guardia_app/core/network/endpoints.dart';
import 'package:guardia_app/features/companion/data/models/journey_session_model.dart';

abstract class JourneyRemoteDataSource {
  Future<JourneySessionModel> startJourney({
    required double lat,
    required double lng,
    required List<String> contactIds,
  });

  Future<void> updateJourneyLocation({
    required String sessionId,
    required double lat,
    required double lng,
  });

  Future<JourneySessionModel?> getActiveJourney();

  Future<void> endJourney({required String sessionId});
}

class JourneyRemoteDataSourceImpl implements JourneyRemoteDataSource {
  final ApiClient apiClient;

  JourneyRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<JourneySessionModel> startJourney({
    required double lat,
    required double lng,
    required List<String> contactIds,
  }) async {
    final response = await apiClient.post(
      Endpoints.journeys,
      data: {
        'originLat': lat,
        'originLng': lng,
        'trustedContactIds': contactIds,
      },
    );
    return JourneySessionModel.fromJson(response.data);
  }

  @override
  Future<void> updateJourneyLocation({
    required String sessionId,
    required double lat,
    required double lng,
  }) async {
    await apiClient.post(
      Endpoints.journeyLocations(sessionId),
      data: {
        'latitude': lat,
        'longitude': lng,
      },
    );
  }

  @override
  Future<JourneySessionModel?> getActiveJourney() async {
    final response = await apiClient.get(Endpoints.activeJourney);
    if (response.data == null) return null;
    return JourneySessionModel.fromJson(response.data);
  }

  @override
  Future<void> endJourney({required String sessionId}) async {
    await apiClient.post(Endpoints.finishJourney(sessionId));
  }
}
