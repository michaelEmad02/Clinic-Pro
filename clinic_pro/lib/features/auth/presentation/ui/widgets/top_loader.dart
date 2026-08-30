import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../../../core/themes/app_colors.dart';

class TopLoader {
  static Widget _buildContainer(BuildContext context) => SizedBox(
        width: 35,
        height: 35,
        child: Center(
          child: LoadingAnimationWidget.threeArchedCircle(
            color: context.primary,
            size: 120,
          ),
        ),
      );

  static void startLoading(BuildContext context) {
    showDialog(
      barrierColor: Colors.black54,
      barrierDismissible: false,
      context: context,
      builder: (ctx) => _buildContainer(ctx),
    );
  }

  static void stopLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}
