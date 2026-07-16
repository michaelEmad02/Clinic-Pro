import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/settings_cubit.dart';
import '../../manager/settings_state.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      child: BlocProvider.value(
        value: context.read<SettingsCubit>(),
        child: const EditProfileSheet(),
      ),
    );
  }

  @override
  State<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends State<EditProfileSheet> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    final state = context.read<SettingsCubit>().state;
    _nameController = TextEditingController(text: state.userName);
    _phoneController = TextEditingController(text: state.userPhone);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppConstants.spaceMd),
          // const _SheetHandle(),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenEdgeH,
                vertical: AppConstants.spaceMd),
            child: Row(
              children: [
                Text(AppStrings.editProfile,
                    style: AppTextStyles.headlineSmall(context)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon:  Icon(Icons.close,
                      color: context.dangerText),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenEdgeH),
            child: Column(
              children: [
                _buildAvatarUpload(context),
                const SizedBox(height: AppConstants.spaceLg),
                _buildTextField(context,
                    label: AppStrings.fullName, controller: _nameController),
                const SizedBox(height: AppConstants.spaceMd),
                _buildPhoneField(context,
                    label: AppStrings.mobileNumber,
                    controller: _phoneController),
                const SizedBox(height: AppConstants.spaceLg),
                _buildSaveButton(context),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  Widget _buildAvatarUpload(BuildContext context) {
    return Center(
      child: Stack(
        children: [
          BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, state) {
              return CircleAvatar(
                radius: 40,
                backgroundColor: context.primaryLightColor,
                child: CircleAvatar(
                  radius: 38,
                  backgroundColor: context.surface,
                  child: Text(
                    state.userName.isNotEmpty ? state.userName[0] : '?',
                    style: AppTextStyles.headlineMedium(context)
                        .copyWith(color: context.primary),
                  ),
                ),
              );
            },
          ),
          Positioned(
            left: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: context.primaryLightColor,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.photo_camera, color: context.primary, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(BuildContext context,
      {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(label,
              style: AppTextStyles.labelChip(context)
                  .copyWith(color: context.textSecondary)),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'أدخل $label',
            hintStyle: AppTextStyles.bodyMedium(context)
                .copyWith(color: context.textHint),
            filled: true,
            fillColor: context.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd, vertical: 14),
          ),
          style: AppTextStyles.bodyMedium(context),
        ),
      ],
    );
  }

  Widget _buildPhoneField(BuildContext context,
      {required String label, required TextEditingController controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(label,
              style: AppTextStyles.labelChip(context)
                  .copyWith(color: context.textSecondary)),
        ),
        const SizedBox(height: AppConstants.spaceSm),
        TextField(
          controller: controller,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          decoration: InputDecoration(
            hintText: '+966 5X XXX XXXX',
            hintStyle: AppTextStyles.bodyMedium(context)
                .copyWith(color: context.textHint),
            filled: true,
            fillColor: context.backgroundColor,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              borderSide: BorderSide(color: context.border),
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd, vertical: 14),
            suffixIcon:
                Icon(Icons.phone_iphone, color: context.textHint, size: 20),
          ),
          style: AppTextStyles.dataNumeric(context),
        ),
      ],
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () async {
          context.read<SettingsCubit>().updateProfile(
                name: _nameController.text.trim(),
                phone: _phoneController.text.trim(),
              );
          if (!context.mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content:
                    Text(AppStrings.changesSaved, textAlign: TextAlign.right),
                behavior: SnackBarBehavior.floating),
          );
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: context.primaryContainer,
          foregroundColor: context.onPrimary,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.radiusButton),
          ),
          elevation: 0,
          shadowColor: context.primaryContainer.withAlpha(64),
        ),
        child: Text(AppStrings.saveChanges,
            style: AppTextStyles.headlineSmall(context)),
      ),
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.surfaceVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
