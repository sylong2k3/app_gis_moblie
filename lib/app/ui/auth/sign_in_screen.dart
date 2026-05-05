// lib/app/ui/auth/sign_in_screen.dart

import 'package:app_core/app/bloc/auth/auth_bloc.dart';
import 'package:app_core/app/bloc/locale/locale_bloc.dart';
// import 'package:app_core/app/bloc/locale/locale_event.dart';
import 'package:app_core/app/bloc/locale/locale_state.dart';
import 'package:app_core/domain/enums/app_language.dart';
import 'package:app_core/shared/constants/app_dimensions.dart';
import 'package:app_core/shared/constants/image_path.dart';
import 'package:app_core/shared/extensions/localization_extension.dart';
import 'package:app_core/shared/utils/logger.dart';
import 'package:app_core/shared/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    // Hardcode credentials for development/testing
    // _emailController.text = 'admin123';
    // _passwordController.text = 'Admin@1234';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleSignIn() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignInRequested(
          _emailController.text.trim(),
          _passwordController.text,
        ),
      );
    }
  }

  // void _showLanguageBottomSheet(BuildContext context) {
  //   showModalBottomSheet(
  //     context: context,
  //     shape: RoundedRectangleBorder(
  //       borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
  //     ),
  //     builder: (_) {
  //       return Padding(
  //         padding: EdgeInsets.all(16.w),
  //         child: Column(
  //           mainAxisSize: MainAxisSize.min,
  //           children: [
  //             Text(
  //               context.l10n.chooseLanguage,
  //               style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
  //             ),
  //             SizedBox(height: 16.h),
  //             _languageTile(AppLanguage.vi, context.l10n.vietnamese),
  //             _languageTile(AppLanguage.en, context.l10n.english),
  //           ],
  //         ),
  //       );
  //     },
  //   );
  // }

  // Widget _languageTile(AppLanguage language, String title) {
  //   return ListTile(
  //     leading: Image.asset(
  //       ImagePath.flagByLanguage(language),
  //       width: 24.w,
  //       height: 24.h,
  //     ),
  //     title: Text(title),
  //     onTap: () {
  //       context.read<LocaleBloc>().add(
  //         ChangeLocale(Locale(language == AppLanguage.vi ? 'vi' : 'en')),
  //       );
  //       Navigator.pop(context);
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthAuthenticated) {
            AppLogger.info('Login success → Home');
            context.go('/main');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            final isLoading = state is AuthLoading;

            return Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFE8F5E9),
                    Color(0xFFB7E4C7),
                    Color(0xFF95D5B2),
                  ],
                ),
              ),
              child: SafeArea(
                child: Stack(
                  children: [
                    Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(24.w),
                        child: _buildLoginCard(isLoading),
                      ),
                    ),
                    Positioned(
                      top: 16.h,
                      right: 16.w,
                      child: BlocBuilder<LocaleBloc, LocaleState>(
                        builder: (context, state) {
                          final lang = state.locale.languageCode == 'vi'
                              ? AppLanguage.vi
                              : AppLanguage.en;
                          return _LanguageSwitcher(
                            currentLanguage: lang,
                            onTap: () => (),

                            // onTap: () => _showLanguageBottomSheet(context),
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
      ),
    );
  }

  Widget _buildLoginCard(bool isLoading) {
    return Container(
      constraints: BoxConstraints(maxWidth: 420.w),
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(243),
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(20),
            blurRadius: 20.r,
            offset: Offset(0, 10.h),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Image.asset(
                ImagePath.logo,
                height: AppDimensions.imageSizeExtraSmall.height,
              ),
            ),
            SizedBox(height: 16.h),
            Text(
              context.l10n.login,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 26.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8.h),
            Text(
              context.l10n.loginSubtitle,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 14.sp),
            ),
            SizedBox(height: 24.h),

            _emailField(isLoading),
            SizedBox(height: 16.h),
            _passwordField(isLoading),

            // SizedBox(height: 8.h),
            // Align(
            //   alignment: Alignment.centerRight,
            //   child: TextButton(
            //     onPressed: isLoading
            //         ? null
            //         : () {
            //             context.push('/forgot-password');
            //           },
            //     style: TextButton.styleFrom(
            //       padding: EdgeInsets.zero,
            //       minimumSize: Size.zero,
            //       tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            //     ),
            //     child: Text(
            //       context.l10n.forgotPassword,
            //       style: TextStyle(
            //         fontWeight: FontWeight.w600,
            //         color: Theme.of(context).colorScheme.primary,
            //       ),
            //     ),
            //   ),
            // ),
            SizedBox(height: 16.h),

            SizedBox(
              height: 52.h,
              child: ElevatedButton(
                onPressed: isLoading ? null : _handleSignIn,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                ),
                child: isLoading
                    ? const LoadingIndicator()
                    : Text(
                        context.l10n.logIn,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            SizedBox(height: 16.h),

            // Guest login button
            SizedBox(
              height: 52.h,
              child: OutlinedButton.icon(
                onPressed: isLoading
                    ? null
                    : () {
                        // Navigate to main screen without authentication
                        context.go('/main');
                      },
                icon: Icon(Icons.person_outline, size: 20.sp),
                label: Text(
                  'Tiếp tục với tư cách khách',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.primary,
                    width: 1.5,
                  ),
                ),
              ),
            ),

            // SizedBox(height: 12.h),

            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text("${context.l10n.alreadyHaveAccount} "),
            //     TextButton(
            //       onPressed: isLoading
            //           ? null
            //           : () {
            //               context.push('/sign-up');
            //             },
            //       child: Text(
            //         context.l10n.signUp,
            //         style: const TextStyle(fontWeight: FontWeight.bold),
            //       ),
            //     ),
            //   ],
            // ),
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
        borderRadius: BorderRadius.circular(14.r),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _emailField(bool isLoading) {
    return TextFormField(
      controller: _emailController,
      enabled: !isLoading,
      decoration: _inputDecoration(context.l10n.email, Icons.email_outlined),
      validator: (v) =>
          v == null || v.isEmpty ? context.l10n.emailRequired : null,
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
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: Colors.grey.shade400),
          color: Colors.white,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              ImagePath.flagByLanguage(currentLanguage),
              width: 20.w,
              height: 20.h,
            ),
            SizedBox(width: 6.w),
            Text(
              currentLanguage == AppLanguage.vi ? 'VI' : 'EN',
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
            ),
          ],
        ),
      ),
    );
  }
}
