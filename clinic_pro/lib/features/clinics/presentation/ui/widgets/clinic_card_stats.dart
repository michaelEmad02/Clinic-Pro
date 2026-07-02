import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/clinics_state.dart';

class ClinicCardStats extends StatelessWidget {
  final ClinicItem clinic;

  const ClinicCardStats({
    super.key,
    required this.clinic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildStatColumn(
          context,
          label: AppStrings.todayPatients,
          value: _formatNumber(clinic.todayAppointments),
          color: AppColors.primary,
        ),
        Container(
          width: 1,
          height: 32,
          color: AppColors.border,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: _buildStatColumn(
            context,
            label: AppStrings.upcomingAppointments,
            value: _formatNumber(clinic.todayRemaining),
            color: AppColors.primary,
          ),
        ),
        Container(
          width: 1,
          height: 32,
          color: AppColors.border,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: _buildRevenueColumn(context),
        ),
      ],
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            value,
            style: AppTextStyles.dataNumeric(context).copyWith(
              color: color,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRevenueColumn(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
            Text(
              AppStrings.todayRevenue,
            style: AppTextStyles.caption(context).copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Row(
            children: [
              Text(
                _formatRevenue(clinic.monthlyRevenue),
                style: AppTextStyles.dataNumeric(context).copyWith(
                  color: AppColors.successText,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: AppConstants.spaceXs),
              Text(
                AppStrings.sar,
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatNumber(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
  }

  String _formatRevenue(double value) {
    final str = value.toInt().toString().replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]},',
    );
    return str;
  }
}
