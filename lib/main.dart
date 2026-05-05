import 'package:app_core/data/datasources/local/auth_local_datasource.dart';
import 'package:app_core/data/datasources/remote/auth_remote_datasource.dart';
import 'package:app_core/app/bloc/auth/auth_bloc.dart';
import 'package:app_core/app/bloc/locale/locale_bloc.dart';
import 'package:app_core/app/bloc/locale/locale_state.dart';
import 'package:app_core/app/bloc/theme/theme_bloc.dart';
import 'package:app_core/app/bloc/navbar/navbar_cubit.dart';
import 'package:app_core/app/bloc/map/map_cubit.dart';
import 'package:app_core/app/bloc/map_ui/map_ui_cubit.dart';
import 'package:app_core/app/bloc/location/location_cubit.dart';
import 'package:app_core/app/bloc/weather/weather_cubit.dart';
import 'package:app_core/app/bloc/notification/notification_cubit.dart';
import 'package:app_core/app/navigation/app_router.dart';
import 'package:app_core/app/notification/notification_service.dart';
import 'package:app_core/di/injection_container.dart';
import 'package:app_core/firebase_options.dart';
import 'package:app_core/l10n/app_localizations.dart';
import 'package:app_core/shared/configs/mapbox_config.dart';
import 'package:app_core/shared/themes/app_theme.dart';
import 'package:app_core/shared/utils/logger.dart';
import 'package:app_core/shared/widget/loading_indicator.dart';
import 'package:app_core/shared/configs/env_config.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:app_core/shared/utils/mapbox_setup_helper.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

const bool _enableFirebaseBootstrap = false;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (_enableFirebaseBootstrap) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  AppLogger.info('Initializing app...');
  Object? bootstrapError;

  // Register background handler as early as possible
  if (_enableFirebaseBootstrap) {
    NotificationService.registerBackgroundHandler();
  }

  try {
    // Initialize Hive
    await Hive.initFlutter();
    await EnvConfig.initialize();
    MapboxOptions.setAccessToken(MapboxConfig.accessToken);

    // Setup timeago Vietnamese locale
    timeago.setLocaleMessages('vi', timeago.ViMessages());

    await setupDependencies();

    if (_enableFirebaseBootstrap) {
      // Initialize Firebase Push Notifications
      final notificationService = await sl.getAsync<NotificationService>();
      await notificationService.initialize();
    }
  } catch (e, stackTrace) {
    bootstrapError = e;
    AppLogger.error('Failed to setup dependencies: $e');
    AppLogger.error(stackTrace.toString());
  }

  if (bootstrapError == null && EnvConfig.isMapboxConfigured) {
    try {
      AppLogger.info('Setting up Mapbox...');
      await MapboxSetupHelper.setupNativePlatforms();

      if (EnvConfig.isDevelopment) {
        MapboxSetupHelper.debugConfiguration();

        final isValid = await MapboxSetupHelper.validateSetup();
        AppLogger.info('Mapbox validation result: $isValid');
      }
    } catch (e) {
      AppLogger.error('Mapbox setup failed (non-blocking): $e');
    }
  }

  if (bootstrapError == null && EnvConfig.isDevelopment) {
    try {
      final authLocalDatasource = sl.getAsync<AuthLocalDatasource>();
      final authRemoteDatasource = sl.getAsync<AuthRemoteDatasource>();

      await Future.wait([authLocalDatasource, authRemoteDatasource]);
    } catch (e) {
      AppLogger.error('Auth debug failed: $e');
    }
  }

  runApp(MyApp(bootstrapError: bootstrapError));
}

class MyApp extends StatelessWidget {
  final Object? bootstrapError;

  const MyApp({super.key, this.bootstrapError});

  @override
  Widget build(BuildContext context) {
    if (bootstrapError != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Failed to initialize app',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  'Error: $bootstrapError',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return FutureBuilder<List<dynamic>>(
      future: _initializeBlocs(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(body: Center(child: LoadingIndicator())),
          );
        }

        // Handle error case
        if (snapshot.hasError) {
          AppLogger.error('Failed to initialize blocs: ${snapshot.error}');
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            home: Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    const Text(
                      'Failed to initialize app',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Error: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        final blocs = snapshot.data!;
        final authBloc = blocs[0] as AuthBloc;
        final themeBloc = blocs[1] as ThemeBloc;
        final navbarCubit = blocs[2] as NavbarCubit;
        final mapCubit = blocs[3] as MapCubit;
        final locationCubit = blocs[4] as LocationCubit;
        final weatherCubit = blocs[5] as WeatherCubit;
        final notificationCubit = blocs[6] as NotificationCubit;
        final mapUiCubit = blocs[7] as MapUiCubit;

        return MultiBlocProvider(
          providers: [
            BlocProvider.value(value: authBloc),
            BlocProvider.value(value: themeBloc),
            BlocProvider.value(value: navbarCubit),
            BlocProvider.value(value: mapCubit),
            BlocProvider.value(value: locationCubit),
            BlocProvider.value(value: weatherCubit),
            BlocProvider.value(value: notificationCubit),
            BlocProvider.value(value: mapUiCubit),
            BlocProvider(create: (context) => LocaleBloc()),
          ],
          child: ScreenUtilInit(
            // designSize: const Size(375, 812),
            minTextAdapt: true,
            splitScreenMode: true,
            builder: (context, child) => BlocBuilder<LocaleBloc, LocaleState>(
              builder: (context, localeState) =>
                  BlocBuilder<ThemeBloc, ThemeState>(
                    builder: (context, themeState) => MaterialApp.router(
                      title: 'Aqua Farm',
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.lightTheme,
                      darkTheme: AppTheme.darkTheme,
                      themeMode: themeState.themeMode,
                      locale: localeState.locale,
                      localizationsDelegates: const [
                        AppLocalizations.delegate,
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],
                      supportedLocales: const [Locale('en'), Locale('vi')],
                      routerConfig: appRouter,
                    ),
                  ),
            ),
          ),
        );
      },
    );
  }

  Future<List<dynamic>> _initializeBlocs() async {
    try {
      // Đảm bảo tất cả dependencies đã sẵn sàng
      await sl.allReady();

      // Khởi tạo các BLoCs bất đồng bộ
      final authBloc = await sl.getAsync<AuthBloc>();
      final themeBloc = await sl.getAsync<ThemeBloc>();
      final navbarCubit = sl.get<NavbarCubit>(); // NavbarCubit vẫn là sync
      final mapCubit = sl.get<MapCubit>(); // MapCubit cũng là sync
      final locationCubit = sl
          .get<LocationCubit>(); // LocationCubit cũng là sync
      final weatherCubit = sl.get<WeatherCubit>(); // WeatherCubit cũng là sync
      final notificationCubit = await sl.getAsync<NotificationCubit>();
      final mapUiCubit = sl.get<MapUiCubit>(); // MapUiCubit cũng là sync

      // Trigger auth check
      authBloc.add(AuthCheckRequested());

      AppLogger.info('All blocs initialized successfully');

      return [
        authBloc,
        themeBloc,
        navbarCubit,
        mapCubit,
        locationCubit,
        weatherCubit,
        notificationCubit,
        mapUiCubit,
      ];
    } catch (e) {
      AppLogger.error('Error initializing blocs: $e');
      rethrow;
    }
  }
}
