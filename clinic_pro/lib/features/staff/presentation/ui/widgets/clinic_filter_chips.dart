import 'package:clinic_pro/features/clinics/domain/entities/clinic_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

/// ويدجت فلاتر العيادات بتصميم راقٍ وحديث
/// يعرض صفاً أفقياً من البطاقات المصغرة للعيادات مع صورها وشعاراتها
class ClinicFilterChips extends StatelessWidget {
  final List<ClinicEntity> clinics;
  final String? selectedClinicId;
  final ValueChanged<String?> onChanged;

  const ClinicFilterChips({
    super.key,
    required this.clinics,
    required this.selectedClinicId,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    if (clinics.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            AppStrings.filterByClinic,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              // زر "كل العيادات"
              _buildClinicCard(
                context: context,
                id: '',
                name: AppStrings.allClinics,
                logoUrl: null,
                isSelected:
                    selectedClinicId == null || selectedClinicId!.isEmpty,
              ),

              // بطاقات العيادات الفردية
              ...clinics.map((clinic) {
                final id = clinic.id;
                final name = clinic.name;
                final logoUrl = clinic.logoUrl;
                final isSelected = selectedClinicId == id;
                return _buildClinicCard(
                  context: context,
                  id: id,
                  name: name,
                  logoUrl: logoUrl.isEmpty ? null : logoUrl,
                  isSelected: isSelected,
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildClinicCard({
    required BuildContext context,
    required String? id,
    required String name,
    required String? logoUrl,
    required bool isSelected,
  }) {
    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 10),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Material(
          color: isSelected ? context.primary : context.surface,
          borderRadius: BorderRadius.circular(14),
          elevation: isSelected ? 4 : 0,
          shadowColor: context.primary.withOpacity(0.3),
          child: InkWell(
            onTap: () => onChanged(id),
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected ? context.primary : context.border,
                  width: 1.5,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // شعار العيادة الدائري
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Colors.white.withOpacity(0.2)
                          : context.background,
                      shape: BoxShape.circle,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: logoUrl != null
                          ? Image.network(
                              logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _buildPlaceholderIcon(isSelected, context),
                            )
                          : _buildPlaceholderIcon(isSelected, context),
                    ),
                  ),
                  const SizedBox(width: 10),

                  // اسم العيادة
                  Text(
                    name,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w500,
                      color: isSelected
                          ? context.textPrimary
                          : context.textSecondary,
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

  Widget _buildPlaceholderIcon(bool isSelected, BuildContext context) {
    return Icon(
      Icons.business_outlined,
      size: 16,
      color: isSelected ? Colors.white : context.primary,
    );
  }
}
