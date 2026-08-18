// ─────────────────────────────────────────
// مكونات المحاكاة الهيكلية لعيادة الطبيب (Doctor Dashboard Skeleton Shimmers)
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';

class DoctorDashboardShimmer extends StatelessWidget {
  const DoctorDashboardShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    return Shimmer.fromColors(
      baseColor: context.borderColor.withOpacity(0.5),
      highlightColor: context.surfaceColor,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 20),
        children: [
          // Current Patient Card Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 160,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor),
              ),
            ),
          ),
          const SizedBox(height: 24),
          // Stats Row Shimmer (4 cards)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              crossAxisCount: isMobile ? 2 : 4,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: isMobile ? 1.55 : 1.85,
              children: List.generate(4, (index) {
                return Container(
                  decoration: BoxDecoration(
                    color: context.surfaceColor,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: context.borderColor),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 24),
          // Waiting Queue List Shimmer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              height: 200,
              decoration: BoxDecoration(
                color: context.surfaceColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: context.borderColor),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
