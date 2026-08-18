-- ────────────────────────────────────────────────────────
-- تفعيل البث المباشر (Supabase Realtime Replication) لجدول المواعيد
-- قم بتشغيل هذا النص في SQL Editor داخل لوحة تحكم Supabase
-- ────────────────────────────────────────────────────────

-- 1. إضافة جدول المواعيد إلى الـ Publication الخاص بالـ Realtime
ALTER PUBLICATION supabase_realtime ADD TABLE appointments;

-- 2. إتاحة البث لجدول المرضى والعيادات (اختياري)
ALTER PUBLICATION supabase_realtime ADD TABLE patients;
ALTER PUBLICATION supabase_realtime ADD TABLE clinics;
