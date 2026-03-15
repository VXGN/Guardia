import 'package:equatable/equatable.dart';

abstract class RiskEvent extends Equatable {
  const RiskEvent();

  @override
  List<Object?> get props => [];
}

class RiskFiltersChanged extends RiskEvent {
  final String categoryFilter;
  final String timeRange;

  const RiskFiltersChanged({
    required this.categoryFilter,
    required this.timeRange,
  });

  @override
  List<Object?> get props => [categoryFilter, timeRange];
}

class RiskRequested extends RiskEvent {
  const RiskRequested();
}
