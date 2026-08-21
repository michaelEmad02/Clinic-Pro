// ────────────────────────────────────────────────────────
// حقل اختيار المريض مع بحث — مطابق لتصميم Stitch
// يستخدم PatientEntity بدلاً من PatientItem
// ────────────────────────────────────────────────────────
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/constants/app_constants.dart';
import '../../../../../core/strings/app_strings.dart';
import '../../../../../core/themes/app_colors.dart';
import '../../../../../core/themes/app_text_styles.dart';
import '../../../../../core/widgets/app_loading.dart';
import '../../../../patients/domain/entities/patient_entity.dart';
import '../../../../patients/presentation/manager/patients_cubit.dart';
import '../../../../patients/presentation/manager/patients_state.dart';

class PatientPickerField extends StatefulWidget {
  final String? selectedPatientId;
  final ValueChanged<String?> onChanged;
  final String? doctorId;

  const PatientPickerField({
    super.key,
    required this.selectedPatientId,
    required this.onChanged,
    this.doctorId,
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

  String? _selectedName(PatientsState state) {
    if (widget.selectedPatientId == null) return null;
    if (state is PatientsLoaded) {
      final patient = state.allPatients.firstWhere(
        (p) => p.id == widget.selectedPatientId,
        
      );
      return patient.name.isNotEmpty ? patient.name : null;
    }
    return null;
  }

  List<PatientEntity> _filteredPatients(PatientsState state) {
    if (state is! PatientsLoaded) return [];
    final query = _searchController.text.trim().toLowerCase();

    var list = state.allPatients;

    if (query.isNotEmpty) {
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              (p.phone != null && p.phone!.contains(query)))
          .toList();
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PatientsCubit, PatientsState>(
      builder: (context, state) {
        final selectedName = _selectedName(state);
        final filteredPatients = _filteredPatients(state);
        final isLoading = state is PatientsLoading;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              AppStrings.selectPatient,
              style: AppTextStyles.caption(context).copyWith(
                color: context.textSecondary,
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
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusInput),
                  border: Border.all(color: context.borderColor),
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
                      child: isLoading
                          ? const Align(
                              alignment: AlignmentDirectional.centerStart,
                              child: SizedBox(
                                height: 20,
                                width: 20,
                                child: AppLoadingWidget(size: AppLoadingSize.small),
                              ),
                            )
                          : Text(
                              selectedName ?? AppStrings.searchPatientHint,
                              style: AppTextStyles.bodyMedium(context).copyWith(
                                color: selectedName != null
                                    ? context.textPrimary
                                    : context.textHint,
                               ),
                            ),
                    ),
                    Icon(Icons.search, color: context.textSecondary, size: 20),
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
                  hintText: AppStrings.searchByName,
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
              Container(
                constraints: const BoxConstraints(maxHeight: 200),
                decoration: BoxDecoration(
                  color: context.surfaceColor,
                  borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                  border: Border.all(color: context.borderColor),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: isLoading
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.all(16.0),
                          child: AppLoadingWidget(size: AppLoadingSize.small),
                        ),
                      )
                    : filteredPatients.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Center(
                              child: Text(
                                AppStrings.noPatientsFound,
                                style: AppTextStyles.bodyMedium(context).copyWith(
                                  color: context.textSecondary,
                                ),
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            itemCount: filteredPatients.length,
                            separatorBuilder: (_, __) => Divider(color: context.borderColor, height: 1),
                            itemBuilder: (context, index) {
                              final patient = filteredPatients[index];
                              final id = patient.id;
                              final isSelected = widget.selectedPatientId == id;
                              return ListTile(
                                dense: true,
                                contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                                title: Text(
                                  patient.name,
                                  style: AppTextStyles.bodyMedium(context).copyWith(
                                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                                  ),
                                ),
                                subtitle: patient.phone != null
                                    ? Text(
                                        patient.phone!,
                                        style: AppTextStyles.caption(context).copyWith(
                                          color: context.textSecondary,
                                        ),
                                        textDirection: TextDirection.ltr,
                                      )
                                    : null,
                                trailing: isSelected
                                    ? Icon(Icons.check_circle, color: context.primary)
                                    : null,
                                onTap: () {
                                  widget.onChanged(id);
                                  setState(() => _expanded = false);
                                },
                              );
                            },
                          ),
              ),
            ],
          ],
        );
      },
    );
  }
}
