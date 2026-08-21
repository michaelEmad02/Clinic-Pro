// ─────────────────────────────────────────
// هذا الملف يحتوي على ويدجت وشاشة وحوار التحميل الطبي الموحد (AppLoading)
// مصمم بأسلوب طبي أنيق (Minimalist Medical) مع أنيميشن نبض دقات القلب وحلقة تدفق سلسة
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/responsive_helper.dart';

/// أحجام ويدجت التحميل
enum AppLoadingSize {
  small,
  medium,
  large,
}

/// ويدجت التحميل الطبي المباشر (Inline / Embedded Widget)
class AppLoadingWidget extends StatefulWidget {
  final AppLoadingSize size;
  final String? message;
  final Color? color;

  const AppLoadingWidget({
    super.key,
    this.size = AppLoadingSize.medium,
    this.message,
    this.color,
  });

  @override
  State<AppLoadingWidget> createState() => _AppLoadingWidgetState();
}

class _AppLoadingWidgetState extends State<AppLoadingWidget>
    with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScaleAnimation;

  late final AnimationController _rotateController;

  @override
  void initState() {
    super.initState();

    // أنيميشن نبض القلب الداخلي
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);

    _pulseScaleAnimation = Tween<double>(begin: 0.82, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    // أنيميشن دوران الحلقة الخارجية
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  double get _dimension {
    switch (widget.size) {
      case AppLoadingSize.small:
        return 28.0;
      case AppLoadingSize.medium:
        return 48.0;
      case AppLoadingSize.large:
        return 72.0;
    }
  }

  double get _iconSize {
    switch (widget.size) {
      case AppLoadingSize.small:
        return 14.0;
      case AppLoadingSize.medium:
        return 22.0;
      case AppLoadingSize.large:
        return 34.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.color ?? context.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: _dimension,
          height: _dimension,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // الحلقة الخارجية الدوارة بأسلوب ناعم
              RotationTransition(
                turns: _rotateController,
                child: SizedBox(
                  width: _dimension,
                  height: _dimension,
                  child: CircularProgressIndicator(
                    strokeWidth: widget.size == AppLoadingSize.small ? 2.0 : 3.0,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      primaryColor.withOpacity(0.85),
                    ),
                    backgroundColor: primaryColor.withOpacity(0.12),
                  ),
                ),
              ),

              // الأيقونة الطبية بنبض دقات القلب في المركز
              AnimatedBuilder(
                animation: _pulseController,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseScaleAnimation.value,
                    child: Container(
                      padding: EdgeInsets.all(
                        widget.size == AppLoadingSize.small ? 2.0 : 4.0,
                      ),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: primaryColor.withOpacity(0.08),
                      ),
                      child: Icon(
                        Icons.vaccines_rounded,
                        size: _iconSize,
                        color: primaryColor,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
        if (widget.message != null && widget.message!.isNotEmpty) ...[
          const SizedBox(height: AppConstants.spaceSm + 4),
          Text(
            widget.message!,
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: context.textSecondary,
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// شاشة كاملة بحالة التحميل الطبي
class AppLoadingScreen extends StatelessWidget {
  final String? message;

  const AppLoadingScreen({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: ResponsiveHelper.responsiveCenter(
          maxWidth: AppConstants.maxContentWidth,
          child: Center(
            child: AppLoadingWidget(
              size: AppLoadingSize.large,
              message: message,
            ),
          ),
        ),
      ),
    );
  }
}

/// خدمة إظهار Loading Overlay عائم فوق الشاشة للحالات التفاعلية والعمليات الخلفية
class AppLoadingOverlay {
  static BuildContext? _overlayContext;

  /// إظهار حوار التحميل العائم
  static void show(
    BuildContext context, {
    String? message,
    bool barrierDismissible = false,
  }) {
    if (_overlayContext != null) return; // يمنع تكرار فتح الحوار

    showDialog(
      context: context,
      barrierDismissible: barrierDismissible,
      barrierColor: Colors.black.withOpacity(0.35),
      builder: (dialogContext) {
        _overlayContext = dialogContext;
        return PopScope(
          canPop: barrierDismissible,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: AppConstants.maxDialogWidth,
              ),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: AppConstants.spaceLg),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.spaceLg + 4,
                  vertical: AppConstants.spaceLg,
                ),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(
                    color: context.primary.withOpacity(0.2),
                    width: 1.2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: context.primary.withOpacity(0.12),
                      blurRadius: 24,
                      spreadRadius: 2,
                      offset: const Offset(0, 8),
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: AppLoadingWidget(
                  size: AppLoadingSize.large,
                  message: message,
                ),
              ),
            ),
          ),
        );
      },
    ).then((_) {
      _overlayContext = null;
    });
  }

  /// إغلاق حوار التحميل العائم
  static void hide(BuildContext context) {
    if (_overlayContext != null) {
      if (Navigator.canPop(_overlayContext!)) {
        Navigator.pop(_overlayContext!);
      }
      _overlayContext = null;
    }
  }
}
