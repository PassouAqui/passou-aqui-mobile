import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

import 'data/api/api_client.dart';
import 'data/api/auth/login.dart';
import 'data/api/profile/get_profile.dart';
import 'data/api/profile/update_profile.dart';
import 'data/api/drugs/get_drugs.dart';
import 'data/repositories/auth_repository_impl.dart';
import 'data/repositories/profile_repository_impl.dart';
import 'data/services/auth_service.dart';
import 'data/services/profile_service.dart';
import 'data/services/drug_service.dart';
import 'domain/usecases/login_usecase.dart';
import 'domain/usecases/get_profile_usecase.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/profile_provider.dart';
import 'presentation/providers/drug_provider.dart';
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/pages/login_screen.dart';
import 'presentation/pages/profile_page.dart';
import 'data/repositories/drug_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'presentation/providers/dashboard_provider.dart';

final getIt = GetIt.instance;

class DependencyInjection {
  static Widget setup(BuildContext context) {
    return MultiProvider(
      providers: [
        // Core services
        Provider<FlutterSecureStorage>(
          create: (_) => const FlutterSecureStorage(),
          lazy: true,
        ),
        Provider<ApiClient>(
          create: (_) => ApiClient(),
          lazy: true,
        ),

        // API Calls
        ProxyProvider<ApiClient, LoginApi>(
          update: (_, client, __) => LoginApi(client),
          lazy: true,
        ),
        ProxyProvider<ApiClient, GetProfileApi>(
          update: (_, client, __) => GetProfileApi(client),
          lazy: true,
        ),
        ProxyProvider<ApiClient, UpdateProfileApi>(
          update: (_, client, __) => UpdateProfileApi(client),
          lazy: true,
        ),
        ProxyProvider<ApiClient, GetDrugsApi>(
          update: (_, client, __) => GetDrugsApi(client),
          lazy: true,
        ),

        // Services
        ProxyProvider2<LoginApi, ApiClient, AuthService>(
          update: (_, loginApi, apiClient, __) =>
              AuthService(loginApi, apiClient),
          lazy: true,
        ),
        ProxyProvider2<GetProfileApi, UpdateProfileApi, ProfileService>(
          update: (_, getProfileApi, updateProfileApi, __) =>
              ProfileService(getProfileApi, updateProfileApi),
          lazy: true,
        ),
        ProxyProvider<GetDrugsApi, DrugService>(
          update: (_, getDrugsApi, __) => DrugService(getDrugsApi),
          lazy: true,
        ),

        // Repositories
        Provider<AuthRepositoryImpl>(
          create: (context) => AuthRepositoryImpl(
            authService: AuthService(
              LoginApi(context.read<ApiClient>()),
              context.read<ApiClient>(),
            ),
          ),
          lazy: true,
        ),
        ProxyProvider<ProfileService, ProfileRepositoryImpl>(
          update: (_, profileService, __) =>
              ProfileRepositoryImpl(profileService),
          lazy: true,
        ),
        ProxyProvider<ApiClient, DrugRepository>(
          update: (_, apiClient, __) => DrugRepository(apiClient),
          lazy: true,
        ),
        ProxyProvider<ApiClient, DashboardRepository>(
          update: (_, apiClient, __) => DashboardRepository(apiClient),
          lazy: true,
        ),

        // Blocs
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            context.read<AuthRepositoryImpl>(),
            context.read<ApiClient>(),
          ),
        ),

        // Use cases
        ProxyProvider<AuthRepositoryImpl, LoginUseCase>(
          update: (_, repository, __) => LoginUseCase(repository),
          lazy: true,
        ),
        ProxyProvider<ProfileRepositoryImpl, GetProfileUseCase>(
          update: (_, repository, __) => GetProfileUseCase(repository),
          lazy: true,
        ),

        // Providers
        ChangeNotifierProvider<AuthProvider>(
          create: (context) => AuthProvider(
            LoginUseCase(context.read<AuthRepositoryImpl>()),
            context.read<ApiClient>(),
            context,
          ),
        ),
        ChangeNotifierProxyProvider<GetProfileUseCase, ProfileProvider>(
          create: (context) => ProfileProvider(
            context.read<GetProfileUseCase>(),
          ),
          update: (_, getProfileUseCase, previous) =>
              previous ?? ProfileProvider(getProfileUseCase),
          lazy: true,
        ),
        ChangeNotifierProvider<DrugProvider>(
          create: (context) => DrugProvider(
            context.read<DrugRepository>(),
          ),
        ),
        ChangeNotifierProvider<DashboardProvider>(
          create: (context) => DashboardProvider(
            context.read<DashboardRepository>(),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'Passou Aqui',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/profile': (context) => const ProfilePage(),
        },
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const MainPage();
            }
            return const LoginScreen();
          },
        ),
        builder: (context, child) {
          return BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state is AuthUnauthenticated || state is AuthError) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/login',
                  (route) => false,
                );
              }
            },
            child: child!,
          );
        },
      ),
    );
  }
}

void setupDependencies() {
  // Repositories
  getIt.registerLazySingleton<DrugRepository>(
    () => DrugRepository(getIt<ApiClient>()),
  );
  // ... existing repositories ...

  // Providers
  getIt.registerFactory<DrugProvider>(
    () => DrugProvider(getIt<DrugRepository>()),
  );
  // ... existing providers ...
}
