import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:guardia_app/common/widgets/custom_button.dart';
import 'package:guardia_app/core/constants/app_colors.dart';
import 'package:guardia_app/features/companion/domain/entities/trusted_contact_entity.dart';
import 'package:guardia_app/features/companion/presentation/bloc/companion/companion_bloc.dart';

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
    context.read<CompanionBloc>().add(const CompanionStarted());
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
    return BlocConsumer<CompanionBloc, CompanionState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.errorMessage!),
              backgroundColor: AppColors.error,
            ),
          );
          // Auto reset error after showing
          context.read<CompanionBloc>().add(const CompanionResetError());
        }
      },
      builder: (context, state) {
        final bool isJourneyActive = state.isJourneyActive;

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
              if (isJourneyActive) _buildActiveJourneyBanner(),
              
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
              
              if (!isJourneyActive && state.selectedContactIds.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: CustomButton(
                    text: 'Start Journey with ${state.selectedContactIds.length} Contacts',
                    onPressed: state.isLoading ? null : _onStartJourney,
                    backgroundColor: AppColors.primary,
                  ),
                ),
              
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              
              Expanded(
                child: state.isLoadingContacts && state.contacts.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : state.contacts.isEmpty
                        ? _buildEmptyState()
                        : _buildContactsList(state.contacts, state.selectedContactIds, isJourneyActive),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildActiveJourneyBanner() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.directions_run, color: AppColors.success),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Journey is Active',
                  style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.success),
                ),
                Text(
                  'Your location is being shared.',
                  style: TextStyle(fontSize: 12, color: AppColors.success),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () => context.pushNamed('active_journey'),
            child: const Text('View Details'),
          ),
        ],
      ),
    );
  }

  Future<void> _onStartJourney() async {
    context.read<CompanionBloc>().add(const JourneyStartRequested());
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

  Widget _buildContactsList(
    List<TrustedContactEntity> contacts,
    Set<String> selectedIds,
    bool isJourneyActive,
  ) {
    return ListView.separated(
      padding: const EdgeInsets.all(24),
      itemCount: contacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 16),
      itemBuilder: (context, index) {
        final contact = contacts[index];
        final bool isSelected = selectedIds.contains(contact.id);

        return InkWell(
          onTap: isJourneyActive 
            ? null 
            : () => context.read<CompanionBloc>().add(TrustedContactToggled(contact.id)),
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isSelected ? AppColors.primary.withValues(alpha: 0.3) : const Color(0xFFF1F5F9),
              ),
            ),
            child: Row(
              children: [
                if (!isJourneyActive)
                  Checkbox(
                    value: isSelected,
                    onChanged: (val) {
                      context.read<CompanionBloc>().add(TrustedContactToggled(contact.id));
                    },
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                  ),
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
                if (!isSelected && !isJourneyActive) ...[
                  IconButton(
                    icon: const Icon(Icons.message_outlined, color: Color(0xFF61EBCF)),
                    onPressed: () => context.pushNamed('companion_chat', pathParameters: {'companionId': contact.id}),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call_outlined, color: Color(0xFF6366F1)),
                    onPressed: () => context.pushNamed('companion_call', pathParameters: {'companionId': contact.id}),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Color(0xFF64748B)),
                    onSelected: (value) {
                      if (value == 'edit') {
                        _showEditContactBottomSheet(context, contact);
                      } else if (value == 'delete') {
                        _showDeleteConfirm(context, contact);
                      }
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Row(
                          children: [
                            Icon(Icons.edit_outlined, color: Colors.amber, size: 20),
                            SizedBox(width: 8),
                            Text('Edit'),
                          ],
                        ),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                            SizedBox(width: 8),
                            Text('Hapus'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirm(BuildContext context, TrustedContactEntity contact) {
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
              context.read<CompanionBloc>().add(TrustedContactDeleted(contact.id));
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

  void _showEditContactBottomSheet(BuildContext context, TrustedContactEntity contact) {
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
                    context.read<CompanionBloc>().add(TrustedContactUpdated(
                      contact.copyWith(
                        contactName: _nameController.text,
                        contactPhone: _phoneController.text,
                        relationship: _relationController.text,
                      ),
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
    _nameController.clear();
    _phoneController.clear();
    _relationController.clear();
    
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
                    context.read<CompanionBloc>().add(TrustedContactAdded(
                      contactName: _nameController.text,
                      contactPhone: _phoneController.text,
                      relationship: _relationController.text,
                    ));
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
