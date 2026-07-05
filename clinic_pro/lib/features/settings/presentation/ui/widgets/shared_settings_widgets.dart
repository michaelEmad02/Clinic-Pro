// ────────────────────────────────────────────────────────
// ويدجت مشتركة لصفحة الإعدادات (Shared Settings Widgets)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

/// بطاقة القسم التي تحتضن مجموعة من الخيارات
class SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const SectionCard({super.key, required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceXs),
          child: Text(
            title,
            style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: child,
        ),
      ],
    );
  }
}

/// شريحة تمثل خانة انتظار في النمط
class QueueChip extends StatelessWidget {
  final String label;
  final bool isUrgent;

  const QueueChip(this.label, {super.key, this.isUrgent = false});

  @override
  Widget build(BuildContext context) {
    final bg = isUrgent ? AppColors.warningBg : AppColors.primaryLight;
    final textColor = isUrgent ? AppColors.warningText : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusChip),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelChip(context).copyWith(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// مفتاح تشغيل الوضع الليلي المبسط
class DarkModeSwitch extends StatefulWidget {
  const DarkModeSwitch({super.key});

  @override
  State<DarkModeSwitch> createState() => _DarkModeSwitchState();
}

class _DarkModeSwitchState extends State<DarkModeSwitch> {
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {
    return Switch(
      value: _isDark,
      activeColor: AppColors.primary,
      onChanged: (v) => setState(() => _isDark = v),
    );
  }
}

/// ويدجت خيار التبديل (Toggle Switch Item)
class ToggleSettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final Widget trailing;

  const ToggleSettingsItem({
    super.key,
    required this.icon,
    required this.label,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(child: Text(label, style: AppTextStyles.bodyLarge(context))),
          trailing,
        ],
      ),
    );
  }
}

/// ويدجت خيار النقر والانتقال (Navigable Settings Item)
class NavSettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subLabel;
  final VoidCallback onTap;
  final Color? textColor;

  const NavSettingsItem({
    super.key,
    required this.icon,
    required this.label,
    this.subLabel,
    required this.onTap,
    this.textColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusButton),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
        child: Row(
          children: [
            Icon(icon, size: 20, color: textColor ?? AppColors.textSecondary),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: AppTextStyles.bodyLarge(context).copyWith(color: textColor)),
                  if (subLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subLabel!,
                      style: AppTextStyles.caption(context).copyWith(color: AppColors.textHint),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_left, size: 20, color: textColor ?? AppColors.textHint),
          ],
        ),
      ),
    );
  }
}

/// تذييل صفحة الإعدادات لعرض النسخة وحالة النظام
class SettingsFooter extends StatelessWidget {
  final bool showSystemStatus;

  const SettingsFooter({super.key, this.showSystemStatus = false});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Text(
            'v1.0.0 — ClinicPro',
            style: AppTextStyles.caption(context).copyWith(color: AppColors.textHint),
          ),
          if (showSystemStatus) ...[
            const SizedBox(height: AppConstants.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: AppColors.successText,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  'جميع الأنظمة تعمل بشكل طبيعي',
                  style: AppTextStyles.caption(context).copyWith(color: AppColors.textHint),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// شريط التنقل السفلي المشترك للصفحة
class SettingsBottomNavBar extends StatelessWidget {
  const SettingsBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusSheet)),
        boxShadow: [
          BoxShadow(
            color: Color(0x1F000000),
            blurRadius: 24,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(context, Icons.home_outlined, 'الرئيسية', false),
              _navItem(context, Icons.calendar_today_outlined, 'المواعيد', false),
              _navItem(context, Icons.groups_outlined, 'المرضى', false),
              _navItem(context, Icons.settings, 'الإعدادات', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(BuildContext context, IconData icon, String label, bool active) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: active ? AppColors.primaryLight : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: active ? AppColors.primary : AppColors.textSecondary,
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTextStyles.labelChip(context).copyWith(
              color: active ? AppColors.primary : AppColors.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
