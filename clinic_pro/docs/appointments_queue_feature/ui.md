# ui.md — Appointments & Queue Feature

---

## Screens

| Screen | Route | Roles |
|--------|-------|-----------|
| Appointments | `/appointments` | All |
| Appointment Details | `/appointments/:id` | All |
| Waiting Queue | `/queue` | All |
| Add Appointment Sheet | — | All |

---

## Appointments Screen

```
Tabs: اليوم | الأسبوع | الكل
List items: time (Inter Bold) + patient + doctor + type + status badge + (···)

Urgent badge: shown if is_urgent = true (🚨 pill, warningLight bg)
Arrived indicator: green dot + "وصل" if arrived_at != null

(···) actions:
  ✅ تأكيد الوصول     — shown when arrived_at = null AND status = 'scheduled'
  🚨 تمييز كطارئ      — shown when status is not cancelled and not done
  تأكيد الكشف          — doctor only → opens Prescription screen
  تعديل الموعد        — shown when status is not done, not in_progress, and not cancelled
  إلغاء الموعد        — shown when status is not done and not cancelled
  حذف الموعد نهائياً   — shown when status is cancelled
  تسجيل فاتورة        — shown when status is not cancelled and not done
  عرض التفاصيل

FAB → Add Appointment Sheet

Urgent indicator: Shows 🚨 emoji badge next to items if is_urgent = true

```

### Add Appointment Sheet

```
Patient autocomplete + doctor dropdown + date/time pickers
Visit type dropdown:
  → fetches from doctor_appointment_types WHERE doctor_id = selected_doctor
    filtered by current clinic_id first, fallback to clinic_id IS NULL
  → shows: type name (from appointment_types.name) + price (from doctor_appointment_types.price)
  → if doctor has no configured types: show "لم يتم إعداد أنواع الزيارات لهذا الطبيب"
Notes field
Urgent toggle: "حالة طارئة 🚨" at bottom before save button
```

---

## Appointment Details Screen

```
Status Timeline (4 steps): حُجز → وصل → داخل → منتهي
  Step 2 (وصل) uses arrived_at timestamp
  Step 3 (داخل) uses called_at timestamp

Urgent banner shown above data card if is_urgent = true
Linked prescription card (if exists)
Linked invoice card (if exists)
Actions: تعديل | إلغاء
```

---

## Waiting Queue Screen

```
Realtime indicator (pulse dot) in AppBar
Pattern indicator row below AppBar: shows active doctor_queue_rules.slots as chips

Sections (in display order):
  🚨 Urgent section (if any waiting urgent patients)
  Fixed entries (done/in_progress) — dimmed/highlighted per status
  Waiting entries — sorted per QueueSorter algorithm
  🔁 "دورة جديدة" divider between pattern cycles

Each queue item: number + avatar + name + visit type badge + (···)
  (···) → تمييز كطارئ (if not already urgent)

Bottom: "استدعاء التالي →" button — fixed, full-width, primary
  → sets called_at, status='in_progress' on next waiting entry
```

---

## Settings — Queue Rule Builder (Doctor only)

```
Drag & drop slot builder in Settings screen (Doctor only):
- Add/remove/reorder slot types: عادي | مستعجل | إعادة | استشارة
- Live preview of resulting queue order
- Cycle divider shown in preview between each full pattern repetition
- Saves to doctor_queue_rules table
```
