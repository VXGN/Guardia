import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../domain/entities/report_entity.dart';
import '../../../domain/usecases/create_report.dart';
import '../../../domain/usecases/get_my_reports.dart';
import '../../../domain/usecases/get_all_reports.dart';
import '../../../domain/usecases/get_report_detail.dart';
import '../../../domain/usecases/update_report.dart';
import '../../../domain/usecases/delete_report.dart';
import 'report_event.dart';
import 'report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final CreateReport createReport;
  final GetMyReports getMyReports;
  final GetAllReports getAllReports;
  final GetReportDetail getReportDetail;
  final UpdateReport updateReport;
  final DeleteReport deleteReport;

  ReportBloc({
    required this.createReport,
    required this.getMyReports,
    required this.getAllReports,
    required this.getReportDetail,
    required this.updateReport,
    required this.deleteReport,
  }) : super(const ReportState()) {
    on<ReportStarted>(_onReportStarted);
    on<ReportCategorySelected>(_onCategorySelected);
    on<ReportLocationTimeUpdated>(_onLocationTimeUpdated);
    on<ReportDetailsUpdated>(_onDetailsUpdated);
    on<ReportPrivacyMediaUpdated>(_onPrivacyMediaUpdated);
    on<ReportSubmitted>(_onSubmitted);
    on<MyReportsRequested>(_onMyReportsRequested);
    on<ReportDetailRequested>(_onReportDetailRequested);
    on<ReportTabChanged>(_onTabChanged);
    on<ToggleCreateReport>(_onToggleCreateReport);
    on<GlobalReportsRequested>(_onGlobalReportsRequested);
    on<DeleteReportRequested>(_onDeleteReportRequested);
    on<EditReportRequested>(_onEditReportRequested);
    on<ReportFilterChanged>(_onFilterChanged);
  }

  void _onFilterChanged(ReportFilterChanged event, Emitter<ReportState> emit) {
    emit(state.copyWith(
      statusFilter: event.status,
      categoryFilter: event.category,
    ));
  }


  void _onReportStarted(ReportStarted event, Emitter<ReportState> emit) {
    emit(const ReportState());
    add(GlobalReportsRequested());
  }

  void _onCategorySelected(ReportCategorySelected event, Emitter<ReportState> emit) {
    emit(state.copyWith(
      selectedCategory: event.category,
      currentStep: 1,
    ));
  }

  void _onLocationTimeUpdated(ReportLocationTimeUpdated event, Emitter<ReportState> emit) {
    emit(state.copyWith(
      latitude: event.lat,
      longitude: event.lng,
      locationLabel: event.locationLabel,
      time: event.time,
      currentStep: 2,
    ));
  }

  void _onDetailsUpdated(ReportDetailsUpdated event, Emitter<ReportState> emit) {
    emit(state.copyWith(
      description: event.description,
      currentStep: 3,
    ));
  }

  void _onPrivacyMediaUpdated(ReportPrivacyMediaUpdated event, Emitter<ReportState> emit) {
    emit(state.copyWith(
      isAnonymous: event.isAnonymous,
      mediaFiles: event.mediaFiles,
    ));
  }

  Future<void> _onSubmitted(ReportSubmitted event, Emitter<ReportState> emit) async {
    if (state.selectedCategory == null) {
      emit(state.copyWith(
        submitStatus: ReportStatus.failure,
        errorMessage: 'Please select a category.',
      ));
      return;
    }

    final description = state.description?.trim();
    if (description != null && description.isNotEmpty && description.length < 10) {
      emit(state.copyWith(
        submitStatus: ReportStatus.failure,
        errorMessage: 'Description must be at least 10 characters.',
      ));
      return;
    }

    emit(state.copyWith(submitStatus: ReportStatus.loading));

    try {
      final report = ReportEntity(
        id: DateTime.now().millisecondsSinceEpoch.toString(), // Temp ID
        userId: FirebaseAuth.instance.currentUser?.uid,
        category: state.selectedCategory!,
        description: state.description,
        latitude: state.latitude ?? 0.0,
        longitude: state.longitude ?? 0.0,
        locationLabel: state.locationLabel ?? '',
        timestamp: state.time ?? DateTime.now(),
        isAnonymous: state.isAnonymous,
        status: 'RECEIVED',
        mediaUrls: const [], // Will be filled after upload
      );

      if (state.editingReportId != null) {
        // Handle update
        final updatedReport = report.copyWith(id: state.editingReportId);
        await updateReport(updatedReport, state.mediaFiles);
      } else {
        // Handle create
        await createReport(report, state.mediaFiles);
      }

      emit(state.copyWith(
        submitStatus: ReportStatus.success,
        isCreatingReport: false,
        editingReportId: null, // Clear after success
      ));
      // Optionally reset or refresh
      add(MyReportsRequested());
    } catch (e) {
      emit(state.copyWith(
        submitStatus: ReportStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onMyReportsRequested(MyReportsRequested event, Emitter<ReportState> emit) async {
    emit(state.copyWith(myReportsStatus: ReportStatus.loading));
    try {
      final reports = await getMyReports();
      emit(state.copyWith(
        myReports: reports,
        myReportsStatus: ReportStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        myReportsStatus: ReportStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onGlobalReportsRequested(GlobalReportsRequested event, Emitter<ReportState> emit) async {
    emit(state.copyWith(globalReportsStatus: ReportStatus.loading));
    try {
      final reports = await getAllReports();
      emit(state.copyWith(
        globalReports: reports,
        globalReportsStatus: ReportStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        globalReportsStatus: ReportStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  Future<void> _onReportDetailRequested(ReportDetailRequested event, Emitter<ReportState> emit) async {
    emit(state.copyWith(detailStatus: ReportStatus.loading));
    try {
      final report = await getReportDetail(event.id);
      emit(state.copyWith(
        selectedReport: report,
        detailStatus: ReportStatus.success,
      ));
    } catch (e) {
      emit(state.copyWith(
        detailStatus: ReportStatus.failure,
        errorMessage: e.toString(),
      ));
    }
  }

  void _onTabChanged(ReportTabChanged event, Emitter<ReportState> emit) {
    final newTab = event.index == 0 ? ReportTab.community : ReportTab.myReports;
    emit(state.copyWith(
      currentTab: newTab,
      isCreatingReport: false, // Reset wizard when switching tabs
    ));
    if (newTab == ReportTab.myReports && state.myReports.isEmpty) {
      add(MyReportsRequested());
    } else if (newTab == ReportTab.community && state.globalReports.isEmpty) {
      add(GlobalReportsRequested());
    }
  }

  void _onToggleCreateReport(ToggleCreateReport event, Emitter<ReportState> emit) {
    emit(state.copyWith(
      isCreatingReport: event.value ?? !state.isCreatingReport,
      // Reset wizard state if starting a new report
      submitStatus: ReportStatus.initial,
      currentStep: 0,
      selectedCategory: null,
      description: null,
      latitude: null,
      longitude: null,
      locationLabel: null,
      editingReportId: null,
    ));
  }

  Future<void> _onDeleteReportRequested(DeleteReportRequested event, Emitter<ReportState> emit) async {
    // Optionally update status to loading if needed
    try {
      await deleteReport(event.id);
      add(MyReportsRequested()); // Refresh list
    } catch (e) {
      emit(state.copyWith(
        errorMessage: e.toString(),
      ));
    }
  }

  void _onEditReportRequested(EditReportRequested event, Emitter<ReportState> emit) {
    // Initialize wizard with existing report data
    emit(state.copyWith(
      isCreatingReport: true,
      currentStep: 0,
      selectedCategory: event.report.category,
      description: event.report.description,
      latitude: event.report.latitude,
      longitude: event.report.longitude,
      locationLabel: event.report.locationLabel,
      time: event.report.timestamp,
      isAnonymous: event.report.isAnonymous,
      editingReportId: event.report.id,
    ));
  }
}
