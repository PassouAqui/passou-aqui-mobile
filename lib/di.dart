import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

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
import 'presentation/blocs/auth/auth_event.dart';
import 'presentation/blocs/auth/auth_state.dart';
import 'presentation/pages/main_page.dart';
import 'presentation/pages/login_screen.dart';

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
        ProxyProvider<AuthService, AuthRepositoryImpl>(
          update: (_, authService, __) => AuthRepositoryImpl(
            authService: authService,
          ),
          lazy: true,
        ),
        ProxyProvider<ProfileService, ProfileRepositoryImpl>(
          update: (_, profileService, __) =>
              ProfileRepositoryImpl(profileService),
          lazy: true,
        ),

        // Bloc
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(
            context.read<AuthRepositoryImpl>(),
          )..add(AuthCheckRequested()),
          lazy: false,
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
        ChangeNotifierProxyProvider<LoginUseCase, AuthProvider>(
          create: (context) => AuthProvider(
            context.read<LoginUseCase>(),
            context.read<ApiClient>(),
            context,
          ),
          update: (_, loginUseCase, previous) =>
              previous ??
              AuthProvider(loginUseCase, context.read<ApiClient>(), context),
          lazy: true,
        ),
        ChangeNotifierProxyProvider<GetProfileUseCase, ProfileProvider>(
          create: (context) => ProfileProvider(
            context.read<GetProfileUseCase>(),
          ),
          update: (_, getProfileUseCase, previous) =>
              previous ?? ProfileProvider(getProfileUseCase),
          lazy: true,
        ),
        ChangeNotifierProxyProvider<DrugService, DrugProvider>(
          create: (context) => DrugProvider(
            context.read<DrugService>(),
          ),
          update: (_, drugService, previous) =>
              previous ?? DrugProvider(drugService),
          lazy: true,
        ),
      ],
      child: MaterialApp(
        title: 'Passou Aqui',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          useMaterial3: true,
        ),
        home: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            if (state is AuthAuthenticated) {
              return const MainPage();
            }
            return const LoginScreen();
          },
        ),
      ),
    );
  }
}
