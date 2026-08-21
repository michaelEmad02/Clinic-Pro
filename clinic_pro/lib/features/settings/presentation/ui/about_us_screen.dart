// ─────────────────────────────────────────
// هذا الملف يعرض شاشة "من نحن" مع معلومات الشركة ومعلومات الاتصال
// ─────────────────────────────────────────

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/utils/responsive_helper.dart';
import '../../../../core/widgets/app_error_widget.dart';
import '../../../../core/widgets/app_loading.dart';
import '../../../plans_and_subscriptions/domain/entities/company_info_entity.dart';
import '../manager/about_us_cubit.dart';
import '../manager/about_us_state.dart';

class AboutUsScreen extends StatelessWidget {
  const AboutUsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<AboutUsCubit>()..loadCompanyInfo(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            AppStrings.aboutUs,
            style: AppTextStyles.headlineMedium(context)
                .copyWith(color: context.primary),
          ),
        ),
        body: BlocBuilder<AboutUsCubit, AboutUsState>(
          builder: (context, state) {
            if (state is AboutUsLoading) {
              return const Center(child: AppLoadingWidget());
            }

            if (state is AboutUsError) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    state.message,
                    style: AppTextStyles.bodyMedium(context),
                  ),
                ),
              );
            }

            if (state is AboutUsLoaded) {
              return RefreshIndicator(
                onRefresh: () async {
                  await context.read<AboutUsCubit>().loadCompanyInfo();
                },
                child: ResponsiveHelper.responsiveCenter(
                  maxWidth: 720,
                  child: SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(AppConstants.screenEdgeH),
                    child: _AboutUsBody(info: state.companyInfo),
                  ),
                ),
              );
            }

            final errorMsg = state is AboutUsError ? state.message : null;
            return AppErrorWidget.buildErrorView(
              context: context,
              error: errorMsg,
              onRetry: () => context.read<AboutUsCubit>().loadCompanyInfo(),
            );
          },
        ),
      ),
    );
  }
}

class _AboutUsBody extends StatelessWidget {
  final CompanyInfoEntity info;

  const _AboutUsBody({required this.info});

  Future<void> _launchUrl(String urlStr) async {
    try {
      final uri = Uri.parse(urlStr);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _makePhoneCall(String phone) async {
    final rawPhone = phone.trim();
    final cleanPhone =
        rawPhone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '');
    final telUri = Uri.parse('tel:$cleanPhone');
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
      } else {
        await launchUrl(telUri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  Future<void> _openWhatsApp(String whatsapp) async {
    final rawPhone = whatsapp.trim();
    final cleanPhone =
        rawPhone.replaceAll('+', '').replaceAll(' ', '').replaceAll('-', '');

    final url = Uri.parse('https://wa.me/+2$cleanPhone');
    final apiUrl =
        Uri.parse('https://api.whatsapp.com/send?phone=+2$cleanPhone');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else if (await canLaunchUrl(apiUrl)) {
        await launchUrl(apiUrl, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(url, mode: LaunchMode.platformDefault);
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: AppConstants.spaceLg),
        // شعار التطبيق / الشركة
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            color: context.primary.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: context.primary.withOpacity(0.3), width: 2),
          ),
          child: info.logoUrl != null &&
                  info.logoUrl!.trim().isNotEmpty &&
                  info.logoUrl!.trim().startsWith('http')
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Image.network(
                    info.logoUrl!.trim(),
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.local_hospital_rounded,
                      size: 50,
                      color: context.primary,
                    ),
                  ),
                )
              : Icon(
                  Icons.local_hospital_rounded,
                  size: 50,
                  color: context.primary,
                ),
        ),
        const SizedBox(height: AppConstants.spaceMd),

        // اسم الشركة / المنظومة
        Text(
          info.name,
          style: AppTextStyles.headlineMedium(context).copyWith(
            color: context.textPrimary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        if (info.location != null && info.location!.isNotEmpty) ...[
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on_outlined,
                  size: 18, color: context.textSecondary),
              const SizedBox(width: 4),
              Text(
                info.location!,
                style: AppTextStyles.bodyMedium(context)
                    .copyWith(color: context.textSecondary),
              ),
            ],
          ),
        ],

        const SizedBox(height: AppConstants.spaceXl),

        // بطاقة معلومات التواصل
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(AppConstants.spaceLg),
          decoration: BoxDecoration(
            color: context.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
            border: Border.all(color: context.border, width: 0.5),
            boxShadow: const [
              BoxShadow(
                color: Color(0x0F000000),
                blurRadius: 6,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.contactUs,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  color: context.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),

              // أزرار التواصل الهاتفية
              _ContactActionTile(
                icon: Icons.phone_outlined,
                title: '${AppStrings.callUs} (${info.phone1})',
                color: context.primary,
                onTap: () => _makePhoneCall(info.phone1),
              ),
              if (info.phone2 != null && info.phone2!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spaceSm),
                _ContactActionTile(
                  icon: Icons.phone_outlined,
                  title: '${AppStrings.callUs} (${info.phone2})',
                  color: context.primary,
                  onTap: () => _makePhoneCall(info.phone2!),
                ),
              ],

              const SizedBox(height: AppConstants.spaceSm),

              // أزرار واتساب
              _ContactActionTile(
                icon: Icons.chat_bubble_outline_rounded,
                title: '${AppStrings.chatOnWhatsApp} (${info.whatsApp1})',
                color: context.accent,
                onTap: () => _openWhatsApp(info.whatsApp1),
              ),
              if (info.whatsApp2 != null && info.whatsApp2!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spaceSm),
                _ContactActionTile(
                  icon: Icons.chat_bubble_outline_rounded,
                  title: '${AppStrings.chatOnWhatsApp} (${info.whatsApp2})',
                  color: context.accent,
                  onTap: () => _openWhatsApp(info.whatsApp2!),
                ),
              ],

              // الموقع الإلكتروني
              if (info.website != null && info.website!.isNotEmpty) ...[
                const SizedBox(height: AppConstants.spaceSm),
                _ContactActionTile(
                  icon: Icons.language_rounded,
                  title: AppStrings.visitWebsite,
                  subtitle: info.website,
                  color: context.primary,
                  onTap: () => _launchUrl(info.website!),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: AppConstants.spaceXl),

        // رقم الإصدار
        Text(
          'Clinic Pro v1.0.0',
          style: AppTextStyles.caption(context).copyWith(
            color: context.textHint,
          ),
        ),
        const SizedBox(height: AppConstants.spaceLg),
      ],
    );
  }
}

class _ContactActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ContactActionTile({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.radiusButton),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.spaceMd),
        decoration: BoxDecoration(
          color: context.surfaceBright,
          borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          border: Border.all(color: context.border, width: 0.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: AppConstants.spaceMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: context.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: AppTextStyles.caption(context).copyWith(
                        color: context.textSecondary,
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: context.textHint, size: 14),
          ],
        ),
      ),
    );
  }
}
