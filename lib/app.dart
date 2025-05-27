import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:passou_aqui_mobile/presentation/blocs/auth/auth_bloc.dart';
import 'package:passou_aqui_mobile/presentation/blocs/auth/auth_state.dart';
import 'package:passou_aqui_mobile/presentation/pages/login_screen.dart';
import 'package:passou_aqui_mobile/presentation/pages/main_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          return const MainPage();
        }
        return const LoginScreen();
      },
    );
  }
}
