// ────────────────────────────────────────────────────────
// Cubit شاشة العيادات — تحميل وإضافة وتعديل وحذف (Mock)
// ────────────────────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/mocks/mock_data.dart';
import 'clinics_state.dart';

class ClinicsCubit extends Cubit<ClinicsState> {
  ClinicsCubit() : super(ClinicsInitial());

  Future<void> loadClinics() async {
    emit(ClinicsLoading());
    await Future.delayed(const Duration(milliseconds: 500));

    try {
      final items = _mapMockData();
      emit(ClinicsLoaded(clinics: items));
    } catch (_) {
      emit(const ClinicsError('تعذّر تحميل قائمة العيادات'));
    }
  }

  Future<void> addClinic({
    required String name,
    required String phone,
    required String address,
    String? logoUrl,
  }) async {
    if (state is! ClinicsLoaded) return;
    final loaded = state as ClinicsLoaded;
    await Future.delayed(const Duration(milliseconds: 400));

    final newClinic = ClinicItem(
      id: 'c-new-${DateTime.now().millisecondsSinceEpoch}',
      ownerId: 'u-owner-1',
      name: name,
      phone: phone,
      address: address,
      logoUrl: logoUrl,
      isActive: true,
      totalPatients: 0,
      todayAppointments: 0,
      doctorsCount: 0,
      rating: 0,
      totalReviews: 0,
      monthlyRevenue: 0,
    );

    emit(ClinicsLoaded(clinics: [...loaded.clinics, newClinic]));
  }

  Future<void> updateClinic(ClinicItem updated) async {
    if (state is! ClinicsLoaded) return;
    final loaded = state as ClinicsLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final list = loaded.clinics.map((c) {
      return c.id == updated.id ? updated : c;
    }).toList();

    emit(ClinicsLoaded(clinics: list));
  }

  Future<void> deleteClinic(String clinicId) async {
    if (state is! ClinicsLoaded) return;
    final loaded = state as ClinicsLoaded;
    await Future.delayed(const Duration(milliseconds: 300));

    final list =
        loaded.clinics.where((c) => c.id != clinicId).toList();
    emit(ClinicsLoaded(clinics: list));
  }

  Future<void> toggleActive(String clinicId) async {
    if (state is! ClinicsLoaded) return;
    final loaded = state as ClinicsLoaded;
    await Future.delayed(const Duration(milliseconds: 200));

    final list = loaded.clinics.map((c) {
      if (c.id == clinicId) {
        return c.copyWith(isActive: !c.isActive);
      }
      return c;
    }).toList();

    emit(ClinicsLoaded(clinics: list));
  }

  /// إضافة عضو إلى طاقم العيادة
  Future<void> addStaffMember({
    required String clinicId,
    required String userId,
    required String role,
  }) async {
    if (state is! ClinicsLoaded) return;
    final loaded = state as ClinicsLoaded;

    // إضافة العضو للبيانات الوهمية
    MockData.clinicStaff.add({
      'id': 'cs-${DateTime.now().millisecondsSinceEpoch}',
      'clinic_id': clinicId,
      'user_id': userId,
      'role': role,
      'is_active': true,
    });

    // إعادة بث الحالة لتحديث الشاشات
    emit(ClinicsLoaded(clinics: _mapMockData()));
  }

  /// إزالة عضو من طاقم العيادة
  Future<void> removeStaffMember(String staffEntryId) async {
    if (state is! ClinicsLoaded) return;

    // إزالة العضو من البيانات الوهمية
    MockData.clinicStaff.removeWhere((cs) => cs['id'] == staffEntryId);

    // إعادة بث الحالة لتحديث الشاشات
    emit(ClinicsLoaded(clinics: _mapMockData()));
  }

  /// تحويل MockData إلى ClinicItem
  List<ClinicItem> _mapMockData() {
    return MockData.clinics.map((raw) {
      final clinicId = raw['id'] as String;

      // نجلب الإحصائيات إن وجدت
      final stats = MockData.clinicStats
          .where((s) => s['clinic_id'] == clinicId)
          .toList();

      int totalPatients = 0;
      int patientsChange = 0;
      int todayAppointments = 0;
      int todayRemaining = 0;
      int doctorsCount = 0;
      int doctorsOnLeave = 0;
      double rating = 0;
      int totalReviews = 0;
      double monthlyRevenue = 0;

      if (stats.isNotEmpty) {
        final s = stats.first;
        totalPatients = s['total_patients'] as int? ?? 0;
        patientsChange = s['patients_change'] as int? ?? 0;
        todayAppointments = s['today_appointments'] as int? ?? 0;
        todayRemaining = s['today_remaining'] as int? ?? 0;
        doctorsCount = s['doctors_count'] as int? ?? 0;
        doctorsOnLeave = s['doctors_on_leave'] as int? ?? 0;
        rating = (s['rating'] as num?)?.toDouble() ?? 0;
        totalReviews = s['total_reviews'] as int? ?? 0;
        monthlyRevenue = (s['monthly_revenue'] as num?)?.toDouble() ?? 0;
      }

      return ClinicItem(
        id: clinicId,
        ownerId: raw['owner_id'] as String? ?? '',
        name: raw['name'] as String,
        phone: raw['phone'] as String? ?? '',
        address: raw['address'] as String? ?? '',
        logoUrl: raw['logo_url'] as String?,
        isActive: true,
        totalPatients: totalPatients,
        patientsChange: patientsChange,
        todayAppointments: todayAppointments,
        todayRemaining: todayRemaining,
        doctorsCount: doctorsCount,
        doctorsOnLeave: doctorsOnLeave,
        rating: rating,
        totalReviews: totalReviews,
        monthlyRevenue: monthlyRevenue,
      );
    }).toList();
  }

  /// البحث عن عيادة بالـ ID
  static ClinicItem? findClinicById(String id) {
    final clinics = MockData.clinics.where((c) => c['id'] == id).toList();
    if (clinics.isEmpty) return null;

    final raw = clinics.first;
    final clinicId = raw['id'] as String;

    final stats = MockData.clinicStats
        .where((s) => s['clinic_id'] == clinicId)
        .toList();

    return ClinicItem(
      id: clinicId,
      ownerId: raw['owner_id'] as String? ?? '',
      name: raw['name'] as String,
      phone: raw['phone'] as String? ?? '',
      address: raw['address'] as String? ?? '',
      logoUrl: raw['logo_url'] as String?,
      isActive: true,
      totalPatients: stats.isNotEmpty ? (stats.first['total_patients'] as int? ?? 0) : 0,
      patientsChange: stats.isNotEmpty ? (stats.first['patients_change'] as int? ?? 0) : 0,
      todayAppointments: stats.isNotEmpty ? (stats.first['today_appointments'] as int? ?? 0) : 0,
      todayRemaining: stats.isNotEmpty ? (stats.first['today_remaining'] as int? ?? 0) : 0,
      doctorsCount: stats.isNotEmpty ? (stats.first['doctors_count'] as int? ?? 0) : 0,
      doctorsOnLeave: stats.isNotEmpty ? (stats.first['doctors_on_leave'] as int? ?? 0) : 0,
      rating: stats.isNotEmpty ? (stats.first['rating'] as num?)?.toDouble() ?? 0 : 0,
      totalReviews: stats.isNotEmpty ? (stats.first['total_reviews'] as int? ?? 0) : 0,
      monthlyRevenue: stats.isNotEmpty ? (stats.first['monthly_revenue'] as num?)?.toDouble() ?? 0 : 0,
    );
  }
}
