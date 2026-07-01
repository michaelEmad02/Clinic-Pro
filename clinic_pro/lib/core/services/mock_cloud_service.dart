import 'package:injectable/injectable.dart';
import 'i_cloud_service.dart';
import '../mocks/mock_data.dart';

@LazySingleton(as: ICloudService)
class MockCloudService implements ICloudService {
  @override
  Future<List<Map<String, dynamic>>> select({
    required String table,
    String columns = '*',
    Map<String, dynamic>? eq,
    Map<String, dynamic>? neq,
    String? notIsNull,
    String? order,
    bool ascending = true,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    List<Map<String, dynamic>> data = List.from(_getTableData(table));
    
    // Filtering (eq)
    if (eq != null) {
      data = data.where((item) {
        return eq.entries.every((entry) => item[entry.key] == entry.value);
      }).toList();
    }
    
    // Sorting (order)
    if (order != null) {
      data.sort((a, b) {
        final valA = a[order];
        final valB = b[order];
        if (valA == null || valB == null) return 0;
        return ascending ? valA.compareTo(valB) : valB.compareTo(valA);
      });
    }

    return data;
  }

  @override
  Future<Map<String, dynamic>> insert({
    required String table,
    required Map<String, dynamic> data,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final tableData = _getTableData(table);
    final newData = Map<String, dynamic>.from(data);
    newData['id'] = DateTime.now().millisecondsSinceEpoch.toString();
    tableData.add(newData);
    return newData;
  }

  @override
  Future<List<Map<String, dynamic>>> update({
    required String table,
    required Map<String, dynamic> data,
    required String matchColumn,
    required dynamic matchValue,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final tableData = _getTableData(table);
    final results = <Map<String, dynamic>>[];
    
    for (int i = 0; i < tableData.length; i++) {
      if (tableData[i][matchColumn] == matchValue) {
        final updatedItem = Map<String, dynamic>.from(tableData[i]);
        data.forEach((key, value) {
          updatedItem[key] = value;
        });
        tableData[i] = updatedItem;
        results.add(updatedItem);
      }
    }
    
    return results;
  }

  @override
  Future<void> delete({
    required String table,
    required String matchColumn,
    required dynamic matchValue,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    final tableData = _getTableData(table);
    tableData.removeWhere((item) => item[matchColumn] == matchValue);
  }

  @override
  Stream<List<Map<String, dynamic>>> subscribe({
    required String table,
    required String primaryKey,
    String? clinicId,
  }) {
    // محاكاة Realtime - يرسل البيانات كل 5 ثواني
    return Stream.periodic(const Duration(seconds: 5), (_) {
      List<Map<String, dynamic>> data = List.from(_getTableData(table));
      if (clinicId != null) {
        data = data.where((item) => item['clinic_id'] == clinicId).toList();
      }
      return data;
    });
  }

  // دالة مساعدة للحصول على بيانات الجدول من MockData
  List<Map<String, dynamic>> _getTableData(String table) {
    switch (table) {
      case 'users': return MockData.users;
      case 'clinics': return MockData.clinics;
      case 'clinic_staff': return MockData.clinicStaff;
      case 'patients': return MockData.patients;
      case 'appointment_types': return MockData.appointmentTypes;
      case 'appointments': return MockData.appointments;
      case 'doctor_queue_rules': return MockData.doctorQueueRules;
      case 'drugs': return MockData.drugs;
      case 'prescription_templates': return MockData.prescriptionTemplates;
      case 'prescription_template_items': return MockData.prescriptionTemplateItems;
      case 'prescriptions': return MockData.prescriptions;
      case 'prescription_items': return MockData.prescriptionItems;
      case 'expenses': return MockData.expenses;
      case 'expense_categories': return MockData.expenseCategories;
      case 'invoices': return MockData.invoices;
      case 'subscriptions': return MockData.subscriptions;
      case 'patient_visits': return MockData.patientVisits;
      case 'patient_prescription_records': return MockData.patientPrescriptionRecords;
      case 'weekly_revenue': return MockData.weeklyRevenue;
      case 'top_services': return MockData.topServices;
      case 'doctor_performance': return MockData.doctorPerformance;
      default: return [];
    }
  }
}
