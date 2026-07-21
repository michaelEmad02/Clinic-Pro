// ────────────────────────────────────────────────────────
// EditVisitTypesSheet — واجهة تعديل أسعار زيارات الطبيب بالعيادة
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/settings_cubit.dart';
import '../../manager/visit_types_cubit.dart';
import '../../manager/visit_types_state.dart';
import 'visit_type_list_section.dart';
import 'visit_type_form_section.dart';

class EditVisitTypesSheet extends StatelessWidget {
  final String doctorId;
  final String clinicId;

  const EditVisitTypesSheet({
    super.key,
    required this.doctorId,
    required this.clinicId,
  });

  static Future<void> show(BuildContext context) {
    final settingsState = context.read<SettingsCubit>().state;
    final docId = context.read<AuthCubit>().state.user?.id ?? "";
    final clId = settingsState.clinicEntity?.id ?? "";

    return AppBottomSheet.show(
      context: context,
      child: BlocProvider(
        create: (_) => sl<VisitTypesCubit>()..loadData(doctorId: docId, clinicId: clId),
        child: EditVisitTypesSheet(doctorId: docId, clinicId: clId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<VisitTypesCubit, VisitTypesState>(
      listenWhen: (prev, curr) => prev.isSaving && !curr.isSaving && curr.error == null,
      listener: (context, state) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppStrings.visitTypesSaved, textAlign: TextAlign.right),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      },
      builder: (context, state) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildHeader(context),
              const SizedBox(height: AppConstants.spaceSm),
              if (state.isLoading)
                const Padding(
                  padding: EdgeInsets.all(32),
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Center(
                      child: Text(
                        state.error!,
                        style: AppTextStyles.bodyMedium(context).copyWith(color: context.danger),
                      ),
                    ),
                  ),
                VisitTypeListSection(
                  entries: state.addedEntries,
                  onRemove: (index) => context.read<VisitTypesCubit>().removeEntry(index),
                ),
                VisitTypeFormSection(
                  availableTypes: state.availableTypes,
                  hasEntries: state.addedEntries.isNotEmpty,
                  onAdd: (typeId, typeName, price) => context.read<VisitTypesCubit>().addEntry(
                        doctorId: doctorId,
                        clinicId: clinicId,
                        typeId: typeId,
                        typeName: typeName,
                        price: price,
                      ),
                ),
                const SizedBox(height: AppConstants.spaceLg),
                _buildSaveButton(context, state),
              ],
              SizedBox(height: MediaQuery.of(context).padding.bottom + AppConstants.spaceMd),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: Row(
        children: [
          Text(AppStrings.visitTypes, style: AppTextStyles.headlineSmall(context)),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.close, color: context.dangerText),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context, VisitTypesState state) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: state.addedEntries.isNotEmpty && !state.isSaving
              ? () => context.read<VisitTypesCubit>().save(doctorId: doctorId, clinicId: clinicId)
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: context.primaryContainer,
            foregroundColor: context.onPrimary,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusButton),
            ),
            elevation: 0,
          ),
          child: state.isSaving
              ? SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: context.onPrimary),
                )
              : Text(AppStrings.save, style: AppTextStyles.headlineSmall(context)),
        ),
      ),
    );
  }
}
