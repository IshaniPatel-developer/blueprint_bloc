import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:get_it/get_it.dart';
import 'core/network/api_client.dart';
import 'core/network/api_config.dart';
import 'core/network/dio_interceptors.dart';
import 'core/network/network_info.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/domain/usecases/get_current_user.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/usecases/logout.dart';
import 'features/auth/domain/usecases/signup.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/post/data/datasources/post_local_datasource.dart';
import 'features/post/data/datasources/post_remote_datasource.dart';
import 'features/post/data/repositories/post_repository_impl.dart';
import 'features/post/domain/repositories/post_repository.dart';
import 'features/post/domain/usecases/create_post.dart';
import 'features/post/domain/usecases/get_local_posts.dart';
import 'features/post/domain/usecases/get_posts.dart';
import 'features/post/domain/usecases/sync_posts.dart';
import 'features/post/presentation/bloc/post_bloc.dart';

/// Service locator instance.
final sl = GetIt.instance;

/// Initialize all dependencies.
/// Call this once at app startup.
Future<void> initializeDependencies() async {
  // ================================
  // BLoCs - Register as factories so new instances are created for each request
  // ================================

  sl.registerFactory(
    () => AuthBloc(
      loginUseCase: sl(),
      signupUseCase: sl(),
      logoutUseCase: sl(),
      getCurrentUserUseCase: sl(),
    ),
  );

  sl.registerFactory(
    () => PostBloc(
      createPostUseCase: sl(),
      syncPostsUseCase: sl(),
      getLocalPostsUseCase: sl(),
      getPostsUseCase: sl(),
    ),
  );

  // ================================
  // Use Cases - Register as lazy singletons
  // ================================

  // Auth use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => Signup(sl()));
  sl.registerLazySingleton(() => Logout(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Post use cases
  sl.registerLazySingleton(() => CreatePost(sl()));
  sl.registerLazySingleton(() => SyncPosts(sl()));
  sl.registerLazySingleton(() => GetLocalPosts(sl()));
  sl.registerLazySingleton(() => GetPosts(sl()));

  // ================================
  // Repositories - Register as lazy singletons
  // ================================

  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl()),
  );

  sl.registerLazySingleton<PostRepository>(
    () => PostRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
      networkInfo: sl(),
    ),
  );

  // ================================
  // Data Sources - Register as lazy singletons
  // ================================

  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(firebaseAuth: sl()),
  );

  sl.registerLazySingleton<PostRemoteDataSource>(
    () => PostRemoteDataSourceImpl(apiClient: sl()),
  );

  sl.registerLazySingleton<PostLocalDataSource>(
    () => PostLocalDataSourceImpl(),
  );

  // ================================
  // Core - Register external dependencies
  // ================================

  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Register ApiClient with configured Dio instance
  sl.registerLazySingleton<ApiClient>(() => ApiClient(sl()));

  // ================================
  // External - Third party libraries
  // ================================

  // Firebase Auth
  sl.registerLazySingleton(() => firebase_auth.FirebaseAuth.instance);

  // Dio for HTTP requests with interceptors
  sl.registerLazySingleton(() => _configureDio());

  // Connectivity for network checking
  sl.registerLazySingleton(() => Connectivity());
}

/// Configure Dio instance with base options and interceptors.
Dio _configureDio() {
  final dio = Dio(
    BaseOptions(
      baseUrl: ApiConfig.baseUrl,
      connectTimeout: ApiConfig.connectTimeout,
      receiveTimeout: ApiConfig.receiveTimeout,
      sendTimeout: ApiConfig.sendTimeout,
      headers: ApiConfig.defaultHeaders,
    ),
  );

  // Add interceptors in order
  dio.interceptors.addAll([
    LoggingInterceptor(), // Log requests/responses
    AuthInterceptor(), // Add auth tokens
    ErrorInterceptor(), // Convert errors to custom exceptions
    RetryInterceptor(), // Retry failed requests
  ]);

  return dio;
}
