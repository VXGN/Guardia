import 'package:flutter/material.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

/// Reusable widget for a single onboarding slide.
class OnboardingContent extends StatelessWidget {
  const OnboardingContent({
    required this.title,
    required this.description,
    required this.imageAsset,
    super.key,
  });

  final String title;
  final String description;
  final String imageAsset;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Illustration
          Expanded(
            flex: 3,
            child: Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Image.asset(
                imageAsset,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 240,
                  height: 240,
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight.withAlpha(30),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    size: 80,
                    color: AppColors.primaryLight,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Title & Description
          Expanded(
            flex: 2,
            child: Column(
              children: [
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: textTheme.bodyLarge?.copyWith(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
