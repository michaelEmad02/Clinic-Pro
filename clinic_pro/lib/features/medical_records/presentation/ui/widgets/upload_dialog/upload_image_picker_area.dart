// ────────────────────────────────────────────────────────
// منطقة اختيار صورة الفحص الطبي (UploadImagePickerArea)
// توفر معاينة سلسة ومتحركة للصورة وأزرار الالتقاط والاختيار
// ────────────────────────────────────────────────────────

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:clinic_pro/core/constants/app_constants.dart';
import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';

class UploadImagePickerArea extends StatelessWidget {
  final File? selectedImage;
  final Function(ImageSource source) onPickImage;
  final VoidCallback onClearImage;

  const UploadImagePickerArea({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
    required this.onClearImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.recordImageLabel,
          style: AppTextStyles.caption(context).copyWith(
            fontWeight: FontWeight.bold,
            color: context.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: ScaleTransition(
                scale: Tween<double>(begin: 0.95, end: 1.0).animate(animation),
                child: child,
              ),
            );
          },
          child: selectedImage != null
              ? _buildImagePreview(context)
              : _buildPickerBox(context),
        ),
      ],
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('image_preview'),
      child: Stack(
        children: [
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppConstants.radiusCard),
              child: Image.file(
                selectedImage!,
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Material(
              color: Colors.black.withOpacity(0.55),
              shape: const CircleBorder(),
              elevation: 4,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onClearImage,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPickerBox(BuildContext context) {
    return KeyedSubtree(
      key: const ValueKey('picker_box'),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        decoration: BoxDecoration(
          color: context.surfaceContainerLow,
          borderRadius: BorderRadius.circular(AppConstants.radiusCard),
          border: Border.all(
            color: context.borderColor,
            width: 1.2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              Icons.cloud_upload_outlined,
              size: 42,
              color: context.primary.withOpacity(0.8),
            ),
            const SizedBox(height: 8),
            Text(
              AppStrings.selectImageRequired,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onPickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded, size: 18),
                    label: Text(AppStrings.pickFromCamera),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.surfaceColor,
                      foregroundColor: context.primary,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      side: BorderSide(color: context.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusButton),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => onPickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded, size: 18),
                    label: Text(AppStrings.pickFromGallery),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.surfaceColor,
                      foregroundColor: context.primary,
                      elevation: 1,
                      padding: const EdgeInsets.symmetric(vertical: 11),
                      side: BorderSide(color: context.borderColor),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppConstants.radiusButton),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
