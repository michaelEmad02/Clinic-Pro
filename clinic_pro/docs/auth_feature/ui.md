# ui.md — Auth Feature

---

## Screens

| Screen | Route | Roles |
|--------|-------|-----------|
| Splash | `/splash` | All |
| Login | `/login` | All |
| Create Account | `/register` | Owner |
| Accept Invitation | `/join/:token` | All |

---

## Splash Screen

```
- App logo (centered)
- App name "ClinicPro" — Cairo Bold
- Tagline "نظام إدارة العيادات الذكي" — Cairo Regular
- Auto-redirect after session check (no user interaction)
```

---

## Login Screen

```
- Logo (top)
- "أهلاً بك" heading
- Subtitle: "سجل الدخول للوصول إلى لوحة تحكم عيادتك المتقدمة"
- Button: "المتابعة باستخدام Google" — Primary full-width
- Button: "المتابعة باستخدام Apple" — Outlined full-width
- Divider "أو"
- Email input + "إرسال رابط الدخول" button (Magic Link)
- Link: "صاحب عيادة جديد؟ أنشئ حساباً ←"
```

---

## Create Account Screen

```
Form fields (all required — match Owners table NOT NULL constraints):
  - الاسم الكامل (name)
  - رقم الموبايل (phone)
  - الدولة (country) — dropdown or text
  - العنوان (address)

- Google / Apple Sign Up buttons
- Terms checkbox
- Note: "أعضاء الفريق يُضافون عبر الدعوة فقط"
```

---

## Accept Invitation Screen

```
- Clinic logo + name (fetched via invitation token)
- Role badge: "دُعيت كـ [دكتور/سكرتير]"
- Accept button (Google/Apple)
- Reject button (text)
- Expired state: "انتهت صلاحية الدعوة" banner
```

---

## Design Tokens
See `architecture.md` → Design System section for colors, typography, spacing.
