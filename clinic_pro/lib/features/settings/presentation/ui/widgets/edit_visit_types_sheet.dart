import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/di/injection_container.dart';
import '../../../../../core/services/i_cloud_service.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_bottom_sheet.dart';
import '../../manager/settings_cubit.dart';

class _VisitTypeEntry {
  String appointmentTypeId;
  String typeName;
  double price;

  _VisitTypeEntry({
    required this.appointmentTypeId,
    required this.typeName,
    required this.price,
  });
}

class EditVisitTypesSheet extends StatefulWidget {
  final String doctorId;
  final String clinicId;

  const EditVisitTypesSheet({
    super.key,
    required this.doctorId,
    required this.clinicId,
  });

  static Future<void> show(BuildContext context) {
    final state = context.read<SettingsCubit>().state;
    return AppBottomSheet.show(
      context: context,
      child: EditVisitTypesSheet(
        doctorId: state.userId,
        clinicId: state.clinicId,
      ),
    );
  }

  @override
  State<EditVisitTypesSheet> createState() => _EditVisitTypesSheetState();
}

class _EditVisitTypesSheetState extends State<EditVisitTypesSheet> {
  final ICloudService _cloudService = sl<ICloudService>();
  List<_VisitTypeEntry> _entries = [];
  List<Map<String, dynamic>> _availableTypes = [];
  bool _isLoading = true;
  bool _isSaving = false;

  String? _selectedTypeId;
  final _priceController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final results = await _cloudService.select(
        table: 'appointment_types',
      );

      final existing = await _cloudService.select(
        table: 'doctor_appointment_types',
        eq: {'doctor_id': widget.doctorId, 'clinic_id': widget.clinicId},
      );

      final usedTypeIds = existing.map((e) => e['appointment_type_id'] as String).toSet();

      final entries = existing.map((e) => _VisitTypeEntry(
        appointmentTypeId: e['appointment_type_id'] as String,
        typeName: '',
        price: (e['price'] as num?)?.toDouble() ?? 0.0,
      )).toList();

      for (final entry in entries) {
        final type = results.firstWhere(
          (t) => t['id'] == entry.appointmentTypeId,
          orElse: () => <String, dynamic>{},
        );
        entry.typeName = type['name'] as String? ?? 'غير معروف';
      }

      if (mounted) {
        setState(() {
          _availableTypes = results.where((t) => !usedTypeIds.contains(t['id'])).toList();
          _entries = entries;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _addEntry() {
    final typeId = _selectedTypeId;
    if (typeId == null || typeId.isEmpty) return;

    final priceText = _priceController.text.trim();
    final price = double.tryParse(priceText) ?? 0.0;

    final type = _availableTypes.firstWhere((t) => t['id'] == typeId);
    final typeName = type['name'] as String? ?? '';

    setState(() {
      _entries.add(_VisitTypeEntry(
        appointmentTypeId: typeId,
        typeName: typeName,
        price: price,
      ));
      _availableTypes.removeWhere((t) => t['id'] == typeId);
      _selectedTypeId = null;
      _priceController.clear();
    });
  }

  void _removeEntry(int index) {
    final removed = _entries.removeAt(index);
    setState(() {
      final type = _availableTypes.isNotEmpty
          ? {'id': removed.appointmentTypeId, 'name': removed.typeName}
          : null;
      if (type != null) {
        _availableTypes.add(type);
      }
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    try {
      // Delete all existing entries for this doctor+clinic
      final existing = await _cloudService.select(
        table: 'doctor_appointment_types',
        eq: {'doctor_id': widget.doctorId, 'clinic_id': widget.clinicId},
      );
      for (final e in existing) {
        await _cloudService.delete(
          table: 'doctor_appointment_types',
          matchColumn: 'id',
          matchValue: e['id'],
        );
      }

      // Insert new entries
      for (final entry in _entries) {
        await _cloudService.insert(
          table: 'doctor_appointment_types',
          data: {
            'appointment_type_id': entry.appointmentTypeId,
            'price': entry.price,
            'doctor_id': widget.doctorId,
            'clinic_id': widget.clinicId,
          },
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ أنواع الزيارات بنجاح ✓'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('فشل الحفظ: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
            child: Row(
              children: [
                Text('أنواع الزيارات', style: AppTextStyles.headlineSmall(context)),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppConstants.spaceSm),
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else ...[
            if (_entries.isNotEmpty) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
                child: Text(
                  'الأنواع المضافة',
                  style: AppTextStyles.labelChip(context).copyWith(color: AppColors.textSecondary),
                ),
              ),
              const SizedBox(height: AppConstants.spaceSm),
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.25),
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
                  itemCount: _entries.length,
                  itemBuilder: (context, index) {
                    final entry = _entries[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: AppConstants.spaceSm),
                      padding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: AppConstants.spaceSm),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(entry.typeName, style: AppTextStyles.bodyLarge(context)),
                                Text(
                                  '${entry.price.toStringAsFixed(0)} ريال',
                                  style: AppTextStyles.dataNumeric(context).copyWith(color: AppColors.primary),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            onPressed: () => _removeEntry(index),
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.danger, size: 20),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppConstants.spaceMd),
              const Divider(height: 1, thickness: 0.5, color: AppColors.border),
              const SizedBox(height: AppConstants.spaceMd),
            ],
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
              child: Text(
                _entries.isEmpty ? 'أضف نوع زيارة' : 'إضافة نوع جديد',
                style: AppTextStyles.labelChip(context).copyWith(color: AppColors.textSecondary),
              ),
            ),
            const SizedBox(height: AppConstants.spaceSm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
              child: Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: DropdownButtonFormField<String>(
                      value: _selectedTypeId,
                      hint: Text('اختر النوع', style: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textHint)),
                      items: _availableTypes.map((t) {
                        return DropdownMenuItem(
                          value: t['id'] as String,
                          child: Text(t['name'] as String, style: AppTextStyles.bodyMedium(context)),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedTypeId = val),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spaceMd),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      textDirection: TextDirection.ltr,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        hintText: 'السعر',
                        hintStyle: AppTextStyles.bodyMedium(context).copyWith(color: AppColors.textHint),
                        filled: true,
                        fillColor: AppColors.surfaceContainerLowest,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                          borderSide: const BorderSide(color: AppColors.border),
                        ),
                        contentPadding: const EdgeInsets.symmetric(horizontal: AppConstants.spaceMd, vertical: 14),
                      ),
                      style: AppTextStyles.dataNumeric(context),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppConstants.spaceMd),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _selectedTypeId != null ? _addEntry : null,
                  icon: const Icon(Icons.add, size: 18),
                  label: Text('إضافة', style: AppTextStyles.bodyLarge(context)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primary,
                    side: BorderSide(color: AppColors.primary.withAlpha(76)),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppConstants.spaceLg),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.screenEdgeH),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _entries.isNotEmpty && !_isSaving ? _save : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryContainer,
                    foregroundColor: AppColors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.radiusButton),
                    ),
                    elevation: 0,
                  ),
                  child: _isSaving
                      ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.onPrimary))
                      : Text('حفظ', style: AppTextStyles.headlineSmall(context)),
                ),
              ),
            ),
          ],
          SizedBox(height: MediaQuery.of(context).padding.bottom + AppConstants.spaceMd),
        ],
      ),
    );
  }
}
