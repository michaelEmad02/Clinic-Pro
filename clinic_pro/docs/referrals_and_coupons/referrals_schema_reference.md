# 🗄️ وثيقة هيكل وتفاصيل الجداول (Database Schema Reference): نظام الإحالة والمكافآت (Referrals)

توثق هذه الصفحة مكونات الجداول، الحقول، الأنواع، والعلاقات الخاصة بنظام الإحالة ودعوة الأطباء وجوائز الأهداف (Milestones).

---

## 1. جدول الملاك / الحسابات الأساسية (`Owners / Profiles`)
يحتوي على بيانات مالك العيادة، ومضاف إليه كود الإحالة الخاص به.

| الحقل (Column) | النوع (Type) | القيود (Constraints) | الوصف والشرح |
| :--- | :--- | :--- | :--- |
| `id` | UUID | Primary Key | المعرف الفريد للمالك |
| `name` | VARCHAR | NOT NULL | اسم الطبيب / المالك |
| `email` | VARCHAR | NOT NULL, UNIQUE | البريد الإلكتروني |
| `referral_code` | VARCHAR(20) | UNIQUE | **كود الإحالة الفريد** (يتم توليده تلقائياً عبر السيرفر مثل: `DOC-7X92`) |
| `created_at` | TIMESTAMPTZ | Default NOW() | تاريخ إنشاء الحساب |

---

## 2. جدول قواعد وأهداف محطات الدعوات (`referral_milestone_rewards`)
يحدد أهداف الدعوات والمكافأة المرتبطة بكل هدف لكلا الطرفين (الداعي والمدعو).

| الحقل (Column) | النوع (Type) | القيود (Constraints) | الوصف والشرح |
| :--- | :--- | :--- | :--- |
| `id` | UUID | Primary Key | المعرف الفريد للهدف |
| `target_count` | INT | NOT NULL | **عدد الدعوات المطلوب لتحقيق الهدف** (مثل: 1، 3، 5، 10) |
| `title` | VARCHAR(100) | NOT NULL | عنوان المكافأة (مثل: *"مكافأة 5 أطباء - شهر مجاني"*) |
| `description` | TEXT | Optional | شرح وتفاصيل المكافأة |
| `referrer_reward_type` | ENUM | `discount_percent`, `free_days`, `fixed_amount` | **نوع مكافأة الداعي** عند الوصول للهدف |
| `referrer_reward_value`| DECIMAL | NOT NULL | **قيمة مكافأة الداعي** (مثلاً: 30 يوماً مجاناً أو 25% خصم) |
| `referee_reward_type`  | ENUM | `discount_percent`, `free_days`, `fixed_amount` | **نوع المكافأة الترحيبية للمدعو الجديد** |
| `referee_reward_value` | DECIMAL | NOT NULL | **قيمة المكافأة الترحيبية للمدعو** (مثلاً: 20% خصم) |
| `trigger_event`| ENUM | `'after_register'`, `'after_subscription'` | **توقيت منح المكافأة:** بعد التسجيل مباشرة أو بعد الدفع والاشتراك |
| `is_active` | BOOLEAN | Default TRUE | هل هذا التحدي مفعّل حالياً في التطبيق |
| `created_at` | TIMESTAMPTZ | Default NOW() | تاريخ إضافة القاعدة |

---

## 3. جدول سجل الإحالات بين الأطباء (`referral_redemptions`)
يسجل كل عملية دعوة تمت بين طبيب داعي وطبيب جديد مدعو، ويتابع حالة انضمامه واشتراكه.

| الحقل (Column) | النوع (Type) | القيود (Constraints) | الوصف والشرح |
| :--- | :--- | :--- | :--- |
| `id` | UUID | Primary Key | المعرف الفريد لسجل الإحالة |
| `referrer_owner_id` | UUID | FK -> `Owners.id` | معرف الطبيب صاحب الدعوة (الداعي) |
| `referee_owner_id` | UUID | FK -> `Owners.id`, UNIQUE | معرف الطبيب الجديد المنضم (كل طبيب يسجل بكود واحد فقط) |
| `referral_code` | VARCHAR(20) | NOT NULL | كود الدعوة المستخدم أثناء التسجيل |
| `status` | ENUM | `'pending'`, `'completed'`, `'cancelled'` | **حالة الدعوة:** `pending` (معلقة بانتظار الدفع) / `completed` (مكتملة ومستحقة) |
| `trigger_event` | ENUM | `'after_register'`, `'after_subscription'` | سياسة التوقيت المطبقة على هذه الدعوة |
| `referee_coupon_id`| UUID | FK -> `coupons.id` (Optional) | الكوبون الترحيبي الذي تم منحه للمدعو إن وجد |
| `created_at` | TIMESTAMPTZ | Default NOW() | تاريخ تسجيل الطبيب الجديد |
| `completed_at` | TIMESTAMPTZ | Optional | تاريخ اكتمال الدعوة واستحقاق المكافأة |

---

## 4. جدول سجل الجوائز والمحطات المكتسبة (`owner_claimed_milestones`)
سجل الأمان والتدقيق الذي يثبت استلام المالك لمكافأة هدف معين لمنع صرفها مرتين.

| الحقل (Column) | النوع (Type) | القيود (Constraints) | الوصف والشرح |
| :--- | :--- | :--- | :--- |
| `id` | UUID | Primary Key | المعرف الفريد للسجل |
| `owner_id` | UUID | FK -> `Owners.id` | معرف الطبيب الفائز بالمكافأة |
| `milestone_id` | UUID | FK -> `referral_milestone_rewards.id` | معرف الهدف الذي تم تحقيقه |
| `invites_count_at_claim` | INT | NOT NULL | عدد دعواته وقت فتح هذه المكافأة |
| `reward_applied_details` | JSONB | NOT NULL | تفاصيل ما تم منحه (نوع المكافأة، قيمتها، تاريخ الاستلام) |
| `generated_coupon_id` | UUID | FK -> `coupons.id` (Optional) | معرف الكوبون الخاص الذي تم إنشاؤه له تلقائياً (إن كانت المكافأة خصماً) |
| `claimed_at` | TIMESTAMPTZ | Default NOW() | وقت وتاريخ استلام المكافأة |
| **قيد التميز** | `UNIQUE(owner_id, milestone_id)` | Constraint | **يمنع حصول الطبيب على مكافأة نفس الهدف أكثر من مرة** |

---

## 🔗 مخطط علاقات جداول الإحالة

```text
    ┌───────────────┐
    │    Owners     │◄────────────────────────────────┐
    └───────┬───────┘                                 │
            │ 1                                       │
            ├───────────────(1 to Many)───────────────┼───────────────(1 to Many)───────────────┐
            ▼                                         ▼                                         ▼
   ┌─────────────────┐                       ┌─────────────────┐                       ┌─────────────────┐
   │     coupons     │                       │    referral_    │                       │  owner_claimed_ │
   │ (referee gift)  │                       │   redemptions   │                       │    milestones   │
   └─────────────────┘                       └─────────────────┘                       └────────┬────────┘
                                                                                                │
                                                                                                ▼ Many
                                                                                       ┌─────────────────┐
                                                                                       │    referral_    │
                                                                                       │milestone_rewards│
                                                                                       └─────────────────┘
```
