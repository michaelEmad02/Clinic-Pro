/* ==============================================================================
   🔒 Clinic Pro: Zero-Trust Authorization & Subscription Security Layer (RLS)
   ==============================================================================
   - Database: Supabase PostgreSQL
   - Security Model: Zero-Client-Trust
   - Features:
     1. Multi-Tenant Isolation (Clinic & Owner Scoping)
     2. Subscription Validation (Blocks write actions if subscription expired/inactive)
     3. Strict Role-Based Data Isolation (e.g. Doctors cannot view other doctors' prescriptions)
     4. High-Performance Execution using STABLE Security Definer Functions & Targeted Indexes
   ============================================================================== */

-- ─────────────────────────────────────────────────────────────────────────────
-- 0️⃣ تنظيف وحذف كافة السياسات القديمة على الجداول الثمانية منعاً للتعارض
-- (Automated Cleanup of all old policies to prevent permissive OR conditions)
-- ─────────────────────────────────────────────────────────────────────────────

DO $$
DECLARE
  pol RECORD;
BEGIN
  FOR pol IN 
    SELECT schemaname, tablename, policyname 
    FROM pg_policies 
    WHERE schemaname = 'public' 
      AND tablename IN ('Owners', 'users', 'clinic_staff', 'doctor_secretary_schedule', 'appointments', 'prescriptions', 'invoices', 'expenses')
  LOOP
    EXECUTE format('DROP POLICY IF EXISTS %I ON %I.%I;', pol.policyname, pol.schemaname, pol.tablename);
    RAISE NOTICE 'Dropped old policy % on table %', pol.policyname, pol.tablename;
  END LOOP;
END $$;


-- ─────────────────────────────────────────────────────────────────────────────
-- 1️⃣ الفهارس المستهدفة لضمان سرعة فائقة للـ RLS (Performance Indexes)
-- ─────────────────────────────────────────────────────────────────────────────

CREATE INDEX IF NOT EXISTS idx_clinics_owner_id 
  ON public.clinics(owner_id);

CREATE INDEX IF NOT EXISTS idx_clinic_staff_user_clinic 
  ON public.clinic_staff(user_id, clinic_id, is_active);

CREATE INDEX IF NOT EXISTS idx_subscriptions_owner_status 
  ON public.subscriptions(owner_id, status, end_at);

CREATE INDEX IF NOT EXISTS idx_users_owner_id 
  ON public.users(owner_id);

CREATE INDEX IF NOT EXISTS idx_appointments_clinic_doc 
  ON public.appointments(clinic_id, doctor_id);

CREATE INDEX IF NOT EXISTS idx_prescriptions_clinic_doc 
  ON public.prescriptions(clinic_id, doctor_id);

CREATE INDEX IF NOT EXISTS idx_invoices_clinic_doc 
  ON public.invoices(clinic_id, doctor_id);

CREATE INDEX IF NOT EXISTS idx_expenses_clinic_doc 
  ON public.expenses(clinic_id, doctor_id);

CREATE INDEX IF NOT EXISTS idx_doc_sec_sched_lookup 
  ON public.doctor_secretary_schedule(clinic_id, doctor_id, secretary_id, is_active);


-- ─────────────────────────────────────────────────────────────────────────────
-- 2️⃣ الدوال المركزية للتحقق الأمني (Centralized Helper Functions)
-- تم ضبطها بـ STABLE لتخزين النتيجة مؤقتاً أثناء الاستعلام ومنع الـ N+1 Queries
-- ─────────────────────────────────────────────────────────────────────────────

-- أ. استخراج معرّف المالك (owner_id) للمستخدم الحالي
CREATE OR REPLACE FUNCTION public.get_user_owner_id()
RETURNS UUID AS $$
DECLARE
  v_owner_id UUID;
BEGIN
  -- التحقق من تسجيل الدخول أولاً
  IF auth.uid() IS NULL THEN
    RETURN NULL;
  END IF;

  -- 1. فحص ما إذا كان المستخدم الحالي مالكاً في جدول "Owners"
  IF EXISTS (SELECT 1 FROM public."Owners" WHERE id = auth.uid()) THEN
    RETURN auth.uid();
  END IF;

  -- 2. إذا كان موظفاً (طبيب/سكرتير)، جلب المالك من جدول users
  SELECT owner_id INTO v_owner_id 
  FROM public.users 
  WHERE id = auth.uid() 
  LIMIT 1;

  IF v_owner_id IS NOT NULL THEN
    RETURN v_owner_id;
  END IF;

  -- 3. في حال عدم وجوده بـ users، جلبه عبر عيادات clinic_staff
  SELECT c.owner_id INTO v_owner_id
  FROM public.clinic_staff cs
  JOIN public.clinics c ON c.id = cs.clinic_id
  WHERE cs.user_id = auth.uid() AND cs.is_active = TRUE
  LIMIT 1;

  RETURN v_owner_id;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;


-- ب. التحقق من انتماء المستخدم للعيادة (سواء كان المالك أو موظفاً نشطاً بها)
CREATE OR REPLACE FUNCTION public.is_clinic_member(p_clinic_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  -- التحقق الصريح من وجود عيادة ومستخدم مسجل دخول
  IF p_clinic_id IS NULL OR auth.uid() IS NULL THEN
    RETURN FALSE;
  END IF;

  RETURN EXISTS (
    SELECT 1 FROM public.clinics c
    WHERE c.id = p_clinic_id
      AND (
        c.owner_id = auth.uid()
        OR EXISTS (
          SELECT 1 FROM public.clinic_staff cs
          WHERE cs.clinic_id = p_clinic_id
            AND cs.user_id = auth.uid()
            AND cs.is_active = TRUE
        )
      )
  );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;


-- ج. التحقق مما إذا كان المستخدم هو المالك المباشر للعيادة
CREATE OR REPLACE FUNCTION public.is_clinic_owner(p_clinic_id UUID)
RETURNS BOOLEAN AS $$
BEGIN
  IF p_clinic_id IS NULL OR auth.uid() IS NULL THEN
    RETURN FALSE;
  END IF;

  RETURN EXISTS (
    SELECT 1 FROM public.clinics c
    WHERE c.id = p_clinic_id AND c.owner_id = auth.uid()
  );
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;


-- د. التحقق من سريان اشتراك مالك العيادة ورمي استثناء واضح عند انتهائه (Active Subscription Check with Explicit Exceptions)
CREATE OR REPLACE FUNCTION public.has_active_clinic_subscription(p_clinic_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  v_owner_id UUID;
  v_sub_status text;
  v_sub_end TIMESTAMPTZ;
BEGIN
  IF p_clinic_id IS NULL OR auth.uid() IS NULL THEN
    RETURN FALSE;
  END IF;

  SELECT owner_id INTO v_owner_id FROM public.clinics WHERE id = p_clinic_id;
  IF v_owner_id IS NULL THEN
    RETURN FALSE;
  END IF;

  -- فحص حالة آخر اشتراك لمالك هذه العيادة
  SELECT status::text, end_at INTO v_sub_status, v_sub_end
  FROM public.subscriptions
  WHERE owner_id = v_owner_id
  ORDER BY created_at DESC
  LIMIT 1;

  -- 1. في حال عدم وجود أي اشتراك مسجل
  IF v_sub_status IS NULL THEN
    RAISE EXCEPTION 'NO_SUBSCRIPTION: لا يوجد اشتراك مسجل لهذه العيادة | No active subscription registered for this clinic' USING ERRCODE = '40301';
  END IF;

  -- 2. في حال كان الاشتراك منتهياً أو معلقاً أو غير نشط
  IF v_sub_status != 'active' OR (v_sub_end IS NOT NULL AND v_sub_end <= now()) THEN
    RAISE EXCEPTION 'SUBSCRIPTION_EXPIRED: انتهت صلاحية الاشتراك  يرجى التجديد للمتابعة | subscription has expired, please renew to continue' USING ERRCODE = '40302';
  END IF;

  RETURN TRUE;
END;
$$ LANGUAGE plpgsql STABLE SECURITY DEFINER SET search_path = public;


-- ─────────────────────────────────────────────────────────────────────────────
-- 3️⃣ تطبيق سياسات RLS على الجداول الثمانية (Row Level Security Policies)
-- ─────────────────────────────────────────────────────────────────────────────

-- =============================================================================
-- [1] جدول الملاك: "Owners"
-- =============================================================================
ALTER TABLE public."Owners" ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "owners_select_policy" ON public."Owners";
CREATE POLICY "owners_select_policy" ON public."Owners"
FOR SELECT TO authenticated
USING (
  id = auth.uid()
  OR EXISTS (
    SELECT 1 FROM public.users u 
    WHERE u.id = auth.uid() AND u.owner_id = "Owners".id
  )
);

DROP POLICY IF EXISTS "owners_insert_policy" ON public."Owners";
CREATE POLICY "owners_insert_policy" ON public."Owners"
FOR INSERT TO authenticated
WITH CHECK (
  id = auth.uid()
);

DROP POLICY IF EXISTS "owners_update_policy" ON public."Owners";
CREATE POLICY "owners_update_policy" ON public."Owners"
FOR UPDATE TO authenticated
USING (
  id = auth.uid()
) WITH CHECK (
  id = auth.uid()
);

DROP POLICY IF EXISTS "owners_delete_policy" ON public."Owners";
CREATE POLICY "owners_delete_policy" ON public."Owners"
FOR DELETE TO authenticated
USING (
  id = auth.uid()
);


-- =============================================================================
-- [2] جدول الموظفين (الأطباء والسكرتارية): users
-- =============================================================================
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "users_select_policy" ON public.users;
CREATE POLICY "users_select_policy" ON public.users
FOR SELECT TO authenticated
USING (
  id = auth.uid()
  OR owner_id = auth.uid()
  OR owner_id = public.get_user_owner_id()
);

DROP POLICY IF EXISTS "users_insert_policy" ON public.users;
CREATE POLICY "users_insert_policy" ON public.users
FOR INSERT TO authenticated
WITH CHECK (
  id = auth.uid()
  OR owner_id = auth.uid()
);

DROP POLICY IF EXISTS "users_update_policy" ON public.users;
CREATE POLICY "users_update_policy" ON public.users
FOR UPDATE TO authenticated
USING (
  id = auth.uid()
  OR owner_id = auth.uid()
) WITH CHECK (
  id = auth.uid()
  OR owner_id = auth.uid()
);

DROP POLICY IF EXISTS "users_delete_policy" ON public.users;
CREATE POLICY "users_delete_policy" ON public.users
FOR DELETE TO authenticated
USING (
  owner_id = auth.uid()
);


-- =============================================================================
-- [3] جدول ارتباط الموظفين بالعيادات: clinic_staff
-- =============================================================================
ALTER TABLE public.clinic_staff ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "clinic_staff_select_policy" ON public.clinic_staff;
CREATE POLICY "clinic_staff_select_policy" ON public.clinic_staff
FOR SELECT TO authenticated
USING (
  user_id = auth.uid()
  OR public.is_clinic_member(clinic_id)
);

DROP POLICY IF EXISTS "clinic_staff_insert_policy" ON public.clinic_staff;
CREATE POLICY "clinic_staff_insert_policy" ON public.clinic_staff
FOR INSERT TO authenticated
WITH CHECK (
  public.is_clinic_owner(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "clinic_staff_update_policy" ON public.clinic_staff;
CREATE POLICY "clinic_staff_update_policy" ON public.clinic_staff
FOR UPDATE TO authenticated
USING (
  public.is_clinic_owner(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "clinic_staff_delete_policy" ON public.clinic_staff;
CREATE POLICY "clinic_staff_delete_policy" ON public.clinic_staff
FOR DELETE TO authenticated
USING (
  public.is_clinic_owner(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);


-- =============================================================================
-- [4] جدول جدول مواعيد السكرتير مع الطبيب: doctor_secretary_schedule
-- =============================================================================
ALTER TABLE public.doctor_secretary_schedule ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "doc_sec_sched_select_policy" ON public.doctor_secretary_schedule;
CREATE POLICY "doc_sec_sched_select_policy" ON public.doctor_secretary_schedule
FOR SELECT TO authenticated
USING (
  doctor_id = auth.uid()
  OR secretary_id = auth.uid()
  OR public.is_clinic_member(clinic_id)
);

DROP POLICY IF EXISTS "doc_sec_sched_insert_policy" ON public.doctor_secretary_schedule;
CREATE POLICY "doc_sec_sched_insert_policy" ON public.doctor_secretary_schedule
FOR INSERT TO authenticated
WITH CHECK (
  public.is_clinic_owner(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "doc_sec_sched_update_policy" ON public.doctor_secretary_schedule;
CREATE POLICY "doc_sec_sched_update_policy" ON public.doctor_secretary_schedule
FOR UPDATE TO authenticated
USING (
  public.is_clinic_owner(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "doc_sec_sched_delete_policy" ON public.doctor_secretary_schedule;
CREATE POLICY "doc_sec_sched_delete_policy" ON public.doctor_secretary_schedule
FOR DELETE TO authenticated
USING (
  public.is_clinic_owner(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);


-- =============================================================================
-- [5] جدول الحجوزات والمواعيد: appointments
-- =============================================================================
ALTER TABLE public.appointments ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "appointments_select_policy" ON public.appointments;
CREATE POLICY "appointments_select_policy" ON public.appointments
FOR SELECT TO authenticated
USING (
  public.is_clinic_member(clinic_id)
);

DROP POLICY IF EXISTS "appointments_insert_policy" ON public.appointments;
CREATE POLICY "appointments_insert_policy" ON public.appointments
FOR INSERT TO authenticated
WITH CHECK (
  public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "appointments_update_policy" ON public.appointments;
CREATE POLICY "appointments_update_policy" ON public.appointments
FOR UPDATE TO authenticated
USING (
  public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "appointments_delete_policy" ON public.appointments;
CREATE POLICY "appointments_delete_policy" ON public.appointments
FOR DELETE TO authenticated
USING (
  public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);


-- =============================================================================
-- [6] جدول الروشتات: prescriptions
-- 🔒 تطبيق العزل الصارم: الطبيب يرى فقط روشتاته الشخصية (doctor_id = auth.uid())
-- =============================================================================
ALTER TABLE public.prescriptions ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "prescriptions_select_policy" ON public.prescriptions;
CREATE POLICY "prescriptions_select_policy" ON public.prescriptions
FOR SELECT TO authenticated
USING (
  -- الطبيب يرى فقط روشتاته الخاصة
  doctor_id = auth.uid()
  -- المالك يرى روشتات عياداته للمتابعة والتدقيق
  OR public.is_clinic_owner(clinic_id)
  -- السكرتير المربوط بهذا الطبيب فقط في نفس العيادة (للطباعة أو المساعدة)
  OR (
    public.is_clinic_member(clinic_id)
    AND EXISTS (
      SELECT 1 FROM public.doctor_secretary_schedule dss
      WHERE dss.doctor_id = prescriptions.doctor_id
        AND dss.secretary_id = auth.uid()
        AND dss.clinic_id = prescriptions.clinic_id
        AND dss.is_active = TRUE
    )
  )
);

DROP POLICY IF EXISTS "prescriptions_insert_policy" ON public.prescriptions;
CREATE POLICY "prescriptions_insert_policy" ON public.prescriptions
FOR INSERT TO authenticated
WITH CHECK (
  (doctor_id = auth.uid() OR public.is_clinic_owner(clinic_id))
  AND public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "prescriptions_update_policy" ON public.prescriptions;
CREATE POLICY "prescriptions_update_policy" ON public.prescriptions
FOR UPDATE TO authenticated
USING (
  (doctor_id = auth.uid() OR public.is_clinic_owner(clinic_id))
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "prescriptions_delete_policy" ON public.prescriptions;
CREATE POLICY "prescriptions_delete_policy" ON public.prescriptions
FOR DELETE TO authenticated
USING (
  (doctor_id = auth.uid() OR public.is_clinic_owner(clinic_id))
  AND public.has_active_clinic_subscription(clinic_id)
);


-- =============================================================================
-- [7] جدول الفواتير: invoices
-- =============================================================================
ALTER TABLE public.invoices ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "invoices_select_policy" ON public.invoices;
CREATE POLICY "invoices_select_policy" ON public.invoices
FOR SELECT TO authenticated
USING (
  public.is_clinic_member(clinic_id)
);

DROP POLICY IF EXISTS "invoices_insert_policy" ON public.invoices;
CREATE POLICY "invoices_insert_policy" ON public.invoices
FOR INSERT TO authenticated
WITH CHECK (
  public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "invoices_update_policy" ON public.invoices;
CREATE POLICY "invoices_update_policy" ON public.invoices
FOR UPDATE TO authenticated
USING (
  public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "invoices_delete_policy" ON public.invoices;
CREATE POLICY "invoices_delete_policy" ON public.invoices
FOR DELETE TO authenticated
USING (
  public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);


-- =============================================================================
-- [8] جدول المصروفات: expenses
-- =============================================================================
ALTER TABLE public.expenses ENABLE ROW LEVEL SECURITY;

DROP POLICY IF EXISTS "expenses_select_policy" ON public.expenses;
CREATE POLICY "expenses_select_policy" ON public.expenses
FOR SELECT TO authenticated
USING (
  public.is_clinic_owner(clinic_id)
  OR (
    public.is_clinic_member(clinic_id)
   -- AND (doctor_id IS NULL OR doctor_id = auth.uid())
    AND (doctor_id = auth.uid())
  )
);

DROP POLICY IF EXISTS "expenses_insert_policy" ON public.expenses;
CREATE POLICY "expenses_insert_policy" ON public.expenses
FOR INSERT TO authenticated
WITH CHECK (
  public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "expenses_update_policy" ON public.expenses;
CREATE POLICY "expenses_update_policy" ON public.expenses
FOR UPDATE TO authenticated
USING (
  public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);

DROP POLICY IF EXISTS "expenses_delete_policy" ON public.expenses;
CREATE POLICY "expenses_delete_policy" ON public.expenses
FOR DELETE TO authenticated
USING (
  public.is_clinic_member(clinic_id)
  AND public.has_active_clinic_subscription(clinic_id)
);


-- ─────────────────────────────────────────────────────────────────────────────
-- 4️⃣ حماية دوال الـ RPC من تجاوز الصلاحيات (RPC Hardening)
-- دالة get_all_prescriptions_rpc: إذا كان المستدعي طبيباً، يتم تقييده بروشتاته فقط
-- ─────────────────────────────────────────────────────────────────────────────

CREATE OR REPLACE FUNCTION public.get_all_prescriptions_rpc(
  p_clinic_id uuid DEFAULT NULL,
  p_doctor_id uuid DEFAULT NULL,
  p_patient_id uuid DEFAULT NULL,
  p_limit int DEFAULT 200,
  p_offset int DEFAULT 0
) RETURNS jsonb AS $$
DECLARE
  v_effective_doctor_id uuid := p_doctor_id;
  v_is_doctor boolean := false;
  v_result jsonb := '[]'::jsonb;
BEGIN
  -- التحقق مما إذا كان المستخدم الحالي طبيباً
  SELECT EXISTS (
    SELECT 1 FROM public.clinic_staff 
    WHERE user_id = auth.uid() AND role = 'doctor'
  ) INTO v_is_doctor;

  -- إذا كان المستدعي طبيباً، يتم إجباره فقط على رؤية روشتاته الشخصية لمنع أي اختراق
  IF v_is_doctor THEN
    v_effective_doctor_id := auth.uid();
  END IF;

  SELECT COALESCE(jsonb_agg(
    jsonb_build_object(
      'id', sub.id,
      'created_at', sub.created_at,
      'clinic_id', sub.clinic_id,
      'doctor_id', sub.doctor_id,
      'patient_id', sub.patient_id,
      'appointment_id', sub.appointment_id,
      'diagnosis', sub.diagnosis,
      'notes', sub.notes,
      'next_visit_days', sub.next_visit_days,
      'patients', (
        SELECT jsonb_build_object(
          'id', pt.id,
          'name', pt.name,
          'phone', pt.phone,
          'gender', pt.gender,
          'date_of_birth', pt.date_of_birth
        )
        FROM patients pt
        WHERE pt.id = sub.patient_id
      ),
      'prescription_items', COALESCE((
        SELECT jsonb_agg(
          jsonb_build_object(
            'id', pi.id,
            'prescription_id', pi.prescription_id,
            'drug_id', pi.drug_id,
            'frequency', pi.frequency,
            'duration', pi.duration,
            'timing', pi.timing,
            'is_prn', COALESCE(pi.is_prn, false),
            'drug', (
              SELECT jsonb_build_object(
                'id', d.id,
                'trade_name', d.trade_name,
                'generic_name', d.generic_name,
                'category', d.category
              )
              FROM drugs d
              WHERE d.id = pi.drug_id
            )
          )
        )
        FROM prescription_items pi
        WHERE pi.prescription_id = sub.id
      ), '[]'::jsonb)
    )
  ), '[]'::jsonb)
  INTO v_result
  FROM (
    SELECT p.*
    FROM prescriptions p
    WHERE (p_clinic_id IS NULL OR p.clinic_id = p_clinic_id)
      AND (v_effective_doctor_id IS NULL OR p.doctor_id = v_effective_doctor_id)
      AND (p_patient_id IS NULL OR p.patient_id = p_patient_id)
      AND public.is_clinic_member(p.clinic_id)
    ORDER BY p.created_at DESC
    LIMIT p_limit OFFSET p_offset
  ) sub;

  RETURN v_result;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;
