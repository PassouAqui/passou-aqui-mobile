import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:form_validator/form_validator.dart';
import 'package:passou_aqui_mobile/design_system/widgets/custom_button.dart';
import 'package:passou_aqui_mobile/design_system/widgets/custom_text_field.dart';
import 'package:passou_aqui_mobile/presentation/blocs/auth/auth_bloc.dart';
import 'package:passou_aqui_mobile/presentation/blocs/auth/auth_event.dart';
import 'package:passou_aqui_mobile/presentation/blocs/auth/auth_state.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _emailValidator = ValidationBuilder()
      .email('Por favor, insira um email válido')
      .required('Email é obrigatório')
      .build();

  final _passwordValidator = ValidationBuilder()
      .minLength(8, 'A senha deve ter pelo menos 8 caracteres')
      .required('Senha é obrigatória')
      .build();

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('As senhas não coincidem')),
        );
        return;
      }

      context.read<AuthBloc>().add(
            RegisterRequested(
              username: _usernameController.text,
              email: _emailController.text,
              password: _passwordController.text,
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Criar Conta'),
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          } else if (state is AuthAuthenticated) {
            Navigator.of(context).pushReplacementNamed('/home');
          }
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),
                  CustomTextField(
                    controller: _usernameController,
                    label: 'Nome de usuário',
                    validator: ValidationBuilder()
                        .required('Nome de usuário é obrigatório')
                        .minLength(3,
                            'Nome de usuário deve ter pelo menos 3 caracteres')
                        .build(),
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    validator: _emailValidator,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Senha',
                    obscureText: true,
                    validator: _passwordValidator,
                  ),
                  const SizedBox(height: 16),
                  CustomTextField(
                    controller: _confirmPasswordController,
                    label: 'Confirmar Senha',
                    obscureText: true,
                    validator: (value) {
                      if (value != _passwordController.text) {
                        return 'As senhas não coincidem';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return CustomButton(
                        onPressed:
                            state is AuthLoading ? null : _handleRegister,
                        child: state is AuthLoading
                            ? const CircularProgressIndicator()
                            : const Text('Criar Conta'),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Já tem uma conta? Faça login'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
