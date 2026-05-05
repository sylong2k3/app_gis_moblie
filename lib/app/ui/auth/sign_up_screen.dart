// lib/presentation/pages/auth/sign_up_page.dart
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
import 'package:go_router/go_router.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleSignUp() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthRegisterRequested(
          _emailController.text.trim(),
          _passwordController.text,
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
          if (state is AuthRegistrationPending) {
            context.go(
              '/verify-email?email=${Uri.encodeComponent(state.email)}',
            );
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
                      child: _buildSignUpCard(isLoading),
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

  Widget _buildSignUpCard(bool isLoading) {
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
              context.l10n.signUp,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              context.l10n.signUpSubtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),

            _emailField(isLoading),
            const SizedBox(height: 16),
            _passwordField(isLoading),
            const SizedBox(height: 16),
            _confirmPasswordField(isLoading),
            const SizedBox(height: 24),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSignUp,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: isLoading
                    ? const LoadingIndicator()
                    : Text(
                        context.l10n.signUp,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 16),

            // Text(
            //   'By signing up, you agree to our Terms of Service and Privacy Policy',
            //   textAlign: TextAlign.center,
            //   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
            // ),
            const SizedBox(height: 16),

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("${context.l10n.alreadyHaveAccount} "),
                TextButton(
                  onPressed: isLoading
                      ? null
                      : () {
                          Navigator.of(context).pop();
                        },
                  child: Text(
                    context.l10n.signIn,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
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

  Widget _emailField(bool isLoading) {
    return TextFormField(
      controller: _emailController,
      enabled: !isLoading,
      keyboardType: TextInputType.emailAddress,
      decoration: _inputDecoration(context.l10n.email, Icons.email_outlined),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return context.l10n.emailRequired;
        }
        if (!v.contains('@')) {
          return context.l10n.invalidEmail;
        }
        return null;
      },
    );
  }

  Widget _passwordField(bool isLoading) {
    return TextFormField(
      controller: _passwordController,
      enabled: !isLoading,
      obscureText: _obscurePassword,
      decoration: _inputDecoration(context.l10n.password, Icons.lock_outline)
          .copyWith(
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
      validator: (v) {
        if (v == null || v.isEmpty) {
          return context.l10n.passwordRequired;
        }
        if (v.length < 8) {
          return context.l10n.passwordTooShort;
        }
        if (!v.contains(RegExp(r'[A-Z]'))) {
          return context.l10n.passwordUppercase;
        }
        if (!v.contains(RegExp(r'[a-z]'))) {
          return context.l10n.passwordLowercase;
        }
        if (!v.contains(RegExp(r'[0-9]'))) {
          return context.l10n.passwordNumber;
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
      decoration:
          _inputDecoration(
            context.l10n.confirmPassword,
            Icons.lock_outline,
          ).copyWith(
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
          return context.l10n.confirmPasswordRequired;
        }
        if (v != _passwordController.text) {
          return context.l10n.passwordsDoNotMatch;
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
