
import 'package:clinic_pro/core/constants/route_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class SettingsLogoutSection extends StatelessWidget {
  final bool inline;

  const SettingsLogoutSection({super.key, this.inline = false});

  @override
  Widget build(BuildContext context) {
    if (inline) {
      return InkWell(
        onTap: () {context.read<AuthCubit>().logout();
        context.go(RouteConstants.login);
        },
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        child: Padding(
          padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceMd),
          child: Row(
            children: [
              Icon(Icons.logout, size: 20, color: context.danger),
              const SizedBox(width: AppConstants.spaceMd),
              Expanded(
                child: Text(
                  AppStrings.logout,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: context.danger,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: () {context.read<AuthCubit>().logout();
        context.go(RouteConstants.login);
        },
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: context.dangerBg, width: 2),
          backgroundColor: context.surface,
          padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceMd),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          ),
        ),
        icon: Icon(Icons.logout, color: context.danger, size: 20),
        label: Text(
          AppStrings.logout,
          style: AppTextStyles.headlineSmall(context)
              .copyWith(color: context.danger),
        ),
      ),
    );
  }
}
