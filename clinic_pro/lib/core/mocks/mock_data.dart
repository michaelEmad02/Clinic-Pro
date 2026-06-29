// ────────────────────────────────────────────────────────
// هذا الملف يحتوي على البيانات الوهمية (Mock Data) للتطبيق
// تُستخدم لعرض واجهات واقعية باللغة العربية قبل ربط Supabase
// ────────────────────────────────────────────────────────

class MockData {
  // بيانات المستخدمين (الأطباء، السكرتارية، المالكين)
  static final List<Map<String, dynamic>> users = [
    {
      'id': 'u-owner-1',
      'name': 'د. محمد عبد الرحمن',
      'email': 'owner@clinicpro.com',
      'role': 'owner',
      'phone': '+201011111111',
      'avatar_url': 'https://randomuser.me/api/portraits/men/32.jpg',
    },
    {
      'id': 'u-doc-1',
      'name': 'د. ياسر مصطفى',
      'email': 'yasser@clinicpro.com',
      'role': 'doctor',
      'phone': '+201022222222',
      'specialty': 'طب عام',
      'rating': 4.9,
      'avatar_url': 'https://randomuser.me/api/portraits/men/43.jpg',
    },
    {
      'id': 'u-doc-2',
      'name': 'د. نورة السالم',
      'email': 'nora@clinicpro.com',
      'role': 'doctor',
      'phone': '+201044444444',
      'specialty': 'طب أطفال',
      'rating': 4.8,
      'avatar_url': 'https://randomuser.me/api/portraits/women/68.jpg',
    },
    {
      'id': 'u-doc-3',
      'name': 'د. خالد عبدالله القحطاني',
      'email': 'khaled@clinicpro.com',
      'role': 'doctor',
      'phone': '+201066666666',
      'specialty': 'طب أسنان',
      'rating': 5.0,
      'avatar_url': 'https://randomuser.me/api/portraits/men/75.jpg',
    },
    {
      'id': 'u-nurse-1',
      'name': 'م. ياسر محمود',
      'email': 'yasser.nurse@clinicpro.com',
      'role': 'nurse',
      'phone': '+201055555555',
      'specialty': 'رئيس تمريض',
      'rating': 4.5,
      'avatar_url': null,
    },
    {
      'id': 'u-nurse-2',
      'name': 'م. نور محمد',
      'email': 'noor.nurse@clinicpro.com',
      'role': 'nurse',
      'phone': '+201099999999',
      'specialty': 'تمريض أطفال',
      'rating': 4.3,
      'avatar_url': null,
    },
    {
      'id': 'u-acc-1',
      'name': 'أ. عبدالله العمري',
      'email': 'abdullah@clinicpro.com',
      'role': 'accountant',
      'phone': '+201077777777',
      'specialty': 'محاسب قانوني',
      'avatar_url': null,
    },
    {
      'id': 'u-sec-1',
      'name': 'أ. سارة أحمد',
      'email': 'sara@clinicpro.com',
      'role': 'secretary',
      'phone': '+201033333333',
      'specialty': 'استقبال',
      'avatar_url': 'https://randomuser.me/api/portraits/women/44.jpg',
    },
    {
      'id': 'u-sec-2',
      'name': 'أ. فاطمة الزهراء',
      'email': 'fatima@clinicpro.com',
      'role': 'secretary',
      'phone': '+201088888888',
      'specialty': 'سكرتارية طبية',
      'avatar_url': null,
    },
    {
      'id': 'u-sec-3',
      'name': 'أ. سارة عبدالله',
      'email': 'sara.admin@clinic.com',
      'role': 'secretary',
      'phone': '+201099988877',
      'specialty': 'سكرتير طبي',
      'avatar_url': null,
    },
    {
      'id': 'u-doc-4',
      'name': 'د. أحمد صالح',
      'email': 'ahmed.saleh@clinicpro.com',
      'role': 'doctor',
      'phone': '+201012345678',
      'specialty': 'طب عام',
      'rating': 4.7,
      'avatar_url': null,
    },
    {
      'id': 'u-doc-5',
      'name': 'د. أحمد العبدالله',
      'email': 'dr.ahmed@example.com',
      'role': 'doctor',
      'phone': '+201098765432',
      'specialty': 'نساء وولادة',
      'rating': 4.6,
      'avatar_url': null,
    },
  ];

  // بيانات العيادات
  static final List<Map<String, dynamic>> clinics = [
    {
      'id': 'c-1',
      'owner_id': 'u-owner-1',
      'name': 'عيادة كليوباترا لطب الأطفال',
      'phone': '+20223456789',
      'address': '١٢ شارع الميرغني، مصر الجديدة، القاهرة',
      'logo_url': 'https://logo.clearbit.com/cleopatrahospitals.com',
      'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
    },
    {
      'id': 'c-2',
      'owner_id': 'u-owner-1',
      'name': 'عيادة النيل لجلدية وتجميل',
      'phone': '+20229876543',
      'address': '٤٥ برج النيل، المعادي، القاهرة',
      'logo_url': null,
      'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
    },
    {
      'id': 'c-3',
      'owner_id': 'u-owner-1',
      'name': 'عيادة الأمل الطبية',
      'phone': '+966501234567',
      'address': 'الرياض، حي الملقا، شارع الملك فهد',
      'logo_url': null,
      'created_at': DateTime.now().subtract(const Duration(days: 60)).toIso8601String(),
    }
  ];

  // موظفي العيادات (العلاقة بين العيادة والمستخدم)
  static final List<Map<String, dynamic>> clinicStaff = [
    {
      'id': 'cs-1',
      'clinic_id': 'c-1',
      'user_id': 'u-owner-1',
      'role': 'owner',
      'is_active': true,
    },
    {
      'id': 'cs-2',
      'clinic_id': 'c-1',
      'user_id': 'u-doc-1',
      'role': 'doctor',
      'is_active': true,
    },
    {
      'id': 'cs-3',
      'clinic_id': 'c-1',
      'user_id': 'u-sec-1',
      'role': 'secretary',
      'is_active': true,
    },
    {
      'id': 'cs-4',
      'clinic_id': 'c-1',
      'user_id': 'u-doc-2',
      'role': 'doctor',
      'is_active': true,
    },
    {
      'id': 'cs-5',
      'clinic_id': 'c-1',
      'user_id': 'u-doc-3',
      'role': 'doctor',
      'is_active': true,
    },
    {
      'id': 'cs-6',
      'clinic_id': 'c-1',
      'user_id': 'u-nurse-1',
      'role': 'nurse',
      'is_active': true,
    },
    {
      'id': 'cs-7',
      'clinic_id': 'c-2',
      'user_id': 'u-owner-1',
      'role': 'owner',
      'is_active': true,
    },
    {
      'id': 'cs-8',
      'clinic_id': 'c-2',
      'user_id': 'u-doc-1',
      'role': 'doctor',
      'is_active': true,
    },
    {
      'id': 'cs-9',
      'clinic_id': 'c-2',
      'user_id': 'u-sec-2',
      'role': 'secretary',
      'is_active': true,
    },
    {
      'id': 'cs-10',
      'clinic_id': 'c-2',
      'user_id': 'u-acc-1',
      'role': 'accountant',
      'is_active': true,
    },
    {
      'id': 'cs-11',
      'clinic_id': 'c-3',
      'user_id': 'u-owner-1',
      'role': 'owner',
      'is_active': true,
    },
    {
      'id': 'cs-12',
      'clinic_id': 'c-3',
      'user_id': 'u-doc-4',
      'role': 'doctor',
      'is_active': true,
    },
    {
      'id': 'cs-13',
      'clinic_id': 'c-3',
      'user_id': 'u-doc-5',
      'role': 'doctor',
      'is_active': true,
    },
    {
      'id': 'cs-14',
      'clinic_id': 'c-3',
      'user_id': 'u-nurse-2',
      'role': 'nurse',
      'is_active': true,
    },
    {
      'id': 'cs-15',
      'clinic_id': 'c-3',
      'user_id': 'u-sec-3',
      'role': 'secretary',
      'is_active': true,
    },
  ];

  // بيانات المرضى
  static final List<Map<String, dynamic>> patients = [
    {
      'id': 'p-1',
      'clinic_id': 'c-1',
      'name': 'يوسف خالد منصور',
      'phone': '01123456789',
      'gender': 'male',
      'birth_date': '2018-05-15',
      'blood_type': 'O+',
      'allergies': 'حساسية من البنسلين والغبار',
      'chronic_conditions': 'ربو شعبي خفيف',
      'created_at': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
    },
    {
      'id': 'p-2',
      'clinic_id': 'c-1',
      'name': 'فاطمة عمر الشريف',
      'phone': '01298765432',
      'gender': 'female',
      'birth_date': '2020-11-22',
      'blood_type': 'A+',
      'allergies': 'لا يوجد',
      'chronic_conditions': 'لا يوجد',
      'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    },
    {
      'id': 'p-3',
      'clinic_id': 'c-1',
      'name': 'كريم هشام عادل',
      'phone': '01533445566',
      'gender': 'male',
      'birth_date': '2019-02-08',
      'blood_type': 'B+',
      'allergies': 'حساسية لاكتوز',
      'chronic_conditions': 'لا يوجد',
      'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    },
    {
      'id': 'p-4',
      'clinic_id': 'c-1',
      'name': 'محمد عبدالله صالح',
      'phone': '0501234567',
      'gender': 'male',
      'birth_date': '1985-03-12',
      'blood_type': 'A+',
      'email': 'mohamed.a@example.com',
      'address': 'الرياض، حي الملقا، شارع الأمير محمد بن سعد',
      'emergency_contact': 'أحمد عبدالله (أخ) - 0509876543',
      'allergies': 'البنسلين، الأسبرين',
      'chronic_conditions': 'السكري (النوع الثاني)، ارتفاع ضغط الدم',
      'is_chronic': true,
      'last_visit_date': '2023-10-12',
      'last_visit_label': '12 أكتوبر 2023',
      'status_tag': 'follow_up',
      'created_at': DateTime.now().subtract(const Duration(days: 300)).toIso8601String(),
    },
    {
      'id': 'p-5',
      'clinic_id': 'c-1',
      'name': 'سارة اليوسف',
      'phone': '0559876543',
      'gender': 'female',
      'birth_date': '1992-07-08',
      'blood_type': 'O-',
      'email': 'sara.y@example.com',
      'address': 'جدة، حي الروضة',
      'emergency_contact': 'فهد اليوسف (زوج) - 0551112233',
      'allergies': 'لا يوجد',
      'chronic_conditions': 'لا يوجد',
      'is_chronic': false,
      'last_visit_date': DateTime.now().toIso8601String().substring(0, 10),
      'last_visit_label': 'اليوم، 10:30 ص',
      'status_tag': 'completed',
      'created_at': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
    },
    {
      'id': 'p-6',
      'clinic_id': 'c-1',
      'name': 'خالد الرحمن',
      'phone': '0534445555',
      'gender': 'male',
      'birth_date': '1978-11-25',
      'blood_type': 'B+',
      'email': 'khaled.r@example.com',
      'address': 'الدمام، حي الفيصلية',
      'emergency_contact': 'نورة الرحمن (زوجة) - 0536667777',
      'allergies': 'لا يوجد',
      'chronic_conditions': 'ربo مزمن، ضغط مرتفع',
      'is_chronic': true,
      'last_visit_date': '2023-09-05',
      'last_visit_label': '05 سبتمبر 2023',
      'status_tag': 'chronic',
      'created_at': DateTime.now().subtract(const Duration(days: 200)).toIso8601String(),
    },
  ];

  static final List<Map<String, dynamic>> patientVisits = [
    {
      'id': 'v-1',
      'patient_id': 'p-4',
      'title': 'مراجعة دورية (سكر وضغط)',
      'date': '2023-10-15',
      'display_date': '15 أكتوبر 2023',
      'description':
          'تم فحص مستويات السكر التراكمي (HbA1c) وضغط الدم. المستويات مستقرة، تم التوصية بالاستمرار على نفس الجرعة الدوائية.',
      'doctor_name': 'د. أحمد العلي',
    },
    {
      'id': 'v-2',
      'patient_id': 'p-4',
      'title': 'ألم في المفاصل',
      'date': '2023-08-02',
      'display_date': '02 أغسطس 2023',
      'description':
          'شكوى من ألم في الركبة اليمنى. تم صرف مسكنات موضعية وتحويل لعيادة العلاج الطبيعي.',
      'doctor_name': 'د. سارة خالد',
    },
    {
      'id': 'v-3',
      'patient_id': 'p-4',
      'title': 'زيارة أولى - فتح ملف',
      'date': '2023-01-10',
      'display_date': '10 يناير 2023',
      'description':
          'تم تسجيل البيانات الأولية وإجراء الفحوصات الشاملة (تحليل دم كامل، وظائف كبد وكلى).',
      'doctor_name': 'د. أحمد العلي',
    },
    {
      'id': 'v-4',
      'patient_id': 'p-5',
      'title': 'كشف سخونية ورشح',
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'display_date': 'اليوم',
      'description': 'سخونة ورشح مستمر منذ يومين.',
      'doctor_name': 'د. أحمد العلي',
    },
    {
      'id': 'v-5',
      'patient_id': 'p-6',
      'title': 'متابعة ضغط الدم',
      'date': '2023-09-05',
      'display_date': '05 سبتمبر 2023',
      'description': 'ضغط مستقر. استمرار على العلاج الحالي.',
      'doctor_name': 'د. أحمد العلي',
    },
  ];

  static final List<Map<String, dynamic>> patientPrescriptionRecords = [
    {
      'id': 'pr-1',
      'patient_id': 'p-4',
      'title': 'وصفة أدوية السكري والضغط',
      'date': '2023-10-15',
      'display_date': '15 أكتوبر 2023',
      'doctor_name': 'د. أحمد العلي',
    },
    {
      'id': 'pr-2',
      'patient_id': 'p-4',
      'title': 'مسكنات ألم مفاصل',
      'date': '2023-08-02',
      'display_date': '02 أغسطس 2023',
      'doctor_name': 'د. سارة خالد',
    },
    {
      'id': 'pr-3',
      'patient_id': 'p-5',
      'title': 'علاج سخونية ورشح',
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'display_date': 'اليوم',
      'doctor_name': 'د. أحمد العلي',
    },
  ];

  // أنواع الكشف/المواعيد
  static final List<Map<String, dynamic>> appointmentTypes = [
    {
      'id': 'at-1',
      'clinic_id': 'c-1',
      'name': 'كشف عادي',
      'price': 250.0,
      'duration_minutes': 20,
    },
    {
      'id': 'at-2',
      'clinic_id': 'c-1',
      'name': 'استشارة مابعد الكشف',
      'price': 0.0,
      'duration_minutes': 10,
    },
    {
      'id': 'at-3',
      'clinic_id': 'c-1',
      'name': 'إعادة كشف',
      'price': 100.0,
      'duration_minutes': 15,
    },
    {
      'id': 'at-4',
      'clinic_id': 'c-1',
      'name': 'كشف مستعجل طوارئ',
      'price': 400.0,
      'duration_minutes': 25,
    },
    {
      'id': 'at-5',
      'clinic_id': 'c-3',
      'name': 'كشف عادي',
      'price': 150.0,
      'duration_minutes': 20,
    },
    {
      'id': 'at-6',
      'clinic_id': 'c-3',
      'name': 'متابعة حمل',
      'price': 300.0,
      'duration_minutes': 30,
    },
    {
      'id': 'at-7',
      'clinic_id': 'c-3',
      'name': 'تنظيف أسنان',
      'price': 200.0,
      'duration_minutes': 45,
    }
  ];

  // مواعيد اليوم
  static final List<Map<String, dynamic>> appointments = [
    {
      'id': 'appt-1',
      'clinic_id': 'c-1',
      'patient_id': 'p-1',
      'doctor_id': 'u-doc-1',
      'appointment_type_id': 'at-1',
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'time': '16:30:00',
      'status': 'done',
      'price': 250.0,
      'is_urgent': false,
      'arrived_at': DateTime.now().subtract(const Duration(hours: 3)).toIso8601String(),
      'called_at': DateTime.now().subtract(const Duration(hours: 2, minutes: 40)).toIso8601String(),
      'notes': 'متابعة دورية لحالة الصدر والربو',
      'patients': {'name': 'يوسف خالد منصور', 'phone': '01123456789'},
      'appointment_types': {'name': 'كشف عادي', 'price': 250.0}
    },
    {
      'id': 'appt-2',
      'clinic_id': 'c-1',
      'patient_id': 'p-2',
      'doctor_id': 'u-doc-1',
      'appointment_type_id': 'at-1',
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'time': '17:00:00',
      'status': 'in_progress',
      'price': 250.0,
      'is_urgent': false,
      'arrived_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      'called_at': DateTime.now().subtract(const Duration(minutes: 15)).toIso8601String(),
      'notes': 'سخونة ورشح مستمر منذ يومين',
      'patients': {'name': 'فاطمة عمر الشريف', 'phone': '01298765432'},
      'appointment_types': {'name': 'كشف عادي', 'price': 250.0}
    },
    {
      'id': 'appt-3',
      'clinic_id': 'c-1',
      'patient_id': 'p-3',
      'doctor_id': 'u-doc-1',
      'appointment_type_id': 'at-4',
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'time': '17:30:00',
      'status': 'confirmed',
      'price': 400.0,
      'is_urgent': true,
      'arrived_at': DateTime.now().subtract(const Duration(minutes: 40)).toIso8601String(),
      'called_at': null,
      'notes': 'ضيق تنفس شديد وحالة طارئة جداً',
      'patients': {'name': 'كريم هشام عادل', 'phone': '01533445566'},
      'appointment_types': {'name': 'كشف مستعجل طوارئ', 'price': 400.0}
    },
    {
      'id': 'appt-4',
      'clinic_id': 'c-1',
      'patient_id': 'p-1',
      'doctor_id': 'u-doc-1',
      'appointment_type_id': 'at-3',
      'date': DateTime.now().toIso8601String().substring(0, 10),
      'time': '18:00:00',
      'status': 'scheduled',
      'price': 100.0,
      'is_urgent': false,
      'arrived_at': null,
      'called_at': null,
      'notes': 'إعادة كشف لمتابعة الربو',
      'patients': {'name': 'يوسف خالد منصور', 'phone': '01123456789'},
      'appointment_types': {'name': 'إعادة كشف', 'price': 100.0}
    },
    {
      'id': 'appt-5',
      'clinic_id': 'c-1',
      'patient_id': 'p-2',
      'doctor_id': 'u-doc-1',
      'appointment_type_id': 'at-2',
      'date': DateTime.now().add(const Duration(days: 1)).toIso8601String().substring(0, 10),
      'time': '10:00:00',
      'status': 'scheduled',
      'price': 0.0,
      'is_urgent': false,
      'arrived_at': null,
      'called_at': null,
      'notes': 'استشارة بعد الكشف الأسبوع الماضي',
      'patients': {'name': 'فاطمة عمر الشريف', 'phone': '01298765432'},
      'appointment_types': {'name': 'استشارة مابعد الكشف', 'price': 0.0}
    },
    {
      'id': 'appt-6',
      'clinic_id': 'c-1',
      'patient_id': 'p-3',
      'doctor_id': 'u-doc-1',
      'appointment_type_id': 'at-1',
      'date': DateTime.now().add(const Duration(days: 3)).toIso8601String().substring(0, 10),
      'time': '11:30:00',
      'status': 'scheduled',
      'price': 250.0,
      'is_urgent': false,
      'arrived_at': null,
      'called_at': null,
      'notes': null,
      'patients': {'name': 'كريم هشام عادل', 'phone': '01533445566'},
      'appointment_types': {'name': 'كشف عادي', 'price': 250.0}
    },
    {
      'id': 'appt-7',
      'clinic_id': 'c-1',
      'patient_id': 'p-2',
      'doctor_id': 'u-doc-1',
      'appointment_type_id': 'at-1',
      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String().substring(0, 10),
      'time': '14:00:00',
      'status': 'done',
      'price': 250.0,
      'is_urgent': false,
      'arrived_at': DateTime.now().subtract(const Duration(days: 2, hours: 1)).toIso8601String(),
      'called_at': DateTime.now().subtract(const Duration(days: 2, minutes: 45)).toIso8601String(),
      'notes': 'كشف دوري — حالة مستقرة',
      'patients': {'name': 'فاطمة عمر الشريف', 'phone': '01298765432'},
      'appointment_types': {'name': 'كشف عادي', 'price': 250.0}
    },
    {
      'id': 'appt-8',
      'clinic_id': 'c-1',
      'patient_id': 'p-1',
      'doctor_id': 'u-doc-1',
      'appointment_type_id': 'at-1',
      'date': DateTime.now().subtract(const Duration(days: 1)).toIso8601String().substring(0, 10),
      'time': '09:00:00',
      'status': 'cancelled',
      'price': 250.0,
      'is_urgent': false,
      'arrived_at': null,
      'called_at': null,
      'notes': 'ألغى المريض الموعد',
      'patients': {'name': 'يوسف خالد منصور', 'phone': '01123456789'},
      'appointment_types': {'name': 'كشف عادي', 'price': 250.0}
    },
  ];

  // نمط ترتيب الطابور للطبيب
  static final List<Map<String, dynamic>> doctorQueueRules = [
    {
      'id': 'dqr-1',
      'doctor_id': 'u-doc-1',
      'clinic_id': 'c-1',
      'slots': ['normal', 'normal', 'normal', 'urgent'],
      'cycle_length': 4,
      'is_active': true,
    }
  ];

  // الأدوية
  static final List<Map<String, dynamic>> drugs = [
    {
      'id': 'd-1',
      'trade_name': 'بندول شراب للأطفال',
      'generic_name': 'باراسيتامول البشري للأطفال',
      'category': 'خافض حرارة',
      'form': 'شراب',
      'stock_count': 120,
      'stock_status': 'متوفر',
    },
    {
      'id': 'd-2',
      'trade_name': 'زيترون شراب مضاد حيوي',
      'generic_name': 'أزيثروميسين شراب',
      'category': 'مضاد حيوي',
      'form': 'شراب',
      'stock_count': 18,
      'stock_status': 'مخزون منخفض',
    },
    {
      'id': 'd-3',
      'trade_name': 'فنتولين بخاخ صدر',
      'generic_name': 'سالبوتامول بخاخ صدر',
      'category': 'أمراض صدر',
      'form': 'بخاخ',
      'stock_count': 36,
      'stock_status': 'متوفر',
    },
    {
      'id': 'd-4',
      'trade_name': 'أوجمنتين 1 جم',
      'generic_name': 'أموكسيسيلين / كلافولانيك أسيد',
      'category': 'مضاد حيوي',
      'form': 'أقراص',
      'stock_count': 14,
      'stock_status': 'مخزون منخفض',
    },
    {
      'id': 'd-5',
      'trade_name': 'كونكور 5 مجم',
      'generic_name': 'بيسوبرولول',
      'category': 'أدوية مزمنة',
      'form': 'أقراص',
      'stock_count': 90,
      'stock_status': 'متوفر',
    }
  ];

  static final List<Map<String, dynamic>> diagnosisTemplates = [
    {'id': 'diag-1', 'title': 'التهاب اللوزتين الحاد'},
    {'id': 'diag-2', 'title': 'نزلة شعبية حادة'},
    {'id': 'diag-3', 'title': 'ارتفاع ضغط الدم'},
    {'id': 'diag-4', 'title': 'سكر غير منضبط'},
  ];

  // قوالب الروشتات للأطباء
  static final List<Map<String, dynamic>> prescriptionTemplates = [
    {
      'id': 'pt-1',
      'doctor_id': 'u-doc-1',
      'title': 'قالب النزلة الشعبية للأطفال',
      'use_count': 142,
      'category': 'حالات حادة',
    },
    {
      'id': 'pt-2',
      'doctor_id': 'u-doc-1',
      'title': 'متابعة الضغط الأساسية',
      'use_count': 87,
      'category': 'أمراض مزمنة',
    }
  ];

  // مكونات قوالب الروشتات
  static final List<Map<String, dynamic>> prescriptionTemplateItems = [
    {
      'id': 'pti-1',
      'template_id': 'pt-1',
      'drug_id': 'd-1',
      'dose_frequency': 'كل ٨ ساعات عند اللزوم',
      'dose_duration': '٥ أيام',
      'dose_timing': 'بعد الأكل',
    },
    {
      'id': 'pti-2',
      'template_id': 'pt-1',
      'drug_id': 'd-2',
      'dose_frequency': 'مرة واحدة يومياً',
      'dose_duration': '٣ أيام',
      'dose_timing': 'قبل الأكل بساعة',
    },
    {
      'id': 'pti-3',
      'template_id': 'pt-2',
      'drug_id': 'd-5',
      'dose_frequency': 'مرة واحدة يومياً',
      'dose_duration': '٣٠ يوم',
      'dose_timing': 'بعد الأكل',
    }
  ];

  // الروشتات الطبية الصادرة
  static final List<Map<String, dynamic>> prescriptions = [
    {
      'id': 'presc-1',
      'appointment_id': 'appt-1',
      'doctor_id': 'u-doc-1',
      'patient_id': 'p-1',
      'diagnosis': 'نزلة معوية حادة ونقص سوائل',
      'notes': 'الالتزام التام بجرعات السوائل والراحة التامة للطفل',
      'created_at': DateTime.now().subtract(const Duration(hours: 2, minutes: 40)).toIso8601String(),
    },
    {
      'id': 'presc-2',
      'appointment_id': 'appt-7',
      'doctor_id': 'u-doc-1',
      'patient_id': 'p-2',
      'diagnosis': 'نزلة برد وسخونية',
      'notes': 'الإكثار من السوائل والراحة المنزلية',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    }
  ];

  static final List<Map<String, dynamic>> prescriptionItems = [
    {
      'id': 'pi-1',
      'prescription_id': 'presc-1',
      'drug_id': 'd-1',
      'dose_option': '١٠ مل',
      'dose_frequency': 'عند اللزوم',
      'dose_duration': '٣ أيام',
      'dose_timing': 'بعد الأكل',
      'is_prn': true,
    },
    {
      'id': 'pi-2',
      'prescription_id': 'presc-1',
      'drug_id': 'd-2',
      'dose_option': '٥ مل',
      'dose_frequency': 'مرة واحدة يومياً',
      'dose_duration': '٣ أيام',
      'dose_timing': 'قبل الأكل',
      'is_prn': false,
    },
    {
      'id': 'pi-3',
      'prescription_id': 'presc-2',
      'drug_id': 'd-1',
      'dose_option': '١٠ مل',
      'dose_frequency': '٣ مرات يومياً',
      'dose_duration': '٥ أيام',
      'dose_timing': 'بعد الأكل',
      'is_prn': false,
    },
  ];

  // المصروفات
  static final List<Map<String, dynamic>> expenses = [
    {
      'id': 'exp-1',
      'clinic_id': 'c-1',
      'title': 'شراء مستلزمات طبية ومعقمات',
      'amount': 1500.0,
      'category': 'medical_supplies',
      'date': DateTime.now().subtract(const Duration(days: 2)).toIso8601String().substring(0, 10),
      'notes': 'فاتورة شركة النصر الطبية',
    },
    {
      'id': 'exp-2',
      'clinic_id': 'c-1',
      'title': 'فاتورة كهرباء شهر مايو',
      'amount': 850.0,
      'category': 'utilities',
      'date': DateTime.now().subtract(const Duration(days: 8)).toIso8601String().substring(0, 10),
      'notes': 'عداد تجاري للعيادة الرئيسي',
    }
  ];

  // الفواتير الصادرة للمرضى
  static final List<Map<String, dynamic>> invoices = [
    {
      'id': 'inv-1',
      'clinic_id': 'c-1',
      'appointment_id': 'appt-1',
      'patient_id': 'p-1',
      'amount': 250.0,
      'status': 'paid',
      'payment_method': 'cash',
      'created_at': DateTime.now().subtract(const Duration(hours: 2, minutes: 40)).toIso8601String(),
    }
  ];

  // الاشتراكات
  static final List<Map<String, dynamic>> subscriptions = [
    {
      'id': 'sub-1',
      'owner_id': 'u-owner-1',
      'plan_type': 'growth',
      'status': 'active',
      'trial_end_at': null,
      'current_period_end': DateTime.now().add(const Duration(days: 340)).toIso8601String(),
    }
  ];

  // الدعوات المعلقة
  static final List<Map<String, dynamic>> invitations = [
    {
      'id': 'inv-1',
      'clinic_id': 'c-1',
      'email': 'sara.admin@clinic.com',
      'name': 'سارة عبدالله',
      'role': 'secretary',
      'status': 'pending',
      'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
    },
    {
      'id': 'inv-2',
      'clinic_id': 'c-2',
      'email': 'dr.ahmed@example.com',
      'name': 'د. أحمد العبدالله',
      'role': 'doctor',
      'status': 'pending',
      'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    },
    {
      'id': 'inv-3',
      'clinic_id': 'c-1',
      'email': 'noor.nurse@example.com',
      'name': 'نور محمد',
      'role': 'nurse',
      'status': 'expired',
      'created_at': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
    },
    {
      'id': 'inv-4',
      'clinic_id': 'c-3',
      'email': 'hassan.dr@example.com',
      'name': 'د. حسن النمر',
      'role': 'doctor',
      'status': 'pending',
      'created_at': DateTime.now().subtract(const Duration(days: 1)).toIso8601String(),
    },
  ];

  // إحصائيات العيادات (محسوبة مسبقاً)
  static final List<Map<String, dynamic>> clinicStats = [
    {
      'clinic_id': 'c-1',
      'total_patients': 1248,
      'patients_change': 12,
      'today_appointments': 42,
      'today_remaining': 8,
      'doctors_count': 3,
      'doctors_on_leave': 0,
      'rating': 4.8,
      'total_reviews': 320,
      'monthly_revenue': 5400.0,
    },
    {
      'clinic_id': 'c-2',
      'total_patients': 856,
      'patients_change': 8,
      'today_appointments': 28,
      'today_remaining': 15,
      'doctors_count': 1,
      'doctors_on_leave': 0,
      'rating': 4.6,
      'total_reviews': 189,
      'monthly_revenue': 8200.0,
    },
    {
      'clinic_id': 'c-3',
      'total_patients': 2048,
      'patients_change': 22,
      'today_appointments': 60,
      'today_remaining': 22,
      'doctors_count': 2,
      'doctors_on_leave': 1,
      'rating': 4.9,
      'total_reviews': 512,
      'monthly_revenue': 12500.0,
    },
  ];

  // ساعات العمل لكل عيادة
  static final List<Map<String, dynamic>> clinicWorkingHours = [
    {
      'clinic_id': 'c-1',
      'sunday': '08:00 - 22:00',
      'monday': '08:00 - 22:00',
      'tuesday': '08:00 - 22:00',
      'wednesday': '08:00 - 22:00',
      'thursday': '08:00 - 22:00',
      'friday': 'مغلق',
      'saturday': '10:00 - 18:00',
    },
    {
      'clinic_id': 'c-2',
      'sunday': '09:00 - 21:00',
      'monday': '09:00 - 21:00',
      'tuesday': '09:00 - 21:00',
      'wednesday': '09:00 - 21:00',
      'thursday': '09:00 - 21:00',
      'friday': 'مغلق',
      'saturday': 'مغلق',
    },
    {
      'clinic_id': 'c-3',
      'sunday': '08:00 - 22:00',
      'monday': '08:00 - 22:00',
      'tuesday': '08:00 - 22:00',
      'wednesday': '08:00 - 22:00',
      'thursday': '08:00 - 22:00',
      'friday': 'مغلق',
      'saturday': '10:00 - 18:00',
    },
  ];
}
