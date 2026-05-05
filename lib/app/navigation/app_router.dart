import 'package:app_core/app/ui/auth/forgot_password_screen.dart';
import 'package:app_core/app/ui/auth/reset_password_screen.dart';
import 'package:app_core/app/ui/auth/sign_in_screen.dart';
import 'package:app_core/app/ui/auth/sign_up_screen.dart';
import 'package:app_core/app/ui/auth/verify_email_screen.dart';
import 'package:app_core/app/ui/home/home_screen.dart';

import 'package:app_core/app/ui/main/main_navbar.dart';
import 'package:app_core/app/ui/notifications/notifications_screen.dart';
import 'package:app_core/app/ui/profile/profile_screen.dart';
import 'package:app_core/app/ui/splash/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    // Splash Screen
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (BuildContext context, GoRouterState state) {
        return const SplashPage();
      },
    ),

    // Auth Routes
    GoRoute(
      path: '/sign-in',
      name: 'signIn',
      builder: (BuildContext context, GoRouterState state) {
        return const SignInScreen();
      },
    ),
    GoRoute(
      path: '/sign-up',
      name: 'signUp',
      builder: (BuildContext context, GoRouterState state) {
        return const SignUpPage();
      },
    ),
    GoRoute(
      path: '/forgot-password',
      name: 'forgotPassword',
      builder: (BuildContext context, GoRouterState state) {
        return const ForgotPasswordPage();
      },
    ),
    GoRoute(
      path: '/reset-password',
      name: 'resetPassword',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return ResetPasswordScreen(email: email);
      },
    ),
    GoRoute(
      path: '/verify-email',
      name: 'verifyEmail',
      builder: (BuildContext context, GoRouterState state) {
        final email = state.uri.queryParameters['email'] ?? '';
        return VerifyEmailPage(email: email);
      },
    ),

    // Main App with Bottom Navigation
    GoRoute(
      path: '/main',
      name: 'main',
      builder: (BuildContext context, GoRouterState state) {
        return const MainNavbar();
      },
    ),

    // Home Routes
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (BuildContext context, GoRouterState state) {
        return const HomeScreen();
      },
      routes: [
        // GoRoute(
        //   path: 'device-list/:zoneId',
        //   name: 'deviceList',
        //   builder: (BuildContext context, GoRouterState state) {
        //     final zoneId = state.pathParameters['zoneId']!;
        //     return DeviceListScreen(zoneId: zoneId);
        //   },
        // ),
        // GoRoute(
        //   path: 'device-detail/:zoneId/:deviceId',
        //   name: 'deviceDetail',
        //   builder: (BuildContext context, GoRouterState state) {
        //     final zoneId = state.pathParameters['zoneId']!;
        //     final deviceId = state.pathParameters['deviceId']!;
        //     return DeviceDetailScreen(zoneId: zoneId, deviceId: deviceId);
        //   },
        // ),
        // GoRoute(
        //   path: 'zone-list',
        //   name: 'zoneList',
        //   builder: (BuildContext context, GoRouterState state) {
        //     return const ZoneListScreen();
        //   },
        // ),
      ],
    ),

    // Notifications Route
    GoRoute(
      path: '/notifications',
      name: 'notifications',
      builder: (BuildContext context, GoRouterState state) {
        return const NotificationsScreen();
      },
    ),

    // Profile Route
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (BuildContext context, GoRouterState state) {
        return const ProfileScreen();
      },
    ),
  ],
);
