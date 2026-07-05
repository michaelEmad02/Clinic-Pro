# ui.md — Settings (Composite Screen)

> This is a **composite feature** — it has no dedicated DB tables.
> It aggregates data from multiple features depending on the user's role.
> No `schema.md` or `business_logic.md` — refer to source features below.

---

## Source Features Used

| Section | Data From | Tables / Cache |
|---------|-----------|----------------|
| Profile (edit) | `auth/` | `users`, `Owners` |
| Current clinic | `clinics_staff/` | `clinics`, `clinic_staff` |
| Change clinic | `clinics_staff/` | `clinic_staff` + SharedPreferences |
| Queue pattern (Doctor) | `appointments_queue/` | `doctor_queue_rules` |
| Current doctor (Secretary) | `clinics_staff/` | `doctor_secretary_schedule` + SharedPreferences |
| Subscription (Owner) | `subscriptions/` | `subscriptions`, `plans`, `plans_features` |
| Appointment types (Owner) | `appointments_queue/` | `appointment_types`, `doctor_appointment_types` |
| Working hours (Owner) | `clinics_staff/` | `doctor_schedules` |

---

## 3 Screen Variants (one per role)

---

### Settings — Owner

```
AppBar: "الإعدادات"

─── Section "الحساب" ───
Card:
  [Avatar 56px]  الاسم الكامل
                 صاحب عيادة
                 [تعديل الملف الشخصي ←]

  → opens Edit Profile Bottom Sheet

  → "تغيير العيادة" opens Clinic Picker Bottom Sheet
  → "إعدادات العيادة" opens Clinic Settings Bottom Sheet

─── Section "الإدارة" ───
Card (rows with chevron):
  👥 الطاقم الطبي           ←   → navigates to /staff
  💳 الاشتراك والخطة        ←   → navigates to /settings/subscription
  🗓️ أنواع الزيارات والأسعار ←   → opens Appointment Types Bottom Sheet
  🕐 ساعات العمل            ←   → opens Working Hours Bottom Sheet

─── Section "التطبيق" ───
Card:
  🌙 الوضع الليلي    [Toggle]

─── Footer ───
  [زر تسجيل الخروج]  ← Danger color, outlined
  v1.0.0 — ClinicPro  ← caption, centered, textHint
```

---

### Settings — Doctor

```
AppBar: "الإعدادات"

─── Section "الحساب" ───
Card:
  [Avatar 56px]  الاسم الكامل
                 التخصص (specialty from users table)
                 [تعديل الملف الشخصي ←]

─── Section "العيادة الحالية" ───
Card:
  [Logo 40px]  اسم العيادة
               العنوان
  ─────────────────────────────
  تغيير العيادة             ←    (only if in > 1 clinic via clinic_staff)

─── Section "نظام قائمة الانتظار" ───
Card:
  النمط الحالي:
  [عادي][عادي][عادي][مستعجل]   ← fetched from doctor_queue_rules
  🔁 يتكرر كل N مرضى
                      [تعديل ←]

  → "تعديل" opens Queue Rule Builder Bottom Sheet
  → if no rule exists: shows "لم يتم إعداد نظام انتظار بعد" + زر إعداد

─── Section "التطبيق" ───
Card:
  🌙 الوضع الليلي    [Toggle]

─── Footer ───
  [زر تسجيل الخروج]
  v1.0.0 — ClinicPro
```

---

### Settings — Secretary

```
AppBar: "الإعدادات"

─── Section "الحساب" ───
Card:
  [Avatar 56px]  الاسم الكامل
                 سكرتير
                 [تعديل الملف الشخصي ←]

─── Section "العمل الحالي" ───
Card:
  [Logo 40px]  اسم العيادة الحالية   ← from SharedPreferences/cache
  ─────────────────────────────────
  تغيير العيادة                  ←   → Clinic Picker
  ─────────────────────────────────
  الطبيب الحالي:
  [Avatar 32px]  د. أحمد محمد        ← from SharedPreferences/cache
  تغيير الطبيب                   ←   → Doctor Picker

  Note on change behavior:
    → Change clinic: reloads doctors from doctor_secretary_schedule
      + auto-selects by time from doctor_schedules
      + updates SharedPreferences
    → Change doctor: updates SharedPreferences only (no DB write)
    → Both changes: reload Dashboard immediately

─── Section "التطبيق" ───
Card:
  🌙 الوضع الليلي    [Toggle]

─── Footer ───
  [زر تسجيل الخروج]
  v1.0.0 — ClinicPro
```

---

## Shared Bottom Sheets

---

### Edit Profile Sheet (all roles)

```
Fields:
  [Avatar 80px + camera overlay]   → image picker → Supabase Storage upload
  الاسم الكامل *
  رقم الموبايل
  التخصص (dropdown — doctors only, hidden for secretary/owner-non-doctor)

Save → UPDATE users SET name, phone, specialty, image_url WHERE id = auth.uid()
       (or UPDATE "Owners" for owner profile)
```

---

### Clinic Picker Sheet ( Doctor + Secretary)

```
List of clinics from clinic_staff WHERE user_id = me AND is_active = true
Each item: [Logo] + clinic name + role badge + active indicator

Active clinic:
  border: 1.5px solid #1A6B8A | bg: #EAF4F8
  checkmark (accent) on left (RTL)

On select:
  → update SharedPreferences: currentClinicId
  → for Secretary: re-run doctor auto-selection (doctor_secretary_schedule + doctor_schedules)
  → reload Dashboard
```

---

### Doctor Picker Sheet (Secretary only)

```
List of doctors from:
  SELECT u.name, u.specialty, u.image_url
  FROM doctor_secretary_schedule dss
  JOIN users u ON u.id = dss.doctor_id
  WHERE dss.secretary_id = me
    AND dss.clinic_id = currentClinicId
    AND dss.is_active = true

Each item: [Avatar] + doctor name + specialty + (auto-selected indicator if matches schedule)

On select:
  → update SharedPreferences: currentDoctorId
  → reload Dashboard
  → does NOT write to DB
```

---

### Clinic Settings Sheet (Owner only)

```
Fields:
  اسم العيادة *
  العنوان
  الهاتف الأول
  الهاتف الثاني (optional)
  [Logo upload]

Save → UPDATE clinics SET ... WHERE id = currentClinicId
```

---

### Appointment Types Sheet (doctor only)

```
Two sections:

① Global Types (read-only list from appointment_types):
   كشف عادي | مستعجل | إعادة كشف | استشارة | ...
   (developer-managed — shown for reference only)

② Doctor Pricing (per clinic):
   For each doctor in the clinic:
     Doctor name header
     List of their doctor_appointment_types:
       [type name] — [price] — [تعديل]
     + زر "إضافة نوع جديد للدكتور"

   Add/Edit doctor type → mini form:
     Dropdown: type (from appointment_types)
     Price field (numeric)
     Clinic scope: هذه العيادة | كل العيادات (sets clinic_id = null)
```

---

### Working Hours Sheet (doctor only)

```
For each doctor in the clinic:
  Doctor name header
  7 days toggle (Sat/Sun/Mon/Tue/Wed/Thu/Fri)
  For each active day: start_time picker + end_time picker

Save → UPSERT doctor_schedules
```

---

### Queue Rule Builder Sheet (Doctor only)

```
Drag & drop slot cards:
  عادي (normal) | مستعجل (urgent) | إعادة (revisit) | استشارة (consult)

Each card: 64×64px, colored per QueueSlotType, slot number, delete (×)
+ "أضف نوع" button

Live preview section:
  Shows mock queue with "دورة جديدة" divider at correct positions

Save → UPSERT doctor_queue_rules SET slots, cycle_length
        WHERE doctor_id = me AND clinic_id = currentClinicId
```

---

## State Management Architecture

```
lib/features/settings/
├── presentation/
│   ├── manager/
│   │   ├── settings_cubit.dart       ← loads profile + clinic + subscription data
│   │   └── settings_state.dart
│   └── ui/
│       ├── settings_screen.dart       ← renders correct variant based on role
│       └── widgets/
│           ├── owner_settings_body.dart
│           ├── doctor_settings_body.dart
│           ├── secretary_settings_body.dart
│           ├── edit_profile_sheet.dart
│           ├── clinic_picker_sheet.dart
│           ├── doctor_picker_sheet.dart        ← secretary only
│           ├── clinic_settings_sheet.dart      ← owner only
│           ├── appointment_types_sheet.dart    ← owner only
│           ├── working_hours_sheet.dart        ← owner only
│           └── queue_rule_builder_sheet.dart   ← doctor only

# No data/ or domain/ here — settings calls UseCases from:
#   auth/, clinics_staff/, appointments_queue/, subscriptions/
```

---

## What Each Role Sees (summary)

| Section | Owner | Doctor | Secretary |
|---------|-------|--------|-----------|
| Edit Profile | ✅ | ✅ | ✅ |
| Current Clinic | ❌ | ✅ | ✅ |
| Change Clinic | ❌ (if >1) | ✅ (if >1) | ✅ |
| Clinic Settings | ✅ | ❌ | ❌ |
| Staff Management | ✅ | ❌ | ❌ |
| Subscription | ✅ | ❌ | ❌ |
| Appointment Types | ❌ | ✅ | ❌ |
| Working Hours | ❌ | ✅ | ❌ |
| Queue Rule Builder | ❌ | ✅ | ❌ |
| Current Doctor | ❌ | ❌ | ✅ |
| Change Doctor | ❌ | ❌ | ✅ |
| Dark Mode Toggle | ✅ | ✅ | ✅ |
| Logout | ✅ | ✅ | ✅ |
