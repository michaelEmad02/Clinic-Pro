// ────────────────────────────────────────────────────────
// عنصر بطاقة المريض في طابور الانتظار
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../../core/constants/route_constants.dart';
import '../../../../../core/constants/supabase_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../domain/entities/appointment_entity.dart';
import '../../manager/appointments_bloc.dart';
import '../../manager/appointments_event.dart';
import 'appointment_dialogs.dart';

class QueueItem extends StatelessWidget {
  final int index;
  final AppointmentEntity patient;

  const QueueItem({
    super.key,
    required this.index,
    required this.patient,
  });

  @override
  Widget build(BuildContext context) {
    final isUrgent = patient.isUrgent;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: context.surfaceColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.borderColor),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── رقم الترتيب في الطابور ──
            CircleAvatar(
              backgroundColor: context.primaryLightColor,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.bold,
                  color: context.primary,
                ),
              ),
            ),
            const SizedBox(width: 12),

            // ── بيانات المريض عموديًا ──
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    patient.patientName ?? AppStrings.patient,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    patient.doctorName ?? AppStrings.generalPractitioner,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    patient.typeName ?? AppStrings.normalCheckup,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: context.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (patient.arrivedAt != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.primaryLightColor,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.access_time_rounded,
                                size: 12,
                                color: context.primary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _formatArrivalTime(patient.arrivedAt, context),
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.primary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (patient.displayTime != null &&
                          patient.displayTime!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.background,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: context.borderColor),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.event_note_rounded,
                                size: 12,
                                color: context.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                '${AppStrings.isArabic ? 'الحجز:' : 'Booked:'} ${patient.displayTime}',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (patient.status == AppointmentStatus.confirmed &&
                          patient.arrivedAt != null &&
                          DateTime.now()
                                  .difference(patient.arrivedAt!.toLocal())
                                  .inHours >=
                              4)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: context.warningBg,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: context.warningText.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.warning_amber_rounded,
                                size: 12,
                                color: context.warningText,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                AppStrings.isArabic
                                    ? 'منتظر منذ ${DateTime.now().difference(patient.arrivedAt!.toLocal()).inHours} ساعات'
                                    : 'Waiting for ${DateTime.now().difference(patient.arrivedAt!.toLocal()).inHours}h',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.warningText,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // ── أزرار الإجراءات + شارة مستعجل ──
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                IconButton(
                  icon: const Icon(Icons.more_vert),
                  color: context.textSecondary,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () {
                    // إظهار Bottom Sheet مع خيارات المريض
                    AppBottomSheet.show(
                      context: context,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              patient.patientName ?? AppStrings.patient,
                              style: AppTextStyles.headlineSmall(context).copyWith(
                                fontWeight: FontWeight.bold,
                                color: context.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              patient.patientPhone ?? '',
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: context.textSecondary,
                              ),
                              textDirection: TextDirection.ltr,
                            ),
                            const SizedBox(height: 16),
                            ListTile(
                              leading: Icon(Icons.person_outline, color: context.primary),
                              title: Text(
                                AppStrings.patientDetails,
                                style: AppTextStyles.bodyMedium(context).copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onTap: () {
                                Navigator.pop(context);
                                context.push(
                                  RouteConstants.patientDetails.replaceAll(':id', patient.patientId),
                                );
                              },
                              contentPadding: EdgeInsets.zero,
                            ),
                            if (patient.status == AppointmentStatus.confirmed &&
                                patient.arrivedAt != null &&
                                DateTime.now()
                                        .difference(patient.arrivedAt!.toLocal())
                                        .inHours >=
                                    4) ...[
                              const Divider(height: 16),
                              ListTile(
                                leading: Icon(
                                  Icons.check_circle_outline,
                                  color: context.successText,
                                ),
                                title: Text(
                                  AppStrings.isArabic ? 'إتمام الزيارة' : 'Complete Visit',
                                  style: AppTextStyles.bodyMedium(context).copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.successText,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  AppointmentDialogs.confirmComplete(
                                    context: context,
                                    item: patient,
                                    bloc: context.read<AppointmentsBloc>(),
                                  );
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                              ListTile(
                                leading: Icon(
                                  Icons.cancel_outlined,
                                  color: context.dangerText,
                                ),
                                title: Text(
                                  AppStrings.isArabic ? 'إلغاء الزيارة' : 'Cancel Visit',
                                  style: AppTextStyles.bodyMedium(context).copyWith(
                                    fontWeight: FontWeight.w600,
                                    color: context.dangerText,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  context.read<AppointmentsBloc>().add(
                                        CancelAppointmentEvent(patient.id),
                                      );
                                },
                                contentPadding: EdgeInsets.zero,
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 8),
                if (isUrgent)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 6,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: context.dangerBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      AppStrings.urgent,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.dangerText,
                        fontWeight: FontWeight.bold,
                        fontSize: 10,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatArrivalTime(DateTime? arrivedAt, BuildContext context) {
    if (arrivedAt == null) return '';
    final local = arrivedAt.toLocal();
    final hour = local.hour;
    final minute = local.minute.toString().padLeft(2, '0');
    final isAr = AppStrings.isArabic;
    final period = hour >= 12 ? (isAr ? 'م' : 'PM') : (isAr ? 'ص' : 'AM');
    final h12 = hour % 12 == 0 ? 12 : hour % 12;
    final timeStr = '$h12:$minute $period';
    return isAr ? 'وصل $timeStr' : 'Arrived $timeStr';
  }
}
