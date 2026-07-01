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
Filter chips: الكل | مدفوع | جزئي | معلق  (status derived client-side)
List items: patient name + amount (Inter Bold) + date + status badge + (···)
(···) → تحصيل دفعة | إرسال للمريض | تفاصيل   ⚠️ no "حذف" — invoices not deletable
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
Category filter chips — MUST be fetched dynamically from expense_categories
table (13 categories), not hardcoded:
  [الكل] [إيجار] [كهرباء] [مستلزمات] [رواتب] [صيانه] [اجهزة طبية]
  [انترنت] [تسويق و اعلانات] [خدمات] [ضرائب و رسوم] [طاقه اخري] [مياه] [أخري]

Summary card: total expenses for selected period
List items: category icon + title/notes + amount (Inter Bold, danger color) + date + (···)
(···) → تعديل | حذف (with confirm dialog)
FAB → Add Expense Sheet
```

### Add Expense Sheet
```
Title/notes field
Category dropdown — populated from expense_categories table (13 options)
Amount field (numeric)
Date picker
Notes field (optional)
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

---

## Design Tokens
See `architecture.md` → Design System section.
