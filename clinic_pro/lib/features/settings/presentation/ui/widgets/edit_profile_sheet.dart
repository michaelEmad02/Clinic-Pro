import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../../../auth/presentation/manager/auth_cubit.dart';
import '../../../../auth/presentation/manager/auth_state.dart';
import '../../manager/settings_cubit.dart';

class EditProfileSheet extends StatefulWidget {
  const EditProfileSheet({super.key});

  static Future<void> show(BuildContext context) {
    return AppBottomSheet.show(
      context: context,
      child: MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<SettingsCubit>()),
          BlocProvider.value(value: context.read<AuthCubit>()),
        ],
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
  late final TextEditingController _addressController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthCubit>().state.user;
    _nameController = TextEditingController(text: user?.name ?? '');
    _phoneController = TextEditingController(text: user?.phone ?? '');
    _addressController = TextEditingController(text: user?.address ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthCubit>().state.user;
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
                vertical: AppConstants.spaceSm),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  AppStrings.editProfile,
                  style: AppTextStyles.headlineSmall(context),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          _buildAvatarPicker(context),
          const SizedBox(height: AppConstants.spaceLg),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenEdgeH),
            child: _buildTextField(
              context,
              label: AppStrings.fullName,
              controller: _nameController,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenEdgeH),
            child: _buildTextField(
              context,
              label: AppStrings.phoneNumber,
              controller: _phoneController,
            ),
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenEdgeH),
            child: _buildTextField(
              context,
              label: AppStrings.address,
              controller: _addressController,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXl),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.screenEdgeH),
            child: ElevatedButton(
              onPressed: () {
                if (user != null) {
                  final name = _nameController.text.trim();
                  final phone = _phoneController.text.trim();
                  final address = _addressController.text.trim();
                  context.read<SettingsCubit>().updateProfile(
                        userId: user.id,
                        name: name,
                        phone: phone,
                        address: address,
                        imagePath: _imagePath,
                      );
                  // تحديث كائن المستخدم في AuthCubit لتحديث الواجهات فوراً
                  context.read<AuthCubit>().updateUserData(
                        name: name,
                        phone: phone,
                        address: address,
                        imageUrl: _imagePath,
                      );
                }
                Navigator.pop(context);
              },
              child: Text(AppStrings.save),
            ),
          ),
          const SizedBox(height: AppConstants.spaceXl),
        ],
      ),
    );
  }

  String? _imagePath;

  Widget _buildAvatarPicker(BuildContext context) {
    return Center(
      child: GestureDetector(
        onTap: () => _showImageSourcePicker(context),
        child: Stack(
          children: [
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                final name = state.user?.name ?? '';
                final avatarUrl = state.user?.imageUrl;

                ImageProvider? backgroundImage;
                if (_imagePath != null) {
                  backgroundImage = FileImage(File(_imagePath!));
                } else if (avatarUrl != null && avatarUrl.isNotEmpty) {
                  backgroundImage = NetworkImage(avatarUrl);
                }

                return CircleAvatar(
                  radius: 40,
                  backgroundColor: context.primaryLightColor,
                  backgroundImage: backgroundImage,
                  child: backgroundImage == null
                      ? CircleAvatar(
                          radius: 38,
                          backgroundColor: context.surface,
                          child: Text(
                            name.isNotEmpty ? name[0] : '?',
                            style: AppTextStyles.headlineMedium(context)
                                .copyWith(color: context.primary),
                          ),
                        )
                      : null,
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
      ),
    );
  }

  void _showImageSourcePicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: Icon(Icons.photo_library, color: context.primary),
                title: Text(AppStrings.gallery),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_camera, color: context.primary),
                title: Text(AppStrings.cameraLabel),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: source,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );
      if (pickedFile != null) {
        setState(() {
          _imagePath = pickedFile.path;
        });
      }
    } catch (e) {
      // Handling errors if any
    }
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
            hintText: AppStrings.enterLabel(label),
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
}
