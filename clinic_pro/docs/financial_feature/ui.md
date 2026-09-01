# ui.md — Financial Feature (Invoices, Expenses, Reports)

---

## Screens

| Screen | Route | Roles |
|--------|-------|-----------|
| Invoices | `/invoices` | Owner + Doctor + Secretary |
| Expenses | `/expenses` | Owner + Doctor + Secretary |
| Reports | `/reports` | Owner + Doctor |
| Add Expense Sheet | — | Owner + Doctor + Secretary |
| Add Invoice Sheet | — | Owner + Doctor + Secretary |

---

## Invoices Screen

```
Summary bar: إيرادات اليوم | فواتير معلقة | إجمالي الشهر
Date range chips: اليوم | هذا الأسبوع | هذا الشهر | 3 أشهر | الكل | مخصص
Filter chips: الكل | مدفوع | جزئي | معلق  (status derived client-side)
List items: patient name + amount (Inter Bold) + date + status badge + (···)
(···) → تسديد دفعة (if not fully paid) | تعديل الفاتورة | طباعة الفاتورة | حذف الفاتورة (with confirm dialog)
FAB → Add Invoice Sheet
```

### Add Invoice Sheet
See `figma_invoice_sheet_prompt.md` for full detailed spec.
Key points:
- No invoice status indicator inside the form (removed)
- Patient/appointment autocomplete
- expected_fee shown as info hint card only — not pre-filled
- Payment method chips (optional, 3 options: نقد / بطاقة / تحويل)

---

## Expenses Screen

```
Role-Based Scoping & Complete Separation:
  - Owner (المالك):
    • يرى فقط مصاريف العيادة العامة (doctor_id == null).
    • لا تظهر له أي خيارات أو عناصر متعلقة بمصاريف الأطباء نهائياً.
    • الإجمالي والشارت يعكسان فقط مصاريف العيادة العامة.
  - Doctor (الطبيب):
    • يرى فقط مصاريفه الشخصية الخاصة به (doctor_id == currentDoctorId).
    • لا تظهر له مصاريف العيادة العامة ولا مصاريف الأطباء الآخرين.
    • الإجمالي يعكس فقط مصاريفه الشخصية.
  - Secretary (السكرتير):
    • يتعامل مع مصاريف العيادة العامة افتراضياً (doctor_id == null).

Category filter chips — MUST be fetched dynamically from expense_categories
table (13 categories), not hardcoded:
  [الكل] [إيجار] [كهرباء] [مستلزمات] [رواتب] [صيانه] [اجهزة طبية]
  [انترنت] [تسويق و اعلانات] [خدمات] [ضرائب و رسوم] [طاقه اخري] [مياه] [أخري]

Summary card: total expenses for the selected role's scope
List items: category icon + title/notes + amount (Inter Bold, danger color) + date + (···)
(···) → تعديل | حذف (with confirm dialog)
FAB → Add Expense Sheet
```

### Add Expense Sheet
```
Fields:
- Title field (required)
- Category dropdown — populated from expense_categories table (13 options)
- Amount field (numeric, > 0)
- Date picker
- Notes field (optional)

Role Handling on Save:
- If Owner / Secretary: saved as Clinic Expense automatically (doctor_id = null).
- If Doctor: saved as Doctor Personal Expense automatically (doctor_id = auth.uid()).
(No confusing dropdowns or scope selectors — seamless based on role).
```

---

## Reports Screen

```
Date range chips: هذا الأسبوع | هذا الشهر | 3 أشهر | مخصص
Summary cards: إيرادات | مصروفات | صافي ربح | عدد المرضى
Bar chart: إيرادات vs مصروفات
Line chart: عدد المرضى يومياً
Top diagnoses list:
  ⚠️ Since prescriptions.diagnosis is free text (not FK), this report
  groups by exact/fuzzy text match on the diagnosis string — not a clean join.
Doctor performance list
Export PDF button
```

 - تقرير الايرادات 
   إيرادات اليوم / الأسبوع / الشهر / السنة
   مقارنة بنفس الفترة السابقة (↑↓ %)
   إيرادات vs مصروفات → صافي الربح
 - المدفوعات
    إجمالي مدفوع vs متبقي (paid_amount vs total_amount)
    فواتير معلقة وقيمتها
    متوسط قيمة الفاتورة
    توزيع طرق الدفع: نقد / كارت / تحويل

  - المصروفات
    مصروفات كل فئة (إيجار / كهرباء / رواتب...)
     أكبر بند مصروفات
     مقارنة المصروفات شهر بشهر
---

## Design Tokens
See `architecture.md` → Design System section.
