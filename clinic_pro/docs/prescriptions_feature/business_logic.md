# business_logic.md — Prescriptions Feature

---

## Diagnosis = Free Text (confirmed)

```
prescriptions.diagnosis is a TEXT field — not a foreign key.

Two ways the doctor fills it:
  1. Types a custom diagnosis freely (via text field + "إضافة" button)
  2. Selects template names from chips → each name is ADDED to a list
     (multi-select, NOT single-select)

At save time, the selected diagnosis list is joined with ' ، ' (Arabic comma)
and the final free-text diagnosis (if any) is appended after ' - '.
Example: "تشخيص1 ، تشخيص2 - ملاحظات إضافية"

After save, there is NO retained link between the prescription and the
template(s) that were used to populate the diagnosis text (other than
each template's user_count being incremented at save time).

Analytics implication:
  "Most common diagnosis" reports must GROUP BY the diagnosis text string,
  with fuzzy/exact matching — not by a foreign key join.
```

---

## Prescription Save Flow

```
1. Doctor opens Prescription screen (from "تأكيد الكشف" on an appointment)
   → PrescriptionBloc receives LoadPrescriptionDataEvent(appointmentId)
   → repository.loadData(appointmentId) fetches: appointment, patient, doctor, type
   → If a prescription already exists for this patient, its data is loaded
     (drugs, diagnosis, notes) for editing

2. Doctor selects one or more template NAMES as diagnosis chips (multi-select)
   → ToggleDiagnosisEvent adds/removes template names from selectedDiagnosis list
   → Doctor can also type custom diagnosis → AddCustomDiagnosisEvent

3. Doctor applies a template to auto-add its drugs:
   → ApplyTemplateEvent(templateId) → repository.getTemplateData(templateId)
   → Template items (drugs + dose settings) are merged with existing selectedDrugs
     (duplicates skipped by drug ID)
   → Template name is added to selectedDiagnosis if not already present

4. Doctor can also "نسخ روشتة سابقة" (copy previous prescription):
   → CopyPreviousPrescriptionEvent → fetches most recent prescription globally
   → REPLACES current drugs and diagnosis (not merge)

5. Doctor adjusts/adds drugs manually via AddDrugSearchSheet
   → AddDrugToPrescriptionEvent(drug raw map)
   → Default dose: frequency=2, duration=7, timing='after_meal', isPrn=false

6. Doctor edits drug dose via DrugDoseCard:
   → UpdateDrugDoseEvent(drugId, frequency?, duration?, timing?, isPrn?)

7. Doctor adds notes via UpdatePrescriptionFieldsEvent

8. On save (SavePrescriptionEvent):
   a. Validation:
      - selectedDiagnosis must NOT be empty AND/OR finalDiagnosis must have text
      - selectedDrugs must NOT be empty (at least 1 drug)
      - Per drug (if !isPrn): frequency AND duration must be set
      - Per drug: timing must be set (always required, even for PRN)

   b. INSERT into prescriptions:
      - clinic_id, doctor_id (⚠️ hardcoded 'u-doc-1'), patient_id
      - diagnosis = selectedDiagnosis.join(' ، ') + optional ' - finalDiagnosis'
      - notes, created_at
      - ⚠️ NO appointment_id is saved

   c. INSERT into prescription_items for each drug:
      - prescription_id, drug_id, frequency, duration, timing, is_prn

   d. For each selected diagnosis name → find matching prescription_template by name:
      - UPDATE prescription_templates SET user_count = user_count + 1

   e. UPDATE appointments SET status = 'done' WHERE id = appointmentId
```

---

## ⚠️ Known Issues in Save Flow

```
1. doctor_id is HARDCODED to 'u-doc-1' in prescription_repository.dart:128
   → Should use the actual logged-in doctor's ID from auth state

2. appointment_id is NOT saved to prescriptions table
   → No direct link between prescription and the appointment it was created from
   → Linking happens indirectly via patient_id + doctor_id + created_at date

3. "Copy Previous" fetches the most recent prescription GLOBALLY (no patient filter)
   → Should filter by patient_id to copy the same patient's last prescription
```

---

## PRN Rule (is_prn = true)

```
When PRN is toggled ON in DrugDoseCard:
  - frequency → set to null (cleared)
  - duration → set to null (cleared)
  - frequency chips HIDDEN (if !isPrn block)
  - duration chips HIDDEN (if !isPrn block)
  - timing chips remain VISIBLE and ACTIVE (always shown)

When PRN is toggled OFF:
  - frequency → reset to 2 (twice daily)
  - duration → reset to 7 (7 days)

Validation: PRN drugs skip frequency/duration validation but timing is still required.
```

---

## Drug Timing — Known Typo & Extra Value

```
The DB enum 'drug_timing' has 3 values:
  'after_meal', 'before_meal', 'throught_meal'

The Dart enum DrugTiming (prescription_enums.dart) has 4 values:
  beforeMeal('before_meal')
  afterMeal('after_meal')
  throughMeal('throught_meal')  ← typo preserved from DB
  anyTime('any_time')           ← ⚠️ NOT confirmed in DB enum

⚠️ 'throught_meal' is a typo (should be 'through_meal' or 'with_meal').
   Do NOT fix client-side — must match DB enum exactly.

⚠️ 'any_time' may not exist in the DB enum. If it doesn't, inserts with
   timing='any_time' will fail with a constraint violation. Verify with
   DB admin or check via: SELECT enum_range(NULL::drug_timing)
```

---

## DrugFrequency & DrugDuration — Extra Values

```
DrugFrequency enum has an extra value: onDemand(0)
  - This is UI-only display text ("عند اللزوم")
  - NOT used for DB inserts — PRN is handled via is_prn boolean flag
  - When is_prn=true, frequency is NULL in the DB, not 0

DrugDuration enum has an extra value: continuing(0)
  - Represents indefinite treatment ("مستمر")
  - Stored as 0 in DB if selected
```

---

## Validations

```
diagnosis:    required — at least one selected chip OR non-empty finalDiagnosis text
drugs:        at least 1 drug must be added to selectedDrugs
  per drug:
    frequency: required unless is_prn = true (null when PRN)
    duration:  required unless is_prn = true (null when PRN)
    timing:    ALWAYS required (even for PRN drugs)
```

---

## Template Management (TemplatesCubit)

```
Templates are managed via a separate TemplatesCubit (not the PrescriptionBloc).

Load: Fetches all prescription_templates + their items + drug details (N+1 pattern)
Add:  Creates template with doctor_id='u-doc-1' (⚠️ hardcoded), user_count=0
Edit: Updates name, deletes old items, inserts new items, then full reload
Delete: Deletes items first (by template_id), then the template itself

⚠️ doctor_id is hardcoded to 'u-doc-1' — templates should be personal to each doctor
⚠️ loadTemplates has N+1 query pattern (per template → per item → per drug)
```

---

## Drugs Management (DrugsCubit)

```
Drugs are global (no clinic_id or doctor_id scoping).
Any doctor can add, edit, or delete any drug.

Operations: loadDrugs, addDrug, updateDrug, deleteDrug
Search/filter: local (on loaded state) by text query and category
```

---

## Open Questions

```
1. appointment_id column:
   Not in the live schema. Linking prescriptions to appointments happens
   indirectly. Consider adding the column if "linked prescription" card
   is needed on Appointment Details screen.

2. doctor_id hardcoding:
   'u-doc-1' is used in both prescription save and template creation.
   Must be replaced with actual auth user ID before multi-doctor support.

3. 'any_time' timing value:
   Exists in Dart enum but may not exist in DB enum. Must verify.

4. prescription_docs table:
   Exists in DB and in SupabaseTables constants but no feature code uses it.
   Planned for patient document uploads (X-rays, lab results).

5. "Copy Previous" scope:
   Currently fetches the last prescription globally, not per-patient.
   Should be scoped to the current patient.
```
