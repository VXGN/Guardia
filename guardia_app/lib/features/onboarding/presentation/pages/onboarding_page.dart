import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/features/onboarding/data/onboarding_item.dart';
import 'package:guardia_app/features/onboarding/presentation/cubit/onboarding_cubit.dart';
import 'package:guardia_app/features/onboarding/presentation/widgets/onboarding_content.dart';

/// Onboarding page with 4 swipeable slides.
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  late final PageController _pageController;

  /// Onboarding content data.
  static const List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Lindungi perjalananmu',
      description:
          'Guardia membantumu merasa lebih aman di ruang publik '
          'dan transportasi umum.',
      imageAsset: 'assets/images/onboarding_1.png',
    ),
    OnboardingItem(
      title: 'Lapor insiden dengan aman',
      description:
          'Kirim laporan secara anonim tanpa harus menceritakan '
          'semuanya berulang kali.',
      imageAsset: 'assets/images/onboarding_2.png',
    ),
    OnboardingItem(
      title: 'Peta risiko berbasis komunitas',
      description:
          'Lihat area rawan di sekitarmu dari laporan warga '
          'lain secara anonim.',
      imageAsset: 'assets/images/onboarding_3.png',
    ),
    OnboardingItem(
      title: 'Temani perjalananmu',
      description:
          'Bagikan perjalanan secara real-time ke kontak '
          'terpercaya saat kamu pulang.',
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

  /// Called when onboarding is complete (Skip or Mulai pressed).
  void _onOnboardingComplete() {
    // TODO: navigate to login or home when auth is ready.
    // For now, this is a placeholder.
    // context.goNamed('login');
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => OnboardingCubit(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: BlocBuilder<OnboardingCubit, int>(
            builder: (context, currentIndex) {
              return Column(
                children: [
                  // Skip button
                  _buildSkipButton(context, currentIndex),

                  // PageView
                  Expanded(
                    child: PageView.builder(
                      controller: _pageController,
                      itemCount: _items.length,
                      onPageChanged: (index) {
                        context.read<OnboardingCubit>().updatePage(index);
                      },
                      itemBuilder: (context, index) {
                        final item = _items[index];
                        return OnboardingContent(
                          title: item.title,
                          description: item.description,
                          imageAsset: item.imageAsset,
                        );
                      },
                    ),
                  ),

                  // Dot indicator + Next/Mulai button
                  _buildBottomSection(context, currentIndex),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  /// Skip button at top-right.
  Widget _buildSkipButton(BuildContext context, int currentIndex) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 8, right: 16),
        child: TextButton(
          onPressed: currentIndex == OnboardingCubit.totalPages - 1
              ? null
              : _onOnboardingComplete,
          child: Text(
            'Skip',
            style: TextStyle(
              fontSize: 16,
              color: currentIndex == OnboardingCubit.totalPages - 1
                  ? AppColors.textHint
                  : AppColors.textSecondary,
            ),
          ),
        ),
      ),
    );
  }

  /// Bottom section with dot indicators and Next/Mulai button.
  Widget _buildBottomSection(BuildContext context, int currentIndex) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
      child: Column(
        children: [
          // Dot indicators
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(
              OnboardingCubit.totalPages,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: index == currentIndex ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: index == currentIndex
                      ? AppColors.primary
                      : AppColors.dotInactive,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Next / Mulai button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: ElevatedButton(
              onPressed: () async {
                if (currentIndex == OnboardingCubit.totalPages - 1) {
                  // Last page — complete onboarding
                  _onOnboardingComplete();
                } else {
                  // Go to next page
                  await _pageController.nextPage(
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOut,
                  );
                }
              },
              child: Text(
                currentIndex == OnboardingCubit.totalPages - 1
                    ? 'Mulai'
                    : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
