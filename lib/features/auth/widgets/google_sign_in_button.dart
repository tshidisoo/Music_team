import 'package:flutter/material.dart';
import '../../../core/constants/app_strings.dart';

class GoogleSignInButton extends StatelessWidget {
  final VoidCallback onPressed;

  const GoogleSignInButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Google "G" icon using a simple colored widget
          Container(
            width: 20,
            height: 20,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
            ),
            child: const Text(
              'G',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Color(0xFF4285F4),
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 12),
          const Text(AppStrings.signInWithGoogle),
        ],
      ),
    );
  }
}
