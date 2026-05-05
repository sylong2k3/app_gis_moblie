import 'package:app_core/app/bloc/auth/auth_bloc.dart';
import 'package:app_core/app/bloc/location/location_cubit.dart';
import 'package:app_core/app/bloc/map/map_cubit.dart';
import 'package:app_core/app/bloc/map_ui/map_ui_cubit.dart';
import 'package:app_core/app/bloc/theme/theme_bloc.dart';
import 'package:app_core/app/bloc/navbar/navbar_cubit.dart';
import 'package:app_core/app/bloc/weather/weather_cubit.dart';
import 'package:app_core/app/bloc/citizen_feedback/citizen_feedback_cubit.dart';
import 'package:app_core/app/bloc/notification/notification_cubit.dart'
    as user_notif;
import 'package:app_core/data/datasources/local/map_local_datasource.dart';
import 'package:app_core/data/datasources/local/map_layer_update_queue_local_datasource.dart';
import 'package:app_core/data/datasources/local/layer_visibility_local_datasource.dart';
import 'package:app_core/data/datasources/remote/location_datasource.dart';
import 'package:app_core/data/datasources/remote/map_remote_datasource.dart';
import 'package:app_core/data/datasources/remote/citizen_feedback_remote_datasource.dart';
import 'package:app_core/data/datasources/remote/user_notification_remote_datasource.dart';
import 'package:app_core/data/repositories/location_repository_impl.dart';
import 'package:app_core/data/repositories/map_repository_impl.dart';
import 'package:app_core/data/repositories/citizen_feedback_repository_impl.dart';
import 'package:app_core/data/repositories/user_notification_repository_impl.dart';
import 'package:app_core/domain/repositories/location_repository.dart';
import 'package:app_core/domain/repositories/map_repository.dart';
import 'package:app_core/domain/repositories/citizen_feedback_repository.dart';
import 'package:app_core/domain/repositories/user_notification_repository.dart';
import 'package:app_core/domain/services/bluetooth_permission_service.dart';
import 'package:app_core/domain/services/bluetooth_device_service.dart';
import 'package:app_core/domain/services/location_service.dart';
import 'package:app_core/data/datasources/local/auth_local_datasource.dart';
import 'package:app_core/data/datasources/local/theme_local_datasource.dart';
import 'package:app_core/domain/usecases/device/get_devices_usecase.dart';
import 'package:app_core/domain/usecases/device/get_device_detail_usecase.dart';
import 'package:app_core/domain/usecases/device/create_device_usecase.dart';
import 'package:app_core/domain/usecases/device/update_device_usecase.dart';
import 'package:app_core/domain/usecases/device/update_device_config_usecase.dart';
import 'package:app_core/domain/usecases/device/delete_device_usecase.dart';
import 'package:app_core/domain/usecases/map/get_current_location.dart';
import 'package:app_core/domain/usecases/map/get_layers.dart';
import 'package:app_core/domain/usecases/map/get_map_layers_by_category.dart';
import 'package:app_core/domain/usecases/map/get_map_layer_detail.dart';
import 'package:app_core/domain/usecases/map/search_features.dart';
import 'package:app_core/domain/usecases/map/search_map_layers.dart';
import 'package:app_core/domain/usecases/map/toggle_layer_visibility.dart';
import 'package:app_core/domain/usecases/citizen_feedback/submit_citizen_feedback.dart';
import 'package:app_core/domain/usecases/notification/get_notifications.dart';
import 'package:app_core/domain/usecases/notification/mark_notification_as_read.dart';
import 'package:app_core/domain/usecases/notification/mark_all_notifications_as_read.dart';
import 'package:app_core/domain/usecases/notification/delete_notification.dart';
import 'package:app_core/domain/usecases/notification/delete_all_notifications.dart';
import 'package:app_core/domain/usecases/weather/get_weather.dart';
import 'package:app_core/data/services/weather_api_service.dart';
import 'package:app_core/data/services/notification_websocket_service.dart';
import 'package:app_core/data/repositories/weather_repository_impl.dart';
import 'package:app_core/domain/repositories/weather_repository.dart';
import 'package:app_core/shared/constants/api_endpoints.dart';
import 'package:app_core/shared/constants/network_constants.dart';
import 'package:app_core/shared/network/auth_interceptor.dart';
import 'package:app_core/shared/utils/logger.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_core/data/datasources/remote/auth_remote_datasource.dart';
import 'package:app_core/data/repositories/auth_repository_impl.dart';
import 'package:app_core/domain/repositories/auth_repository.dart';
import 'package:app_core/app/notification/notification_service.dart';
import 'package:app_core/data/datasources/remote/firebase_notification_datasource.dart';
import 'package:app_core/data/repositories/notification_repository_impl.dart';
import 'package:app_core/domain/repositories/notification_repository.dart';
import 'package:app_core/domain/usecases/notification/get_fcm_token.dart';
import 'package:app_core/domain/usecases/notification/listen_notification.dart';
import 'package:app_core/domain/usecases/notification/save_device_token.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';

//Map

final sl = GetIt.instance;

Future<void> setupDependencies() async {
  // External dependencies
  sl.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(
      // ignore: deprecated_member_use
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
    ),
  );

  sl.registerLazySingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );

  // Data sources - Local first
  sl.registerLazySingletonAsync<AuthLocalDatasource>(
    () async =>
        AuthLocalDatasource(sl(), await sl.getAsync<SharedPreferences>()),
  );

  sl.registerLazySingletonAsync<ThemeLocalDatasource>(
    () async => ThemeLocalDatasource(await sl.getAsync<SharedPreferences>()),
  );

  // Dio instance - Register BEFORE AuthRemoteDatasource
  sl.registerLazySingletonAsync<Dio>(() async {
    final dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        headers: {
          NetworkConstants.headerContentType: NetworkConstants.contentTypeJson,
          NetworkConstants.headerAccept: NetworkConstants.contentTypeJson,
        },
      ),
    );

    // Add logging interceptor (development only)
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        responseHeader: false,
        error: true,
        logPrint: (obj) {
          AppLogger.info('DIO: $obj');
        },
      ),
    );

    // Add AuthInterceptor - must be added after AuthLocalDatasource is ready
    final authLocalDatasource = await sl.getAsync<AuthLocalDatasource>();
    final authInterceptor = AuthInterceptor(authLocalDatasource);
    dio.interceptors.add(authInterceptor);

    AppLogger.info('Dio setup complete with AuthInterceptor');

    return dio;
  });

  // AuthRemoteDatasource - Register BEFORE AuthRepository
  sl.registerLazySingletonAsync<AuthRemoteDatasource>(
    () async => AuthRemoteDatasource(await sl.getAsync<Dio>()),
  );

  // AuthRepository - Now can use both local and remote datasources
  sl.registerLazySingletonAsync<AuthRepository>(
    () async => AuthRepositoryImpl(
      await sl.getAsync<AuthRemoteDatasource>(),
      await sl.getAsync<AuthLocalDatasource>(),
    ),
  );

  // Repository
  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(localDataSource: sl(), remoteDataSource: sl()),
  );

  // BLoCs - Change to async factories since they depend on async dependencies
  sl.registerFactoryAsync<AuthBloc>(
    () async => AuthBloc(await sl.getAsync<AuthRepository>()),
  );

  sl.registerFactoryAsync<ThemeBloc>(
    () async => ThemeBloc(await sl.getAsync<ThemeLocalDatasource>()),
  );

  sl.registerFactory<NavbarCubit>(() => NavbarCubit());

  // Bluetooth Setup dependencies
  sl.registerLazySingleton<BluetoothPermissionService>(
    () => BluetoothPermissionService(),
  );

  sl.registerLazySingleton<LocationService>(() => LocationService());

  // Features - Map
  // Cubit
  sl.registerFactory(
    () => MapCubit(
      getLayers: sl(),
      toggleLayerVisibility: sl(),
      searchFeatures: sl(),
      searchMapLayers: sl(),
      getMapLayersByCategory: sl(),
      getMapLayerDetail: sl(),
      layerVisibilityDataSource: sl(),
    ),
  );

  // Map UI Cubit - for managing map screen UI state
  sl.registerFactory(() => MapUiCubit());

  // WiFi Configuration dependencies
  sl.registerLazySingleton<BluetoothDeviceService>(
    () => BluetoothDeviceService(),
  );
  // Map dependencies
  sl.registerLazySingleton(() => GetLayers(sl()));
  sl.registerLazySingleton(() => ToggleLayerVisibility(sl()));
  sl.registerLazySingleton(() => SearchFeatures(sl()));
  sl.registerLazySingleton(() => SearchMapLayers(sl()));
  sl.registerLazySingleton(() => GetMapLayersByCategory(sl()));
  sl.registerLazySingleton(() => GetMapLayerDetail(sl()));

  // Device dependencies
  sl.registerLazySingleton<GetDevicesUsecase>(() => GetDevicesUsecase(sl()));
  sl.registerLazySingleton<GetDeviceDetailUsecase>(
    () => GetDeviceDetailUsecase(sl()),
  );
  sl.registerLazySingleton<CreateDeviceUsecase>(
    () => CreateDeviceUsecase(sl()),
  );
  sl.registerLazySingleton<UpdateDeviceUsecase>(
    () => UpdateDeviceUsecase(sl()),
  );
  sl.registerLazySingleton<UpdateDeviceConfigUsecase>(
    () => UpdateDeviceConfigUsecase(sl()),
  );
  sl.registerLazySingleton<DeleteDeviceUsecase>(
    () => DeleteDeviceUsecase(sl()),
  );
  // Data sources
  sl.registerLazySingleton<MapLocalDataSource>(() => MapLocalDataSourceImpl());
  sl.registerLazySingleton<MapRemoteDataSource>(
    () => MapRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<LayerVisibilityLocalDataSource>(
    () => LayerVisibilityLocalDataSource(sharedPreferences: sl()),
  );

  sl.registerLazySingleton<MapLayerUpdateQueueLocalDataSource>(
    () => MapLayerUpdateQueueLocalDataSourceImpl(),
  );

  // Features - Weather
  // Cubit
  sl.registerFactory(
    () => WeatherCubit(getWeatherByCoordinates: sl(), getWeatherByCity: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetWeatherByCoordinates(sl()));
  sl.registerLazySingleton(() => GetWeatherByCity(sl()));

  // Repository
  sl.registerLazySingleton<WeatherRepository>(
    () => WeatherRepositoryImpl(sl()),
  );

  // Services
  sl.registerLazySingleton<WeatherApiService>(() => WeatherApiService(sl()));

  // Features - Location
  // Cubit
  sl.registerFactory(
    () => LocationCubit(getCurrentLocation: sl(), repository: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentLocation(sl()));

  // Repository
  sl.registerLazySingleton<LocationRepository>(
    () => LocationRepositoryImpl(dataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<LocationDataSource>(() => LocationDataSourceImpl());

  // --- Citizen Feedback ---
  sl.registerLazySingleton<CitizenFeedbackRemoteDatasource>(
    () => CitizenFeedbackRemoteDatasourceImpl(sl()),
  );

  sl.registerLazySingleton<CitizenFeedbackRepository>(
    () => CitizenFeedbackRepositoryImpl(
      remoteDatasource: sl(),
      authLocalDatasource: sl(),
    ),
  );

  sl.registerLazySingleton(() => SubmitCitizenFeedback(sl()));
  sl.registerFactory(() => CitizenFeedbackCubit(submitCitizenFeedback: sl()));

  // --- Notifications ---
  sl.registerLazySingleton<FirebaseNotificationDatasource>(
    () => FirebaseNotificationDatasource(),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(sl()),
  );

  sl.registerLazySingleton<GetFcmToken>(() => GetFcmToken(sl()));
  sl.registerLazySingleton<ListenNotification>(() => ListenNotification(sl()));
  sl.registerLazySingletonAsync<SaveDeviceToken>(
    () async => SaveDeviceToken(await sl.getAsync<SharedPreferences>()),
  );

  sl.registerLazySingleton<FlutterLocalNotificationsPlugin>(
    () => FlutterLocalNotificationsPlugin(),
  );

  sl.registerLazySingletonAsync<NotificationService>(
    () async => NotificationService(
      firebaseDatasource: sl(),
      localNotifications: sl(),
      saveDeviceToken: await sl.getAsync<SaveDeviceToken>(),
    ),
  );

  // --- User Notifications (API) ---
  sl.registerLazySingleton<UserNotificationRemoteDatasource>(
    () => UserNotificationRemoteDatasourceImpl(sl()),
  );

  sl.registerLazySingleton<UserNotificationRepository>(
    () => UserNotificationRepositoryImpl(sl()),
  );

  // WebSocket Service
  sl.registerLazySingletonAsync<NotificationWebSocketService>(
    () async =>
        NotificationWebSocketService(await sl.getAsync<AuthLocalDatasource>()),
  );

  sl.registerLazySingleton(() => GetNotifications(sl()));
  sl.registerLazySingleton(() => MarkNotificationAsRead(sl()));
  sl.registerLazySingleton(() => MarkAllNotificationsAsRead(sl()));
  sl.registerLazySingleton(() => DeleteNotification(sl()));
  sl.registerLazySingleton(() => DeleteAllNotifications(sl()));

  sl.registerLazySingletonAsync<user_notif.NotificationCubit>(
    () async => user_notif.NotificationCubit(
      getNotifications: sl(),
      markNotificationAsRead: sl(),
      markAllNotificationsAsRead: sl(),
      deleteNotification: sl(),
      deleteAllNotifications: sl(),
      webSocketService: await sl.getAsync<NotificationWebSocketService>(),
      notificationService: await sl.getAsync<NotificationService>(),
    ),
  );
}
