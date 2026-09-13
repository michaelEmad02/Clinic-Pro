# business_logic.md — Medical Records Feature (Lab Tests & Radiology)

---

## 1. Core Business Rules

```
1. Record Classification:
   - type = 'lab_test'  (🧪 Lab Tests / التحاليل المخبرية)
   - type = 'radiology' (🩻 Radiology & Scans / الأشعة والفحوصات)

2. File Upload Rules:
   - Images picked via ImagePicker from Camera or Gallery.
   - Constrained to max 2400×2400 resolution at 95% quality.
   - Storage path convention: patients/{patient_id}/{timestamp}_{filename}
   - Bucket: 'attachments' (public bucket for fast CDN caching).

3. Appointment & Prescription Linkage:
   - If uploaded from Prescription Screen or Appointment Details:
     appointment_id, prescription_id, and doctor_id are attached.
   - If uploaded directly from Patient Details tab:
     appointment_id and prescription_id may be null (standalone record).
```

---

## 2. Upload Workflow Sequence

```
1. User opens UploadMedicalRecordDialog:
   - Selects type ('lab_test' or 'radiology') → updates state & quick suggestions list.
   - Picks image from Camera or Gallery → converts to File.
   - Enters test title (or picks from quick suggestions: CBC, HbA1c, CT Scan, X-Ray, etc.).
   - Selects test date (default: today).
   - Enters optional doctor diagnostic notes.

2. User submits form:
   a. Validation:
      - Title text must not be empty.
      - Image file must be selected.
   b. Uploading:
      - Cubit triggers UploadMedicalRecordUseCase.
      - RemoteDataSource uploads image file to Supabase Storage bucket ('attachments').
      - Gets public URL for file.
      - Inserts metadata into public.medical_records table.
   c. On Success:
      - Dialog pops with result true.
      - Cubit reloads records list and emits operationMessage: "تم رفع الفحص الطبي بنجاح".
```

---

## 3. Delete Workflow Sequence

```
1. User clicks delete icon on MedicalRecordCard:
   - Confirmation dialog opens (AppStrings.deleteRecordConfirm).
2. On Confirmation:
   - Cubit triggers DeleteMedicalRecordUseCase(recordId, storagePath).
   - Data source deletes storage object from 'attachments' bucket via storagePath.
   - Data source deletes DB row from 'medical_records' table by ID.
   - Cubit reloads record list for patient and emits operationMessage: "تم حذف الفحص الطبي بنجاح".
```

---

## 4. State Management & Filtering (`MedicalRecordsCubit`)

```
State Hierarchy:
  - MedicalRecordsInitial
  - MedicalRecordsLoading
  - MedicalRecordsLoaded:
      records: List<MedicalRecordEntity>
      selectedFilter: 'all' | 'lab_test' | 'radiology' | 'linked' | 'unlinked'
      operationMessage: String?
      Getters:
        - filteredRecords: returns subset matching selectedFilter
        - labTestsCount: count of lab_test items
        - radiologyCount: count of radiology items
        - linkedCount: count of items with appointment_id != null
        - unlinkedCount: count of items with appointment_id == null
  - MedicalRecordsError:
      message: String
```

---

## 5. Clean Architecture Execution

```
Presentation (Cubit)
   ↓ calls UseCase
Domain (GetMedicalRecordsUseCase / UploadMedicalRecordUseCase / DeleteMedicalRecordUseCase)
   ↓ calls Repository Interface
Data (MedicalRecordsRepositoryImpl) -> returns Either<Failure, T>
   ↓ calls RemoteDataSource
Data (MedicalRecordsRemoteDataSourceImpl) -> communicates with Supabase Storage & Postgres DB
```
