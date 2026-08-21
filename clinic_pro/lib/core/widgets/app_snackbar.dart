// ─────────────────────────────────────────
// هذا الملف يحتوي على ويدجت إشعارات التطبيق الطبي الموحد (AppSnackbar)
// مصمم بأسلوب طبي أنيق (Minimalist Medical) مع أيقونة ناعمة وشريط جانبي مخصص
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import '../constants/app_constants.dart';
import '../themes/app_colors.dart';
import '../themes/app_text_styles.dart';
import '../utils/responsive_helper.dart';

/// أنواع إشعارات التطبيق
enum SnackbarType {
  success,
  error,
  info,
}

/// فئة خدمات إشعارات التطبيق الموحدة
class AppSnackbar {
  /// عرض إشعار نجاح العملية
  static void success(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackbarType.success,
      duration: duration,
    );
  }

  /// عرض إشعار خطأ
  static void error(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 4),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackbarType.error,
      duration: duration,
    );
  }

  /// عرض إشعار معلومات أو تنبيه عام
  static void info(
    BuildContext context, {
    required String message,
    String? title,
    Duration duration = const Duration(seconds: 3),
  }) {
    show(
      context,
      message: message,
      title: title,
      type: SnackbarType.info,
      duration: duration,
    );
  }

  /// الدالة الرئيسية لإظهار الـ SnackBar
  static void show(
    BuildContext context, {
    required String message,
    String? title,
    required SnackbarType type,
    Duration duration = const Duration(seconds: 3),
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();

    final isMobile = ResponsiveHelper.isMobile(context);

    messenger.showSnackBar(
      SnackBar(
        duration: duration,
        elevation: 0,
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.transparent,
        margin: EdgeInsets.symmetric(
          horizontal: isMobile ? AppConstants.spaceMd : AppConstants.spaceLg,
          vertical: AppConstants.spaceSm,
        ),
        padding: EdgeInsets.zero,
        content: ResponsiveHelper.responsiveCenter(
          maxWidth: 480.0,
          child: _AppSnackbarContent(
            message: message,
            title: title,
            type: type,
          ),
        ),
      ),
    );
  }
}

class _AppSnackbarContent extends StatefulWidget {
  final String message;
  final String? title;
  final SnackbarType type;

  const _AppSnackbarContent({
    required this.message,
    this.title,
    required this.type,
  });

  @override
  State<_AppSnackbarContent> createState() => _AppSnackbarContentState();
}

class _AppSnackbarContentState extends State<_AppSnackbarContent>
    with TickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseScaleAnimation;

  @override
  void initState() {
    super.initState();

    // انيميشن ظهور الكارت بالكامل (Slide Up + Fade In)
    _entryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    _slideAnimation = Tween<double>(begin: 0.2, end: 0.0).animate(
      CurvedAnimation(
        parent: _entryController,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: Curves.easeIn,
    );

    // انيميشن نبض الأيقونة (Pulse)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _pulseScaleAnimation = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _entryController.forward();
    _pulseController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _entryController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = _getColors(context);
    final icon = _getIcon();

    return AnimatedBuilder(
      animation: Listenable.merge([_entryController, _pulseController]),
      builder: (context, child) {
        return FractionalTranslation(
          translation: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Container(
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                border: Border.all(
                  color: colors.primaryColor.withOpacity(0.25),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: colors.primaryColor.withOpacity(0.12),
                    blurRadius: 20,
                    spreadRadius: 1,
                    offset: const Offset(0, 6),
                  ),
                  BoxShadow(
                    color: Colors.black.withOpacity(0.06),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: IntrinsicHeight(
                child: Row(
                  children: [
                    // الشريط الجانبي الملون بديكور متدرج ناعم
                    Container(
                      width: 6,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            colors.primaryColor,
                            colors.primaryColor.withOpacity(0.6),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppConstants.spaceMd,
                          vertical: AppConstants.spaceSm + 4,
                        ),
                        child: Row(
                          children: [
                            // الأيقونة الطبية المميزة بالدائرة والنبض المتحرك
                            Transform.scale(
                              scale: _pulseScaleAnimation.value,
                              child: Container(
                                padding: const EdgeInsets.all(AppConstants.spaceSm),
                                decoration: BoxDecoration(
                                  color: colors.backgroundColor,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: colors.primaryColor.withOpacity(0.15),
                                      blurRadius: 8,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  icon,
                                  size: 22,
                                  color: colors.primaryColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: AppConstants.spaceMd),
                            // المحتوى النصي
                            Expanded(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (widget.title != null && widget.title!.isNotEmpty) ...[
                                    Text(
                                      widget.title!,
                                      style: AppTextStyles.bodyMedium(context).copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: context.textPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    widget.message,
                                    style: AppTextStyles.bodyMedium(context).copyWith(
                                      color: context.textPrimary.withOpacity(0.95),
                                      fontWeight: FontWeight.w500,
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  IconData _getIcon() {
    switch (widget.type) {
      case SnackbarType.success:
        return Icons.check_circle_rounded;
      case SnackbarType.error:
        return Icons.error_outline_rounded;
      case SnackbarType.info:
        return Icons.info_outline_rounded;
    }
  }

  _SnackbarColors _getColors(BuildContext context) {
    switch (widget.type) {
      case SnackbarType.success:
        return _SnackbarColors(
          primaryColor: context.success,
          backgroundColor: context.successBg,
        );
      case SnackbarType.error:
        return _SnackbarColors(
          primaryColor: context.danger,
          backgroundColor: context.dangerBg,
        );
      case SnackbarType.info:
        return _SnackbarColors(
          primaryColor: context.primary,
          backgroundColor: context.primaryLightColor,
        );
    }
  }
}

class _SnackbarColors {
  final Color primaryColor;
  final Color backgroundColor;

  _SnackbarColors({
    required this.primaryColor,
    required this.backgroundColor,
  });
}
