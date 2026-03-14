import 'package:flutter/material.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

/// Reusable widget for a single onboarding slide illustration.
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
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
    );
  }
}
