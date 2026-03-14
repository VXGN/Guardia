import 'package:flutter/material.dart';
import 'package:guardia_app/common/widgets/custom_button.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

class CompanionSetupPage extends StatefulWidget {
  const CompanionSetupPage({super.key});

  @override
  State<CompanionSetupPage> createState() => _CompanionSetupPageState();
}

class _CompanionSetupPageState extends State<CompanionSetupPage> {
  final List<Map<String, String>> _contacts = [
    {'name': 'Bapa (Emergency)', 'phone': '+62 812-3456-7890', 'relation': 'Father'},
    {'name': 'Mama', 'phone': '+62 811-9876-5432', 'relation': 'Mother'},
    {'name': 'Mas Alif', 'phone': '+62 857-1122-3344', 'relation': 'Brother'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Temani (Companion)',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 8, 24, 16),
            child: InkWell(
              onTap: () => _showAddContactBottomSheet(context),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.primary.withValues(alpha: 0.1)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.person_add_outlined, color: AppColors.primary),
                    SizedBox(width: 16),
                    Text(
                      'Add New Trusted Contact',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    Spacer(),
                    Icon(Icons.add_circle_outline, color: AppColors.primary, size: 20),
                  ],
                ),
              ),
            ),
          ),
          const Divider(height: 1, color: Color(0xFFF1F5F9)),
          Expanded(
            child: _contacts.isEmpty ? _buildEmptyState() : _buildContactsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: const BoxDecoration(
                color: Color(0xFFF1F5F9),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.people_alt_outlined,
                size: 80,
                color: Color(0xFF94A3B8),
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'No Trusted Contacts',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Add family or friends who can monitor your journey when you feel unsafe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsList() {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: _contacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final contact = _contacts[index];
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFF1F5F9)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                radius: 24,
                child: const Icon(Icons.person, color: AppColors.primary),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact['name']!,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${contact['relation']} â€¢ ${contact['phone']}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.message_outlined, color: Color(0xFF61EBCF)),
                onPressed: () {},
              ),
              IconButton(
                icon: const Icon(Icons.call_outlined, color: Color(0xFF6366F1)),
                onPressed: () {},
              )
            ],
          ),
        );
      },
    );
  }

  void _showAddContactBottomSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Add Trusted Contact', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 24),
              _buildTextField('Full Name', Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField('Phone Number', Icons.phone_outlined),
              const SizedBox(height: 16),
              _buildTextField('Relationship', Icons.favorite_border),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save Contact', 
                onPressed: () => Navigator.pop(context),
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(String hint, IconData icon) {
    return TextField(
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.grey[400], size: 20),
        filled: true,
        fillColor: const Color(0xFFF8FAFC),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Color(0xFFF1F5F9))),
      ),
    );
  }
}
