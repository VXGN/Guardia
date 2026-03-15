import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/features/onboarding/domain/entities/onboarding_item.dart';
import 'package:guardia_app/features/onboarding/presentation/bloc/onboarding_cubit.dart';
import 'package:guardia_app/features/onboarding/presentation/widgets/onboarding_content.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:guardia_app/di/injection_container.dart';

/// Onboarding page with 4 swipeable slides.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  static const List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Welcome to GUARDIA',
      description:
          'Smart, safe and inclusive public spaces in the palm of your hand, Your smart travel companion',
      imageAsset: 'assets/images/onboarding_1.png',
    ),
    OnboardingItem(
      title: 'Safe and Fast Routes',
      description:
          'We find the brightest, most crowded, and most monitored routes for your comfort, not just the fastest navigation.',
      imageAsset: 'assets/images/onboarding_2.png',
    ),
    OnboardingItem(
      title: 'Smart Report & SOS',
      description:
          'Use the instant SOS button to report safely and trauma-informed. Your identity stays confidential.',
      imageAsset: 'assets/images/onboarding_3.png',
    ),
    OnboardingItem(
      title: 'Community Support',
      description:
          'Stay anonymous in Safe Space, report safely, and share your location with Trusted Contacts.',
      imageAsset: 'assets/images/onboarding_4.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onOnboardingComplete() async {
    final prefs = sl<SharedPreferences>();
    await prefs.setBool('has_seen_onboarding', true);

    if (mounted) {
      context.goNamed('login');
    }
  }

  Color _scaffoldBg(int currentIndex) {
    if (currentIndex == 2) return const Color(0xFFFDE8E8);
    return Colors.white;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: BlocBuilder<OnboardingCubit, int>(
        builder: (context, currentIndex) {
          final isLastPage =
              currentIndex == OnboardingCubit.totalPages - 1;

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            color: _scaffoldBg(currentIndex),
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: SafeArea(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: 48,
                      child: isLastPage
                          ? const SizedBox.shrink()
                          : Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: _onOnboardingComplete,
                                child: const Text(
                                  'Skip',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                    ),
                    Expanded(
                      flex: 5,
                      child: PageView.builder(
                        controller: _pageController,
                        itemCount: _items.length,
                        onPageChanged: (index) {
                          context.read<OnboardingCubit>().updatePage(index);
                        },
                        itemBuilder: (context, index) {
                          return OnboardingContent(
                            title: _items[index].title,
                            description: _items[index].description,
                            imageAsset: _items[index].imageAsset,
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          OnboardingCubit.totalPages,
                          (index) => AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            height: 10,
                            width: currentIndex == index ? 24 : 10,
                            decoration: BoxDecoration(
                              color: currentIndex == index
                                  ? AppColors.secondary
                                  : AppColors.dotInactive,
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          topRight: Radius.circular(32),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Color(0x0F000000),
                            blurRadius: 16,
                            offset: Offset(0, -4),
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.fromLTRB(32, 36, 32, 36),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _items[currentIndex].title,
                              key: ValueKey(currentIndex),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF111827),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 12),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: Text(
                              _items[currentIndex].description,
                              key: ValueKey('desc_$currentIndex'),
                              style: const TextStyle(
                                fontSize: 15,
                                color: Color(0xFF6B7280),
                                height: 1.6,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: 28),
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (isLastPage) {
                                  _onOnboardingComplete();
                                } else {
                                  await _pageController.nextPage(
                                    duration: const Duration(milliseconds: 350),
                                    curve: Curves.easeInOut,
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                elevation: 0,
                              ),
                              child: Text(
                                isLastPage ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
