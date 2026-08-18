/// واجهة مصدر بيانات لوحة تحكم الطبيب البعيد (Remote Data Source Interface)
abstract class IDoctorDashboardRemoteDataSource {
  Future<Map<String, dynamic>> fetchDoctorDashboardData({
    required String doctorId,
    required String clinicId,
    String? doctorName,
    String? clinicName,
  });
}
