# business_logic.md — Financial Feature (Invoices & Expenses)

---

## Invoice Creation — Manual Only

```
Invoices are created MANUALLY by secretary or owner.
NOT auto-generated after examination.

Creation flow:
  1. Select patient          → autocomplete search
  2. Select appointment      → filtered to selected patient,
                                appointments that are not fully paid yet
                                (regardless of appointment status)
  3. appointment.price       → shown as HINT only ("السعر المتوقع: X")
                                NOT pre-filled in the total_amount input
  4. Enter total_amount      → actual charged amount (required, > 0)
  5. Enter paid_amount       → can be partial (required, >= 0, <= total)
  6. Select payment_method   → optional
  7. Save:
     INSERT into invoices with ALL of:
       clinic_id, patient_id, source_id (appointment id),
       source_type = 'appointment', total_amount, paid_amount,
       created_by = auth.uid()
     ⚠️ Every one of these MUST be explicit — DB defaults are placeholder
        random UUIDs and will silently corrupt data if relied upon.

Also accessible via:
  Appointments screen → (···) → "تسجيل فاتورة"
  → pre-fills patient_id + source_id automatically (still requires
    explicit total_amount/paid_amount entry)
```

---

## Invoice Status (derived — not stored)

```dart
String get status {
  if (paidAmount <= 0)          return 'pending';   // معلق
  if (paidAmount < totalAmount) return 'partial';    // جزئي
  return 'paid';                                     // مدفوع
}
```

> No status indicator UI inside the Add Invoice form (removed per request) —
> status is shown only in the Invoices list view, computed from stored amounts.

---

## Business Rules

```
- One appointment can have multiple invoice records (partial payments over time)
- Secretary and Owner can create/edit invoices
- Doctor can VIEW invoices only — cannot create
- Invoices can be edited or deleted (deleting triggers confirmation dialog since it impacts reports)
```

---

## Expense Categories — Dynamic Lookup

```
expense_categories is a real table with 13 seeded Arabic categories
(see schema.md for full list). UI must:
  - Fetch categories via SELECT * FROM expense_categories ORDER BY name
  - Render as dropdown/chips dynamically
  - Never hardcode the category list in Dart constants
  - category_id (not category name/enum) is stored on each expense
```

---

## Expense Creation

```
Fields: title/notes, category_id (dropdown from expense_categories),
        amount, date (created_at), notes
created_by MUST be set explicitly to auth.uid()
clinic_id MUST be set explicitly
```

---

## Validations

```
Invoice:
  patient_id:    required
  source_id:     required (appointment)
  total_amount:  required, > 0
  paid_amount:   required, >= 0, <= total_amount

Expense:
  category_id:  required (must exist in expense_categories)
  amount:       required, > 0
```
