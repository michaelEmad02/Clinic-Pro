// ────────────────────────────────────────────────────────
// حقل اختيار المريض مع بحث — مطابق لتصميم Stitch
// ────────────────────────────────────────────────────────

import 'package:flutter/material.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/mocks/mock_data.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';

class PatientPickerField extends StatefulWidget {
  final String? selectedPatientId;
  final ValueChanged<String?> onChanged;

  const PatientPickerField({
    super.key,
    required this.selectedPatientId,
    required this.onChanged,
  });

  @override
  State<PatientPickerField> createState() => _PatientPickerFieldState();
}

class _PatientPickerFieldState extends State<PatientPickerField> {
  final _searchController = TextEditingController();
  bool _expanded = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String? get _selectedName {
    if (widget.selectedPatientId == null) return null;
    final patient = MockData.patients.firstWhere(
      (p) => p['id'] == widget.selectedPatientId,
      orElse: () => {},
    );
    return patient['name'] as String?;
  }

  List<Map<String, dynamic>> get _filteredPatients {
    final query = _searchController.text.trim();
    if (query.isEmpty) return MockData.patients;
    return MockData.patients
        .where((p) => (p['name'] as String).contains(query))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'اختيار المريض',
          style: AppTextStyles.caption(context).copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => setState(() => _expanded = !_expanded),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppConstants.spaceMd,
              vertical: 13,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              border: Border.all(color: AppColors.border),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 2,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _selectedName ?? 'ابحث أو اختر مريضاً...',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      color: _selectedName != null
                          ? AppColors.textPrimary
                          : AppColors.textHint,
                    ),
                  ),
                ),
                const Icon(Icons.search, color: AppColors.textSecondary, size: 20),
              ],
            ),
          ),
        ),
        if (_expanded) ...[
          const SizedBox(height: 8),
          TextField(
            controller: _searchController,
            onChanged: (_) => setState(() {}),
            decoration: InputDecoration(
              hintText: 'بحث بالاسم...',
              prefixIcon: const Icon(Icons.search, size: 20),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusInput),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppConstants.spaceMd,
                vertical: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ..._filteredPatients.map((patient) {
            final id = patient['id'] as String;
            final isSelected = widget.selectedPatientId == id;
            return ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text(
                patient['name'] as String,
                style: AppTextStyles.bodyMedium(context),
              ),
              subtitle: Text(
                patient['phone'] as String,
                style: AppTextStyles.caption(context).copyWith(
                  color: AppColors.textSecondary,
                ),
                textDirection: TextDirection.ltr,
              ),
              trailing: isSelected
                  ? const Icon(Icons.check_circle, color: AppColors.primary)
                  : null,
              onTap: () {
                widget.onChanged(id);
                setState(() => _expanded = false);
              },
            );
          }),
        ],
      ],
    );
  }
}
