# ui.md — Prescriptions Feature

---

## Screens

| Screen | Route | Roles |
|--------|-------|-----------|
| Prescription (new) | `/prescription/:appointment_id` | Doctor + Owner |
| Prescription (edit) | `/prescription/:appointment_id` | Doctor + Owner |
| Templates | `/templates` | Doctor + Owner + Secretary |
| Drugs | `/drugs` | Doctor + Owner + Secretary |
| Add Template Sheet | — | Doctor + Owner + Secretary |
| Add Drug Sheet | — | Doctor + Owner + Secretary |

---

## Prescription Screen

```
① Header Card: patient name + age + blood type + visit type + doctor + date

② Diagnosis section:
   - Text input for diagnosis (free text — editable always)
   - Template chips (multi-select) — selecting fills diagnosis text
     with the template's name and auto-adds its drugs
   - "+ إضافة تشخيص جديد" → opens simple text entry (saves as new template)

③ Drugs section — per drug Card:
   - trade_name (bold) + generic_name (caption)
   - Frequency chips: 1× / 2× / 3× / 4× / PRN
   - Duration chips: 3d / 5d / 7d / 10d / 14d / 30d (hidden if PRN)
   - Timing chips: قبل الأكل / بعد الأكل / مع الأكل
     ⚠️ "مع الأكل" maps to enum value 'throught_meal' (DB typo) — label only, not the value
   - [✕] remove button
   - "+ إضافة دواء يدوياً" → search Bottom Sheet

④ Notes field (multiline)

⑤ Bottom Actions Bar (fixed): [حفظ الكشف] [طباعة PDF] [إرسال واتساب]
```

---

## Templates Screen

```
SearchBar + filter chips
List items: template name + user_count badge + drug count + (···)
  ⚠️ Use prescription_templates.user_count (not use_count) when querying
(···) → معاينة (dialog) | تعديل | حذف
FAB → Add Template Sheet
```

### Add Template Sheet
```
Name field + drug search/add + DoseChipSelector per drug
```

---

## Drugs Screen

```
SearchBar (trade_name OR generic_name) + category filter chips
List items: trade_name + generic_name + category badge + (···)
(···) → تعديل | تعطيل
FAB → Add Drug Sheet (trade_name, generic_name, category)
```

---

## DoseChipSelector Shared Widget

```
3 rows per drug:
  Frequency: [1×][2×][3×][4×][PRN]
  Duration:  [3d][5d][7d][10d][14d][30d]  (hidden if is_prn)
  Timing:    [قبل الأكل][بعد الأكل][مع الأكل]

Static options defined in core/constants — NOT fetched from DB.
```

---

## Design Tokens
See `architecture.md` → Design System section.
