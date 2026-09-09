// ────────────────────────────────────────────────────────
// كارت عرض الفحص الطبي (MedicalRecordCard)
// يدعم التجاوب، الثيم الداكن/الفاتح، وتعدد اللغات مع انيميشن ضغط ناعم
// ────────────────────────────────────────────────────────

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/medical_records/domain/entities/medical_record_entity.dart';
import 'medical_record_image_viewer.dart';

class MedicalRecordCard extends StatefulWidget {
  final MedicalRecordEntity record;
  final VoidCallback? onDelete;

  const MedicalRecordCard({
    super.key,
    required this.record,
    this.onDelete,
  });

  @override
  State<MedicalRecordCard> createState() => _MedicalRecordCardState();
}

class _MedicalRecordCardState extends State<MedicalRecordCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isLab = widget.record.isLabTest;
    final badgeColor = isLab ? const Color(0xFF0D9488) : const Color(0xFF6366F1);
    final typeIcon = isLab ? Icons.science_rounded : Icons.camera_alt_rounded;
    final typeLabel = isLab ? AppStrings.labTestShort : AppStrings.radiologyShort;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedScale(
        scale: _isHovered ? 1.02 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => MedicalRecordImageViewer.show(context, widget.record),
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            child: Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                border: Border.all(
                  color: _isHovered
                      ? context.primary.withOpacity(0.4)
                      : context.borderColor,
                  width: _isHovered ? 1.5 : 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(_isHovered ? 0.08 : 0.03),
                    blurRadius: _isHovered ? 12 : 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // قسم معاينة الصورة مع الشارة وزر الحذف
                  Expanded(
                    flex: 5,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CachedNetworkImage(
                          imageUrl: widget.record.fileUrl,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Shimmer.fromColors(
                            baseColor: context.borderColor.withOpacity(0.4),
                            highlightColor: context.surfaceColor,
                            child: Container(color: context.surfaceContainerLow),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: context.borderColor.withOpacity(0.2),
                            child: Center(
                              child: Icon(
                                Icons.broken_image_rounded,
                                size: 32,
                                color: context.textSecondary,
                              ),
                            ),
                          ),
                        ),

                        // شارة نوع الفحص
                        Positioned(
                          top: 8,
                          right: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: context.surfaceColor.withOpacity(0.92),
                              borderRadius:
                                  BorderRadius.circular(AppConstants.radiusChip),
                              border: Border.all(
                                color: badgeColor.withOpacity(0.4),
                                width: 0.8,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.06),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(typeIcon, size: 12, color: badgeColor),
                                const SizedBox(width: 4),
                                Text(
                                  typeLabel,
                                  style: AppTextStyles.caption(context).copyWith(
                                    color: badgeColor,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // زر الحذف
                        if (widget.onDelete != null)
                          Positioned(
                            top: 8,
                            left: 8,
                            child: Material(
                              color: Colors.black.withOpacity(0.45),
                              shape: const CircleBorder(),
                              child: InkWell(
                                customBorder: const CircleBorder(),
                                onTap: () => _confirmDelete(context),
                                child: const Padding(
                                  padding: EdgeInsets.all(6),
                                  child: Icon(
                                    Icons.delete_outline_rounded,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // قسم البيانات النصية
                  Expanded(
                    flex: 4,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // 1. عنوان الفحص
                          Text(
                            widget.record.title,
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),

                          // 2. شارة حالة الارتباط بالموعد
                          _buildAppointmentLinkageBadge(context),

                          // 3. سطر التاريخ والملاحظات
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today_rounded,
                                size: 11,
                                color: context.textSecondary,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                widget.record.recordDate,
                                style: AppTextStyles.caption(context).copyWith(
                                  color: context.textSecondary,
                                  fontSize: 10.5,
                                ),
                              ),
                              if (widget.record.notes != null &&
                                  widget.record.notes!.isNotEmpty) ...[
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    '• ${widget.record.notes!}',
                                    style: AppTextStyles.caption(context).copyWith(
                                      color: context.textSecondary,
                                      fontSize: 10,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// شارة توضح ما إذا كان الفحص مرتبطاً بموعد واسم نوع الموعد
  Widget _buildAppointmentLinkageBadge(BuildContext context) {
    final isLinked = widget.record.isLinkedToAppointment;
    final typeName = widget.record.appointmentTypeName;
    final label = isLinked
        ? (typeName != null && typeName.isNotEmpty
            ? AppStrings.linkedToAppointmentWithName(typeName)
            : AppStrings.linkedToAppointment)
        : AppStrings.unlinkedRecord;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2.5),
      decoration: BoxDecoration(
        color: isLinked
            ? const Color(0xFF10B981).withOpacity(0.12)
            : context.borderColor.withOpacity(0.3),
        borderRadius: BorderRadius.circular(AppConstants.radiusChip),
        border: Border.all(
          color: isLinked
              ? const Color(0xFF10B981).withOpacity(0.4)
              : context.borderColor,
          width: 0.8,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLinked ? Icons.event_available_rounded : Icons.link_off_rounded,
            size: 11,
            color: isLinked ? const Color(0xFF059669) : context.textSecondary,
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isLinked ? FontWeight.bold : FontWeight.normal,
                color: isLinked ? const Color(0xFF059669) : context.textSecondary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.deleteRecordTitle,
          style: AppTextStyles.headlineSmall(ctx).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppStrings.deleteRecordConfirm(widget.record.title),
          style: AppTextStyles.bodyMedium(ctx),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.cancel,
              style: AppTextStyles.bodyMedium(ctx).copyWith(
                color: context.textSecondary,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              widget.onDelete?.call();
            },
            child: Text(
              AppStrings.delete,
              style: AppTextStyles.bodyMedium(ctx).copyWith(
                color: context.danger,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
