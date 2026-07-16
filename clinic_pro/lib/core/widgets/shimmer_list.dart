import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../themes/app_colors.dart';
import '../constants/app_constants.dart';

class ShimmerList extends StatelessWidget {
  final int itemCount;

  const ShimmerList({super.key, this.itemCount = 5});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: itemCount,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: AppConstants.spaceMd),
          child: Shimmer.fromColors(
            baseColor: context.border,
            highlightColor: context.surface,
            child: Container(
              height: 80,
              decoration: BoxDecoration(
                color: context.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              ),
            ),
          ),
        );
      },
    );
  }
}
