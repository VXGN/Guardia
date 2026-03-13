import 'package:guardia_app/domain/entities/report_media.dart';

class ReportMediaModel extends ReportMedia {
  const ReportMediaModel({
    required super.id,
    required super.reportId,
    required super.mediaType,
    required super.storageUrl,
    super.fileSizeKb,
    required super.isEncrypted,
    required super.createdAt,
  });

  factory ReportMediaModel.fromJson(Map<String, dynamic> json) {
    return ReportMediaModel(
      id: json['id'] as String,
      reportId: json['report_id'] as String,
      mediaType: json['media_type'] as String,
      storageUrl: json['storage_url'] as String,
      fileSizeKb: json['file_size_kb'] as int?,
      isEncrypted: json['is_encrypted'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'report_id': reportId,
      'media_type': mediaType,
      'storage_url': storageUrl,
      'file_size_kb': fileSizeKb,
      'is_encrypted': isEncrypted,
      'created_at': createdAt.toIso8601String(),
    };
  }
}
