import 'package:dio/dio.dart';
import 'package:flutter_app/core/network/dio_client.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

Future<void> init() async {
  // --- Core ---
  // Dio
  getIt.registerLazySingleton<Dio>(() => Dio());
  getIt.registerLazySingleton<DioClient>(() => DioClient(getIt()));

  // Add other core dependencies here

  // --- Features ---
  // Example for a feature (will be implemented later)
  // getIt.registerLazySingleton<ApiService>(() => ApiServiceImpl(getIt()));
  // getIt.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(getIt()));
  // getIt.registerLazySingleton<LoginUseCase>(() => LoginUseCase(getIt()));
  // getIt.registerLazySingleton<LoginController>(() => LoginController(getIt()));
}
