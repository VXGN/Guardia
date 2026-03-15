import 'dart:io';
import 'package:equatable/equatable.dart';
import '../../../domain/entities/report_entity.dart';

enum ReportTab { community, myReports }
enum ReportStatus { initial, loading, success, failure }

class ReportState extends Equatable {
  final ReportTab currentTab;
  final int currentStep; // 0..3
  final bool isCreatingReport;
  final String? editingReportId;
  final String statusFilter;
  final String categoryFilter;
  
  // Wizard data
  final String? selectedCategory;
  final double? latitude;
  final double? longitude;
  final String? locationLabel;
  final DateTime? time;
  final String? description;
  final bool isAnonymous;
  final List<File> mediaFiles;
  
  // Statuses
  final ReportStatus submitStatus;
  final String? errorMessage;
  
  // List & Detail
  final List<ReportEntity> myReports;
  final List<ReportEntity> globalReports;
  final ReportEntity? selectedReport;
  final ReportStatus myReportsStatus;
  final ReportStatus globalReportsStatus;
  final ReportStatus detailStatus;

  const ReportState({
    this.currentTab = ReportTab.community,
    this.currentStep = 0,
    this.isCreatingReport = false,
    this.editingReportId,
    this.selectedCategory,
    this.latitude,
    this.longitude,
    this.locationLabel,
    this.time,
    this.description,
    this.isAnonymous = false,
    this.mediaFiles = const [],
    this.submitStatus = ReportStatus.initial,
    this.errorMessage,
    this.myReports = const [],
    this.globalReports = const [],
    this.selectedReport,
    this.myReportsStatus = ReportStatus.initial,
    this.globalReportsStatus = ReportStatus.initial,
    this.detailStatus = ReportStatus.initial,
    this.statusFilter = 'All',
    this.categoryFilter = 'All',
  });

  ReportState copyWith({
    ReportTab? currentTab,
    int? currentStep,
    bool? isCreatingReport,
    String? editingReportId,
    bool clearEditingReportId = false,
    String? selectedCategory,
    double? latitude,
    double? longitude,
    String? locationLabel,
    DateTime? time,
    String? description,
    bool? isAnonymous,
    List<File>? mediaFiles,
    ReportStatus? submitStatus,
    String? errorMessage,
    List<ReportEntity>? myReports,
    List<ReportEntity>? globalReports,
    ReportEntity? selectedReport,
    ReportStatus? myReportsStatus,
    ReportStatus? globalReportsStatus,
    ReportStatus? detailStatus,
    String? statusFilter,
    String? categoryFilter,
  }) {
    return ReportState(
      currentTab: currentTab ?? this.currentTab,
      currentStep: currentStep ?? this.currentStep,
      isCreatingReport: isCreatingReport ?? this.isCreatingReport,
      editingReportId: clearEditingReportId ? null : (editingReportId ?? this.editingReportId),
      selectedCategory: selectedCategory ?? this.selectedCategory,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationLabel: locationLabel ?? this.locationLabel,
      time: time ?? this.time,
      description: description ?? this.description,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      mediaFiles: mediaFiles ?? this.mediaFiles,
      submitStatus: submitStatus ?? this.submitStatus,
      errorMessage: errorMessage ?? this.errorMessage,
      myReports: myReports ?? this.myReports,
      globalReports: globalReports ?? this.globalReports,
      selectedReport: selectedReport ?? this.selectedReport,
      myReportsStatus: myReportsStatus ?? this.myReportsStatus,
      globalReportsStatus: globalReportsStatus ?? this.globalReportsStatus,
      detailStatus: detailStatus ?? this.detailStatus,
      statusFilter: statusFilter ?? this.statusFilter,
      categoryFilter: categoryFilter ?? this.categoryFilter,
    );
  }

  @override
  List<Object?> get props => [
        currentTab,
        currentStep,
        isCreatingReport,
        editingReportId,
        selectedCategory,
        latitude,
        longitude,
        locationLabel,
        time,
        description,
        isAnonymous,
        mediaFiles,
        submitStatus,
        errorMessage,
        myReports,
        globalReports,
        selectedReport,
        myReportsStatus,
        globalReportsStatus,
        detailStatus,
        statusFilter,
        categoryFilter,
      ];
}
