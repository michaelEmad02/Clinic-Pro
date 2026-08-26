# 🗄️ وثيقة هيكل وتفاصيل الجداول (Database Schema Reference): نظام الكوبونات والخصومات (Coupons)

توثق هذه الصفحة مكونات الجداول، الحقول، الأنواع، والعلاقات الخاصة بنظام الكوبونات والخصومات.

---

## 1. جدول الكوبونات (`coupons`)
الجدول المركزي لجميع الكوبونات والخصومات (سواء كانت كوبونات عامة للحملات التسويقية، أو كوبونات خاصة ممنوحة كمكافأة إحالة لطبيب معين).

| الحقل (Column) | النوع (Type) | القيود (Constraints) | الوصف والشرح |
| :--- | :--- | :--- | :--- |
| `id` | UUID | Primary Key | المعرف الفريد للكوبون |
| `code` | TEXT | UNIQUE, NOT NULL | كود الكوبون (مثل: `SUMMER2026` أو `REF-DOC-4A2B`) |
| `scope` | ENUM | `'public'`, `'private'` | **نطاق الكوبون:** `public` (عام لجميع الأطباء) أو `private` (مخصص لطبيب معين) |
| `owner_id` | UUID | FK -> `Owners.id` (Optional) | معرف الطبيب المستفيد إذا كان الكوبون خاصاً (`private`) |
| `reword_type` | ENUM | `discount_percent`, `fixed_amount`, `free_days`, `free_month` | **نوع الخصم/المكافأة** |
| `value` | DECIMAL | NOT NULL | **قيمة الخصم** (مثلاً: `20` أي 20%، أو `150` ج.م، أو `30` يوماً) |
| `max_uses` | INT | Optional (NULL = Unlimited) | أقصى عدد لاستخدام الكوبون إجمالياً |
| `used_count` | INT | Default 0 | عدد مرات استخدام الكوبون الفعلية |
| `valid_from` | TIMESTAMPTZ | Default NOW() | تاريخ بداية تفعيل الكوبون |
| `valid_until` | TIMESTAMPTZ | Optional (NULL = No Expiry) | تاريخ انتهاء صلاحية الكوبون |
| `plan_id` | TEXT[] | Optional (NULL = All Plans) | مصفوفة بمعرفات الباقات المطبق عليها الكوبون |
| `is_active` | BOOLEAN | Default TRUE | هل الكوبون مفعّل حالياً أم موقوف |
| `description` | TEXT | Optional | وصف الكوبون المعروض للطبيب في الواجهة |
| `created_at` | TIMESTAMPTZ | Default NOW() | تاريخ إنشاء الكوبون |

---

## 2. جدول استخدامات الكوبونات (`coupon_redemptions`)
سجل تاريخي يوثق كل عملية استخدام وتطبيق لكوبون من قبل طبيب معين لمنع التلاعب والتكرار.

| الحقل (Column) | النوع (Type) | القيود (Constraints) | الوصف والشرح |
| :--- | :--- | :--- | :--- |
| `id` | UUID | Primary Key | المعرف الفريد للعملية |
| `coupon_id` | UUID | FK -> `coupons.id` | معرف الكوبون المستخدم |
| `owner_id` | UUID | FK -> `Owners.id` | معرف الطبيب الذي استخدم الكوبون |
| `applied_at` | TIMESTAMPTZ | Default NOW() | تاريخ ووقت تطبيق الخصم |
| `discount_amount`| DECIMAL | NOT NULL | **المبلغ الفعلي الذي تم توفيره بالجنيه** |
| `transaction_id` | UUID | Optional | معرف المعاملة البنكية المرتبطة بالعملية |
| **قيد التميز** | `UNIQUE(coupon_id, owner_id)` | Constraint | **يضمن أن كل طبيب يستخدم الكوبون مرة واحدة فقط** |

---

## 🔗 مخطط علاقات جداول الكوبونات

```text
    ┌───────────────┐
    │    Owners     │
    └───────┬───────┘
            │ 1
            ├───────────────(1 to Many)───────────────┐
            ▼                                         ▼
   ┌─────────────────┐                       ┌─────────────────┐
   │     coupons     │1                     *│     coupon_     │
   │ (public/private)├──────────────────────►│   redemptions   │
   └─────────────────┘                       └─────────────────┘
```
