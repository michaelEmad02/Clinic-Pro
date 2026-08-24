// ────────────────────────────────────────────────────────
// شاشة WebView لعرض بوابة دفع Paymob داخل التطبيق (PaymentWebviewScreen)
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../plans_and_subscriptions/domain/entities/plan_entity.dart';
import '../manager/payment_cubit.dart';
import '../manager/payment_state.dart';

class PaymentWebviewScreen extends StatelessWidget {
  final String paymentUrl;
  final String transactionId;
  final PlanEntity plan;
  final String subscriptionType;

  const PaymentWebviewScreen({
    super.key,
    required this.paymentUrl,
    required this.transactionId,
    required this.plan,
    required this.subscriptionType,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<PaymentCubit>(),
      child: _PaymentWebviewBody(
        paymentUrl: paymentUrl,
        transactionId: transactionId,
        plan: plan,
        subscriptionType: subscriptionType,
      ),
    );
  }
}

class _PaymentWebviewBody extends StatefulWidget {
  final String paymentUrl;
  final String transactionId;
  final PlanEntity plan;
  final String subscriptionType;

  const _PaymentWebviewBody({
    required this.paymentUrl,
    required this.transactionId,
    required this.plan,
    required this.subscriptionType,
  });

  @override
  State<_PaymentWebviewBody> createState() => _PaymentWebviewBodyState();
}

class _PaymentWebviewBodyState extends State<_PaymentWebviewBody> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isCheckingStatus = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    final urlStr = widget.paymentUrl.trim();
    if (urlStr.isEmpty || !urlStr.startsWith('http')) {
      setState(() => _isLoading = false);
      return;
    }

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) {
            setState(() => _isLoading = false);
            _checkForCompletionUrl(url);
          },
          onNavigationRequest: (NavigationRequest request) {
            _checkForCompletionUrl(request.url);
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(urlStr));
  }

  void _checkForCompletionUrl(String url) {
    // التحقق مما إذا كانت الدفعية اكتملت بالتحويل إلى صفحات النهاية الخاصة بـ Paymob
    if (url.contains('success=true') || url.contains('txn_response_code=APPROVED')) {
      _verifyPaymentStatus();
    } else if (url.contains('success=false') || url.contains('txn_response_code=DECLINED')) {
      _verifyPaymentStatus();
    }
  }

  void _verifyPaymentStatus() {
    if (_isCheckingStatus) return;
    setState(() => _isCheckingStatus = true);

    context.read<PaymentCubit>().verifyPayment(
          transactionId: widget.transactionId,
          plan: widget.plan,
          subscriptionType: widget.subscriptionType,
        );
  }

  void _onUserClose() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(
          AppStrings.cancelOperationTitle,
          style: AppTextStyles.headlineSmall(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          AppStrings.cancelOperationDesc,
          style: AppTextStyles.bodyMedium(context),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              AppStrings.continuePayment,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: context.primary,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _verifyPaymentStatus();
            },
            style: ElevatedButton.styleFrom(backgroundColor: context.danger),
            child: Text(
              AppStrings.closeAndConfirm,
              style: AppTextStyles.bodyMedium(context).copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          _onUserClose();
        }
      },
      child: Scaffold(
        backgroundColor: context.backgroundColor,
        appBar: AppBar(
          toolbarHeight: 64,
          backgroundColor: context.surfaceColor,
          elevation: 0,
          scrolledUnderElevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            onPressed: _onUserClose,
          ),
          title: Text(
            AppStrings.securePaymentGateway,
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
              color: context.primary,
            ),
            overflow: TextOverflow.ellipsis,
            maxLines: 1,
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded),
              onPressed: () => _controller.reload(),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(color: context.borderColor, height: 1),
          ),
        ),
        body: BlocConsumer<PaymentCubit, PaymentState>(
          listener: (context, state) {
            if (state is PaymentSuccess) {
              context.go(
                RouteConstants.paymentSuccess,
                extra: {
                  'statusResult': state.statusResult,
                  'plan': state.plan,
                  'subscriptionType': state.subscriptionType,
                },
              );
            } else if (state is PaymentFailed) {
              context.go(
                RouteConstants.paymentFailed,
                extra: {
                  'message': state.message,
                  'plan': widget.plan,
                  'subscriptionType': widget.subscriptionType,
                },
              );
            }
          },
          builder: (context, state) {
            if (state is PaymentVerifying || _isCheckingStatus) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const AppLoadingWidget(size: AppLoadingSize.large),
                    const SizedBox(height: AppConstants.spaceLg),
                    Text(
                      AppStrings.verifyingPaymentServer,
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: AppConstants.spaceSm),
                    Text(
                      AppStrings.doNotCloseApp,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        color: context.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            }

            return Stack(
              children: [
                WebViewWidget(controller: _controller),
                if (_isLoading)
                  const Center(
                    child: AppLoadingWidget(size: AppLoadingSize.large),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}
