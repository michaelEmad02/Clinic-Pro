import 'package:clinic_pro/core/constants/staff_roles.dart';
import 'package:clinic_pro/core/constants/supabase_constants.dart';
import 'package:clinic_pro/core/services/i_cloud_service.dart';
import 'package:clinic_pro/features/clinics/data/models/clinic_model.dart';
import 'package:clinic_pro/features/clinics/data/models/clinic_statistics_model.dart';
import 'package:clinic_pro/core/enities/performance_statistics.dart';
import 'package:clinic_pro/features/staff/data/models/doctor_secretaries_model.dart';
import 'package:clinic_pro/features/staff/data/models/staff_model.dart';
import 'package:clinic_pro/features/staff/domain/entities/staff_entity.dart';

import 'package:injectable/injectable.dart';

abstract class IClinicsRemoteDataSource {
  Future<List<ClinicModel>> fetchClinics();
  Future<ClinicModel> fetchClinicById(String id);
  Future<List<StaffEntity>> fetchClinicStaff(String clinicId);
  Future<void> addClinic(ClinicModel clinic);
  Future<void> editClinic(ClinicModel clinic);
  Future<void> deleteClinic(String id);
  Future<void> toggleIsActive(String id, bool isActive);
  Future<void> addStaff(
      String clinicId,
      String staffId,
      String? doctorId,
      StaffRoles
          role); // if the staff is new , will create it by use staff feature
  Future<void> deleteStaff(String clinicId, String staffId);
  Future<ClinicStatisticsModel> fetchClinicStatistics(String clinicId);
}

@LazySingleton(as: IClinicsRemoteDataSource)
class ClinicsRemoteDataSource extends IClinicsRemoteDataSource {
  final ICloudService iCloudService;

  ClinicsRemoteDataSource({required this.iCloudService});
  @override
  Future<void> addClinic(ClinicModel clinic) async {
    await iCloudService.insert(
        table: SupabaseTables.clinics, data: clinic.toJson());
  }

  @override
  Future<void> addStaff(String clinicId, String staffId, String? doctorId,
      StaffRoles role) async {
    var staff = StaffModel(
        id: "",
        clinicId: clinicId,
        userId: staffId,
        name: "",
        email: "",
        phone: "",
        role: role,
        isActive: true,
        joinedAt: DateTime.now());
    await iCloudService.insert(
        table: SupabaseTables.clinicStaff, data: staff.toJson());
    if (role == StaffRoles.secretary) {
      var secretary = DoctorSecretariesModel(
          id: "",
          clinicId: clinicId,
          doctorId: doctorId ?? "",
          secretaryId: staffId,
          isActive: true,
          createdAt: DateTime.now());
      await iCloudService.insert(
          table: SupabaseTables.doctorSecretaries, data: secretary.toJson());
    }
  }

  @override
  Future<void> deleteClinic(String id) async {
    await iCloudService.delete(
        table: SupabaseTables.clinics, matchColumn: 'id', matchValue: id);
  }

  @override
  Future<void> deleteStaff(String clinicId, String staffId) async {
    await iCloudService.delete(
      table: SupabaseTables.clinicStaff,
      matchMap: {
        'clinic_id': clinicId,
        'user_id': staffId,
      },
    );
  }

  @override
  Future<void> editClinic(ClinicModel clinic) async {
    await iCloudService.update(
        table: SupabaseTables.clinics,
        data: clinic.toJson(),
        matchColumn: "id",
        matchValue: clinic.id);
  }

  @override
  Future<ClinicModel> fetchClinicById(String id) async {
    var data = await iCloudService
        .select(table: SupabaseTables.clinics, eq: {"id": id});
    return data.map((clinic) => ClinicModel.fromJson(clinic)).first;
  }

  @override
  Future<ClinicStatisticsModel> fetchClinicStatistics(String clinicId) async {
    // 1. جلب عدد الأطباء من جدول موظفي العيادة (clinic_staff)
    final staffList = await iCloudService.select(
      table: SupabaseTables.clinicStaff,
      eq: {'clinic_id': clinicId, 'role': StaffRoles.doctor.name},
    );
    final numberOfDoctors = staffList.length;

    // 2. جلب مواعيد اليوم للعيادة (appointments)
    final todayStr = DateTime.now().toIso8601String().substring(0, 10);
    final appointmentsList = await iCloudService.select(
      table: SupabaseTables.appointments,
      eq: {'clinic_id': clinicId, 'date': todayStr},
    );
    final dayAppointments = appointmentsList.length;

    // 3. حساب عدد المواعيد المنتهية اليوم (status = 'done')
    final numberOfFinishedAppointments = appointmentsList
        .where((appt) => appt['status'] == AppointmentStatus.done)
        .length;

    // 4. جلب الفواتير لحساب إيرادات الأشهر الأخيرة (invoices)
    final invoicesList = await iCloudService.select(
      table: SupabaseTables.invoices,
      eq: {'clinic_id': clinicId},
    );

    final now = DateTime.now();
    final List<PerformanceStatistics> performance = [];

    // حساب الإيرادات لآخر 5 أشهر (بدءاً من الشهر الحالي)
    for (int i = 0; i < 5; i++) {
      final monthDate = DateTime(now.year, now.month - i, 1);

      final monthInvoices = invoicesList.where((invoice) {
        final createdAtStr = invoice['created_at'] as String?;
        if (createdAtStr == null) return false;
        final createdAt = DateTime.tryParse(createdAtStr);
        if (createdAt == null) return false;
        return createdAt.year == monthDate.year &&
            createdAt.month == monthDate.month;
      });

      final revenue = monthInvoices.fold<double>(
        0.0,
        (sum, invoice) =>
            sum + ((invoice['paid_amount'] ?? 0.0) as num).toDouble(),
      );

      performance.add(
        PerformanceStatistics(month: monthDate, amount: revenue),
      );
    }

    // إيرادات الشهر الحالي هي القيمة الأولى في القائمة (الشهر الحالي)
    final monthlyRevenue = performance.first.amount;

    return ClinicStatisticsModel(
      performance,
      dayAppointments: dayAppointments,
      numberOfDoctors: numberOfDoctors,
      monthlyRevenue: monthlyRevenue,
      numberOfFinishedAppointments: numberOfFinishedAppointments,
    );
  }

  @override
  Future<List<ClinicModel>> fetchClinics() async {
    var data = await iCloudService.select(table: SupabaseTables.clinics);
    return data.map((clinic) => ClinicModel.fromJson(clinic)).toList();
  }

  @override
  Future<void> toggleIsActive(String id, bool isActive) async {
    await iCloudService.update(
        table: SupabaseTables.clinics,
        data: {"is_active": isActive},
        matchColumn: "id",
        matchValue: id);
  }

  @override
  Future<List<StaffEntity>> fetchClinicStaff(String clinicId) async {
    // جلب بيانات الموظفين والمستخدمين
    final staffRows = await iCloudService
        .select(table: SupabaseTables.clinicStaff, eq: {"clinic_id": clinicId});
    final userRows = await iCloudService.select(table: 'users');

    return staffRows.map((cs) {
      final userId = cs['user_id'] as String;
      final userData = userRows.firstWhere(
        (u) => u['id'] == userId,
        orElse: () => <String, dynamic>{},
      );

      final mergedJson = {
        ...cs,
        'users': userData,
      };
      return StaffModel.fromJson(mergedJson);
    }).toList();
    // var result = await iCloudService
    //     .select(table: SupabaseTables.clinicStaff, eq: {"clinic_id": clinicId});

    // return result.map((s) => StaffModel.fromJson(s)).toList();
  }
}
