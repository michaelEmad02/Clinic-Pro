// ────────────────────────────────────────────────────────
// شاشة الفواتير — عرض الفواتير وإدارتها
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../manager/invoices_cubit.dart';
import '../manager/invoices_state.dart';
import 'widgets/add_invoice_sheet.dart';
import 'widgets/invoice_action_sheet.dart';
import 'widgets/invoices_list.dart';
import 'widgets/invoices_summary_bar.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/shimmer_list.dart';

import '../../../../core/di/injection_container.dart';

class InvoicesScreen extends StatelessWidget {
  const InvoicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<InvoicesCubit>()..loadInvoices(),
      child: const _InvoicesBody(),
    );
  }
}

class _InvoicesBody extends StatelessWidget {
  const _InvoicesBody();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: 64,
        backgroundColor: AppColors.surface,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(
          'الفواتير',
          style: AppTextStyles.headlineLarge(context).copyWith(
            fontWeight: FontWeight.bold,
            color: AppColors.primary,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: AppColors.border, height: 1),
        ),
      ),
      body: BlocBuilder<InvoicesCubit, InvoicesState>(
        builder: (context, state) {
          if (state is InvoicesLoading) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: ShimmerList(itemCount: 5),
            );
          }
          if (state is InvoicesError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () =>
                        context.read<InvoicesCubit>().loadInvoices(),
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }
          if (state is InvoicesLoaded) {
            return RefreshIndicator(
              onRefresh: () async {
                context.read<InvoicesCubit>().loadInvoices();
                await Future.delayed(const Duration(milliseconds: 600));
              },
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 16),
                children: [
                  InvoicesSummaryBar(state: state),
                  const SizedBox(height: 12),
                  InvoicesList(
                    invoices: state.filteredInvoices,
                    onItemTap: (inv) => _showActions(context, inv),
                    onItemMore: (inv) => _showActions(context, inv),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddInvoiceSheet.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }

  void _showActions(BuildContext context, InvoiceItem invoice) {
    InvoiceActionSheet.show(
      context: context,
      invoice: invoice,
    );
  }
}
