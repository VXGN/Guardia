import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/common/widgets/custom_button.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/presentation/bloc/report/report_bloc.dart';
import 'package:guardia_app/presentation/bloc/report/report_event.dart';
import 'package:guardia_app/presentation/bloc/report/report_state.dart';

class ReportIncidentPage extends StatefulWidget {
  const ReportIncidentPage({super.key});

  @override
  State<ReportIncidentPage> createState() => _ReportIncidentPageState();
}

class _ReportIncidentPageState extends State<ReportIncidentPage> {
  String? _selectedCategory;
  bool _isAnonymous = false;
  final TextEditingController _descriptionController = TextEditingController();

  final List<Map<String, dynamic>> _categories = [
    {'name': 'Harassment', 'icon': Icons.back_hand_rounded, 'color': const Color(0xFFE11D48)},
    {'name': 'Suspicious Activity', 'icon': Icons.support_agent_rounded, 'color': const Color(0xFF6366F1)},
    {'name': 'Poor Lighting', 'icon': Icons.lightbulb_rounded, 'color': const Color(0xFFF59E0B)},
    {'name': 'Verbal Abuse', 'icon': Icons.chat_rounded, 'color': const Color(0xFFF97316)},
    {'name': 'Medical Issue', 'icon': Icons.medical_services_rounded, 'color': const Color(0xFFEF4444)},
    {'name': 'Other', 'icon': Icons.more_horiz_rounded, 'color': const Color(0xFF6B7280)},
  ];

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('DEBUG: Building ReportIncidentPage');
    return BlocConsumer<ReportBloc, ReportState>(
      listener: (context, state) {
        if (state is ReportCreatedSuccess) {
          context.pushNamed('report_success');
        } else if (state is ReportError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      builder: (context, state) {
        final isLoading = state is ReportLoading;

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            leading: Padding(
              padding: const EdgeInsets.only(left: 16),
              child: CircleAvatar(
                backgroundColor: Colors.grey[100],
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: AppColors.primary, size: 20),
                  onPressed: () => context.pop(),
                ),
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            toolbarHeight: 80,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
            const Text(
              'Report an Incident',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select the type of issue. Your safety and privacy are our priority.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
                fontWeight: FontWeight.w500,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.15,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == (cat['name'] as String);
                final color = cat['color'] as Color;
                
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat['name'] as String;
                    });
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    decoration: BoxDecoration(
                      color: isSelected ? color : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: isSelected ? [
                        BoxShadow(
                          color: color.withValues(alpha: 0.3),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        )
                      ] : [],
                      border: Border.all(
                        color: isSelected ? color : const Color(0xFFF1F5F9),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: isSelected ? Colors.white.withValues(alpha: 0.2) : Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            cat['icon'] as IconData,
                            color: isSelected ? Colors.white : color,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          cat['name'] as String,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : const Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
            // Location Box
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: const Color(0xFFF1F5F9), width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.location_on, color: AppColors.primary, size: 22),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'INCIDENT LOCATION',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF94A3B8),
                            letterSpacing: 1.2,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '1240 Market St, San Francisco',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF1E293B),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right, color: Color(0xFF94A3B8)),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Anonymity Toggle
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: _isAnonymous 
                    ? [const Color(0xFF0F172A), const Color(0xFF1E293B)]
                    : [const Color(0xFFF8FAFC), const Color(0xFFF8FAFC)],
                ),
                borderRadius: BorderRadius.circular(24),
                boxShadow: _isAnonymous ? [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.2),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  )
                ] : [],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Submit Anonymously',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: _isAnonymous ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Keep your identity hidden from authorities and secondary responders.',
                          style: TextStyle(
                            fontSize: 12,
                            color: _isAnonymous ? Colors.white.withValues(alpha: 0.7) : const Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch.adaptive(
                    value: _isAnonymous,
                    onChanged: (value) {
                      setState(() {
                        _isAnonymous = value;
                      });
                    },
                    activeThumbColor: const Color(0xFF10B981),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              maxLines: 5,
              style: const TextStyle(fontSize: 15, color: Color(0xFF1E293B)),
              decoration: InputDecoration(
                hintText: 'Provide as many details as possible to help responders...',
                hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.all(24),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: Color(0xFFF1F5F9), width: 1.5),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 40),
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.error.withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: CustomButton(
                text: isLoading ? 'SUBMITTING...' : 'SUBMIT INCIDENT REPORT',
                onPressed: () {
                  if (isLoading) {
                    return;
                  }

                  if (_selectedCategory == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Please select a category first'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                    return;
                  }

                  context.read<ReportBloc>().add(
                        CreateReportRequested(
                          incidentType: _selectedCategory!,
                          description: _descriptionController.text.trim(),
                          incidentAt: DateTime.now(),
                          latitude: -8.5830695,
                          longitude: 116.1155455,
                          isAnonymous: _isAnonymous,
                          locationLabel: '1240 Market St, San Francisco',
                        ),
                      );
                },
                backgroundColor: AppColors.error,
              ),
            ),
            const SizedBox(height: 120),
              ],
            ),
          ),
        ),
      },
    );
  }
}
