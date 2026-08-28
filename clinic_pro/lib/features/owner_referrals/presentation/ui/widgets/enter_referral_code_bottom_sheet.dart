import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/features/owner_referrals/domain/entities/apply_referral_result_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_tabler_icons/flutter_tabler_icons.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/manager/referral_cubit.dart';
import 'package:clinic_pro/features/owner_referrals/presentation/manager/referral_state.dart';



class EnterReferralCodeBottomSheet extends StatefulWidget {
  final String ownerId;
  final void Function(ApplyReferralResultEntity result)? onSuccess;

  const EnterReferralCodeBottomSheet({
    super.key,
    required this.ownerId,
    this.onSuccess,
  });

  static Future<void> show({
    required BuildContext context,
    required String ownerId,
    void Function(ApplyReferralResultEntity result)? onSuccess,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider(
        create: (_) => sl<ReferralCubit>(),
        child: EnterReferralCodeBottomSheet(
          ownerId: ownerId,
          onSuccess: onSuccess,
        ),
      ),
    );
  }

  @override
  State<EnterReferralCodeBottomSheet> createState() =>
      _EnterReferralCodeBottomSheetState();
}

class _EnterReferralCodeBottomSheetState
    extends State<EnterReferralCodeBottomSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkClipboardForReferral();
  }

  /// فحص الحافظة تلقائياً إذا كان الطبيب نسخ كود دعوة زميله
  Future<void> _checkClipboardForReferral() async {
    try {
      final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
      final text = clipboardData?.text?.trim() ?? '';
      final regExp = RegExp(r'^DOC-[A-Z0-9]{4,10}$', caseSensitive: false);
      if (regExp.hasMatch(text) && mounted) {
        setState(() {
          _controller.text = text.toUpperCase();
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submitCode() async {
    final code = _controller.text.trim().toUpperCase();
    if (code.isEmpty) {
      AppSnackbar.error(
        context,
        message: AppStrings.enterReferralCodePrompt,
      );
      return;
    }

    setState(() => _isLoading = true);
    final result = await context.read<ReferralCubit>().applyReferralCode(
          referralCode: code,
          newOwnerId: widget.ownerId,
        );
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result != null && result.success) {
      Navigator.pop(context);
      AppSnackbar.success(
        context,
        message: AppStrings.applyReferralCodeSuccess,
      );
      widget.onSuccess?.call(result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<ReferralCubit, ReferralState>(
      listener: (context, state) {
        if (state is ReferralError) {
          AppSnackbar.error(
            context,
            message: state.message,
          );
        }
      },
      child: ResponsiveHelper.responsiveCenter(
        maxWidth: AppConstants.maxDialogWidth,
        child: Container(
          padding: EdgeInsets.only(
            left: AppConstants.spaceLg,
            right: AppConstants.spaceLg,
            top: AppConstants.spaceMd,
            bottom: MediaQuery.of(context).viewInsets.bottom + AppConstants.spaceLg,
          ),
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.radiusSheet),
            ),
          ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: context.borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: context.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(TablerIcons.gift, color: context.primary, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppStrings.haveReferralCode,
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          fontWeight: FontWeight.bold,
                          color: context.textPrimary,
                        ),
                      ),
                      Text(
                        AppStrings.enterReferralCodePrompt,
                        style: AppTextStyles.caption(context).copyWith(
                          color: context.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _controller,
              textCapitalization: TextCapitalization.characters,
              style: AppTextStyles.headlineSmall(context).copyWith(
                letterSpacing: 2,
                fontWeight: FontWeight.bold,
              ),
              decoration: InputDecoration(
                hintText: 'DOC-XXXXX',
                hintStyle: AppTextStyles.bodyLarge(context).copyWith(
                  color: context.textHint,
                  letterSpacing: 1,
                ),
                prefixIcon: const Icon(TablerIcons.ticket),
                filled: true,
                fillColor: context.surface,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: context.borderColor),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spaceSm + 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusButton),
                      ),
                    ),
                    child: Text(AppStrings.skip),
                  ),
                ),
                const SizedBox(width: AppConstants.spaceSm + 4),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _submitCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: context.onPrimary,
                      padding: const EdgeInsets.symmetric(
                        vertical: AppConstants.spaceSm + 4,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusButton),
                      ),
                    ),
                    child: _isLoading
                        ? AppLoadingWidget(
                            size: AppLoadingSize.small,
                            color: context.onPrimary,
                          )
                        : Text(AppStrings.applyCoupon),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    ),
  );
  }
}
