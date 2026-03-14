import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/common/widgets/custom_button.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

class ReportSuccessPage extends StatelessWidget {
  const ReportSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Spacer(),
              // Success Icon with Outer Ring
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 48,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Report Received!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Thank you for contributing to Mataram's safety. Your report has been dispatched to the nearest authority center.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 40),
              // Track Status Link
              InkWell(
                onTap: () {
                  // TODO: Navigate to Status Tracker (17B)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Status tracker coming soon!')),
                  );
                },
                child: const Text(
                  'Track Report Status',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
              const Spacer(),
              CustomButton(
                text: 'Back to Home',
                onPressed: () {
                  context.go('/home');
                },
                backgroundColor: AppColors.primary,
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
