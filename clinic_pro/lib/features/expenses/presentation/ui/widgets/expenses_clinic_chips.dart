// ────────────────────────────────────────────────────────
// ExpensesClinicChips — فلاتر العيادات للمالك
// تتيح للمالك التبديل بين عياداته أو استعراض كل العيادات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:flutter/material.dart';

class ExpensesClinicChips extends StatelessWidget {
  final List<ClinicEntity> clinics;
  final String? selectedClinicId;
  final ValueChanged<String?> onChanged;

  const ExpensesClinicChips({
    super.key,
    required this.clinics,
    required this.selectedClinicId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) return const SizedBox.shrink();

    final isDesktop = ResponsiveHelper.isDesktop(context);
    final isAllSelected = selectedClinicId == null || selectedClinicId!.isEmpty;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: isDesktop ? 0 : 16),
      child: Row(
        children: [
          Padding(
            padding: const EdgeInsetsDirectional.only(end: 8),
            child: ChoiceChip(
              avatar: Icon(
                Icons.apartment_rounded,
                size: 16,
                color: isAllSelected ? context.primary : context.textSecondary,
              ),
              label: Text(
                AppStrings.isArabic ? 'كل الفروع / العيادات' : 'All Clinics',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: isAllSelected
                      ? context.primary
                      : context.textSecondary,
                  fontWeight: isAllSelected
                      ? FontWeight.bold
                      : FontWeight.normal,
                ),
              ),
              selected: isAllSelected,
              onSelected: (_) => onChanged(null),
              selectedColor: context.primaryLightColor,
              backgroundColor: context.surfaceColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isAllSelected
                      ? context.primary
                      : context.borderColor,
                ),
              ),
              showCheckmark: false,
            ),
          ),
          ...clinics.map((clinic) {
            final isSelected = selectedClinicId == clinic.id;

            return Padding(
              padding: const EdgeInsetsDirectional.only(end: 8),
              child: ChoiceChip(
                avatar: Icon(
                  Icons.local_hospital_outlined,
                  size: 16,
                  color: isSelected ? context.primary : context.textSecondary,
                ),
                label: Text(clinic.name),
                selected: isSelected,
                onSelected: (_) => onChanged(isSelected ? null : clinic.id),
                selectedColor: context.primaryLightColor,
                backgroundColor: context.surfaceColor,
                labelStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  color: isSelected ? context.primary : context.textSecondary,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                  side: BorderSide(
                    color: isSelected ? context.primary : context.borderColor,
                  ),
                ),
                showCheckmark: false,
              ),
            );
          }),
        ],
      ),
    );
  }
}
