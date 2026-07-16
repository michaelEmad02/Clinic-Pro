// ────────────────────────────────────────────────────────
// هذا Widget مسؤول عن عرض شريط التنقل (التبديل) بين طرق تسجيل الدخول
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
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
        color: context.isDarkMode
            ? AppColors.darkBackground
            : AppColors.primaryLight,
        borderRadius: BorderRadius.circular(12),
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
                  borderRadius: BorderRadius.circular(10),
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
                    'كلمة المرور',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: activeTab == 0 ? AppColors.primary : context.textSecondary,
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
                  borderRadius: BorderRadius.circular(10),
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
                    'الرابط السحري',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: activeTab == 1 ? AppColors.primary : context.textSecondary,
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
