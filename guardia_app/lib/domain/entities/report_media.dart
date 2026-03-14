import 'package:equatable/equatable.dart';

class ReportMedia extends Equatable {

  const ReportMedia({
    required this.id,
    required this.reportId,
    required this.mediaType,
    required this.storageUrl,
    required this.isEncrypted, required this.createdAt, this.fileSizeKb,
  });
  final String id;
  final String reportId;
  final String mediaType; // photo, audio, video
  final String storageUrl;
  final int? fileSizeKb;
  final bool isEncrypted;
  final DateTime createdAt;

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
