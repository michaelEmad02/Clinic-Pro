import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// عنصر قائمة الأدوية في شاشة إدارة الأدوية
// ────────────────────────────────────────────────────────

class DrugListItem extends StatelessWidget {
  final Map<String, dynamic> drug;
  final VoidCallback onTap;

  const DrugListItem({
    super.key,
    required this.drug,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final String tradeName = drug['trade_name'] ?? '';
    final String genericName = drug['generic_name'] ?? '';
    final String category = drug['category'] ?? '';
    final String form = drug['form'] ?? '';
    final int stockCount = drug['stock_count'] ?? 0;
    final String stockStatus = drug['stock_status'] ?? 'متوفر';
    final bool isLowStock = stockStatus == 'مخزون منخفض';

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Center(
            child: Icon(
              Icons.medication_outlined,
              color: AppColors.primary,
              size: 24,
            ),
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                tradeName,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: isLowStock ? AppColors.warningLight : AppColors.primaryLight,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: AppTextStyles.labelChip(context).copyWith(
                  color: isLowStock ? AppColors.warning : AppColors.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              genericName,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                Text(
                  'الشكل: $form',
                  style: AppTextStyles.caption(context).copyWith(
                    color: AppColors.textHint,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 4,
                  height: 4,
                  decoration: const BoxDecoration(
                    color: AppColors.border,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'المخزون: $stockCount وحدة',
                  style: AppTextStyles.caption(context).copyWith(
                    color: isLowStock ? AppColors.danger : AppColors.accent,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert, color: AppColors.textSecondary),
          onPressed: onTap,
        ),
      ),
    );
  }
}
