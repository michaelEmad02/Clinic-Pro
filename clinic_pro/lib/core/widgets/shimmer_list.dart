import 'package:flutter/material.dart';
import 'app_loading.dart';

/// ويدجت التحميل الافتراضي للشاشات والـ Sheets (تستبدل الـ Shimmer التقليدي)
class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: AppLoadingWidget(
          size: AppLoadingSize.medium,
        ),
      ),
    );
  }
}
