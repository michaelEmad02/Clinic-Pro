import 'package:flutter/material.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/reports/domain/entities/reports_entities.dart';

class AdvancedDrugAnalyticsWidget extends StatefulWidget {
  final DrugStatsEntity stats;

  const AdvancedDrugAnalyticsWidget({super.key, required this.stats});

  @override
  State<AdvancedDrugAnalyticsWidget> createState() => _AdvancedDrugAnalyticsWidgetState();
}

class _AdvancedDrugAnalyticsWidgetState extends State<AdvancedDrugAnalyticsWidget> {
  bool _isRepeatExpanded = false;
  bool _isReachExpanded = false;
  bool _isChronicExpanded = false;

  @override
  Widget build(BuildContext context) {
    final top10Repeat = widget.stats.repeatedDrugs.take(10).toList();
    final visibleRepeat = _isRepeatExpanded ? top10Repeat : top10Repeat.take(5).toList();

    final top10Reach = widget.stats.patientReach.take(10).toList();
    final visibleReach = _isReachExpanded ? top10Reach : top10Reach.take(5).toList();

    final top10Chronic = widget.stats.chronicDrugs.take(10).toList();
    final visibleChronic = _isChronicExpanded ? top10Chronic : top10Chronic.take(5).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Repeat Prescriptions (تكرار نفس الدواء لنفس المريض)
        if (widget.stats.repeatedDrugs.isNotEmpty) ...[
          _buildCardContainer(
            context,
            title: '🔄 أكثر الأدوية تكراراً لنفس المريض',
            subtitle: 'توضح الأدوية الأكثر طلباً للتجديد والمتابعة المستمرة',
            isExpanded: _isRepeatExpanded,
            canExpand: top10Repeat.length > 5,
            totalCount: top10Repeat.length,
            onToggle: () => setState(() => _isRepeatExpanded = !_isRepeatExpanded),
            child: Column(
              children: visibleRepeat.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.drugName,
                          style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A6B8A).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'كرر ${item.repeatCount} مرة (${item.patientCount} مريض)',
                          style: AppTextStyles.caption(context).copyWith(
                            color: const Color(0xFF1A6B8A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
        ],

        // 2. Patient Reach (انتشار الدواء بين المرضى)
        if (widget.stats.patientReach.isNotEmpty) ...[
          _buildCardContainer(
            context,
            title: '👥 انتشار الدواء بين المرضى (Reach)',
            subtitle: 'الأدوية المقترحة كخيار خط أول لعدد أكبر من المرضى',
            isExpanded: _isReachExpanded,
            canExpand: top10Reach.length > 5,
            totalCount: top10Reach.length,
            onToggle: () => setState(() => _isReachExpanded = !_isReachExpanded),
            child: Column(
              children: visibleReach.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.drugName,
                          style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFF2ECC9A).withOpacity(0.12),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${item.uniquePatients} مرضى منفصلين',
                          style: AppTextStyles.caption(context).copyWith(
                            color: const Color(0xFF2ECC9A),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
        ],

        // 3. Chronic Medications (أدوية الاستخدام المستمر)
        if (widget.stats.chronicDrugs.isNotEmpty) ...[
          _buildCardContainer(
            context,
            title: '💊 أدوية الاستخدام المستمر (المزمنة)',
            subtitle: 'الأدوية الموصوفة بدون مدة محددة (مستمر)',
            isExpanded: _isChronicExpanded,
            canExpand: top10Chronic.length > 5,
            totalCount: top10Chronic.length,
            onToggle: () => setState(() => _isChronicExpanded = !_isChronicExpanded),
            child: Column(
              children: visibleChronic.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          item.name,
                          style: AppTextStyles.bodyMedium(context).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '${item.count} وصفة مستمرة',
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCardContainer(
    BuildContext context, {
    required String title,
    required String subtitle,
    required Widget child,
    required bool isExpanded,
    required bool canExpand,
    required int totalCount,
    required VoidCallback onToggle,
  }) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: BorderRadius.circular(AppConstants.radiusCard),
        border: Border.all(color: context.borderColor, width: 0.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
              ),
              if (canExpand)
                InkWell(
                  onTap: onToggle,
                  borderRadius: BorderRadius.circular(20),
                  child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'عرض أقل' : 'عرض الكل ($totalCount)',
                          style: AppTextStyles.caption(context).copyWith(
                            color: context.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Icon(
                          isExpanded ? Icons.keyboard_arrow_up_rounded : Icons.keyboard_arrow_down_rounded,
                          color: context.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            style: AppTextStyles.caption(context).copyWith(color: context.textSecondary),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          child,
        ],
      ),
    );
  }
}
