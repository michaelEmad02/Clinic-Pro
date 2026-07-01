# ui.md — Patients Feature

---

## Screens

| Screen | Route | Roles |
|--------|-------|-----------|-------|
| Patients | `/patients` | All |
| Patient Details | `/patients/:id` | Owner + Doctor |

---

## Patients Screen

```
SearchBar + Filter Chips (الكل | اليوم | هذا الأسبوع | مزمن)
List items: avatar + name + phone + last visit date + (···)
(···) → تعديل | حذف | إضافة موعد
FAB → Add/Edit Patient Bottom Sheet (Node 1:1298)
```

### Add/Edit Patient Bottom Sheet

```
Fields:
  الاسم * (required)
  رقم الهاتف
  تاريخ الميلاد (date picker)
  الجنس * (required — radio: ذكر / أنثى)   ⚠️ now required per DB
  فصيلة الدم (dropdown — 8 options)
  الأمراض المزمنة (multiline text)
  الحساسية من أدوية (multiline text)
  العنوان
```

---

## Patient Details Screen

```
SliverAppBar: large avatar + name + age + blood type badge + edit button
Allergy banner (if allergies present) — Danger color, prominent

Tabs:
  المعلومات    — contact info + medical info
  الزيارات     — timeline of appointments across all owner's clinics
  الروشتات     — list of prescriptions with diagnosis text + drug count
```

---

## Design Tokens
See `architecture.md` → Design System section.
