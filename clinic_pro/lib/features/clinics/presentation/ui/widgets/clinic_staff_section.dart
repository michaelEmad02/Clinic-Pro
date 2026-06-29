// ────────────────────────────────────────────────────────
// قسم الطاقم الطبي في العيادة — تمرير أفقي مع شارات التخصص
// مطابق لتصميم phase8_ui/clinic_details_screen
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class ClinicStaffSection extends StatelessWidget {
  final String clinicId;

  const ClinicStaffSection({
    super.key,
    required this.clinicId,
  });

  @override
  Widget build(BuildContext context) {
    final staffEntries = MockData.clinicStaff
        .where((cs) =>
            cs['clinic_id'] == clinicId && cs['is_active'] == true)
        .toList();

    final staffList = staffEntries.map((entry) {
      final userId = entry['user_id'] as String;
      final role = entry['role'] as String;
      final userData = MockData.users.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => <String, dynamic>{},
      );

      return {
        'name': userData['name'] as String? ?? '',
        'role': role,
        'specialty': userData['specialty'] as String? ?? '',
        'avatar_url': userData['avatar_url'] as String?,
        'rating': (userData['rating'] as num?)?.toDouble() ?? 0,
      };
    }).toList();

    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceMd),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
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
          Row(
            children: [
              const Icon(Icons.badge_outlined,
                  size: 18, color: AppColors.primary),
              const SizedBox(width: 8),
              Text(
                'الطاقم الطبي',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Text(
                'عرض الكل',
                style: AppTextStyles.labelChip(context).copyWith(
                  color: AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (staffList.isEmpty)
            Text(
              'لا يوجد طاقم طبي في هذه العيادة',
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textHint,
              ),
            )
          else
            SizedBox(
              height: 210,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: staffList.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final staff = staffList[index];
                  final name = staff['name'] as String;
                  final role = staff['role'] as String;
                  final specialty = staff['specialty'] as String;
                  final avatarUrl = staff['avatar_url'] as String?;
                  final rating = staff['rating'] as double;

                  final initials = name
                      .trim()
                      .split(' ')
                      .where((p) => p.isNotEmpty)
                      .map((p) => p[0])
                      .take(2)
                      .join();

                  final roleLabel = _roleLabel(role);
                  final displaySpecialty =
                      specialty.isNotEmpty ? specialty : roleLabel;

                  return Container(
                    width: 160,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        // صورة الطبيب (64px)
                        CircleAvatar(
                          radius: 32,
                          backgroundColor: AppColors.primaryLight,
                          backgroundImage: avatarUrl != null
                              ? NetworkImage(avatarUrl)
                              : null,
                          child: avatarUrl == null
                              ? Text(
                                  initials,
                                  style: AppTextStyles
                                      .headlineSmall(context)
                                      .copyWith(
                                    color: AppColors.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                )
                              : null,
                        ),
                        const SizedBox(height: 8),
                        // الاسم
                        Text(
                          name,
                          style:
                              AppTextStyles.bodyMedium(context).copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 4),
                        // شارة التخصص
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryLight,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            displaySpecialty,
                            style:
                                AppTextStyles.caption(context).copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        // تقييم النجوم
                        if (rating > 0)
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.star,
                                  size: 14, color: AppColors.warning),
                              const SizedBox(width: 2),
                              Text(
                                rating.toStringAsFixed(1),
                                style: AppTextStyles
                                    .dataNumeric(context)
                                    .copyWith(
                                  color: AppColors.warningText,
                                  fontSize: 11,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _roleLabel(String role) {
    switch (role) {
      case 'doctor':
        return 'طبيب';
      case 'nurse':
        return 'تمريض';
      case 'accountant':
        return 'محاسب';
      case 'secretary':
        return 'سكرتير';
      case 'owner':
        return 'مالك';
      default:
        return role;
    }
  }
}
