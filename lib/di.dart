import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
import 'presentation/pages/register_screen.dart';
import 'data/repositories/drug_repository.dart';
import 'data/repositories/dashboard_repository.dart';
import 'presentation/providers/dashboard_provider.dart';
import 'data/database/database_helper.dart';
import 'data/repositories/user_preferences_repository_impl.dart';
import 'domain/repositories/user_preferences_repository.dart';
import 'domain/usecases/user_preferences_usecase.dart';
import 'presentation/providers/user_preferences_provider.dart';
import 'presentation/pages/preferences_page.dart';
import 'presentation/widgets/app_theme.dart';
import 'rastreamento.dart';

final getIt = GetIt.instance;

class DependencyInjection {
  static Future<Widget> setup(BuildContext context) async {
    // Primeiro, garantir que todas as dependências estejam configuradas
    await setupDependencies();

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
            prefs: getIt<SharedPreferences>(),
            apiClient: context.read<ApiClient>(),
            loginApi: context.read<LoginApi>(),
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
      child: AppTheme(
        child: Builder(
          builder: (context) {
            return MaterialApp(
              title: 'Passou Aqui',
              theme: Theme.of(context),
              darkTheme: Theme.of(context),
              themeMode: ThemeMode.system,
              routes: {
                '/login': (context) => const LoginScreen(),
                '/register': (context) => const RegisterScreen(),
                '/profile': (context) => const ProfilePage(),
                '/preferences': (context) => const PreferencesPage(),
                '/rastreamento': (context) => const TelaRastreamento(),
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
            );
          },
        ),
      ),
    );
  }
}

Future<void> setupDependencies() async {
  // Reset GetIt se já houver registros para evitar duplicação
  if (getIt.isRegistered<DatabaseHelper>()) {
    await getIt.reset();
  }

  // Core Services
  final dbHelper = await DatabaseHelper.instance;
  final prefs = await SharedPreferences.getInstance();
  getIt.registerSingleton<DatabaseHelper>(dbHelper);
  getIt.registerSingleton<SharedPreferences>(prefs);

  // Repositories
  getIt.registerLazySingleton<UserPreferencesRepository>(
    () => UserPreferencesRepositoryImpl(getIt<DatabaseHelper>()),
  );

  // Use Cases
  getIt.registerLazySingleton<UserPreferencesUseCase>(
    () => UserPreferencesUseCase(getIt<UserPreferencesRepository>()),
  );

  // Providers
  getIt.registerLazySingleton<UserPreferencesProvider>(
    () => UserPreferencesProvider(getIt<UserPreferencesUseCase>()),
  );
}

// Método para obter o provider de preferências do usuário
UserPreferencesProvider getUserPreferencesProvider() {
  if (!getIt.isRegistered<UserPreferencesProvider>()) {
    throw StateError(
        'UserPreferencesProvider não está registrado. Certifique-se de que setupDependencies() foi chamado.');
  }
  return getIt<UserPreferencesProvider>();
}
