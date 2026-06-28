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
      'avatar_url': 'https://randomuser.me/api/portraits/men/43.jpg',
    },
    {
      'id': 'u-sec-1',
      'name': 'أ. سارة أحمد',
      'email': 'sara@clinicpro.com',
      'role': 'secretary',
      'phone': '+201033333333',
      'avatar_url': 'https://randomuser.me/api/portraits/women/44.jpg',
    }
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
    }
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
      'allergies': 'حساسية لاكتوز',
      'chronic_conditions': 'لا يوجد',
      'created_at': DateTime.now().subtract(const Duration(days: 5)).toIso8601String(),
    }
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
    },
    {
      'id': 'd-2',
      'trade_name': 'زيترون شراب مضاد حيوي',
      'generic_name': 'أزيثروميسين شراب',
    },
    {
      'id': 'd-3',
      'trade_name': 'فنتولين بخاخ صدر',
      'generic_name': 'سالبوتامول بخاخ صدر',
    }
  ];

  // قوالب الروشتات للأطباء
  static final List<Map<String, dynamic>> prescriptionTemplates = [
    {
      'id': 'pt-1',
      'doctor_id': 'u-doc-1',
      'title': 'قالب النزلة الشعبية للأطفال',
      'use_count': 142,
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
    }
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
}
