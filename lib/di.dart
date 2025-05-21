import 'package:dio/dio.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/profile_service.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/get_profile_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/profile_provider.dart';

class DI {
  static List<SingleChildWidget> get providers => [
    Provider<ApiService>(create: (_) => ApiService(Dio())),
    ProxyProvider<ApiService, AuthService>(
      update: (_, apiService, __) => AuthService(apiService),
    ),
    ProxyProvider<ApiService, ProfileService>(
      update: (_, apiService, __) => ProfileService(apiService),
    ),
    ProxyProvider<AuthService, AuthRepositoryImpl>(
      update: (_, authService, __) => AuthRepositoryImpl(authService),
    ),
    ProxyProvider<ProfileService, ProfileRepositoryImpl>(
      update: (_, profileService, __) => ProfileRepositoryImpl(profileService),
    ),
    ProxyProvider<AuthRepositoryImpl, LoginUseCase>(
      update: (_, repository, __) => LoginUseCase(repository),
    ),
    ProxyProvider<ProfileRepositoryImpl, GetProfileUseCase>(
      update: (_, repository, __) => GetProfileUseCase(repository),
    ),
    ChangeNotifierProxyProvider<LoginUseCase, AuthProvider>(
      create:
          (context) => AuthProvider(
            context.read<LoginUseCase>(),
            context.read<ApiService>(),
          ),
      update:
          (context, loginUseCase, previous) =>
              previous ??
              AuthProvider(loginUseCase, context.read<ApiService>()),
    ),
    ChangeNotifierProxyProvider<GetProfileUseCase, ProfileProvider>(
      create: (context) => ProfileProvider(context.read<GetProfileUseCase>()),
      update:
          (_, getProfileUseCase, previous) =>
              previous ?? ProfileProvider(getProfileUseCase),
    ),
  ];
}
