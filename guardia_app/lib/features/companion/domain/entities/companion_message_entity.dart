import 'package:equatable/equatable.dart';

class CompanionMessageEntity extends Equatable {
  final String id;
  final String text;
  final bool isMe;
  final bool isSystem;
  final bool isLocation;
  final double? latitude;
  final double? longitude;
  final DateTime time;

  const CompanionMessageEntity({
    required this.id,
    required this.text,
    this.isMe = false,
    this.isSystem = false,
    this.isLocation = false,
    this.latitude,
    this.longitude,
    required this.time,
  });

  @override
  List<Object?> get props => [id, text, isMe, isSystem, isLocation, latitude, longitude, time];
}
