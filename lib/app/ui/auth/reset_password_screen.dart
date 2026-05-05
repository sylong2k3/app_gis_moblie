// lib/app/ui/auth/reset_password_screen.dart
import 'package:app_core/app/bloc/auth/auth_bloc.dart';
import 'package:app_core/app/bloc/locale/locale_bloc.dart';
import 'package:app_core/app/bloc/locale/locale_event.dart';
import 'package:app_core/app/bloc/locale/locale_state.dart';
import 'package:app_core/domain/enums/app_language.dart';
import 'package:app_core/shared/constants/image_path.dart';
import 'package:app_core/shared/extensions/localization_extension.dart';
import 'package:app_core/shared/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;

  const ResetPasswordScreen({super.key, required this.email});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleResetPassword() {
    if (_formKey.currentState!.validate()) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(context.l10n.passwordsDoNotMatch),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      context.read<AuthBloc>().add(
        AuthConfirmResetPasswordRequested(
          email: widget.email,
          code: _codeController.text.trim(),
          newPassword: _newPasswordController.text,
        ),
      );
    }
  }

  void _showLanguageBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                context.l10n.chooseLanguage,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              _languageTile(AppLanguage.vi, context.l10n.vietnamese),
              _languageTile(AppLanguage.en, context.l10n.english),
            ],
          ),
        );
      },
    );
  }

  Widget _languageTile(AppLanguage language, String title) {
    return ListTile(
      leading: Image.asset(
        ImagePath.flagByLanguage(language),
        width: 24,
        height: 24,
      ),
      title: Text(title),
      onTap: () {
        context.read<LocaleBloc>().add(
          ChangeLocale(Locale(language == AppLanguage.vi ? 'vi' : 'en')),
        );
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthPasswordResetSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(context.l10n.passwordResetSuccess),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color(0xFFF6E7D8), Color(0xFFEDE4FF)],
              ),
            ),
            child: SafeArea(
              child: Stack(
                children: [
                  Center(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(24),
                      child: _buildResetPasswordCard(isLoading),
                    ),
                  ),
                  Positioned(
                    top: 16,
                    right: 16,
                    child: BlocBuilder<LocaleBloc, LocaleState>(
                      builder: (context, state) {
                        final lang = state.locale.languageCode == 'vi'
                            ? AppLanguage.vi
                            : AppLanguage.en;
                        return _LanguageSwitcher(
                          currentLanguage: lang,
                          onTap: () => _showLanguageBottomSheet(context),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildResetPasswordCard(bool isLoading) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(243),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(child: Image.asset(ImagePath.logo, height: 56)),
            const SizedBox(height: 16),
            Text(
              context.l10n.resetPasswordTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.resetPasswordSubtitle(widget.email),
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            _codeField(isLoading),
            const SizedBox(height: 16),
            _newPasswordField(isLoading),
            const SizedBox(height: 16),
            _confirmPasswordField(isLoading),
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleResetPassword,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const LoadingIndicator()
                    : Text(
                        context.l10n.resetPassword,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            TextButton(
              onPressed: isLoading
                  ? null
                  : () {
                      Navigator.of(context).pop();
                    },
              child: const Text(
                'Back',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String hint, IconData icon) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon),
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _codeField(bool isLoading) {
    return TextFormField(
      controller: _codeController,
      enabled: !isLoading,
      keyboardType: TextInputType.number,
      decoration: _inputDecoration(
        'Confirmation Code',
        Icons.confirmation_number_outlined,
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Code is required';
        }
        return null;
      },
    );
  }

  Widget _newPasswordField(bool isLoading) {
    return TextFormField(
      controller: _newPasswordController,
      enabled: !isLoading,
      obscureText: _obscureNewPassword,
      decoration: _inputDecoration('New Password', Icons.lock_outline).copyWith(
        suffixIcon: IconButton(
          icon: Icon(
            _obscureNewPassword
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
          ),
          onPressed: () =>
              setState(() => _obscureNewPassword = !_obscureNewPassword),
        ),
      ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'New password is required';
        }
        if (v.length < 8) {
          return 'Password must be at least 8 characters';
        }
        return null;
      },
    );
  }

  Widget _confirmPasswordField(bool isLoading) {
    return TextFormField(
      controller: _confirmPasswordController,
      enabled: !isLoading,
      obscureText: _obscureConfirmPassword,
      decoration: _inputDecoration('Confirm Password', Icons.lock_outline)
          .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword,
              ),
            ),
          ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return 'Please confirm your password';
        }
        return null;
      },
    );
  }
}

class _LanguageSwitcher extends StatelessWidget {
  final VoidCallback onTap;
  final AppLanguage currentLanguage;

  const _LanguageSwitcher({required this.onTap, required this.currentLanguage});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              ImagePath.flagByLanguage(currentLanguage),
              width: 20,
              height: 20,
            ),
            const SizedBox(width: 6),
            Text(
              currentLanguage == AppLanguage.vi ? 'VI' : 'EN',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}
