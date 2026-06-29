// ────────────────────────────────────────────────────────
// كارت عيادة بتصميم Bento — مع قائمة إجراءات ⋮
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/clinics_state.dart';

class ClinicCard extends StatelessWidget {
  final ClinicItem clinic;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onToggleActive;
  final VoidCallback onDelete;

  const ClinicCard({
    super.key,
    required this.clinic,
    required this.onTap,
    required this.onEdit,
    required this.onToggleActive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final opacity = clinic.isActive ? 1.0 : 0.5;

    return Opacity(
      opacity: opacity,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.spaceMd),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              border: Border.all(
                color: clinic.isActive
                    ? AppColors.border
                    : AppColors.danger.withOpacity(0.3),
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x08000000),
                  blurRadius: 4,
                  offset: Offset(0, 1),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // رأس الكارد: الشعار + الاسم + العنوان + قائمة الإجراءات
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // شعار العيادة (مربع)
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: clinic.isActive
                            ? AppColors.primaryLight
                            : AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: clinic.logoUrl != null
                          ? ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.network(
                                clinic.logoUrl!,
                                fit: BoxFit.cover,
                              ),
                            )
                          : Center(
                              child: Text(
                                clinic.initials,
                                style: AppTextStyles.headlineSmall(context)
                                    .copyWith(
                                  color: clinic.isActive
                                      ? AppColors.primary
                                      : AppColors.textSecondary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: Text(
                                  clinic.name,
                                  style: AppTextStyles.headlineSmall(context)
                                      .copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: clinic.isActive
                                        ? AppColors.onSurface
                                        : AppColors.textSecondary,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (!clinic.isActive) ...[
                                const SizedBox(width: 8),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppColors.danger.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'معطل',
                                    style: AppTextStyles.caption(context)
                                        .copyWith(
                                      color: AppColors.danger,
                                      fontSize: 10,
                                    ),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  size: 14, color: AppColors.textSecondary),
                              const SizedBox(width: 4),
                              Flexible(
                                child: Text(
                                  clinic.address,
                                  style: AppTextStyles.caption(context)
                                      .copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 4),
                    // قائمة الإجراءات (⋮)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        switch (value) {
                          case 'edit':
                            onEdit();
                          case 'toggleActive':
                            onToggleActive();
                          case 'delete':
                            onDelete();
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(
                          value: 'edit',
                          child: ListTile(
                            leading: Icon(Icons.edit_outlined,
                                color: AppColors.primary),
                            title: Text('تعديل البيانات'),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        PopupMenuItem(
                          value: 'toggleActive',
                          child: ListTile(
                            leading: Icon(
                              clinic.isActive
                                  ? Icons.block
                                  : Icons.check_circle_outline,
                              color: clinic.isActive
                                  ? AppColors.warning
                                  : AppColors.successText,
                            ),
                            title: Text(
                                clinic.isActive ? 'تعطيل العيادة' : 'تفعيل العيادة'),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: ListTile(
                            leading: Icon(Icons.delete_outline,
                                color: AppColors.danger),
                            title: Text('حذف العيادة'),
                            contentPadding: EdgeInsets.zero,
                            visualDensity: VisualDensity.compact,
                          ),
                        ),
                      ],
                      icon: Icon(
                        Icons.more_vert,
                        color: clinic.isActive
                            ? AppColors.textSecondary
                            : AppColors.textSecondary.withOpacity(0.5),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Divider(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                // إحصائيات 3 أعمدة
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'مرضى اليوم',
                            style: AppTextStyles.caption(context).copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatNumber(clinic.todayAppointments),
                            style: AppTextStyles.dataNumeric(context).copyWith(
                              color: AppColors.primary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'مواعيد قادمة',
                              style: AppTextStyles.caption(context).copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _formatNumber(clinic.todayRemaining),
                              style: AppTextStyles.dataNumeric(context).copyWith(
                                color: AppColors.primary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 32,
                      color: AppColors.border,
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsetsDirectional.only(start: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'إيرادات اليوم',
                              style: AppTextStyles.caption(context).copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  _formatRevenue(clinic.monthlyRevenue),
                                  style: AppTextStyles.dataNumeric(context)
                                      .copyWith(
                                    color: AppColors.successText,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'ر.س',
                                  style: AppTextStyles.caption(context).copyWith(
                                    color: AppColors.textSecondary,
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
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
