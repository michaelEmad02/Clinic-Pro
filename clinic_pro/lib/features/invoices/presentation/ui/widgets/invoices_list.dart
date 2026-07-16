// ────────────────────────────────────────────────────────
// قائمة الفواتير — ListView.builder مع EmptyState
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/widgets/empty_state.dart';
import '../../manager/invoices_state.dart';
import 'invoice_list_item.dart';

class InvoicesList extends StatelessWidget {
  final List<InvoiceItem> invoices;
  final ValueChanged<InvoiceItem> onItemTap;
  final ValueChanged<InvoiceItem> onItemMore;

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

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: invoices.length,
      padding: EdgeInsets.zero,
      itemBuilder: (context, index) {
        final invoice = invoices[index];
        return InvoiceListItem(invoice: invoice);
      },
    );
  }
}
