// ────────────────────────────────────────────────────────
// بطاقة عرض روشتة المريض (PatientPrescriptionCard)
// تعرض تفاصيل الروشتة، التشخيصات والأدوية بأسلوب عصري responsive
// مع حماية شاملة للنصوص والأزرار وتكيف مع كافة الشاشات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/appointments/presentation/manager/appointments_bloc.dart';
import 'package:clinic_pro/features/prescription/domain/entities/prescription_entity.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/prescription_screen.dart';
import 'package:clinic_pro/features/prescription/presentation/ui/widgets/prescription_print_dialog.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:flutter/material.dart';

class PatientPrescriptionCard extends StatelessWidget {
  final PrescriptionEntity prescription;

  const PatientPrescriptionCard({
    super.key,
    required this.prescription,
  });

  Future<void> _onEditPrescription(BuildContext context) async {
    final appointmentId = prescription.appointmentId;
    if (appointmentId == null || appointmentId.isEmpty) {
      AppSnackbar.error(
        context,
        message: 'تعذّر تحديد الموعد المرتبط بهذه الروشتة',
      );
      return;
    }

    // إظهار حوار تحميل مؤقت
    AppLoadingOverlay.show(context);

    try {
      final appointmentsBloc = sl<AppointmentsBloc>();
      final realAppointment =
          await appointmentsBloc.getAppointmentById(appointmentId);

      if (context.mounted) {
        AppLoadingOverlay.hide(context); // إغلاق حوار التحميل

        if (realAppointment == null) {
          AppSnackbar.error(
            context,
            message: 'تعذّر جلب بيانات الموعد',
          );
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => PrescriptionScreen(
                appointment: realAppointment,
                isEditing: true,
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) {
        AppLoadingOverlay.hide(context);
        AppSnackbar.error(
          context,
          message: 'حدث خطأ أثناء تحميل بيانات الموعد',
        );
      }
    }
  }

  void _onPreviewPrescription(BuildContext context) {
    PrescriptionPrintDialog.show(
      context,
      prescription: prescription,
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateStr = prescription.createdAt.length >= 10
        ? prescription.createdAt.substring(0, 10)
        : prescription.createdAt;

    final diagnosesList =
        (prescription.diagnosis != null && prescription.diagnosis!.isNotEmpty)
            ? prescription.diagnosis!.split(', ')
            : <String>[];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
        border: Border.all(color: context.outline.withOpacity(0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppConstants.radiusSm),
          ),
          child: Icon(
            Icons.medication_liquid_rounded,
            color: context.primary,
            size: 24,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                'روشتة بتاريخ $dateStr',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              fit: FlexFit.loose,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: context.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${prescription.items.length} أدوية',
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.primary,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            diagnosesList.isNotEmpty
                ? 'التشخيص: ${diagnosesList.join(', ')}'
                : 'بدون تشخيص مسجل',
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        children: [
          const Divider(height: 1),
          const SizedBox(height: 12),

          // ─── قسم التشخيصات والتعليمات ───
          if (diagnosesList.isNotEmpty) ...[
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                'التشخيصات الطبية:',
                style: AppTextStyles.caption(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.primary,
                ),
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: diagnosesList.map((diag) {
                return Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: context.primary.withOpacity(0.3)),
                  ),
                  child: Text(
                    diag,
                    style: AppTextStyles.caption(context).copyWith(
                      color: context.primary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 12),
          ],

          // ─── جدول / قائمة الأدوية ───
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              'الأدوية الموصوفة:',
              style: AppTextStyles.caption(context).copyWith(
                fontWeight: FontWeight.bold,
                color: context.primary,
              ),
            ),
          ),
          const SizedBox(height: 8),

          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: prescription.items.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = prescription.items[index];
              final tradeName = item.drug?.tradeName ?? 'دواء موصوف';
              final genericName = item.drug?.genericName ?? '';
              final frequencyStr = item.frequency != null
                  ? '${item.frequency} مرات يومياً'
                  : (item.timing ?? '');
              final durationStr =
                  item.duration != null ? '${item.duration} أيام' : '';

              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: context.background,
                  borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  border: Border.all(color: context.outline.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 12,
                      backgroundColor: context.primary.withOpacity(0.15),
                      child: Text(
                        '${index + 1}',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tradeName,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          if (genericName.isNotEmpty)
                            Text(
                              genericName,
                              style: AppTextStyles.caption(context).copyWith(
                                color: context.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      fit: FlexFit.loose,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          if (frequencyStr.isNotEmpty)
                            Text(
                              frequencyStr,
                              style: AppTextStyles.caption(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.primary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          if (durationStr.isNotEmpty)
                            Text(
                              durationStr,
                              style: AppTextStyles.caption(context).copyWith(
                                color: context.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          if (prescription.notes != null && prescription.notes!.isNotEmpty) ...[
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: context.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                border: Border.all(color: context.primary.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 18, color: context.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'ملاحظات: ${prescription.notes}',
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),

          // ─── أزرار التحكم والعرض والتعديل التفاعلية ───
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              OutlinedButton.icon(
                onPressed: () => _onPreviewPrescription(context),
                icon: const Icon(Icons.print, size: 18),
                label: const Text('طباعه'),
                style: OutlinedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                  side: BorderSide(color: context.primary),
                  foregroundColor: context.primary,
                  backgroundColor: context.background,
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _onEditPrescription(context),
                icon: const Icon(Icons.edit_outlined, size: 18),
                label: const Text('تعديل الروشتة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.primary,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusSm),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
