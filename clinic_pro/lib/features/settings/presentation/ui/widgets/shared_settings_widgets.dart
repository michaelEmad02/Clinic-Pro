import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/themes/theme_cubit.dart';
import '../../../../../core/localization/language_cubit.dart';

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
            style: AppTextStyles.headlineSmall(context)
                .copyWith(color: context.textSecondary),
          ),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: context.borderColor, width: 0.5),
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
    final bg = isUrgent ? context.warningBg : context.primaryLightColor;
    final textColor = isUrgent ? context.warningText : context.textPrimary;
    return Container(
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppConstants.radiusChip),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelChip(context)
            .copyWith(color: textColor, fontWeight: FontWeight.w600),
      ),
    );
  }
}

/// مفتاح تشغيل الوضع الليلي المبسط
class DarkModeSwitch extends StatelessWidget {
  const DarkModeSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, mode) {
        final isDark = mode == ThemeMode.dark ||
            (mode == ThemeMode.system &&
                MediaQuery.of(context).platformBrightness == Brightness.dark);
        return Switch(
          value: isDark,
          activeColor: context.primary,
          onChanged: (v) {
            context.read<ThemeCubit>().toggleTheme(v);
          },
        );
      },
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
      padding: const EdgeInsets.symmetric(
          horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
      child: Row(
        children: [
          Icon(icon, size: 20, color: context.textSecondary),
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
        padding: const EdgeInsets.symmetric(
            horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
        child: Row(
          children: [
            Icon(icon, size: 20, color: textColor ?? context.textSecondary),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label,
                      style: AppTextStyles.bodyLarge(context)
                          .copyWith(color: textColor)),
                  if (subLabel != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subLabel!,
                      style: AppTextStyles.caption(context)
                          .copyWith(color: context.textHint),
                    ),
                  ],
                ],
              ),
            ),
            Icon(Icons.chevron_left,
                size: 20, color: textColor ?? context.textHint),
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
            style: AppTextStyles.caption(context)
                .copyWith(color: context.textHint),
          ),
          if (showSystemStatus) ...[
            const SizedBox(height: AppConstants.spaceSm),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: context.successText,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm),
                Text(
                  AppStrings.allSystemsNormal,
                  style: AppTextStyles.caption(context)
                      .copyWith(color: context.textHint),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// شريط التنقل الجانبي للشاشات الكبيرة (Navigation Rail for Tablet / Desktop)
class AppNavigationRail extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final List<NavigationRailDestination>? destinations;

  const AppNavigationRail({
    super.key,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final defaultDestinations = [
      NavigationRailDestination(
        icon: const Icon(TablerIcons.smart_home),
        label: Text(AppStrings.home),
      ),
      NavigationRailDestination(
        icon: const Icon(TablerIcons.calendar),
        label: Text(AppStrings.appointments),
      ),
      NavigationRailDestination(
        icon: const Icon(TablerIcons.users),
        label: Text(AppStrings.patients),
      ),
      NavigationRailDestination(
        icon: const Icon(TablerIcons.settings),
        label: Text(AppStrings.settings),
      ),
    ];

    return NavigationRail(
      selectedIndex: selectedIndex,
      onDestinationSelected: onDestinationSelected,
      backgroundColor: context.surfaceColor,
      labelType: NavigationRailLabelType.all,
      indicatorColor: context.primaryLightColor,
      selectedIconTheme: IconThemeData(color: context.primary, size: 24),
      unselectedIconTheme: IconThemeData(color: context.textSecondary, size: 22),
      selectedLabelTextStyle: AppTextStyles.labelChip(context).copyWith(
        color: context.primary,
        fontWeight: FontWeight.bold,
      ),
      unselectedLabelTextStyle: AppTextStyles.labelChip(context).copyWith(
        color: context.textSecondary,
      ),
      leading: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
        child: Icon(Icons.local_hospital, color: context.primary, size: 32),
      ),
      destinations: destinations ?? defaultDestinations,
    );
  }
}

/// شريط التنقل السفلي المشترك للصفحة
class SettingsBottomNavBar extends StatelessWidget {
  const SettingsBottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: context.surfaceColor,
        border: Border(
          top: BorderSide(color: context.borderColor, width: 0.5),
        ),
      ),
      child: SafeArea(
        top: false,
        child: ResponsiveHelper.responsiveCenter(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _navItem(
                    context, TablerIcons.smart_home, AppStrings.home, false),
                _navItem(context, TablerIcons.calendar, AppStrings.appointments,
                    false),
                _navItem(
                    context, TablerIcons.users, AppStrings.patients, false),
                _navItem(
                    context, TablerIcons.settings, AppStrings.settings, true),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _navItem(
      BuildContext context, IconData icon, String label, bool active) {
    return SizedBox(
      width: 76,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              color: active ? context.primaryLightColor : Colors.transparent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: active ? context.primary : context.textSecondary,
              size: 22,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: AppTextStyles.labelChip(context).copyWith(
              color: active ? context.primary : context.textSecondary,
              fontWeight: active ? FontWeight.bold : FontWeight.w500,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}

class LanguageSwitch extends StatelessWidget {
  const LanguageSwitch({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LanguageCubit, Locale>(
      builder: (context, locale) {
        return DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: locale.languageCode,
            icon: Icon(Icons.arrow_drop_down, color: context.primary),
            dropdownColor: context.surfaceColor,
            style: TextStyle(
              color: context.textPrimary,
              fontFamily: locale.languageCode == 'ar' ? 'Cairo' : 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
            items: const [
              DropdownMenuItem(
                value: 'ar',
                child: Text('العربية'),
              ),
              DropdownMenuItem(
                value: 'en',
                child: Text('English'),
              ),
            ],
            onChanged: (val) {
              if (val != null) {
                context.read<LanguageCubit>().changeLanguage(val);
              }
            },
          ),
        );
      },
    );
  }
}
