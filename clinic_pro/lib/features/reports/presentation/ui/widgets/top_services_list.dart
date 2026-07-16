// ────────────────────────────────────────────────────────
// قائمة أبرز الخدمات — أيقونة + اسم + إيراد
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../manager/reports_state.dart';

class TopServicesList extends StatelessWidget {
  final List<TopServiceItem> services;

  const TopServicesList({super.key, required this.services});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: context.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.outline),
        boxShadow: const [
          BoxShadow(
            color: Color(0x08000000),
            blurRadius: 3,
            offset: Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.topServices,
            style: AppTextStyles.headlineSmall(context).copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          ...services.map((service) => _ServiceRow(service: service)),
        ],
      ),
    );
  }
}

class _ServiceRow extends StatelessWidget {
  final TopServiceItem service;

  const _ServiceRow({required this.service});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: context.primaryLightColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              _serviceIcon(service.icon),
              color: context.primary,
              size: 18,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              service.name,
              style: AppTextStyles.bodyMedium(context).copyWith(
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            '${service.revenue.toStringAsFixed(0)} ${AppStrings.egp}',
            style: AppTextStyles.dataNumeric(context).copyWith(
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  IconData _serviceIcon(String icon) {
    switch (icon) {
      case 'dentistry':
        return Icons.medical_services;
      case 'prescriptions':
        return Icons.description;
      case 'biotech':
        return Icons.biotech;
      case 'radiology':
        return Icons.health_and_safety_outlined;
      case 'physiotherapy':
        return Icons.accessibility_new;
      default:
        return Icons.local_hospital;
    }
  }
}
