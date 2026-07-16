// ────────────────────────────────────────────────────────
// هذا Widget يحتوي على صف أزرار تسجيل الدخول الاجتماعي (Google و Apple)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'social_login_button.dart';

class SocialLoginRow extends StatelessWidget {
  final VoidCallback onGooglePressed;
  final VoidCallback onApplePressed;

  const SocialLoginRow({
    super.key,
    required this.onGooglePressed,
    required this.onApplePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // زر المتابعة باستخدام Google
        Expanded(
          child: SocialLoginButton(
            type: SocialLoginType.google,
            text: 'Google',
            onPressed: onGooglePressed,
          ),
        ),
        const SizedBox(width: 16),
        // زر المتابعة باستخدام Apple
        Expanded(
          child: SocialLoginButton(
            type: SocialLoginType.apple,
            text: 'Apple',
            onPressed: onApplePressed,
          ),
        ),
      ],
    );
  }
}
