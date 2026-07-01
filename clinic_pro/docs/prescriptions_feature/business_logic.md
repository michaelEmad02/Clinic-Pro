# business_logic.md — Prescriptions Feature

---

## Diagnosis = Free Text (confirmed)

```
prescriptions.diagnosis is a TEXT field — not a foreign key.

Two ways the doctor fills it:
  1. Types a custom diagnosis freely
  2. Selects a template → template.name is COPIED as text into diagnosis field

After save, there is NO retained link between the prescription and the
template that was used to populate the diagnosis text (other than the
template's user_count being incremented at save time).

Analytics implication:
  "Most common diagnosis" reports must GROUP BY the diagnosis text string,
  with fuzzy/exact matching — not by a foreign key join.
```

---

## Prescription Save Flow

```
1. Doctor opens Prescription screen (from "تأكيد الكشف" on an appointment)
2. Doctor selects one or more prescription_templates (multi-select chips)
   → drugs from prescription_template_items auto-populate as prescription_items
   → diagnosis text field auto-fills with the FIRST selected template's name
     (if multiple templates selected, doctor edits the text manually to combine)
3. Doctor can freely edit the diagnosis text at any point
4. Doctor adjusts/adds drugs manually
5. Doctor adds notes
6. On save:
   a. INSERT into prescriptions (diagnosis = final text, clinic_id, doctor_id,
      patient_id — all set explicitly, never rely on defaults)
   b. INSERT into prescription_items for each drug (prescription_id, drug_id
      set explicitly — DB defaults are placeholder random UUIDs)
   c. For each selected template: UPDATE prescription_templates
      SET user_count = user_count + 1 WHERE id = template.id
   d. appointment.status → 'done' (handled in appointments_queue feature)
```

---

## PRN Rule (is_prn = true)

```
- frequency input disabled/hidden
- duration input disabled/hidden
- timing remains active
- Label: "عند اللزوم (PRN)"
```

---

## Drug Timing — Known Typo

```
The enum value is literally 'throught_meal' in the database (typo, not 'through').
UI label should still display correctly in Arabic ("مع الأكل") —
only the underlying enum string has the typo. Do not attempt to "fix" the
string client-side; it must match the DB enum exactly or inserts will fail.
```

---

## Validations

```
diagnosis:    required (text, min 2 chars) — either typed or from template
drugs:        at least 1 drug must be added to prescription_items
  per drug:
    frequency: required unless is_prn = true
    duration:  required unless is_prn = true
    timing:    required
```

---

## Open Question for Backend

```
prescriptions table has NO appointment_id column in the live schema.
The original plan assumed prescriptions ↔ appointments would be linked
1:1 via appointment_id for showing "linked prescription" on Appointment
Details screen.

Without this column, linking must happen via:
  - matching prescriptions.patient_id + prescriptions.doctor_id +
    prescriptions.created_at (same day as the appointment) — fragile, OR
  - adding appointment_id column via migration before Phase 7

Recommend adding the column before implementing Appointment Details'
"linked prescription card" feature.
```
