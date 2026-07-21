import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../constants/app_constants.dart';

import '../utils/responsive_helper.dart';

class AppBottomSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required Widget child,
    bool isScrollControlled = true,
  }) {
    if (!ResponsiveHelper.isMobile(context)) {
      return showDialog<T>(
        context: context,
        builder: (context) {
          final maxHeight = MediaQuery.sizeOf(context).height * 0.85;
          return Dialog(
            backgroundColor: context.surfaceColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: AppConstants.maxDialogWidth,
                maxHeight: maxHeight,
              ),
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.spaceMd),
                child: SingleChildScrollView(
                  child: child,
                ),
              ),
            ),
          );
        },
      );
    }

    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: isScrollControlled,
      backgroundColor: context.surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppConstants.radiusSheet),
        ),
      ),
      builder: (context) {
        final maxHeight = MediaQuery.sizeOf(context).height * 0.92;
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxHeight: maxHeight),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: AppConstants.spaceSm),
                  Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: context.borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(height: AppConstants.spaceMd),
                  Flexible(
                    child: SingleChildScrollView(
                      padding: const EdgeInsetsDirectional.only(bottom: 8),
                      child: child,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
