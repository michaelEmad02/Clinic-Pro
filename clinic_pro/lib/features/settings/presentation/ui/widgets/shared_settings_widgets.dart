import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

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
          child: Text(title, style: AppTextStyles.headlineSmall(context).copyWith(color: AppColors.textSecondary)),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: AppColors.border, width: 0.5),
            boxShadow: const [
              BoxShadow(color: Color(0x14000000), blurRadius: 3, offset: Offset(0, 1)),
            ],
          ),
          padding: const EdgeInsets.all(AppConstants.spaceMd),
          child: child,
        ),
      ],
    );
  }
}

class QueueChip extends StatelessWidget {
  final String label;
  final bool isUrgent;

  const QueueChip(this.label, {super.key, this.isUrgent = false});

  @override
  Widget build(BuildContext context) {
    final bg = isUrgent ? AppColors.warningBg : AppColors.primaryLight;
    final textColor = isUrgent ? AppColors.warningText : AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 3),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusChip),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: textColor)),
    );
  }
}

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

Widget buildToggleItem(BuildContext context, {required IconData icon, required String label, required Widget trailing}) {
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

Widget buildNavItem(BuildContext context, {required IconData icon, required String label, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textSecondary),
          const SizedBox(width: AppConstants.spaceMd),
          Expanded(child: Text(label, style: AppTextStyles.bodyLarge(context))),
          const Icon(Icons.chevron_left, size: 20, color: AppColors.textHint),
        ],
      ),
    ),
  );
}

Widget buildSettingsFooter(BuildContext context, {bool showSystemStatus = false}) {
  return Center(
    child: Column(
      children: [
        Text('v1.0.0 — ClinicPro', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
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
              Text('جميع الأنظمة تعمل بشكل طبيعي', style: TextStyle(fontSize: 12, color: AppColors.textHint)),
            ],
          ),
        ],
      ],
    ),
  );
}

Widget buildBottomNavBar(BuildContext context, {bool settingsActive = true}) {
  return Container(
    decoration: const BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.vertical(top: Radius.circular(AppConstants.radiusSheet)),
      boxShadow: [
        BoxShadow(color: Color(0x1F000000), blurRadius: 24, offset: Offset(0, -4)),
      ],
    ),
    child: SafeArea(
      top: false,
      child: SizedBox(
        height: 64,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _navItem(Icons.home_outlined, 'الرئيسية', false),
            _navItem(Icons.calendar_today_outlined, 'المواعيد', false),
            _navItem(Icons.groups_outlined, 'المرضى', false),
            _navItem(Icons.settings, 'الإعدادات', true),
          ],
        ),
      ),
    ),
  );
}

Widget _navItem(IconData icon, String label, bool active) {
  return Container(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    decoration: BoxDecoration(
      color: active ? AppColors.primaryLight : Colors.transparent,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: active ? AppColors.primary : AppColors.textSecondary,
          size: 24,
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: active ? AppColors.primary : AppColors.textSecondary)),
      ],
    ),
  );
}
