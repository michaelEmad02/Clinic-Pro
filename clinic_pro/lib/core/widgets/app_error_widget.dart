// ─────────────────────────────────────────
// هذا الملف يحتوي على ويدجت وشاشة معالجة الأخطاء العامة للتطبيق (AppErrorWidget & AppErrorScreen)
// مصممة بأسلوب نظيف وبسيط (Minimalist & Clean) ومباشر بدون تشتيت بصري
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import 'app_loading.dart';
import '../strings/app_strings.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/responsive_helper.dart';

/// ويدجت مستقل لمعالجة وعرض أخطاء التطبيق والشبكة بأسلوب نظيف ومباشر
class AppErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool isRetrying;
  final String? title;
  final String? message;
  final bool isNetwork;

  const AppErrorWidget({
    super.key,
    this.onRetry,
    this.isRetrying = false,
    this.title,
    this.message,
    this.isNetwork = true,
  });

  /// الكشف عما إذا كان الخطأ يعبر عن انقطاع في الاتصال بالشبكة
  static bool isNetworkError(dynamic error) {
    if (error == null) return false;
    final msg = error.toString().toLowerCase();
    return msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('host lookup') ||
        msg.contains('connection') ||
        msg.contains('timed out') ||
        msg.contains('timeout') ||
        msg.contains('انترنت') ||
        msg.contains('إنترنت') ||
        msg.contains('اتصال') ||
        msg.contains('شبكة');
  }

  /// بناء المكون البرمجي المناسب تلقائياً حسب نوع الخطأ
  static Widget buildErrorView({
    required BuildContext context,
    required dynamic error,
    required VoidCallback onRetry,
    bool isRetrying = false,
  }) {
    final errorMsg = error?.toString() ?? AppStrings.error;
    final isNetwork = isNetworkError(error);

    return AppErrorWidget(
      onRetry: onRetry,
      isRetrying: isRetrying,
      isNetwork: isNetwork,
      title: isNetwork ? AppStrings.noInternetTitle : AppStrings.error,
      message: isNetwork ? AppStrings.noInternetMessage : errorMsg,
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayTitle =
        title ?? (isNetwork ? AppStrings.noInternetTitle : AppStrings.error);
    final displayMessage = message ??
        (isNetwork ? AppStrings.noInternetMessage : AppStrings.error);
    final dangerColor = context.danger;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.spaceXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            // // 🩺 أيقونة ناعمة ومباشرة للخطأ بدون تعقيد
            // Container(
            //   width: 84,
            //   height: 84,
            //   decoration: BoxDecoration(
            //     shape: BoxShape.circle,
            //     color: dangerColor.withOpacity(0.08),
            //   ),
            //   child: Icon(
            //     isNetwork
            //         ? Icons.wifi_off_rounded
            //         : Icons.error_outline_rounded,
            //     size: 44,
            //     color: dangerColor,
            //   ),
            // ),
            // 🩺 أيقونة ناعمة ومتحركة بتأثير نبض طبي سلس
            _AnimatedErrorIconBadge(isNetwork: isNetwork),

            const SizedBox(height: AppConstants.spaceLg),

            // العنوان الرئيسي للخطأ
            Text(
              displayTitle,
              style: AppTextStyles.headlineSmall(context).copyWith(
                color: context.textPrimary,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: AppConstants.spaceSm),

            // الوصف التوضيحي للخطأ
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 360),
              child: Text(
                displayMessage,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppConstants.spaceXl),

            // زر إعادة المحاولة التفاعلي المباشر
            if (onRetry != null)
              ElevatedButton.icon(
                onPressed: isRetrying ? null : onRetry,
                icon: isRetrying
                    ? const AppLoadingWidget(
                        size: AppLoadingSize.small,
                        color: Colors.white,
                      )
                    : const Icon(Icons.refresh_rounded, color: Colors.white),
                label: Text(
                  isRetrying
                      ? AppStrings.checkingConnection
                      : AppStrings.retryConnection,
                  style: AppTextStyles.bodyLarge(context).copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: dangerColor,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(180, 48),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.spaceLg,
                    vertical: AppConstants.spaceSm,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(AppConstants.radiusButton),
                  ),
                  elevation: 2,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// شاشة كاملة لمعالجة الأخطاء بحالة منفردة
class AppErrorScreen extends StatelessWidget {
  final VoidCallback? onRetry;
  final bool isRetrying;
  final bool showAppBar;
  final dynamic error;

  const AppErrorScreen({
    super.key,
    this.onRetry,
    this.isRetrying = false,
    this.showAppBar = true,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final isNetwork = AppErrorWidget.isNetworkError(error);

    return Scaffold(
      appBar: showAppBar
          ? AppBar(
              title: Text(
                isNetwork ? AppStrings.noInternetTitle : AppStrings.error,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: context.primary,
                ),
              ),
              centerTitle: true,
            )
          : null,
      body: SafeArea(
        child: ResponsiveHelper.responsiveCenter(
          maxWidth: 600,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(vertical: AppConstants.spaceXl),
            child: error != null
                ? AppErrorWidget.buildErrorView(
                    context: context,
                    error: error,
                    onRetry: onRetry ?? () {},
                    isRetrying: isRetrying,
                  )
                : AppErrorWidget(
                    onRetry: onRetry,
                    isRetrying: isRetrying,
                  ),
          ),
        ),
      ),
    );
  }
}

/// أيقونة ناعمة ومتحركة بتأثير نبض طبي سلس (Medical Pulse Animation)
class _AnimatedErrorIconBadge extends StatefulWidget {
  final bool isNetwork;

  const _AnimatedErrorIconBadge({required this.isNetwork});

  @override
  State<_AnimatedErrorIconBadge> createState() => _AnimatedErrorIconBadgeState();
}

class _AnimatedErrorIconBadgeState extends State<_AnimatedErrorIconBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.08, end: 0.18).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dangerColor = context.danger;

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: dangerColor.withOpacity(_opacityAnimation.value),
              boxShadow: [
                BoxShadow(
                  color: dangerColor.withOpacity(0.08),
                  blurRadius: 16 * _scaleAnimation.value,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              widget.isNetwork
                  ? Icons.wifi_off_rounded
                  : Icons.error_outline_rounded,
              size: 44,
              color: dangerColor,
            ),
          ),
        );
      },
    );
  }
}
