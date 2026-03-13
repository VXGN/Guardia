import 'package:equatable/equatable.dart';

class ReportMedia extends Equatable {
  final String id;
  final String reportId;
  final String mediaType; // photo, audio, video
  final String storageUrl;
  final int? fileSizeKb;
  final bool isEncrypted;
  final DateTime createdAt;

  const ReportMedia({
    required this.id,
    required this.reportId,
    required this.mediaType,
    required this.storageUrl,
    this.fileSizeKb,
    required this.isEncrypted,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        reportId,
        mediaType,
        storageUrl,
        fileSizeKb,
        isEncrypted,
        createdAt,
      ];
}
