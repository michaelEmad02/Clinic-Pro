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

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.border),
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
            color: context.primaryLightColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Center(
            child: Icon(
              Icons.medication_outlined,
              color: context.primary,
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
                  color: context.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                category,
                style: AppTextStyles.labelChip(context).copyWith(
                  color: context.primary,
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
                color: context.textSecondary,
              ),
            ),
          ],
        ),
        trailing: IconButton(
          icon:  Icon(Icons.more_vert, color: context.textSecondary),
          onPressed: onTap,
        ),
      ),
    );
  }
}
