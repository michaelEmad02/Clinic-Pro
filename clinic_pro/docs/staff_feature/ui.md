# ui.md — Clinics & Staff Feature

---

## Screens

| Screen | Route | Roles |
|--------|-------|-----------|
| Plan Selection | `/onboarding/plan` | Owner |
| Create Clinic | `/onboarding/clinic` | Owner |
| Invite Staff | `/onboarding/invite` | Owner |
| Staff | `/staff` | Owner |
| Clinics | `/clinics` | Owner |
| Clinic Details | `/clinics/:id` | Owner |
| Settings — Owner | `/settings` | Owner |
| Settings — Doctor | `/settings` | Doctor |
| Settings — Secretary | `/settings` | Secretary |

---

## Create Clinic Screen

```
Fields: name, address, phone1, phone2 (optional), logo upload
Embedded widget: "هل أنت طبيب في هذه العيادة؟" toggle
  → if yes, shows specialty field, creates users + clinic_staff row
```

---

## Invite Staff Screen

```
Role dropdown options: دكتور | سكرتير ONLY
  ⚠️ Do not show "ممرضة" or "محاسب" — not in staff_role enum yet
Email + name + role → add to pending list → send invitations
```

---

## Staff Screen

```
Filter chips: الكل | دكتور | سكرتير
  ⚠️ No nurse/accountant filter — not available
List items: avatar + name + role badge + online status + (···)
(···) actions: تعديل الدور | تعليق الحساب | حذف
Pending invitations section with count badge
FAB → Invite Staff sheet
```

---

## Settings — 3 Role Variants

See `figma_settings_prompt.md` for full detailed specs of all 3 screens
and their shared bottom sheets (Edit Profile, Clinic Picker, Queue Rule Builder).

Quick summary:
```
Owner:     Account + Manage staff + Admin section (staff/subscription/types/hours) + Login as a doctor + Logout
Doctor:    Account + Current Clinic + Queue Pattern section + manage appointment types + Manage drugs + Manage templates + Logout
Secretary: Account + Current Clinic + Manage drugs + Manage templates + Logout
```

---

## Design Tokens
See `architecture.md` → Design System section.
