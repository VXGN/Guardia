import 'package:flutter_bloc/flutter_bloc.dart';

/// Cubit to manage the current onboarding page index.
class OnboardingCubit extends Cubit<int> {
  OnboardingCubit() : super(0);

  /// Total number of onboarding pages.
  static const int totalPages = 4;

  /// Update the current page index (called from PageView.onPageChanged).
  void updatePage(int index) => emit(index);

  /// Move to the next page.
  void nextPage() {
    if (state < totalPages - 1) {
      emit(state + 1);
    }
  }

  /// Skip to the last page.
  void skip() => emit(totalPages - 1);

  /// Check if the current page is the last one.
  bool get isLastPage => state == totalPages - 1;
}
