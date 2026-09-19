// ────────────────────────────────────────────────────────
// AiSettingsSheet — واجهة تخصيص إعدادات الذكاء الاصطناعي والصوت
// تصميم عصري فخم يدعم الشعارات الرسمية لمزودي AI والنظام الهجين
// متوافق تماماً مع Dark/Light Mode والتصميم المتجاوب (Responsive)
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/services/ai/ai_provider_config.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/ai_settings_cubit.dart';
import 'package:clinic_pro/features/settings/presentation/manager/ai_settings_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'ai_settings/ai_model_picker_section.dart';
import 'ai_settings/ai_provider_picker.dart';
import 'ai_settings/ai_test_and_save_section.dart';

class AiSettingsSheet extends StatefulWidget {
  const AiSettingsSheet({super.key});

  /// إظهار إعدادات الذكاء الاصطناعي بشكل متجاوب:
  /// BottomSheet لشاشات الموبايل (< 600px)، و Centered Dialog للشاشات الأكبر (>= 600px)
  static Future<void> show(BuildContext context) {
    final authUser = context.read<AuthCubit>().state.user;
    final ownerId = (authUser?.ownerId != null && authUser!.ownerId!.isNotEmpty)
        ? authUser.ownerId!
        : (authUser?.id ?? '');

    if (ResponsiveHelper.isMobile(context)) {
      return showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => BlocProvider<AiSettingsCubit>(
          create: (_) => sl<AiSettingsCubit>()..loadSettings(ownerId),
          child: const AiSettingsSheet(),
        ),
      );
    } else {
      return showDialog(
        context: context,
        builder: (_) => Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          ),
          backgroundColor: Colors.transparent,
          insetPadding: const EdgeInsets.symmetric(
            horizontal: AppConstants.screenEdgeH,
            vertical: AppConstants.screenEdgeV,
          ),
          child: ConstrainedBox(
            constraints: const BoxConstraints(
              maxWidth: AppConstants.maxDialogWidth,
            ),
            child: BlocProvider<AiSettingsCubit>(
              create: (_) => sl<AiSettingsCubit>()..loadSettings(ownerId),
              child: const AiSettingsSheet(),
            ),
          ),
        ),
      );
    }
  }

  @override
  State<AiSettingsSheet> createState() => _AiSettingsSheetState();
}

class _AiSettingsSheetState extends State<AiSettingsSheet> {
  final TextEditingController _apiKeyController = TextEditingController();
  final TextEditingController _customUrlController = TextEditingController();
  final TextEditingController _modelTextController = TextEditingController();
  bool _obscureApiKey = true;
  bool _initializedFromState = false;
  bool _manualModelEntry = false;

  @override
  void dispose() {
    _apiKeyController.dispose();
    _customUrlController.dispose();
    _modelTextController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authUser = context.read<AuthCubit>().state.user;
    final ownerId = (authUser?.ownerId != null && authUser!.ownerId!.isNotEmpty)
        ? authUser.ownerId!
        : (authUser?.id ?? '');

    final isMobile = ResponsiveHelper.isMobile(context);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * (isMobile ? 0.9 : 0.85),
        maxWidth: isMobile ? double.infinity : AppConstants.maxDialogWidth,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: isMobile
            ? const BorderRadius.vertical(top: Radius.circular(AppConstants.radiusSheet))
            : BorderRadius.circular(AppConstants.radiusCard),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: isMobile ? 18 : 26,
        right: isMobile ? 18 : 26,
        bottom: MediaQuery.of(context).viewInsets.bottom + (isMobile ? 16 : 24),
      ),
      child: BlocConsumer<AiSettingsCubit, AiSettingsState>(
        listener: (context, state) {
          if (state.status == AiSettingsStatus.loaded && !_initializedFromState) {
            _initializedFromState = true;
            if (state.customBaseUrl != null) {
              _customUrlController.text = state.customBaseUrl!;
            }
            if (state.selectedModel.isNotEmpty) {
              _modelTextController.text = state.selectedModel;
            }
          }

          if (state.status == AiSettingsStatus.saved) {
            AppSnackbar.success(context, message: AppStrings.settingsSavedSuccess);
            Navigator.pop(context);
          } else if (state.status == AiSettingsStatus.error &&
              state.errorMessage != null) {
            AppSnackbar.error(context, message: state.errorMessage!);
          }

          if (state.testStatus == AiTestStatus.success) {
            AppSnackbar.success(context, message: AppStrings.connectionSuccess);
          } else if (state.testStatus == AiTestStatus.error &&
              state.testErrorMessage != null) {
            AppSnackbar.error(context, message: state.testErrorMessage!);
          }
        },
        builder: (context, state) {
          if (state.status == AiSettingsStatus.loading) {
            return const SizedBox(
              height: 300,
              child: Center(child: AppLoadingWidget(size: AppLoadingSize.medium)),
            );
          }

          final cubit = context.read<AiSettingsCubit>();

          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── 1. الترويسة الرئيسية ───
                _buildHeader(context),
                const SizedBox(height: AppConstants.spaceMd),

                // ─── 2. اختيار الوضع (RegEx vs AI) ───
                _buildModeSelector(context, state, cubit),
                const SizedBox(height: 12),

                // ─── 3. تنبيه وضع الـ RegEx إذا كان مفعلاً ───
                if (!state.isAiMode) _buildRegexWarning(context),

                // ─── 4. إعدادات الـ AI (تظهر فقط إذا كان وضع الذكاء الاصطناعي مفعلاً) ───
                if (state.isAiMode) ...[
                  const SizedBox(height: AppConstants.spaceMd),

                  // أ) عنوان وشبكة اختيار المزود
                  Text(
                    AppStrings.selectProvider,
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  AiProviderPicker(
                    selectedProvider: state.selectedProvider,
                    onSelectProvider: (provider) {
                      cubit.selectProvider(provider);
                      final defaults = AiProviderConfig.defaultModels(provider);
                      final defaultModel =
                          defaults.isNotEmpty ? defaults.first.id : '';
                      _modelTextController.text = defaultModel;
                    },
                  ),

                  const SizedBox(height: AppConstants.spaceMd),

                  // ب) رابط Base URL المخصص (إذا تم اختيار Custom)
                  if (state.selectedProvider == AiProviderType.custom) ...[
                    _buildCustomUrlField(context, cubit),
                    const SizedBox(height: AppConstants.spaceMd),
                  ],

                  // ج) حقل مفتاح الـ API مع شارة الأمان
                  _buildApiKeyField(context, state),

                  const SizedBox(height: AppConstants.spaceMd),

                  // د) قسم اختيار الموديل
                  AiModelPickerSection(
                    state: state,
                    modelTextController: _modelTextController,
                    manualModelEntry: _manualModelEntry,
                    onToggleManualEntry: () {
                      setState(() {
                        _manualModelEntry = !_manualModelEntry;
                        if (_manualModelEntry &&
                            _modelTextController.text.isEmpty) {
                          _modelTextController.text = state.selectedModel;
                        }
                      });
                    },
                    onRefreshModels: () {
                      final key = _apiKeyController.text.trim();
                      cubit.fetchAvailableModels(
                        apiKey: key.isNotEmpty ? key : null,
                        ownerId: ownerId,
                      );
                    },
                    onSelectModel: (model) => cubit.selectModel(model),
                  ),

                  const SizedBox(height: AppConstants.spaceLg),

                  // هـ) أزرار الاختبار والحفظ
                  AiTestAndSaveSection(
                    state: state,
                    onTestConnection: () {
                      final key = _apiKeyController.text.trim();
                      cubit.testConnection(
                        apiKey: key.isNotEmpty ? key : null,
                        ownerId: ownerId,
                      );
                    },
                    onSave: () async {
                      final apiKey = _apiKeyController.text.trim();
                      await cubit.saveSettings(
                        ownerId: ownerId,
                        apiKey: apiKey.isNotEmpty ? apiKey : null,
                      );
                    },
                  ),
                ] else ...[
                  const SizedBox(height: AppConstants.spaceLg),
                  // زر الحفظ لوضع RegEx
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: state.status == AiSettingsStatus.saving
                          ? null
                          : () async {
                              await cubit.saveSettings(ownerId: ownerId);
                            },
                      child: state.status == AiSettingsStatus.saving
                          ? const AppLoadingWidget(
                              size: AppLoadingSize.small,
                              color: Colors.white,
                            )
                          : Text(
                              AppStrings.save,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: 10),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: context.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(Icons.auto_awesome, color: context.primary, size: 24),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.aiVoiceAnalysis,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                AppStrings.aiVoiceAnalysisDesc,
                style: AppTextStyles.caption(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ],
    );
  }

  Widget _buildModeSelector(
    BuildContext context,
    AiSettingsState state,
    AiSettingsCubit cubit,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.extractionMode,
          style: AppTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _buildModeCard(
                context: context,
                title: AppStrings.regexMode,
                icon: Icons.code_rounded,
                isSelected: !state.isAiMode,
                onTap: () => cubit.setExtractionMode('regex'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildModeCard(
                context: context,
                title: AppStrings.aiMode,
                icon: Icons.psychology_rounded,
                isSelected: state.isAiMode,
                onTap: () => cubit.setExtractionMode('ai'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildModeCard({
    required BuildContext context,
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? context.primary.withOpacity(0.1)
              : context.surfaceColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? context.primary : context.borderColor.withOpacity(0.5),
            width: isSelected ? 1.8 : 1.0,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? context.primary : context.textSecondary,
              size: 20,
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? context.primary : context.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegexWarning(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.amber.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.amber.withOpacity(0.4)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_outline_rounded, color: Colors.amber, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AppStrings.regexWarning,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textPrimary,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomUrlField(BuildContext context, AiSettingsCubit cubit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.customBaseUrl,
          style: AppTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _customUrlController,
          decoration: InputDecoration(
            hintText: 'https://api.example.com/v1',
            prefixIcon: const Icon(Icons.link_rounded, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
          onChanged: (val) => cubit.setCustomBaseUrl(val.trim()),
        ),
      ],
    );
  }

  Widget _buildApiKeyField(BuildContext context, AiSettingsState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.apiKey,
          style: AppTextStyles.bodyMedium(context).copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        if (state.settings.hasApiKey) ...[
          const SizedBox(height: 6),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.08),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.green.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lock_outline_rounded, color: Colors.green, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${AppStrings.apiKeySaved} • مشفّر بتقنية AES-256-GCM في السيرفر',
                    style: AppTextStyles.caption(context).copyWith(
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            AppStrings.apiKeyChangeHint,
            style: AppTextStyles.caption(context).copyWith(
              color: context.textSecondary,
              fontSize: 11,
            ),
          ),
        ],
        const SizedBox(height: 6),
        TextField(
          controller: _apiKeyController,
          obscureText: _obscureApiKey,
          decoration: InputDecoration(
            hintText: state.settings.hasApiKey
                ? '••••••••••••••••••••••••'
                : AppStrings.apiKeyHint,
            prefixIcon: const Icon(Icons.vpn_key_outlined, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureApiKey
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscureApiKey = !_obscureApiKey;
                });
              },
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          ),
        ),
      ],
    );
  }
}
