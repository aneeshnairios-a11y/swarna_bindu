import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks the current onboarding page index.
class OnboardingViewModel extends Notifier<int> {
  static const int pageCount = 3;

  @override
  int build() => 0;

  void setPage(int index) => state = index;

  bool get isLastPage => state == pageCount - 1;
}

final onboardingViewModelProvider = NotifierProvider<OnboardingViewModel, int>(
  OnboardingViewModel.new,
);
