import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/domain/usecases/reports/create_report.dart';
import 'package:guardia_app/domain/usecases/reports/get_my_reports.dart';
import 'package:guardia_app/domain/usecases/reports/get_report_detail.dart';
import 'package:guardia_app/presentation/bloc/report/report_event.dart';
import 'package:guardia_app/presentation/bloc/report/report_state.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {

  ReportBloc({
    required this.createReportUseCase,
    required this.getMyReportsUseCase,
    required this.getReportDetailUseCase,
  }) : super(ReportInitial()) {
    on<CreateReportRequested>(_onCreateReportRequested);
    on<LoadMyReportsRequested>(_onLoadMyReportsRequested);
    on<LoadReportDetailRequested>(_onLoadReportDetailRequested);
  }
  final CreateReport createReportUseCase;
  final GetMyReports getMyReportsUseCase;
  final GetReportDetail getReportDetailUseCase;

  Future<void> _onCreateReportRequested(
    CreateReportRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final result = await createReportUseCase(
      incidentType: event.incidentType,
      description: event.description,
      incidentAt: event.incidentAt,
      latitude: event.latitude,
      longitude: event.longitude,
      isAnonymous: event.isAnonymous,
      locationLabel: event.locationLabel,
    );
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(ReportCreatedSuccess(report)),
    );
  }

  Future<void> _onLoadMyReportsRequested(
    LoadMyReportsRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final result = await getMyReportsUseCase();
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (reports) => emit(MyReportsLoaded(reports)),
    );
  }

  Future<void> _onLoadReportDetailRequested(
    LoadReportDetailRequested event,
    Emitter<ReportState> emit,
  ) async {
    emit(ReportLoading());
    final result = await getReportDetailUseCase(event.id);
    result.fold(
      (failure) => emit(ReportError(failure.message)),
      (report) => emit(ReportDetailLoaded(report)),
    );
  }
}
