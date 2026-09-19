// ────────────────────────────────────────────────────────
// AppVoiceInputDialog — نافذة حوار الإدخال الصوتي الموحدة لكافة الشاشات
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/di/injection_container.dart';
import 'package:clinic_pro/core/services/ai/ai_provider_config.dart';
import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/widgets/app_loading.dart';
import 'package:clinic_pro/core/widgets/app_snackbar.dart';
import 'package:clinic_pro/core/widgets/voice_input/app_voice_input_cubit.dart';
import 'package:clinic_pro/core/widgets/voice_input/app_voice_input_state.dart';
import 'package:clinic_pro/features/auth/domain/repositories/i_auth_repository.dart';
import 'package:clinic_pro/features/settings/domain/repositories/i_owner_settings_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppVoiceInputDialog extends StatefulWidget {
  final ExtractionTarget target;
  final Map<String, dynamic>? extraContext;

  const AppVoiceInputDialog({
    super.key,
    required this.target,
    this.extraContext,
  });

  /// إظهار حوار الإدخال الصوتي الموحد وإرجاع خريطة البيانات المستخرجة
  static Future<Map<String, dynamic>?> show(
    BuildContext context, {
    required ExtractionTarget target,
    Map<String, dynamic>? extraContext,
  }) {
    return showDialog<Map<String, dynamic>>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => BlocProvider(
        create: (_) => sl<AppVoiceInputCubit>()
          ..startListening(target: target, extraContext: extraContext),
        child: AppVoiceInputDialog(
          target: target,
          extraContext: extraContext,
        ),
      ),
    );
  }

  @override
  State<AppVoiceInputDialog> createState() => _AppVoiceInputDialogState();
}

class _AppVoiceInputDialogState extends State<AppVoiceInputDialog>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseScale;

  bool _isAiMode = false;
  String? _providerDisplayName;
  String? _modelDisplayName;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseScale = Tween<double>(begin: 0.9, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _checkExtractionMode();
  }

  Future<void> _checkExtractionMode() async {
    try {
      final authRepo = sl<IAuthRepository>();
      final userResult = await authRepo.getCurrentUser();
      final user = userResult.fold((_) => null, (u) => u);
      if (user != null) {
        final ownerId = (user.ownerId != null && user.ownerId!.isNotEmpty)
            ? user.ownerId!
            : user.id;
        final settingsRepo = sl<IOwnerSettingsRepository>();
        final settingsResult = await settingsRepo.getAiSettings(ownerId, false);
        final settings = settingsResult.fold((_) => null, (s) => s);
        if (mounted && settings != null && settings.isConfigured) {
          final type = AiProviderConfig.parseType(settings.provider);
          setState(() {
            _isAiMode = true;
            _providerDisplayName = AiProviderConfig.displayName(type);
            _modelDisplayName = settings.model;
          });
        }
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  String _getHintText() {
    if (!AppStrings.isArabic) {
      switch (widget.target) {
        case ExtractionTarget.expense:
          return 'Speak now (e.g. Medical supplies 250 SAR)';
        case ExtractionTarget.patient:
          return 'Speak now (e.g. Patient John Doe, age 30, phone 010...)';
        case ExtractionTarget.invoice:
          return 'Speak now (e.g. Examination fee 300 SAR, discount 50)';
        case ExtractionTarget.appointment:
          return 'Speak now (e.g. Follow-up tomorrow at 5 PM)';
        case ExtractionTarget.prescription:
          return 'Speak now (e.g. Diagnosis Bronchitis, Augmentin twice daily, follow up in 1 week)';
      }
    }

    switch (widget.target) {
      case ExtractionTarget.expense:
        return 'تحدث الآن (مثال: اشتريت مستلزمات طبية 250 جنيه)';
      case ExtractionTarget.patient:
        return 'تحدث الآن (مثال: مريض اسمه أحمد محمد، عمره 30 سنة، تليفونه 010...)';
      case ExtractionTarget.invoice:
        return 'تحدث الآن (مثال: كشف بمبلغ 300 جنيه وخصم 50)';
      case ExtractionTarget.appointment:
        return 'تحدث الآن (مثال: كشف غداً الساعة 5)';
      case ExtractionTarget.prescription:
        return 'تحدث الآن (مثال: التشخيص نزلة برد، أوجمنتين مرتين يوميا، الاستشارة بعد أسبوع)';
    }
  }

  Widget _buildModeBadge(BuildContext context) {
    if (_isAiMode) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.purple.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple.withOpacity(0.25)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.auto_awesome, size: 14, color: Colors.purple),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                _providerDisplayName != null
                    ? '${AppStrings.voiceExtractionWithAi} ($_providerDisplayName${_modelDisplayName != null && _modelDisplayName!.isNotEmpty ? " • $_modelDisplayName" : ""})'
                    : AppStrings.voiceExtractionWithAi,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: context.borderColor.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: context.borderColor.withOpacity(0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.code, size: 14, color: context.textSecondary),
          const SizedBox(width: 6),
          Text(
            AppStrings.voiceExtractionWithRegex,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: context.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppVoiceInputCubit, AppVoiceInputState>(
      listener: (context, state) {
        if (state is AppVoiceInputSuccess) {
          Navigator.of(context).pop(state.data);
        } else if (state is AppVoiceInputFailure) {
          AppSnackbar.error(context, message: state.message);
        }
      },
      builder: (context, state) {
        final isProcessing = state is AppVoiceInputProcessing;
        final recognizedWords =
            state is AppVoiceInputListening ? state.recognizedWords : '';
        final hasWords = recognizedWords.isNotEmpty;

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
          title: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.voiceInput,
                textAlign: TextAlign.center,
                style: AppTextStyles.headlineSmall(context).copyWith(
                  fontWeight: FontWeight.bold,
                  color: context.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              _buildModeBadge(context),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 440),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
              const SizedBox(height: 12),
              ScaleTransition(
                scale: isProcessing ? const AlwaysStoppedAnimation(1.0) : _pulseScale,
                child: GestureDetector(
                  onTap: isProcessing
                      ? null
                      : () {
                          context.read<AppVoiceInputCubit>().startListening(
                                target: widget.target,
                                extraContext: widget.extraContext,
                                keepExisting: true,
                              );
                        },
                  child: Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isProcessing
                          ? context.borderColor.withOpacity(0.3)
                          : context.primary.withOpacity(0.12),
                    ),
                    child: Center(
                      child: isProcessing
                          ? const AppLoadingWidget(size: AppLoadingSize.small)
                          : Icon(
                              Icons.mic,
                              size: 40,
                              color: context.primary,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: context.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Text(
                  isProcessing
                      ? (_isAiMode
                          ? AppStrings.processingVoiceAi
                          : AppStrings.processingVoiceRegex)
                      : (hasWords ? recognizedWords : _getHintText()),
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyMedium(context).copyWith(
                    color: hasWords ? context.textPrimary : context.textSecondary,
                    fontWeight: hasWords ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            TextButton(
              onPressed: () {
                context.read<AppVoiceInputCubit>().cancelListening();
                Navigator.of(context).pop();
              },
              child: Text(
                AppStrings.cancel,
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: context.textSecondary,
                ),
              ),
            ),
            ElevatedButton.icon(
              onPressed: isProcessing
                  ? null
                  : () {
                      context.read<AppVoiceInputCubit>().stopAndProcess(
                            target: widget.target,
                            extraContext: widget.extraContext,
                          );
                    },
              icon: const Icon(Icons.check, size: 18),
              label: Text(AppStrings.doneListening),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.primary,
                foregroundColor: context.onPrimary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
