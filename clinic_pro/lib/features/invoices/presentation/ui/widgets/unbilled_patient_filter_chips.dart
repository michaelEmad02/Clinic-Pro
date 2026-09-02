// ────────────────────────────────────────────────────────
// UnbilledPatientFilterChips — زر وشيت فلترة الزيارات غير المفوترة بحسب المريض
// ────────────────────────────────────────────────────────

import 'package:clinic_pro/core/strings/app_strings.dart';
import 'package:clinic_pro/core/themes/app_colors.dart';
import 'package:clinic_pro/core/themes/app_text_styles.dart';
import 'package:clinic_pro/core/utils/responsive_helper.dart';
import 'package:flutter/material.dart';

class UnbilledPatientFilterChips extends StatelessWidget {
  final List<({String id, String name})> availablePatients;
  final String? selectedPatientId;
  final ValueChanged<String?> onPatientSelected;

  const UnbilledPatientFilterChips({
    super.key,
    required this.availablePatients,
    required this.selectedPatientId,
    required this.onPatientSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (availablePatients.isEmpty) return const SizedBox.shrink();

    final selectedPatient = availablePatients
        .where((p) => p.id == selectedPatientId)
        .firstOrNull;

    final isFiltered = selectedPatient != null;

    return ResponsiveHelper.responsiveCenter(
      maxWidth: 800,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          decoration: BoxDecoration(
            color: context.surfaceColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isFiltered ? context.primary : context.borderColor,
            ),
            boxShadow: isFiltered
                ? [
                    BoxShadow(
                      color: context.primary.withOpacity(0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _showPatientPickerSheet(context),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_search_outlined,
                      size: 18,
                      color: isFiltered ? context.primary : context.textSecondary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            AppStrings.isArabic
                                ? 'تصفية بحسب المريض'
                                : 'Filter by Patient',
                            style: AppTextStyles.caption(context).copyWith(
                              fontSize: 10,
                              color: context.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            isFiltered
                                ? selectedPatient.name
                                : (AppStrings.isArabic
                                    ? 'جميع المرضى'
                                    : 'All Patients'),
                            style: AppTextStyles.bodyMedium(context).copyWith(
                              fontWeight:
                                  isFiltered ? FontWeight.bold : FontWeight.w600,
                              color: isFiltered
                                  ? context.primary
                                  : context.textPrimary,
                              fontSize: 13,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    if (isFiltered)
                      IconButton(
                        icon: const Icon(Icons.close_rounded, size: 18),
                        color: context.textSecondary,
                        tooltip: AppStrings.isArabic ? 'إلغاء التصفية' : 'Clear filter',
                        onPressed: () => onPatientSelected(null),
                      )
                    else
                      Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: context.textSecondary,
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPatientPickerSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return _PatientPickerSheet(
          availablePatients: availablePatients,
          selectedPatientId: selectedPatientId,
          onPatientSelected: onPatientSelected,
        );
      },
    );
  }
}

class _PatientPickerSheet extends StatefulWidget {
  final List<({String id, String name})> availablePatients;
  final String? selectedPatientId;
  final ValueChanged<String?> onPatientSelected;

  const _PatientPickerSheet({
    required this.availablePatients,
    required this.selectedPatientId,
    required this.onPatientSelected,
  });

  @override
  State<_PatientPickerSheet> createState() => _PatientPickerSheetState();
}

class _PatientPickerSheetState extends State<_PatientPickerSheet> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = widget.availablePatients.where((p) {
      if (_searchQuery.isEmpty) return true;
      return p.name.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.7,
      ),
      decoration: BoxDecoration(
        color: context.surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: context.borderColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.person_search_outlined, color: context.primary),
                const SizedBox(width: 8),
                Text(
                  AppStrings.isArabic
                      ? 'اختر المريض لتصفية الزيارات'
                      : 'Select Patient to Filter Visits',
                  style: AppTextStyles.headlineSmall(context).copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          if (widget.availablePatients.length > 5) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: TextField(
                controller: _searchController,
                onChanged: (val) {
                  setState(() {
                    _searchQuery = val.trim();
                  });
                },
                decoration: InputDecoration(
                  hintText: AppStrings.isArabic ? 'بحث باسم المريض...' : 'Search patient...',
                  prefixIcon: const Icon(Icons.search, size: 20),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(color: context.borderColor),
                  ),
                ),
              ),
            ),
          ],
          const Divider(height: 1),
          Flexible(
            child: ListView(
              shrinkWrap: true,
              children: [
                ListTile(
                  leading: CircleAvatar(
                    backgroundColor: widget.selectedPatientId == null
                        ? context.primary
                        : context.borderColor.withOpacity(0.3),
                    child: Icon(
                      Icons.people_outline,
                      color: widget.selectedPatientId == null
                          ? Colors.white
                          : context.textSecondary,
                    ),
                  ),
                  title: Text(
                    AppStrings.isArabic
                        ? 'عرض جميع المرضى (الكل)'
                        : 'Show All Patients',
                    style: AppTextStyles.bodyMedium(context).copyWith(
                      fontWeight: widget.selectedPatientId == null
                          ? FontWeight.bold
                          : FontWeight.w500,
                      color: widget.selectedPatientId == null
                          ? context.primary
                          : context.textPrimary,
                    ),
                  ),
                  trailing: widget.selectedPatientId == null
                      ? Icon(Icons.check_circle, color: context.primary)
                      : null,
                  onTap: () {
                    widget.onPatientSelected(null);
                    Navigator.pop(context);
                  },
                ),
                const Divider(height: 1, indent: 16, endIndent: 16),
                ...filteredList.map((p) {
                  final isSelected = widget.selectedPatientId == p.id;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected
                          ? context.primary
                          : context.primary.withOpacity(0.1),
                      child: Text(
                        p.name.isNotEmpty ? p.name[0].toUpperCase() : '?',
                        style: TextStyle(
                          color: isSelected ? Colors.white : context.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      p.name,
                      style: AppTextStyles.bodyMedium(context).copyWith(
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                        color: isSelected ? context.primary : context.textPrimary,
                      ),
                    ),
                    trailing: isSelected
                        ? Icon(Icons.check_circle, color: context.primary)
                        : null,
                    onTap: () {
                      widget.onPatientSelected(p.id);
                      Navigator.pop(context);
                    },
                  );
                }),
              ],
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
