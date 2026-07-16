import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../domain/entities/clinic_entity.dart';

/// إحصائيات سريعة في بطاقة العيادة — تعرض الهاتف و العنوان
/// ملاحظة: الإحصائيات التفصيلية (مواعيد، إيرادات) تظهر في شاشة التفاصيل فقط
class ClinicCardStats extends StatelessWidget {
  final ClinicEntity clinic;

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
          icon: Icons.phone_outlined,
          label: AppStrings.phoneNumber,
          value: clinic.phone1.isNotEmpty ? clinic.phone1 : '—',
          color: context.primary,
        ),
        Container(
          width: 1,
          height: 32,
          color: context.border,
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: 12),
          child: _buildStatColumn(
            context,
            icon: Icons.calendar_today_outlined,
            label: AppStrings.createdAt,
            value: _formatDate(clinic.createdAt),
            color: context.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatColumn(
    BuildContext context, {
    required IconData icon,
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
              color: context.textSecondary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            value,
            style: AppTextStyles.dataNumeric(context).copyWith(
              color: color,
              fontSize: 14,
            ),
            overflow: TextOverflow.ellipsis,
            textDirection: TextDirection.ltr,
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.year}/${date.month.toString().padLeft(2, '0')}/${date.day.toString().padLeft(2, '0')}';
  }
}
