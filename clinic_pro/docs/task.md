# 📋 Prescription Feature — خطة الإصلاح

---

## Task 1: إنشاء Enums/Constants للوصفات (DrugFrequency, DrugDuration, DrugTiming)
- إنشاء `prescription_enums.dart` في `core/constants/`
- 3 enums بنفس نمط StaffRoles (مع `label` عربي و `dbValue` للقاعدة)
- تحديث `MockData` لاستخدام القيم الصحيحة من Schema (أسماء الحقول + أنواع البيانات)
- إضافة `prescription_items` لـ `_getTableData` في MockCloudService

## Task 2: إصلاح TemplatesCubit + DrugsCubit → ICloudService + DI
- تحويل TemplatesCubit ليستخدم ICloudService بدل MockData المباشر
- تحويل DrugsCubit ليستخدم ICloudService بدل MockData المباشر
- إضافة `@injectable` وحقن ICloudService عبر constructor

## Task 3: إصلاح PrescriptionBloc (field names, hardcoded, validations, simulation) [COMPLETED]
- تصحيح أسماء الحقول (frequency→int, duration→int, timing→enum, name بدل title, user_count)
- إضافة clinic_id + إزالة القيم الثابتة (doctor_id, patient_id, visitDate)
- إضافة Validations قبل الحفظ
- إصلاح بناء diagnosis النهائي
- تحديث user_count عند الحفظ
- إصلاح PRN logic
- إصلاح fallback في copy previous

## Task 4: إصلاح Widgets (إزالة MockData imports + setState)
- إزالة import MockData من كل widgets
- TemplatesSelectorSection: استخدام Bloc بدل MockData + setState
- AddDrugSearchSheet: استخدام Bloc بدل MockData
- AddEditTemplateSheet: استخدام Bloc بدل MockData

## Task 5: تقسيم الملفات الكبيرة
- add_edit_template_sheet.dart (544 سطر) → تقسيم
- prescription_screen.dart (299 سطر) → تقسيم AppBar
- prescription_header_card.dart (219 سطر) → تقسيم
- templates_selector_section.dart (220 سطر) → تقسيم

## Task 6: تشغيل build_runner والتحقق
- تشغيل `flutter pub run build_runner build`
- التحقق من عدم وجود أخطاء compilation

---

**الحالة:** جاري العمل على Task 1
