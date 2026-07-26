# business_logic.md — Patients Feature


---

## Visit History

```
Patient Details → Visits tab:
  Query appointments WHERE patient_id = X
  Shows: date + clinic name + doctor + diagnosis (free text from prescriptions)
  Spans all of the owner's clinics

Patient Details → Prescriptions tab:
  Query prescriptions WHERE patient_id = X
  Shows: date + diagnosis text + drug count
```

---

## Validations

```
name:                required, min 2 chars
phone:                optional, valid format if provided
date_of_birth:        optional, must be in the past
gender:               REQUIRED — enum check (male | female)
blood_type:           optional — enum check if provided
allergies:             optional free text
chronic_conditions:    optional free text
```

---

## Allergy Warning

```
If patients.allergies is not null/empty:
  → Show prominent warning banner on Patient Details screen
  → Show subtle warning icon next to patient name in lists
  → Show in Prescription screen header when writing for this patient
```
