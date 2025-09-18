import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:email_validator/email_validator.dart';
import 'package:mocklet_source/app/core/core.dart';
import 'package:mocklet_source/app/data/app_constants.dart';

class SignUpScreen extends ConsumerStatefulWidget {
  const SignUpScreen({super.key});

  @override
  SignUpScreenState createState() => SignUpScreenState();
}

class SignUpScreenState extends ConsumerState<SignUpScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignUp() async {
    if (!_formKey.currentState!.validate()) return;

    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Passwords do not match')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final email = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final result = await ref.read(coreProvider).signUp(email, password);

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(result.message)));
        if (result.success) {
          Navigator.pop(context);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Sign up failed: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildInputLabel(String label, BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        label,
        style: TextStyle(
          color: Theme.of(context).colorScheme.onSurface.withOpacityValue(0.7),
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'create_account'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'create_account_to_get_started'.tr(),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacityValue(0.6),
                ),
              ),
              const SizedBox(height: 48),

              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputLabel('email'.tr(), context),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'enter_your_email'.tr(),
                      ),
                      validator: (v) => v != null && EmailValidator.validate(v)
                          ? null
                          : 'enter_a_valid_email'.tr(),
                    ),
                    const SizedBox(height: 20),

                    _buildInputLabel('password'.tr(), context),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _passwordController,
                      obscureText: _obscurePassword,
                      decoration: InputDecoration(
                        hintText: 'enter_your_password'.tr(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: theme.colorScheme.onSurface.withOpacityValue(
                              0.5,
                            ),
                          ),
                        ),
                      ),
                      validator: (v) => v != null && v.length >= 6
                          ? null
                          : 'password_must_be_at_least_6_characters'.tr(),
                    ),
                    const SizedBox(height: 20),

                    _buildInputLabel('confirm_password'.tr(), context),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirmPassword,
                      decoration: InputDecoration(
                        hintText: 'confirm_your_password'.tr(),
                        suffixIcon: IconButton(
                          onPressed: () => setState(
                            () => _obscureConfirmPassword =
                                !_obscureConfirmPassword,
                          ),
                          icon: Icon(
                            _obscureConfirmPassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: theme.colorScheme.onSurface.withOpacityValue(
                              0.5,
                            ),
                          ),
                        ),
                      ),
                      validator: (v) => v != null && v.isNotEmpty
                          ? null
                          : 'please_confirm_your_password'.tr(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _handleSignUp,
                child: _isLoading
                    ? _buildSpinner(Colors.white)
                    : Text('sign_up'.tr()),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSpinner([Color? color]) {
    return SizedBox(
      height: 24,
      width: 24,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          color ?? Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
