import 'dart:io';
import 'package:equatable/equatable.dart';

abstract class ReportEvent extends Equatable {
  const ReportEvent();
  @override
  List<Object?> get props => [];
}

class ReportStarted extends ReportEvent {}

class ReportCategorySelected extends ReportEvent {
  final String category;
  const ReportCategorySelected(this.category);
  @override
  List<Object?> get props => [category];
}

class ReportLocationTimeUpdated extends ReportEvent {
  final double? lat;
  final double? lng;
  final String? locationLabel;
  final DateTime? time;

  const ReportLocationTimeUpdated({
    this.lat,
    this.lng,
    this.locationLabel,
    this.time,
  });

  @override
  List<Object?> get props => [lat, lng, locationLabel, time];
}

class ReportDetailsUpdated extends ReportEvent {
  final String? description;
  const ReportDetailsUpdated({this.description});
  @override
  List<Object?> get props => [description];
}

class ReportPrivacyMediaUpdated extends ReportEvent {
  final bool isAnonymous;
  final List<File> mediaFiles;

  const ReportPrivacyMediaUpdated({
    required this.isAnonymous,
    required this.mediaFiles,
  });

  @override
  List<Object?> get props => [isAnonymous, mediaFiles];
}

class ReportSubmitted extends ReportEvent {}

class MyReportsRequested extends ReportEvent {}

class GlobalReportsRequested extends ReportEvent {}

class ReportDetailRequested extends ReportEvent {
  final String id;
  const ReportDetailRequested(this.id);
  @override
  List<Object?> get props => [id];
}

class ReportTabChanged extends ReportEvent {
  final int index; // 0 = Create, 1 = My Reports
  const ReportTabChanged(this.index);
  @override
  List<Object?> get props => [index];
}
class ToggleCreateReport extends ReportEvent {
  final bool? value;
  const ToggleCreateReport({this.value});
  @override
  List<Object?> get props => [value];
}
