import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/common/widgets/custom_button.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/domain/entities/trusted_contact.dart';
import 'package:guardia_app/presentation/bloc/contacts/trusted_contact_bloc.dart';
import 'package:guardia_app/presentation/bloc/contacts/trusted_contact_event.dart';
import 'package:guardia_app/presentation/bloc/contacts/trusted_contact_state.dart';

class CompanionSetupPage extends StatefulWidget {
  const CompanionSetupPage({super.key});

  @override
  State<CompanionSetupPage> createState() => _CompanionSetupPageState();
}

class _CompanionSetupPageState extends State<CompanionSetupPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _relationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<TrustedContactBloc>().add(const LoadTrustedContactsRequested());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<TrustedContactBloc, TrustedContactState>(
      listener: (context, state) {
        if (state is TrustedContactError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message), backgroundColor: AppColors.error),
          );
        }
      },
      child: Scaffold(
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
              child: BlocBuilder<TrustedContactBloc, TrustedContactState>(
                builder: (context, state) {
                  if (state is TrustedContactLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is TrustedContactsLoaded) {
                    if (state.contacts.isEmpty) {
                      return _buildEmptyState();
                    }
                    return _buildContactsList(state.contacts);
                  } else if (state is TrustedContactError) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline, size: 48, color: AppColors.error),
                          const SizedBox(height: 16),
                          Text(state.message),
                          TextButton(
                            onPressed: () => context.read<TrustedContactBloc>().add(const LoadTrustedContactsRequested()),
                            child: const Text('Try Again'),
                          ),
                        ],
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
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

  Widget _buildContactsList(List<TrustedContact> contacts) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final contact = contacts[index];
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
                      contact.contactName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${contact.relationship ?? "No relation"} • ${contact.contactPhone}',
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
                onPressed: () => GoRouter.of(context).pushNamed('companion_chat', pathParameters: {'companionId': contact.id}),
              ),
              IconButton(
                icon: const Icon(Icons.call_outlined, color: Color(0xFF6366F1)),
                onPressed: () => GoRouter.of(context).pushNamed('companion_call', pathParameters: {'companionId': contact.id}),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined, color: Colors.amber),
                onPressed: () => _showEditContactBottomSheet(context, contact),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline, color: AppColors.error),
                onPressed: () => _showDeleteConfirm(context, contact),
              ),
            ],
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, TrustedContact contact) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Contact'),
        content: Text('Remove ${contact.contactName}?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              context.read<TrustedContactBloc>().add(DeleteTrustedContactRequested(contact.id));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showEditContactBottomSheet(BuildContext context, TrustedContact contact) {
    _nameController.text = contact.contactName;
    _phoneController.text = contact.contactPhone;
    _relationController.text = contact.relationship ?? '';

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2))),
              const SizedBox(height: 24),
              const Text('Edit Trusted Contact', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 24),
              _buildTextField('Full Name', Icons.person_outline, _nameController),
              const SizedBox(height: 16),
              _buildTextField('Phone Number', Icons.phone_outlined, _phoneController),
              const SizedBox(height: 16),
              _buildTextField('Relationship', Icons.favorite_border, _relationController),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Update Contact', 
                onPressed: () {
                  if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                    context.read<TrustedContactBloc>().add(UpdateTrustedContactRequested(
                      id: contact.id,
                      contactName: _nameController.text,
                      contactPhone: _phoneController.text,
                      relationship: _relationController.text,
                    ));
                    _nameController.clear();
                    _phoneController.clear();
                    _relationController.clear();
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 16),
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
      builder: (ctx) {
        return Container(
          padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(ctx).viewInsets.bottom + 24),
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
              _buildTextField('Full Name', Icons.person_outline, _nameController),
              const SizedBox(height: 16),
              _buildTextField('Phone Number', Icons.phone_outlined, _phoneController),
              const SizedBox(height: 16),
              _buildTextField('Relationship', Icons.favorite_border, _relationController),
              const SizedBox(height: 32),
              CustomButton(
                text: 'Save Contact', 
                onPressed: () {
                  if (_nameController.text.isNotEmpty && _phoneController.text.isNotEmpty) {
                    context.read<TrustedContactBloc>().add(AddTrustedContactRequested(
                      contactName: _nameController.text,
                      contactPhone: _phoneController.text,
                      relationship: _relationController.text,
                      contactEmail: null,
                    ));
                    _nameController.clear();
                    _phoneController.clear();
                    _relationController.clear();
                    Navigator.pop(ctx);
                  }
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTextField(String hint, IconData icon, TextEditingController controller) {
    return TextField(
      controller: controller,
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
