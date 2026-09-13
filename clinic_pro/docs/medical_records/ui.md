# ui.md — Medical Records Feature (Lab Tests & Radiology)

---

## 1. Components Overview

| Widget | Purpose | Responsive Mode |
|--------|---------|-----------------|
| `UploadMedicalRecordDialog` | Modal dialog/sheet to upload new lab test or radiology scan | Bottom Sheet (Mobile) / Centered Dialog `maxWidth: 560px` (Desktop/Tablet) |
| `MedicalRecordsBottomSheet` | History viewer & quick attachment sheet | Bottom Sheet (Mobile) / Centered Dialog `maxWidth: 720px` (Desktop/Tablet) |
| `MedicalRecordsTab` | Main patient details tab for medical records | Adaptive Grid: 2 cols (Mobile), 3 cols (Tablet), 4 cols (Desktop) |
| `MedicalRecordCard` | Visual preview card for a single lab test / scan | Micro hover animation (`AnimatedScale`), badge styling, dark/light theme aware |
| `MedicalRecordImageViewer` | Interactive fullscreen viewer | `InteractiveViewer` with pinch-to-zoom (0.8x – 5.0x), pan, and appointment link navigation |

---

## 2. Upload Dialog Modular Structure (`upload_dialog/`)

```
upload_medical_record_dialog.dart (Main Coordinator)
├── UploadTypeSelector        (Switch between Lab Tests 🧪 and Radiology 🩻 with 250ms animation)
├── UploadImagePickerArea     (Image preview box, fade/scale animation, Camera & Gallery buttons)
└── UploadRecordFormFields    (Title field, quick suggestion chips, date picker box, doctor notes)
```

---

## 3. Responsive & Adaptive Rules

```
Mobile (< 600px):
  - Modals presented as showModalBottomSheet with draggable handle.
  - MedicalRecordsTab grid: 2 columns, childAspectRatio = 0.78.

Tablet & Desktop (>= 600px):
  - Modals presented as centered Dialog with fixed max width constraints:
      * UploadMedicalRecordDialog: maxWidth = 560px
      * MedicalRecordsBottomSheet: maxWidth = 720px, maxHeight = 680px
  - MedicalRecordsTab grid:
      * Tablet (600px - 1024px): 3 columns, childAspectRatio = 0.82
      * Desktop (>= 1024px): 4 columns, childAspectRatio = 0.86
```

---

## 4. Design Tokens & Localization

- **Theme Colors**: Uses `context.primary`, `context.surfaceColor`, `context.borderColor`, `context.textPrimary`, `context.textSecondary`, `context.surfaceContainerLow`.
- **Localization**: Uses `AppStrings` for all strings with full Arabic (RTL) & English (LTR) support.
- **Feedback & Errors**: Uses `AppLoadingWidget` for loading states and `AppErrorWidget` / `EmptyState` for errors and empty states.
