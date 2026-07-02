import 'package:injectable/injectable.dart';
import '../../../../core/services/i_cloud_service.dart';

@injectable
class InvoicesRepository {
  final ICloudService _cloud;

  InvoicesRepository(this._cloud);

  /// تحميل جميع الفواتير من قاعدة البيانات
  Future<List<Map<String, dynamic>>> loadInvoices() async {
    return await _cloud.select(table: 'invoices');
  }

  /// إنشاء فاتورة جديدة وحفظها في قاعدة البيانات
  Future<Map<String, dynamic>> createInvoice({
    required String patientId,
    required String patientName,
    required String appointmentType,
    required String sourceId,
    required double totalAmount,
    required double paidAmount,
    String? paymentMethod,
  }) async {
    final status = paidAmount >= totalAmount
        ? 'paid'
        : (paidAmount > 0 ? 'partially_paid' : 'unpaid');

    final data = {
      'clinic_id': 'c-1',
      'patient_id': patientId,
      'patient_name': patientName,
      'appointment_type': appointmentType,
      'source_id': sourceId,
      'source_type': 'appointment',
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'payment_method': paymentMethod ?? 'cash',
      'status': status,
      'created_at': DateTime.now().toIso8601String(),
      'created_by': 'u-sec-1',
    };

    return await _cloud.insert(table: 'invoices', data: data);
  }

  /// تحديث المبلغ المدفوع لفاتورة معينة وتحديث حالتها تلقائياً
  Future<void> updatePaidAmount({
    required String invoiceId,
    required double newPaidAmount,
    String? paymentMethod,
  }) async {
    // جلب بيانات الفاتورة لمعرفة الإجمالي
    final target = await _cloud.select(
      table: 'invoices',
      eq: {'id': invoiceId},
    );

    if (target.isNotEmpty) {
      final totalAmount = (target.first['total_amount'] as num).toDouble();
      final status = newPaidAmount >= totalAmount
          ? 'paid'
          : (newPaidAmount > 0 ? 'partially_paid' : 'unpaid');

      final updateData = {
        'paid_amount': newPaidAmount,
        'status': status,
      };

      if (paymentMethod != null) {
        updateData['payment_method'] = paymentMethod;
      }

      await _cloud.update(
        table: 'invoices',
        data: updateData,
        matchColumn: 'id',
        matchValue: invoiceId,
      );
    }
  }
}
