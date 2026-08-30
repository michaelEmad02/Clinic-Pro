// ────────────────────────────────────────────────────────
// هذا Widget مسؤول عن عرض شريط التنقل (التبديل) بين طرق تسجيل الدخول
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class AuthTabSelector extends StatelessWidget {
  final int activeTab;
  final ValueChanged<int> onTabSelected;

  const AuthTabSelector({
    super.key,
    required this.activeTab,
    required this.onTabSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: context.primaryLightColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
      ),
      child: Row(
        children: [
          // تبويب البريد وكلمة المرور
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(0),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: activeTab == 0 ? context.surfaceColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                  boxShadow: activeTab == 0
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    AppStrings.password,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: activeTab == 0 ? context.primary : context.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // تبويب الرابط السحري
          Expanded(
            child: GestureDetector(
              onTap: () => onTabSelected(1),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: activeTab == 1 ? context.surfaceColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                  boxShadow: activeTab == 1
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    AppStrings.isArabic ? 'الرابط السحري' : 'Magic Link',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: activeTab == 1 ? context.primary : context.textSecondary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
