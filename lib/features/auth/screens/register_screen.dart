import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../app/router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../bloc/auth_form_bloc.dart';
import '../widgets/auth_text_field.dart';
import '../widgets/google_sign_in_button.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthFormBloc(AuthService()),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();

  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      context.read<AuthFormBloc>().add(RegisterSubmitted(
            displayName: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthFormBloc, AuthFormState>(
      listener: (context, state) {
        if (state is AuthFormSuccess && state.needsRoleSelection) {
          context.go(AppRoutes.roleSelection, extra: {
            'uid': state.uid,
            'displayName': state.displayName,
            'email': state.email,
            'photoUrl': state.photoUrl,
          });
        }
        if (state is AuthFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Back button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back_rounded),
                      onPressed: () => context.go(AppRoutes.login),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ShaderMask(
                    shaderCallback: (bounds) =>
                        AppColors.heroGradient.createShader(bounds),
                    child: const Icon(
                      Icons.music_note_rounded,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Join the team!',
                    style: theme.textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Create your account to start learning',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  // Name
                  AuthTextField(
                    controller: _nameController,
                    label: AppStrings.displayName,
                    prefixIcon: Icons.person_outline_rounded,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return AppStrings.errorNameRequired;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Email
                  AuthTextField(
                    controller: _emailController,
                    label: AppStrings.email,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    textInputAction: TextInputAction.next,
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Email is required';
                      if (!v.contains('@')) {
                        return AppStrings.errorInvalidEmail;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Password
                  AuthTextField(
                    controller: _passwordController,
                    label: AppStrings.password,
                    obscureText: _obscurePassword,
                    prefixIcon: Icons.lock_outline_rounded,
                    textInputAction: TextInputAction.next,
                    suffixIcon: IconButton(
                      icon: Icon(_obscurePassword
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (v) {
                      if (v == null || v.length < 6) {
                        return AppStrings.errorWeakPassword;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  // Confirm Password
                  AuthTextField(
                    controller: _confirmPasswordController,
                    label: AppStrings.confirmPassword,
                    obscureText: _obscureConfirm,
                    prefixIcon: Icons.lock_outline_rounded,
                    textInputAction: TextInputAction.done,
                    onFieldSubmitted: (_) => _submit(),
                    suffixIcon: IconButton(
                      icon: Icon(_obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined),
                      onPressed: () =>
                          setState(() => _obscureConfirm = !_obscureConfirm),
                    ),
                    validator: (v) {
                      if (v != _passwordController.text) {
                        return AppStrings.errorPasswordMismatch;
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 24),
                  // Register button
                  BlocBuilder<AuthFormBloc, AuthFormState>(
                    builder: (context, state) {
                      return ElevatedButton(
                        onPressed:
                            state is AuthFormLoading ? null : _submit,
                        child: state is AuthFormLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(AppStrings.register),
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          AppStrings.orContinueWith,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 16),
                  GoogleSignInButton(
                    onPressed: () => context
                        .read<AuthFormBloc>()
                        .add(GoogleSignInRequested()),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(AppStrings.hasAccount,
                          style: theme.textTheme.bodyMedium),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.login),
                        child: const Text(AppStrings.login),
                      ),
                    ],
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
