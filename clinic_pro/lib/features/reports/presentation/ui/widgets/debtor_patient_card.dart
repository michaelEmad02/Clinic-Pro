// ────────────────────────────────────────────────────────
// DebtorPatientCard — كارت المريض المديون المتجاف مع مراعاة حجب الإجراءات للمالك
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/invoices/presentation/ui/widgets/add_invoice_sheet.dart';
import 'package:clinic_pro/features/reports/domain/entities/financial_receivables_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class DebtorPatientCard extends StatelessWidget {
  final PatientDebtorEntity debtor;

  const DebtorPatientCard({super.key, required this.debtor});

  Future<void> _launchWhatsApp(BuildContext context, String phone, double amount) async {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    final message = AppStrings.isArabic
        ? 'مرحباً ${debtor.patientName}، نود تذكيركم بوجود مستحقات مالية معلقة بقيمة ${amount.toStringAsFixed(0)} ${AppStrings.egp} لدى العيادة. نسعد بتواصلكم معنا.'
        : 'Hello ${debtor.patientName}, this is a friendly reminder regarding pending dues of ${amount.toStringAsFixed(0)} ${AppStrings.egp}. Thank you.';
    final url = Uri.parse('https://wa.me/$cleanPhone?text=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthCubit>().state.user;
    final isOwner = authUser?.role == StaffRoles.owner;
    final isMobile = ResponsiveHelper.isMobile(context);

    final margin = isMobile
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 4)
        : EdgeInsets.zero;

    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: context.border),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: context.primaryLightColor,
              child: Text(
                debtor.patientName.isNotEmpty ? debtor.patientName.substring(0, 1) : '?',
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    debtor.patientName,
                    style: AppTextStyles.headlineSmall(context).copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  if (debtor.patientPhone != null && debtor.patientPhone!.isNotEmpty)
                    Text(
                      debtor.patientPhone!,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                        fontSize: 11,
                      ),
                    ),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      if (debtor.issuedPendingAmount > 0)
                        _BadgeTag(
                          label: '${AppStrings.isArabic ? "فواتير" : "Invoices"}: ${debtor.issuedPendingAmount.toStringAsFixed(0)} ${AppStrings.egp}',
                          color: context.warning,
                        ),
                      if (debtor.unbilledAmount > 0)
                        _BadgeTag(
                          label: '${AppStrings.isArabic ? "زيارات معلقة" : "Visits"}: ${debtor.unbilledAmount.toStringAsFixed(0)} ${AppStrings.egp}',
                          color: context.danger,
                        ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '${debtor.totalDue.toStringAsFixed(0)} ${AppStrings.egp}',
                  style: AppTextStyles.dataNumeric(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.danger,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                // ⚠️ شرط عدم إظهار الإجراءات المباشرة للمالك (Owner)
                if (!isOwner) ...[
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (debtor.patientPhone != null && debtor.patientPhone!.isNotEmpty)
                        IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          icon: const Icon(Icons.chat_outlined, size: 18, color: Colors.green),
                          tooltip: AppStrings.isArabic ? 'تذكير عبر WhatsApp' : 'WhatsApp Reminder',
                          onPressed: () => _launchWhatsApp(
                            context,
                            debtor.patientPhone!,
                            debtor.totalDue,
                          ),
                        ),
                      const SizedBox(width: 6),
                      OutlinedButton.icon(
                        onPressed: () async {
                          await AddInvoiceSheet.show(
                            context,
                            initialPatientId: debtor.patientId,
                            initialPatientName: debtor.patientName,
                            initialPatientPhone: debtor.patientPhone,
                          );
                        },
                        icon: const Icon(Icons.receipt_long, size: 12),
                        label: Text(
                          AppStrings.isArabic ? 'تحصيل / تفوتر' : 'Settle',
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: context.primary,
                          side: BorderSide(color: context.primary.withOpacity(0.3)),
                          backgroundColor: context.primaryLightColor,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ],
                  ),
                ] else ...[
                  // بالنسبة للمالك (Owner) نوضح آخر نشاط فقط بدون أزرار تفاعلية للتحصيل
                  Text(
                    AppStrings.isArabic ? 'للعرض والتحليل' : 'View Only',
                    style: TextStyle(
                      fontSize: 10,
                      color: context.textSecondary.withOpacity(0.7),
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _BadgeTag extends StatelessWidget {
  final String label;
  final Color color;

  const _BadgeTag({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}
