import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:guardia_app/features/auth/presentation/bloc/auth_state.dart';
import 'package:guardia_app/common/widgets/custom_button.dart';
import 'package:guardia_app/common/widgets/custom_text_field.dart';
import 'package:guardia_app/core/constants/app_colors.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _anonNameController = TextEditingController();

  // PIN Darurat 4 digit state
  final List<TextEditingController> _pinControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _pinFocusNodes = List.generate(4, (_) => FocusNode());

  bool _isLocationConsentChecked = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _anonNameController.dispose();

    for (final controller in _pinControllers) {
      controller.dispose();
    }
    for (final node in _pinFocusNodes) {
      node.dispose();
    }
    super.dispose();
  }

  void _onRegister() {
    // Validate form inputs
    if (!_formKey.currentState!.validate()) return;

    // Validate PIN
    final pin = _pinControllers.map((c) => c.text).join();
    if (pin.length < 4) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Emergency PIN must be 4 digits!')),
      );
      return;
    }

    // Validate Checkbox
    if (!_isLocationConsentChecked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must agree to location data processing.'),
        ),
      );
      return;
    }

    context.read<AuthBloc>().add(
      AuthRegisterRequested(
        _emailController.text.trim(),
        _passwordController.text.trim(),
      ),
    );
  }

  void _onPinChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _pinFocusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _pinFocusNodes[index - 1].requestFocus();
    }
  }

  Widget _buildPinInput(int index) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.dotInactive),
      ),
      child: Center(
        child: TextField(
          controller: _pinControllers[index],
          focusNode: _pinFocusNodes[index],
          textAlign: TextAlign.center,
          keyboardType: TextInputType.number,
          maxLength: 1,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
          decoration: const InputDecoration(
            counterText: '',
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            contentPadding: EdgeInsets.zero,
          ),
          onChanged: (value) => _onPinChanged(value, index),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AuthBloc, AuthState>(
      listenWhen: (previous, current) =>
          previous.status != current.status || current.message != previous.message,
      listener: (context, state) {
        if (state.status == AuthStatus.failure && state.message != null) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(SnackBar(content: Text(state.message!)));
        } else if (state.status == AuthStatus.authenticated) {
          context.goNamed('home');
        }
      },
      builder: (context, state) {
        final isLoading = state.status == AuthStatus.loading;
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            leadingWidth: 120,
            leading: TextButton.icon(
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goNamed('login');
                }
              },
              icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
              label: const Text(
                'Back',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Title section
              const Text(
                'Create Account',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Join our community for a safer city.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 32),

              // Form fields
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    CustomTextField(
                      label: 'Full Name',
                      hintText: 'Your full name',
                      controller: _fullNameController,
                      helperText:
                          'Only visible to authorities during investigation',
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name cannot be empty';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: 'Email',
                      hintText: 'Your email address',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email cannot be empty';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Invalid email format';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: 'Password',
                      hintText: 'Password',
                      controller: _passwordController,
                      isPassword: true,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password cannot be empty';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    CustomTextField(
                      label: 'Anonymous Name*',
                      hintText: 'Anonymous Name',
                      controller: _anonNameController,
                      helperText:
                          'This name will appear in the Social Space (e.g., Citizen_Mataram_99).',
                      textInputAction: TextInputAction.done,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Anonymous name cannot be empty';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // PIN Darurat
              const Text(
                'Emergency PIN (4 Digits)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildPinInput(0),
                  const SizedBox(width: 12),
                  _buildPinInput(1),
                  const SizedBox(width: 12),
                  _buildPinInput(2),
                  const SizedBox(width: 12),
                  _buildPinInput(3),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'This PIN is used to cancel the SOS alarm if you accidentally press it.',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textPrimary,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 32),

              // Checkbox
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _isLocationConsentChecked,
                      onChanged: (value) {
                        setState(() {
                          _isLocationConsentChecked = value ?? false;
                        });
                      },
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: AppColors.dotInactive),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I agree to the processing of encrypted location data',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16), // Adjusted spacing

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: Checkbox(
                      value: _acceptTerms,
                      onChanged: (val) => setState(() => _acceptTerms = val ?? false),
                      activeColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4),
                      ),
                      side: const BorderSide(color: AppColors.dotInactive),
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text(
                      'I agree to share my location and data for security monitoring purposes when SOS or companion mode is active.',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textPrimary,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Register Button
              CustomButton(
                text: isLoading ? 'Loading...' : 'Register',
                onPressed: isLoading ? () {} : _onRegister,
              ),
              const SizedBox(height: 48), // Bottom padding
            ],
          ),
        ),
      ),
        );
      },
    );
  }
}
