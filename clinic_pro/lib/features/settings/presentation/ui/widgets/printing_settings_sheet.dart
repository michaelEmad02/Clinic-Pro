// ────────────────────────────────────────────────────────
// PrintingSettingsSheet — الشيت التفاعلي لتخصيص إعدادات الطباعة للمالك
// متوافق تماماً مع ثيمات التطبيق المختلفة (Dark / Light Mode)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/printing_settings_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/printing_settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PrintingSettingsSheet extends StatelessWidget {
  const PrintingSettingsSheet({super.key});

  static Future<void> show(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BlocProvider<PrintingSettingsCubit>(
        create: (_) =>
            sl<PrintingSettingsCubit>()..loadPrintingSettings(ownerId),
        child: const PrintingSettingsSheet(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ownerId = context.read<AuthCubit>().state.user?.id ?? '';

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 16,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: BlocConsumer<PrintingSettingsCubit, PrintingSettingsState>(
        listener: (context, state) {
          if (state.status == PrintingSettingsStatus.saved) {
            AppSnackbar.success(
              context,
              message: AppStrings.printingSettingsSavedSuccess,
            );
            Navigator.pop(context);
          } else if (state.status == PrintingSettingsStatus.error &&
              state.errorMessage != null) {
            AppSnackbar.error(
              context,
              message: state.errorMessage!,
            );
          }
        },
        builder: (context, state) {
          if (state.status == PrintingSettingsStatus.loading) {
            return const SizedBox(
              height: 250,
              child: Center(child: AppLoadingWidget()),
            );
          }

          final settings = state.settings;
          final cubit = context.read<PrintingSettingsCubit>();

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── رأس الشيت ───
                Row(
                  children: [
                    Icon(Icons.print, color: context.primary),
                    const SizedBox(width: 8),
                    Text(
                      AppStrings.printingSettingsTitle,
                      style: AppTextStyles.bodyLarge(context).copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(),
                const SizedBox(height: 8),

                // ─── قسم خيارات الإخفاء والعرض ───
                Text(
                  AppStrings.headerFooterOptions,
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),

                SwitchListTile(
                  title: Text(AppStrings.hideHeaderTitle),
                  subtitle: Text(AppStrings.hideHeaderSub),
                  value: settings.hideHeader,
                  activeColor: context.primary,
                  onChanged: (val) =>
                      cubit.updateDraft(settings.copyWith(hideHeader: val)),
                ),
                SwitchListTile(
                  title: Text(AppStrings.hideLogoTitle),
                  value: settings.hideLogo,
                  activeColor: context.primary,
                  onChanged: (val) =>
                      cubit.updateDraft(settings.copyWith(hideLogo: val)),
                ),
                SwitchListTile(
                  title: Text(AppStrings.hideDoctorInfoTitle),
                  value: settings.hideDoctorInfo,
                  activeColor: context.primary,
                  onChanged: (val) =>
                      cubit.updateDraft(settings.copyWith(hideDoctorInfo: val)),
                ),
                SwitchListTile(
                  title: Text(AppStrings.hideSignatureTitle),
                  value: settings.hideSignature,
                  activeColor: context.primary,
                  onChanged: (val) =>
                      cubit.updateDraft(settings.copyWith(hideSignature: val)),
                ),
                SwitchListTile(
                  title: Text(AppStrings.hidePatientInfoTitle),
                  value: settings.hidePatientInfo,
                  activeColor: context.primary,
                  onChanged: (val) => cubit
                      .updateDraft(settings.copyWith(hidePatientInfo: val)),
                ),
                SwitchListTile(
                  title: Text(AppStrings.hideFooterTitle),
                  value: settings.hideFooter,
                  activeColor: context.primary,
                  onChanged: (val) =>
                      cubit.updateDraft(settings.copyWith(hideFooter: val)),
                ),
                const SizedBox(height: 12),

                // ─── أسطر التذييل المخصصة ───
                Text(
                  AppStrings.footerLinesSection,
                  style: AppTextStyles.caption(context).copyWith(
                    fontWeight: FontWeight.bold,
                    color: context.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                TextFormField(
                  initialValue: settings.footerLine1,
                  decoration: InputDecoration(
                    labelText: AppStrings.footerLine1Label,
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                      borderSide: BorderSide(color: context.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                      borderSide:
                          BorderSide(color: context.primary, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                    ),
                    isDense: true,
                  ),
                  onChanged: (val) =>
                      cubit.updateDraft(settings.copyWith(footerLine1: val)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: settings.footerLine2,
                  decoration: InputDecoration(
                    labelText: AppStrings.footerLine2Label,
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                      borderSide: BorderSide(color: context.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                      borderSide:
                          BorderSide(color: context.primary, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                    ),
                    isDense: true,
                  ),
                  onChanged: (val) =>
                      cubit.updateDraft(settings.copyWith(footerLine2: val)),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  initialValue: settings.footerLine3,
                  decoration: InputDecoration(
                    labelText: AppStrings.footerLine3Label,
                    enabledBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                      borderSide: BorderSide(color: context.border),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                      borderSide:
                          BorderSide(color: context.primary, width: 1.5),
                    ),
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppConstants.radiusInput),
                    ),
                    isDense: true,
                  ),
                  onChanged: (val) =>
                      cubit.updateDraft(settings.copyWith(footerLine3: val)),
                ),
                const SizedBox(height: 16),

                // ─── مقاس الورق الافتراضي ───
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppStrings.defaultPageFormatLabel,
                      style: AppTextStyles.bodyMedium(context),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ChoiceChip(
                            label: const Text('A4'),
                            selected: settings.defaultPageFormat == 'A4',
                            onSelected: (selected) {
                              if (selected) {
                                cubit.updateDraft(
                                    settings.copyWith(defaultPageFormat: 'A4'));
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('A5'),
                            selected: settings.defaultPageFormat == 'A5',
                            onSelected: (selected) {
                              if (selected) {
                                cubit.updateDraft(
                                    settings.copyWith(defaultPageFormat: 'A5'));
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('A6'),
                            selected: settings.defaultPageFormat == 'A6',
                            onSelected: (selected) {
                              if (selected) {
                                cubit.updateDraft(
                                    settings.copyWith(defaultPageFormat: 'A6'));
                              }
                            },
                          ),
                          ChoiceChip(
                            label: const Text('تخصيص'),
                            selected: settings.defaultPageFormat == 'custom',
                            onSelected: (selected) {
                              if (selected) {
                                cubit.updateDraft(
                                    settings.copyWith(defaultPageFormat: 'custom'));
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                if (settings.defaultPageFormat == 'custom') ...[
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          initialValue: settings.customWidth.toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'عرض الورقة (سم)',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                              borderSide: BorderSide(color: context.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                              borderSide: BorderSide(color: context.primary, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                            ),
                            isDense: true,
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null) {
                              cubit.updateDraft(settings.copyWith(customWidth: parsed));
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          initialValue: settings.customHeight.toString(),
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            labelText: 'ارتفاع الورقة (سم)',
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                              borderSide: BorderSide(color: context.border),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                              borderSide: BorderSide(color: context.primary, width: 1.5),
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                            ),
                            isDense: true,
                          ),
                          onChanged: (val) {
                            final parsed = double.tryParse(val);
                            if (parsed != null) {
                              cubit.updateDraft(settings.copyWith(customHeight: parsed));
                            }
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],

                // ─── زر الحفظ ───
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: state.status == PrintingSettingsStatus.saving
                        ? null
                        : () => cubit.savePrintingSettings(ownerId),
                    icon: state.status == PrintingSettingsStatus.saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.save),
                    label: Text(
                      state.status == PrintingSettingsStatus.saving
                          ? AppStrings.savingSettings
                          : AppStrings.saveSettings,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
