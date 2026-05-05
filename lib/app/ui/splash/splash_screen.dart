// lib/presentation/pages/splash_page.dart
import 'package:app_core/app/bloc/auth/auth_bloc.dart';
import 'package:app_core/shared/widget/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  bool _hasNavigated = false;

  void _navigateToScreen(String route) {
    if (!_hasNavigated && mounted) {
      _hasNavigated = true;
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          _navigateToScreen('/main');
        } else if (state is AuthUnauthenticated) {
          _navigateToScreen('/sign-in');
        } else if (state is AuthError) {
          // Hiển thị error nếu cần, sau đó chuyển đến login
          _navigateToScreen('/sign-in');
        }
      },
      child: Scaffold(
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green.shade400, Colors.green.shade700],
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.gps_fixed, size: 100, color: Colors.white),
                const SizedBox(height: 24),
                const Text(
                  'GIS DAK LAK',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 48),
                const LoadingIndicator(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
