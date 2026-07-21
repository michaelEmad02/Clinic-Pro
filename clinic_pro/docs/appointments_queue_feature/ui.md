# ui.md — Appointments & Queue Feature

---

## Screens

| Screen | Route | Roles |
|--------|-------|-------|
| Appointments | `/appointments` | All |
| Appointment Details | `/appointments/:id` | All |
| Waiting Queue | `/queue` | All |

---

## Appointments Screen

```
Tabs: اليوم | الأسبوع | الكل

List items (AppListItem):
  وقت الموعد (Inter Bold) + اسم المريض + نوع الزيارة + Status Badge + (···)
  لو is_urgent = true → 🚨 badge بجانب الاسم
  لو arrived_at != null → نقطة خضراء + "وصل"

(···) Action Sheet:
  ✅ تأكيد الوصول   — يظهر لو arrived_at = null AND status = 'scheduled'
  🚨 تمييز كطارئ    — يظهر لو is_urgent = false
  تأكيد الكشف       — للدكتور فقط → يفتح Prescription Screen
  تعديل الموعد
  إلغاء الموعد
  عرض التفاصيل

FAB → Add Appointment Bottom Sheet
```

### Add Appointment Bottom Sheet

```
- Patient autocomplete
- Doctor dropdown
- Date + Time pickers
- Visit type dropdown:
    fetches doctor_appointment_types WHERE doctor_id = selected AND clinic_id = current
    fallback to clinic_id IS NULL if no clinic-specific entry
    shows: type name + price
- Notes field
- Urgent toggle: "حالة طارئة 🚨" (sets is_urgent = true)
```

---

## Appointment Details Screen

```
Status Timeline (4 steps):
  حُجز (created_at) → وصل (arrived_at) → داخل (called_at) → منتهي

Urgent banner (if is_urgent = true):
  bg: #FEF3C7 | border: #F5A623 | icon: 🚨 | text: "حالة طارئة — أولوية قصوى"

Sections:
  بيانات الموعد: مريض + دكتور + نوع + سعر متوقع + وقت
  الروشتة المرتبطة (if prescription exists)
  الفاتورة المرتبطة (if invoice exists)

Actions: تعديل | إلغاء
```

---

## Waiting Queue Screen

```
AppBar: "قائمة الانتظار" + Realtime pulse dot (accent color)

Row تحت الـ AppBar — يختلف حسب queue_system:

  arrival / booking:
    "الترتيب: حسب [الحضور / وقت الحجز]" — caption, textSecondary

  pattern:
    "النمط: [عادي][عادي][عادي][مستعجل] 🔁" — chips

  scheduled:
    "متوسط الكشف: X دقيقة" — caption, textSecondary

───────────────────────────────────────────

Queue List:

  [URGENT SECTION — if any is_urgent patients]
  Card بخلفية #FEF3C7 + right border 4px #F5A623 (RTL: left)

  [FIXED entries — done/in_progress]
  مُعتمة — لا أكشن

  [WAITING entries — sorted per QueueSorter]
  كل item:
    رقم الدور + Avatar + اسم المريض + نوع الزيارة badge + (···)

    [queue_system = 'scheduled' فقط]
    الوقت المتوقع: 10:30 ص (Inter Bold, textSecondary)

    in_progress item:
      right border 4px #1A6B8A | bg: #EAF4F8
      badge: "داخل الآن"

    [pattern فقط]
    "دورة جديدة" divider بين كل cycle

  (···) → "تمييز كطارئ" (لو is_urgent = false)

───────────────────────────────────────────

Bottom (fixed):
  [استدعاء التالي →]
  Primary, full-width, height 52px
  → sets called_at + status = 'in_progress' on next confirmed entry
```

---

## Settings — Queue System Section (Doctor only)

```
Section "نظام قائمة الانتظار":

  نوع النظام (Radio buttons):
  ● ترتيب الحضور     — الأبسط، مين وصل أول يدخل أول
  ○ ترتيب الحجز      — حسب وقت الموعد المحجوز
  ○ نمط مخصص        — الدكتور يبني نمطه الخاص
  ○ مواعيد بوقت محدد — كل مريض له وقت متوقع

  [لو اختار "نمط مخصص"]
  → يظهر Queue Rule Builder (drag & drop slots)
    Slot types: عادي | مستعجل | إعادة | استشارة

  [لو اختار "مواعيد بوقت محدد"]
  → يظهر:
    متوسط وقت الزيارة:
    ┌──────────────────┐
    │  15          دقيقة│
    └──────────────────┘

Save → UPSERT doctor_queue_rules:
  queue_system = selected
  slots / cycle_length → only if pattern
  avg_visit_minutes   → only if scheduled
  (other fields set to null)
```

### Queue Rule Builder (pattern only)

```
Drag & drop slot cards (64×64px each):
  عادي:    bg #EAF4F8, border #1A6B8A
  مستعجل:  bg #FEF3C7, border #F5A623
  إعادة:   bg #EAF3DE, border #3B6D11
  استشارة: bg #F7F9FC, border #E2E8F0

[+ أضف نوع] button

Live preview:
  Shows mock patients sorted by the current pattern
  "دورة جديدة" divider at correct positions

Save → sets queue_system = 'pattern' + slots + cycle_length
```

---

## Queue Item States (visual)

| الحالة | المظهر |
|--------|--------|
| done | معتم، لا أكشن |
| in_progress | right border primary + bg primaryLight + badge "داخل الآن" |
| is_urgent + waiting | right border warning + bg warningLight + 🚨 badge |
| normal waiting | white bg، badge بنوع الزيارة |
| scheduled system | + وقت متوقع أسفل الاسم |
