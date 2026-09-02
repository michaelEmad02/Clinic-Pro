// ────────────────────────────────────────────────────────
// InvoicesList — مكون عرض قائمة أو شبكة الفواتير الصادرة
// يتكيف مع الهواتف بـ ListView والشاشات الكبيرة بـ GridView
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/features/invoices/domain/entities/invoice_entity.dart';
import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/empty_state.dart';
import 'invoice_list_item.dart';

class InvoicesList extends StatelessWidget {
  final List<InvoiceEntity> invoices;
  final ValueChanged<InvoiceEntity> onItemTap;
  final ValueChanged<InvoiceEntity> onItemMore;

  const InvoicesList({
    super.key,
    required this.invoices,
    required this.onItemTap,
    required this.onItemMore,
  });

  @override
  Widget build(BuildContext context) {
    if (invoices.isEmpty) {
      return EmptyState(
        title: AppStrings.invoices,
        subtitle: AppStrings.noData,
        icon: Icons.receipt_long_outlined,
      );
    }

    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: invoices.length,
        padding: EdgeInsets.zero,
        itemBuilder: (context, index) {
          final invoice = invoices[index];
          return InkWell(
            onTap: () => onItemTap(invoice),
            child: InvoiceListItem(invoice: invoice),
          );
        },
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        mainAxisExtent: 84,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: invoices.length,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return InkWell(
          onTap: () => onItemTap(invoice),
          child: InvoiceListItem(invoice: invoice),
        );
      },
    );
  }
}
