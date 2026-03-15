import 'package:equatable/equatable.dart';

/// Represents an incident report in the domain layer.
class ReportEntity extends Equatable {
  final String id;
  final String? userId;
  final String category; // e.g. verbal_harassment, physical_harassment, pickpocket, stalking, intimidation, other
  final String? description;
  final double latitude;
  final double longitude;
  final String locationLabel;
  final DateTime timestamp;
  final bool isAnonymous;
  final String status; // RECEIVED, VERIFIED, ACTION_TAKEN, CLOSED
  final List<String> mediaUrls;

  const ReportEntity({
    required this.id,
    this.userId,
    required this.category,
    this.description,
    required this.latitude,
    required this.longitude,
    required this.locationLabel,
    required this.timestamp,
    required this.isAnonymous,
    required this.status,
    required this.mediaUrls,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        category,
        description,
        latitude,
        longitude,
        locationLabel,
        timestamp,
        isAnonymous,
        status,
        mediaUrls,
      ];
}
