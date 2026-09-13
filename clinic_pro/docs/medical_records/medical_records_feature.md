# 🧪🩻 feature: Medical Records (Lab Tests & Radiology)

---

## 1. Overview
The Medical Records feature enables doctors and staff to capture, upload, view, filter, and manage patient lab tests (e.g. CBC, HbA1c, Liver/Kidney functions) and radiology/x-ray scans (X-Ray, CT, MRI, Ultrasound, ECG).

The feature seamlessly links records to specific clinic visits/appointments or keeps them as independent medical records for the patient history.

---

## 2. Architecture & Layering

```
lib/features/medical_records/
├── data/
│   ├── datasources/
│   │   └── medical_records_remote_data_source_impl.dart
│   ├── models/
│   │   └── medical_record_model.dart
│   └── repositories/
│       └── medical_records_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── medical_record_entity.dart
│   ├── repositories/
│   │   └── i_medical_records_repository.dart
│   └── usecases/
│       ├── delete_medical_record_use_case.dart
│       ├── get_medical_records_use_case.dart
│       └── upload_medical_record_use_case.dart
└── presentation/
    ├── manager/
    │   ├── medical_records_cubit.dart
    │   └── medical_records_state.dart
    └── ui/
        └── widgets/
            ├── medical_record_card.dart
            ├── medical_record_image_viewer.dart
            ├── medical_records_bottom_sheet.dart
            ├── medical_records_tab.dart
            ├── upload_medical_record_dialog.dart
            └── upload_dialog/
                ├── upload_image_picker_area.dart
                ├── upload_record_form_fields.dart
                └── upload_type_selector.dart
```

---

## 3. Core Features & Capabilities

1. **Adaptive & Responsive UI**:
   - **Mobile (<600px)**: Bottom sheet presentation (`showModalBottomSheet`), 2-column grid layout in Patient Details tab.
   - **Tablet/Desktop (>=600px)**: Centered `Dialog` (max width `560px` for upload, `720px` for history sheet), 3 to 4 adaptive grid columns (`childAspectRatio` 0.82-0.86).

2. **Smooth Animations & Micro-Interactions**:
   - Animated switcher between Lab Tests 🧪 and Radiology 🩻.
   - Micro scale/hover animation on `MedicalRecordCard`.
   - `InteractiveViewer` with pinch-to-zoom (0.8x to 5.0x) and pan capabilities in `MedicalRecordImageViewer`.

3. **Multi-Language (Arabic & English) & Theme Support**:
   - Full string localization through `AppStrings` (`AppStrings.isArabic`).
   - Pure dynamic color scheme using `context.primary`, `context.surfaceColor`, `context.borderColor`, etc., matching both Light & Dark modes.

4. **Integration Points**:
   - **Prescription View (`prescription_view.dart`)**: Quick access banner tile to launch `MedicalRecordsBottomSheet.show(...)` for the current patient/visit.
   - **Patient Details Screen (`patient_details_screen.dart`)**: `MedicalRecordsTab` tab displaying historical tests with filter chips (All, Lab Tests, Radiology, Linked to Appointment, Standalone).

---

## 4. Localization Keys Added in `AppStrings`

- `AppStrings.medicalRecords`
- `AppStrings.uploadMedicalRecord`
- `AppStrings.labTest` / `AppStrings.radiology`
- `AppStrings.recordTitleLabel` / `AppStrings.recordTitleHint`
- `AppStrings.recordDateLabel` / `AppStrings.changeDate`
- `AppStrings.recordImageLabel` / `AppStrings.pickFromCamera` / `AppStrings.pickFromGallery`
- `AppStrings.patientMedicalRecordsQuickAccess`
- `AppStrings.labSuggestions` / `AppStrings.radiologySuggestions`
- `AppStrings.deleteRecordTitle` / `AppStrings.deleteRecordConfirm(...)`
