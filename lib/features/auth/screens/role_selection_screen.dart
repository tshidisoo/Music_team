import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/auth_service.dart';
import '../../../shared/blocs/auth_bloc.dart';
import '../bloc/auth_form_bloc.dart';

class RoleSelectionScreen extends StatelessWidget {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;

  const RoleSelectionScreen({
    super.key,
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AuthFormBloc(AuthService()),
      child: _RoleSelectionView(
        uid: uid,
        displayName: displayName,
        email: email,
        photoUrl: photoUrl,
      ),
    );
  }
}

class _RoleSelectionView extends StatefulWidget {
  final String uid;
  final String displayName;
  final String email;
  final String? photoUrl;

  const _RoleSelectionView({
    required this.uid,
    required this.displayName,
    required this.email,
    this.photoUrl,
  });

  @override
  State<_RoleSelectionView> createState() => _RoleSelectionViewState();
}

class _RoleSelectionViewState extends State<_RoleSelectionView> {
  String? _selectedRole;
  final _passcodeController = TextEditingController();
  bool _showPasscodeField = false;

  @override
  void dispose() {
    _passcodeController.dispose();
    super.dispose();
  }

  void _selectRole(String role) {
    setState(() {
      _selectedRole = role;
      _showPasscodeField = role == AppConstants.roleTeacher;
    });
  }

  void _confirm() {
    if (_selectedRole == null) return;
    context.read<AuthFormBloc>().add(RoleSelected(
          uid: widget.uid,
          displayName: widget.displayName,
          email: widget.email,
          role: _selectedRole!,
          passcode: _showPasscodeField ? _passcodeController.text : null,
          photoUrl: widget.photoUrl,
        ));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return BlocListener<AuthFormBloc, AuthFormState>(
      listener: (context, state) {
        if (state is AuthFormRoleCreated) {
          // Firestore doc now exists — tell AuthBloc to re-fetch it
          final firebaseUser = FirebaseAuth.instance.currentUser;
          if (firebaseUser != null) {
            context.read<AuthBloc>().add(AuthSignedIn(firebaseUser));
          }
        }
        if (state is AuthFormError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 32),
                Text(
                  'Hi, ${widget.displayName.split(' ').first}! 👋',
                  style: theme.textTheme.displaySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  AppStrings.chooseRole,
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 40),
                // Student card
                _RoleCard(
                  icon: Icons.school_rounded,
                  title: AppStrings.student,
                  subtitle: AppStrings.studentSubtitle,
                  gradient: AppColors.primaryGradient,
                  isSelected: _selectedRole == AppConstants.roleStudent,
                  onTap: () => _selectRole(AppConstants.roleStudent),
                ),
                const SizedBox(height: 16),
                // Teacher card
                _RoleCard(
                  icon: Icons.music_note_rounded,
                  title: AppStrings.teacher,
                  subtitle: AppStrings.teacherSubtitle,
                  gradient: AppColors.secondaryGradient,
                  isSelected: _selectedRole == AppConstants.roleTeacher,
                  onTap: () => _selectRole(AppConstants.roleTeacher),
                ),
                // Passcode field for teacher
                if (_showPasscodeField) ...[
                  const SizedBox(height: 24),
                  TextField(
                    controller: _passcodeController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: AppStrings.teacherPasscode,
                      hintText: 'Enter the teacher passcode',
                      prefixIcon: const Icon(Icons.vpn_key_outlined),
                    ),
                  ),
                ],
                const Spacer(),
                BlocBuilder<AuthFormBloc, AuthFormState>(
                  builder: (context, state) {
                    return ElevatedButton(
                      onPressed: (_selectedRole == null ||
                              state is AuthFormLoading)
                          ? null
                          : _confirm,
                      child: state is AuthFormLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text("Let's Go!"),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final LinearGradient gradient;
  final bool isSelected;
  final VoidCallback onTap;

  const _RoleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.gradient,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: isSelected ? gradient : null,
          color: isSelected ? null : Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : Theme.of(context).dividerColor,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: gradient.colors.first.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : gradient.colors.first.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: isSelected ? Colors.white : gradient.colors.first,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: isSelected ? Colors.white : null,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: isSelected
                          ? Colors.white70
                          : Theme.of(context).textTheme.bodySmall?.color,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle_rounded,
                  color: Colors.white, size: 24),
          ],
        ),
      ),
    );
  }
}
