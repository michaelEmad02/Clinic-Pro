abstract class ISecretaryDashboardRemoteDataSource {
  Future<Map<String, dynamic>> fetchSecretaryDashboardData({
    required String secretaryId,
    required String clinicId,
    String? secretaryName,
    String? clinicName,
  });
}
