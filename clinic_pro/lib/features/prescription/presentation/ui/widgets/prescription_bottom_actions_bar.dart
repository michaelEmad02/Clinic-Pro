import 'package:flutter/material.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

// ────────────────────────────────────────────────────────
// شريط الأزرار السفلي للروشتة: حفظ - طباعة - إرسال
// ────────────────────────────────────────────────────────

class PrescriptionBottomActionsBar extends StatelessWidget {
  final VoidCallback onSave;
  final VoidCallback onPrint;
  final VoidCallback onWhatsApp;

  const PrescriptionBottomActionsBar({
    super.key,
    required this.onSave,
    required this.onPrint,
    required this.onWhatsApp,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: const Border(top: BorderSide(color: AppColors.border, width: 1)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: SafeArea(
        child: Row(
          children: [
            // زر حفظ وإنهاء (رئيسي)
            Expanded(
              flex: 2,
              child: ElevatedButton.icon(
                onPressed: onSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                icon: const Icon(Icons.save, size: 20),
                label: Text(
                  'حفظ وإنهاء',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // زر طباعة
            Expanded(
              flex: 1,
              child: OutlinedButton.icon(
                onPressed: onPrint,
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppColors.border),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.print, size: 20, color: AppColors.primary),
                label: Text(
                  'طباعة',
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            // زر إرسال عبر واتساب
            InkWell(
              onTap: onWhatsApp,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F7ED),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF25D366).withOpacity(0.3),
                  ),
                ),
                child: const Center(
                  child: Icon(
                    Icons.send,
                    color: Color(0xFF006C3E),
                    size: 20,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
