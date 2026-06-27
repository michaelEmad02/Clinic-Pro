# ⚙️ api_reference.md — Supabase API Reference

---

## Overview

### Service Layer Pattern

```
ICloudService (abstract interface)
  ├── SupabaseService     — real implementation using Supabase SDK
  └── MockCloudService    — mock implementation returning static raw data

Both return: raw Map<String,dynamic> or List<Map<String,dynamic>>
Parsing (raw → Model) happens in DataSource layer only.
```

### ICloudService Interface

```dart
// core/services/i_cloud_service.dart

abstract class ICloudService {
  // ── Read ──
  Future<List<Map<String, dynamic>>> fetchAll({
    required String table,
    Map<String, dynamic>? filters,
    List<String>? select,
    String? orderBy,
    bool ascending = true,
    int? limit,
  });

  Future<Map<String, dynamic>?> fetchOne({
    required String table,
    required Map<String, dynamic> filters,
    List<String>? select,
  });

  // ── Write ──
  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  });

  Future<Map<String, dynamic>> update({
    required String table,
    required Map<String, dynamic> data,
    required Map<String, dynamic> filters,
  });

  Future<void> delete({
    required String table,
    required Map<String, dynamic> filters,
  });

  // ── Realtime ──
  RealtimeChannel subscribeToTable({
    required String channelName,
    required String table,
    required Map<String, dynamic> filter,
    required VoidCallback onChange,
  });

  void unsubscribe(RealtimeChannel channel);

  // ── Auth ──
  Future<AuthResponse> signInWithGoogle();
  Future<AuthResponse> signInWithApple();
  Future<void> signInWithMagicLink(String email);
  Future<void> signOut();
  User? get currentUser;
  Stream<AuthState> get authStateChanges;

  // ── Storage ──
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List bytes,
    String? contentType,
  });

  Future<void> deleteFile({
    required String bucket,
    required String path,
  });

  String getPublicUrl({required String bucket, required String path});
}
```

---

## Supabase Storage Buckets

| Bucket | Contents | Access |
|--------|----------|--------|
| `clinic-logos` | Clinic logo images | Public read |
| `user-avatars` | Staff profile pictures | Public read |
| `prescription-docs` | Prescription attachments (X-rays, labs) | Private (authenticated) |

---

## Queries by Feature

---

### 🔐 Auth

```dart
// تسجيل الدخول بـ Google
await supabase.auth.signInWithOAuth(OAuthProvider.google);

// تسجيل الدخول بـ Apple
await supabase.auth.signInWithOAuth(OAuthProvider.apple);

// Magic Link
await supabase.auth.signInWithOtp(email: email);

// تسجيل الخروج
await supabase.auth.signOut();

// المستخدم الحالي
final user = supabase.auth.currentUser;

// دعوة موظف
await supabase.auth.admin.inviteUserByEmail(
  email,
  data: {'clinic_id': clinicId, 'role': role, 'name': name},
);
```

---

### 👤 Owners

```dart
// جلب بيانات الـ Owner الحالي
supabase
  .from('owners')
  .select()
  .eq('id', auth.uid())
  .single()

// إنشاء Owner جديد بعد التسجيل
supabase
  .from('owners')
  .insert({
    'id':    auth.uid(),
    'name':  name,
    'phone': phone,
  })
```

---

### 🏥 Clinics

```dart
// جلب كل عيادات الـ Owner
supabase
  .from('clinics')
  .select()
  .eq('owner_id', ownerId)
  .eq('is_active', true)
  .order('name')

// جلب عيادة بالـ ID
supabase
  .from('clinics')
  .select()
  .eq('id', clinicId)
  .single()

// إنشاء عيادة جديدة
supabase
  .from('clinics')
  .insert({
    'owner_id': ownerId,
    'name':     name,
    'address':  address,
    'phone1':   phone1,
    'logo_url': logoUrl,
  })
  .select()
  .single()

// تحديث بيانات العيادة
supabase
  .from('clinics')
  .update({'name': name, 'address': address})
  .eq('id', clinicId)
```

---

### 👥 Users & Staff

```dart
// جلب الطاقم في عيادة معينة (مع بياناتهم)
supabase
  .from('clinic_staff')
  .select('*, users(*)')
  .eq('clinic_id', clinicId)
  .eq('is_active', true)

// جلب العيادات المتاحة لمستخدم معين
supabase
  .from('clinic_staff')
  .select('*, clinics(id, name, logo_url)')
  .eq('user_id', userId)
  .eq('is_active', true)

// إنشاء user بعد قبول الدعوة
supabase
  .from('users')
  .insert({
    'id':       auth.uid(),
    'owner_id': ownerId,
    'name':     name,
    'phone':    phone,
  })

// ربط الـ user بالعيادة
supabase
  .from('clinic_staff')
  .insert({
    'clinic_id': clinicId,
    'user_id':   userId,
    'role':      role,
  })

// تحديث دور موظف
supabase
  .from('clinic_staff')
  .update({'role': newRole})
  .eq('clinic_id', clinicId)
  .eq('user_id', userId)

// تعليق حساب موظف
supabase
  .from('clinic_staff')
  .update({'is_active': false})
  .eq('clinic_id', clinicId)
  .eq('user_id', userId)
```

---

### 🧑‍⚕️ Patients

```dart
// جلب مرضى الـ Owner مع بحث
supabase
  .from('patients')
  .select()
  .eq('owner_id', ownerId)
  .ilike('name', '%$query%')   // بحث بالاسم
  .order('name')
  .limit(50)

// جلب مريض بالـ ID
supabase
  .from('patients')
  .select()
  .eq('id', patientId)
  .single()

// إضافة مريض
supabase
  .from('patients')
  .insert({
    'owner_id':          ownerId,
    'name':              name,
    'phone':             phone,
    'date_of_birth':     dob,
    'gender':            gender,
    'blood_type':        bloodType,
    'allergies':         allergies,
    'chronic_conditions': chronicConditions,
  })
  .select()
  .single()

// تعديل مريض
supabase
  .from('patients')
  .update({'name': name, 'phone': phone})
  .eq('id', patientId)
```

---

### 💊 Drugs

```dart
// بحث في الأدوية (trade أو generic)
supabase
  .from('drugs')
  .select()
  .or('trade_name.ilike.%$query%,generic_name.ilike.%$query%')
  .limit(20)

// جلب الأدوية بالـ category
supabase
  .from('drugs')
  .select()
  .eq('category', category)
  .order('trade_name')

// إضافة دواء
supabase
  .from('drugs')
  .insert({
    'trade_name':   tradeName,
    'generic_name': genericName,
    'category':     category,
  })
```

---

### 📋 Prescription Templates

```dart
// جلب قوالب الدكتور
supabase
  .from('prescription_templates')
  .select('*, prescription_template_items(*, drugs(*))')
  .eq('doctor_id', doctorId)
  .order('use_count', ascending: false)

// إضافة قالب جديد
supabase
  .from('prescription_templates')
  .insert({
    'doctor_id': doctorId,
    'name':      name,
  })
  .select()
  .single()

// إضافة أدوية للقالب
supabase
  .from('prescription_template_items')
  .insert(items.map((item) => {
    'template_id': templateId,
    'drug_id':     item.drugId,
    'frequency':   item.frequency,
    'duration':    item.duration,
    'is_prn':      item.isPrn,
    'timing':      item.timing,
  }).toList())

// زيادة use_count
supabase
  .rpc('increment_template_use_count', params: {'template_id': id})
// أو:
supabase
  .from('prescription_templates')
  .update({'use_count': currentCount + 1})
  .eq('id', templateId)
```

---

### 🗓️ Appointment Types

```dart
// جلب أنواع الزيارات لدكتور في عيادة
supabase
  .from('appointment_types')
  .select()
  .eq('clinic_id', clinicId)
  .eq('doctor_id', doctorId)

// إضافة نوع زيارة
supabase
  .from('appointment_types')
  .insert({
    'clinic_id': clinicId,
    'doctor_id': doctorId,
    'name':      name,
    'price':     price,
  })
```

---

### 📅 Appointments

```dart
// جلب مواعيد اليوم (تقويم)
supabase
  .from('appointments')
  .select('*, patients(name, phone), users!doctor_id(name), appointment_types(name, price)')
  .eq('clinic_id', clinicId)
  .eq('date', today)
  .order('time')

// جلب قائمة الانتظار (arrived_at != null فقط)
// الترتيب النهائي يتم في Flutter — مش في Supabase
supabase
  .from('appointments')
  .select('*, patients(name, phone), appointment_types(name)')
  .eq('clinic_id', clinicId)
  .eq('doctor_id', doctorId)
  .eq('date', today)
  .not('arrived_at', 'is', null)       // وصل فعلاً
  .neq('status', 'cancelled')
  .order('arrived_at')                 // ترتيب خام بالوصول — Flutter يعيد الترتيب

// تأكيد وصول مريض (Secretary)
supabase
  .from('appointments')
  .update({
    'arrived_at': DateTime.now().toIso8601String(),
    'status':     'confirmed',
  })
  .eq('id', appointmentId)

// استدعاء مريض (Doctor)
supabase
  .from('appointments')
  .update({
    'called_at': DateTime.now().toIso8601String(),
    'status':    'in_progress',
  })
  .eq('id', appointmentId)

// تمييز موعد كطارئ
supabase
  .from('appointments')
  .update({'is_urgent': true})
  .eq('id', appointmentId)

// جلب مواعيد أسبوع
supabase
  .from('appointments')
  .select('*, patients(name), users!doctor_id(name), appointment_types(name)')
  .eq('clinic_id', clinicId)
  .gte('date', weekStart)
  .lte('date', weekEnd)
  .order('date')
  .order('time')

// جلب موعد بالـ ID مع كل التفاصيل
supabase
  .from('appointments')
  .select('''
    *,
    patients(name, phone, blood_type, allergies),
    users!doctor_id(name, specialty),
    appointment_types(name, price),
    prescriptions(id, diagnosis, notes),
    invoices(id, total_amount, paid_amount)
  ''')
  .eq('id', appointmentId)
  .single()

// إضافة موعد
supabase
  .from('appointments')
  .insert({
    'clinic_id':  clinicId,
    'patient_id': patientId,
    'doctor_id':  doctorId,
    'type_id':    typeId,
    'date':       date,
    'time':       time,
    'price':      price,
    'notes':      notes,
    'created_by': currentUserId,
  })

// تحديث حالة الموعد
supabase
  .from('appointments')
  .update({'status': newStatus})
  .eq('id', appointmentId)
```


### 📝 Prescriptions

```dart
// إنشاء روشتة (transaction: prescription + items)
// Step 1: إنشاء الروشتة
final prescription = await supabase
  .from('prescriptions')
  .insert({
    'clinic_id':      clinicId,
    'doctor_id':      doctorId,
    'patient_id':     patientId,
    'appointment_id': appointmentId,
    'diagnosis':      templateId,
    'notes':          notes,
  })
  .select()
  .single();

// Step 2: إضافة الأدوية
await supabase
  .from('prescription_items')
  .insert(drugs.map((d) => {
    'prescription_id': prescription['id'],
    'drug_id':         d.drugId,
    'frequency':       d.frequency,
    'duration':        d.duration,
    'is_prn':          d.isPrn,
    'timing':          d.timing,
  }).toList());

// جلب روشتات مريض
supabase
  .from('prescriptions')
  .select('*, prescription_items(*, drugs(*)), prescription_templates(name)')
  .eq('patient_id', patientId)
  .order('created_at', ascending: false)
```

---

### 🧾 Invoices

```dart
// جلب فواتير العيادة
supabase
  .from('invoices')
  .select('*, patients(name)')
  .eq('clinic_id', clinicId)
  .order('created_at', ascending: false)

// إنشاء فاتورة
supabase
  .from('invoices')
  .insert({
    'clinic_id':      clinicId,
    'patient_id':     patientId,
    'source_id':      appointmentId,
    'source_type':    'appointment',
    'total_amount':   totalAmount,
    'paid_amount':    paidAmount,
    'payment_method': paymentMethod,
  })

// تحديث المبلغ المدفوع
supabase
  .from('invoices')
  .update({'paid_amount': newPaidAmount, 'payment_method': method})
  .eq('id', invoiceId)
```

---

### 💸 Expenses

```dart
// جلب مصروفات العيادة
supabase
  .from('expenses')
  .select()
  .eq('clinic_id', clinicId)
  .gte('created_at', startDate)
  .lte('created_at', endDate)
  .order('created_at', ascending: false)

// إضافة مصروف
supabase
  .from('expenses')
  .insert({
    'clinic_id': clinicId,
    'category_id': categoryId,  // FK → expense_categories.id
    'amount':    amount,
    'notes':     notes,
  })

// حذف مصروف
supabase
  .from('expenses')
  .delete()
  .eq('id', expenseId)
```

---

### 📊 Reports Queries

```dart
// إيرادات يومية
supabase
  .from('invoices')
  .select('paid_amount, created_at')
  .eq('clinic_id', clinicId)
  .gte('created_at', startDate)
  .lte('created_at', endDate)

// مصروفات حسب الفئة
supabase
  .from('expenses')
  .select('category, amount')
  .eq('clinic_id', clinicId)
  .gte('created_at', startDate)
  .lte('created_at', endDate)

// عدد المواعيد المنتهية لكل دكتور
supabase
  .from('appointments')
  .select('doctor_id, users!doctor_id(name)')
  .eq('clinic_id', clinicId)
  .eq('status', 'done')
  .gte('date', startDate)
  .lte('date', endDate)
```

---

### ⚡ Realtime Subscriptions

```dart
// الاشتراك في تحديثات المواعيد
final channel = supabase
  .channel('appointments:$clinicId')
  .onPostgresChanges(
    event:  PostgresChangeEvent.all,
    schema: 'public',
    table:  'appointments',
    filter: PostgresChangeFilter(
      type:   PostgresChangeFilterType.eq,
      column: 'clinic_id',
      value:  clinicId,
    ),
    callback: (_) => refreshAppointments(),
  )
  .subscribe();

// إلغاء الاشتراك
await supabase.removeChannel(channel);
```

---

## Storage Operations

```dart
// رفع شعار عيادة
final path = 'clinics/$clinicId/logo.jpg';
await supabase.storage
  .from('clinic-logos')
  .uploadBinary(path, imageBytes, fileOptions: const FileOptions(upsert: true));

final url = supabase.storage.from('clinic-logos').getPublicUrl(path);

// رفع صورة شخصية
final path = 'users/$userId/avatar.jpg';
await supabase.storage
  .from('user-avatars')
  .uploadBinary(path, imageBytes, fileOptions: const FileOptions(upsert: true));

// رفع مستند روشتة
final path = 'prescriptions/$prescriptionId/${fileName}';
await supabase.storage
  .from('prescription-docs')
  .uploadBinary(path, fileBytes);

final url = supabase.storage.from('prescription-docs').createSignedUrl(path, 3600);
```


---

### 📦 Plans & Subscriptions

```dart
// جلب كل الخطط مع ميزاتها
supabase
  .from('plans')
  .select('*, plan_features(*)')
  .order('monthly_price')

// جلب اشتراك الـ Owner الحالي
supabase
  .from('subscriptions')
  .select('*, plans(*, plan_features(*))')
  .eq('owner_id', ownerId)
  .eq('status', 'active')
  .maybeSingle()

// إنشاء اشتراك جديد
supabase
  .from('subscriptions')
  .insert({
    'owner_id':          ownerId,
    'plan_id':           planId,
    'subscription_type': subscriptionType,  // 'trial' | 'monthly' | 'yearly'
    'status':            'pending',
    'start_at':          startDate,
    'end_at':            endDate,
    'created_by':        ownerId,
  })

// تحديث حالة الاشتراك
supabase
  .from('subscriptions')
  .update({'status': newStatus})
  .eq('id', subscriptionId)
```

---

### 🏷️ Expense Categories

```dart
// جلب كل فئات المصروفات (seeded data)
supabase
  .from('expense_categories')
  .select()
  .order('name')
```

---

## Error Handling Pattern

```dart
// في DataSource — كل Supabase call ملفوف في try/catch
try {
  final raw = await _service.fetchAll(table: SupabaseTables.appointments);
  return raw.map(AppointmentModel.fromJson).toList();
} on PostgrestException catch (e) {
  throw ServerException(message: e.message, code: e.code);
} on SocketException {
  throw NetworkException();
} catch (e) {
  throw UnknownException(message: e.toString());
}

// في Repository — يحول Exception إلى Failure
try {
  final models = await _dataSource.getAppointments(clinicId);
  return Right(models.map((m) => m.toEntity()).toList());
} on ServerException catch (e) {
  return Left(ServerFailure(e.message));
} on NetworkException {
  return Left(NetworkFailure());
} catch (e) {
  return Left(UnknownFailure());
}
```
