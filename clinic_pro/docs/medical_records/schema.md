# schema.md — Medical Records Feature (Lab Tests & Radiology)

---

## 1. Table Schema (`public.medical_records`)

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| `id` | `UUID` | `PRIMARY KEY DEFAULT gen_random_uuid()` | Record unique identifier |
| `clinic_id` | `UUID` | `NOT NULL REFERENCES public.clinics(id) ON DELETE CASCADE` | Associated clinic |
| `patient_id` | `UUID` | `NOT NULL REFERENCES public.patients(id) ON DELETE CASCADE` | Patient owning the record |
| `doctor_id` | `UUID` | `REFERENCES public.users(id) ON DELETE SET NULL` | Doctor who ordered/uploaded |
| `appointment_id` | `UUID` | `REFERENCES public.appointments(id) ON DELETE SET NULL` | Linked clinic appointment |
| `prescription_id` | `UUID` | `REFERENCES public.prescriptions(id) ON DELETE SET NULL` | Linked prescription |
| `type` | `TEXT` | `NOT NULL CHECK (type IN ('lab_test', 'radiology'))` | Record type classification |
| `title` | `TEXT` | `NOT NULL` | Test/scan title name |
| `file_url` | `TEXT` | `NOT NULL` | Public CDN access URL for the image |
| `storage_path` | `TEXT` | `NOT NULL` | Relative path inside Supabase storage bucket |
| `record_date` | `DATE` | `NOT NULL DEFAULT CURRENT_DATE` | Date test/scan was performed |
| `notes` | `TEXT` | `NULL` | Optional doctor diagnostic notes |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL DEFAULT NOW()` | Record creation timestamp |

---

## 2. Indexes

- `idx_medical_records_patient` ON `public.medical_records(patient_id)`
- `idx_medical_records_clinic` ON `public.medical_records(clinic_id)`
- `idx_medical_records_type` ON `public.medical_records(type)`
- `idx_medical_records_appointment` ON `public.medical_records(appointment_id)`
- `idx_medical_records_date` ON `public.medical_records(record_date DESC)`

---

## 3. Storage Bucket Configuration & RLS

- **Bucket ID**: `attachments` (Public = `true`)
- **Storage Path Pattern**: `patients/{patient_id}/{file_name}`
- **Storage RLS Policies**:
  - `Allow public read for attachments`: Public GET access for CDN rendering via `CachedNetworkImage`.
  - `Allow upload attachments for clinic members`: Authenticated INSERT for staff belonging to patient's clinic.
  - `Allow update attachments for clinic members`: Authenticated UPDATE for upserts.
  - `Allow delete attachments for clinic members`: Authenticated DELETE for removal.
