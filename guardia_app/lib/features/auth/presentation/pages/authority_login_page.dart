import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Authority/Police Login Screen - 03B
/// Designed with a more rigid, formal aesthetic as per roadmap.
class AuthorityLoginPage extends StatefulWidget {
  const AuthorityLoginPage({super.key});

  @override
  State<AuthorityLoginPage> createState() => _AuthorityLoginPageState();
}

class _AuthorityLoginPageState extends State<AuthorityLoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _nrpController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nrpController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement Authority Login action
      // For now, redirect to a placeholder or back home
      context.goNamed('home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F172A), // Deeper Midnight Blue
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 16),
              // Official Badge Icon placeholder
              const Center(
                child: Icon(
                  Icons.admin_panel_settings,
                  size: 80,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 32),
              
              const Text(
                'AUTHORITY PORTAL',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Authorized Personnel Only. Please provide your institutional credentials.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white60,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 48),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildFormalTextField(
                      label: 'Agency ID (NRP / NIK)',
                      hint: 'Enter your ID',
                      controller: _nrpController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'ID is required';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),
                    _buildFormalTextField(
                      label: 'Encryption Password',
                      hint: 'â€¢â€¢â€¢â€¢â€¢â€¢â€¢â€¢',
                      controller: _passwordController,
                      isPassword: true,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Password is required';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Formal Login Button
              SizedBox(
                height: 56,
                child: ElevatedButton(
                  onPressed: _onLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF0F172A),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4), // Sharper corners
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'AUTHENTICATE',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 32),
              const Center(
                child: Text(
                  'All sessions are logged and monitored.',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white24,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormalTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.1,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: isPassword,
          style: const TextStyle(color: Colors.white),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24),
            filled: true,
            fillColor: Colors.white.withAlpha(10),
            enabledBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white24),
            ),
            focusedBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.white),
            ),
            errorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: const OutlineInputBorder(
              borderSide: BorderSide(color: Colors.redAccent),
            ),
          ),
        ),
      ],
    );
  }
}
