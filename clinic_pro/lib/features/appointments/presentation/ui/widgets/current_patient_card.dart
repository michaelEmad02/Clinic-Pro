// ────────────────────────────────────────────────────────
// كرت المريض الحالي في غرفة الكشف (مع أنيميشن الاستدعاء والتجاوب)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../domain/entities/appointment_entity.dart';

class CurrentPatientCard extends StatefulWidget {
  final AppointmentEntity? patient;
  final VoidCallback onStartExamination;

  const CurrentPatientCard({
    super.key,
    required this.patient,
    required this.onStartExamination,
  });

  @override
  State<CurrentPatientCard> createState() => _CurrentPatientCardState();
}

class _CurrentPatientCardState extends State<CurrentPatientCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    if (widget.patient != null) {
      _controller.forward();
    }
  }

  @override
  void didUpdateWidget(covariant CurrentPatientCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.patient != null &&
        (oldWidget.patient == null || widget.patient?.id != oldWidget.patient?.id)) {
      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveHelper.isDesktop(context);

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      switchInCurve: Curves.easeOut,
      switchOutCurve: Curves.easeIn,
      child: widget.patient == null
          ? _buildEmptyState(context, isDesktop)
          : _buildActivePatientCard(context, isDesktop),
    );
  }

  Widget _buildEmptyState(BuildContext context, bool isDesktop) {
    return Container(
      key: const ValueKey('empty_room'),
      margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
      padding: EdgeInsets.symmetric(
        horizontal: 20,
        vertical: isDesktop ? 16 : 24,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor),
      ),
      child: isDesktop
          ? Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primaryLightColor.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.meeting_room_outlined,
                    size: 26,
                    color: context.primary,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        AppStrings.isArabic
                            ? 'غرفة الكشف — جاهزة لاستقبال المريض'
                            : 'Exam Room — Ready for next patient',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: context.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AppStrings.pressCallNext,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              children: [
                Icon(
                  Icons.person_off_outlined,
                  size: 48,
                  color: context.textHint,
                ),
                const SizedBox(height: 12),
                Text(
                  AppStrings.isArabic
                      ? 'لا يوجد مريض في غرفة الكشف حالياً'
                      : 'No patient in the exam room',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    color: context.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppStrings.pressCallNext,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption(context).copyWith(
                    color: context.textHint,
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildActivePatientCard(BuildContext context, bool isDesktop) {
    final patient = widget.patient!;

    return FadeTransition(
      key: ValueKey('patient_${patient.id}'),
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
            padding: EdgeInsets.all(isDesktop ? 20 : 16),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: context.primaryContainer,
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: context.primaryContainer.withOpacity(0.09),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── شريط الرأس مع شارة الغرفة ونوع الكشف (Wrap لمنع أي overflow) ──
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: context.primaryLightColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.meeting_room_outlined,
                            size: 15,
                            color: context.primary,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            AppStrings.isArabic
                                ? 'غرفة الكشف الحالية'
                                : 'Current Exam Room',
                            style: AppTextStyles.labelChip(context).copyWith(
                              color: context.primary,
                              fontWeight: FontWeight.bold,
                              fontSize: isDesktop ? 12.5 : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: patient.isUrgent
                            ? context.dangerBg
                            : context.successBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        patient.isUrgent
                            ? AppStrings.urgent
                            : (patient.typeName != null &&
                                    patient.typeName!.isNotEmpty
                                ? patient.typeName!
                                : AppStrings.normalCheckup),
                        style: AppTextStyles.caption(context).copyWith(
                          color: patient.isUrgent
                              ? context.dangerText
                              : context.successText,
                          fontWeight: FontWeight.bold,
                          fontSize: isDesktop ? 12.5 : null,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── بيانات المريض ──
                Row(
                  children: [
                    Container(
                      width: isDesktop ? 52 : 48,
                      height: isDesktop ? 52 : 48,
                      decoration: BoxDecoration(
                        color: context.primaryLightColor,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Icon(
                          Icons.person,
                          color: context.primary,
                          size: isDesktop ? 26 : 24,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            patient.patientName ?? AppStrings.patient,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTextStyles.headlineSmall(context).copyWith(
                              fontWeight: FontWeight.bold,
                              color: context.textPrimary,
                              fontSize: isDesktop ? 18 : null,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Wrap(
                            spacing: 8,
                            runSpacing: 4,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              Text(
                                patient.patientPhone ?? '',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  fontFamily: 'Inter',
                                  fontSize: isDesktop ? 13.5 : null,
                                ),
                              ),
                              if ((patient.patientPhone?.isNotEmpty ?? false) &&
                                  (patient.displayTime?.isNotEmpty ?? false))
                                Container(
                                  width: 1,
                                  height: 12,
                                  color: context.borderColor,
                                ),
                              Text(
                                patient.displayTime ?? '',
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  fontFamily: 'Inter',
                                  fontWeight: FontWeight.bold,
                                  fontSize: isDesktop ? 13.5 : null,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // ── صندوق الملاحظات ──
                Container(
                  padding: EdgeInsets.all(isDesktop ? 14 : 12),
                  decoration: BoxDecoration(
                    color: context.backgroundColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.description_outlined,
                        size: isDesktop ? 18 : 16,
                        color: context.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          patient.notes ??
                              (AppStrings.isArabic
                                  ? 'لا توجد ملاحظات إضافية للموعد'
                                  : 'No additional notes'),
                          style: AppTextStyles.bodyMedium(context).copyWith(
                            color: context.onSurfaceVariant,
                            fontSize: isDesktop ? 14 : null,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // ── زر بدء الكشف وكتابة الروشتة ──
                ElevatedButton(
                  onPressed: widget.onStartExamination,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.primaryContainer,
                    foregroundColor: context.onPrimary,
                    elevation: 0,
                    padding: EdgeInsets.symmetric(
                      vertical: isDesktop ? 14 : 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    minimumSize: Size(double.infinity, isDesktop ? 48 : 44),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.edit_note, size: isDesktop ? 22 : 20),
                      const SizedBox(width: 8),
                      Text(
                        AppStrings.isArabic
                            ? 'بدء الكشف وكتابة الروشتة'
                            : 'Start Examination & Prescription',
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: context.onPrimary,
                          fontSize: isDesktop ? 16 : null,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
