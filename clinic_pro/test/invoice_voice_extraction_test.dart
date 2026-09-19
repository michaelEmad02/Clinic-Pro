import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/services/regex_voice_extraction_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = RegexVoiceExtractionServiceImpl();

  test('Invoice 1: فاتورة للمريض أحمد محمد بمبلغ 300 كاش', () async {
    final res = await service.extractData(
      text: 'فاتورة للمريض أحمد محمد بمبلغ 300 كاش',
      target: ExtractionTarget.invoice,
    );

    expect(res['patientName'], 'أحمد محمد');
    expect(res['totalAmount'], 300.0);
    expect(res['paidAmount'], 300.0);
    expect(res['paymentMethod'], 'cash');
  });

  test('Invoice 2: فاتورة كشف 400 جنيه دفع 250 فيزا والباقي بعدين للمريض محمود عبد الرحمن', () async {
    final res = await service.extractData(
      text: 'فاتورة كشف 400 جنيه دفع 250 فيزا للمريض محمود عبد الرحمن',
      target: ExtractionTarget.invoice,
    );

    expect(res['patientName'], 'محمود عبد الرحمن');
    expect(res['totalAmount'], 400.0);
    expect(res['paidAmount'], 250.0);
    expect(res['paymentMethod'], 'card');
  });

  test('Invoice 3: كشف 500 ريال تحويل بنكي للمريض 0501234567', () async {
    final res = await service.extractData(
      text: 'كشف 500 ريال تحويل بنكي للمريض 0501234567',
      target: ExtractionTarget.invoice,
    );

    expect(res['patientPhone'], '0501234567');
    expect(res['totalAmount'], 500.0);
    expect(res['paidAmount'], 500.0);
    expect(res['paymentMethod'], 'bank');
  });

  test('Invoice 4 with discount: كشف 300 وخصم 50 نقدي للمريضة سارة علي', () async {
    final res = await service.extractData(
      text: 'كشف 300 وخصم 50 نقدي للمريضة سارة علي',
      target: ExtractionTarget.invoice,
    );

    expect(res['patientName'], 'سارة علي');
    expect(res['discount'], 50.0);
    expect(res['totalAmount'], 250.0);
    expect(res['paidAmount'], 250.0);
    expect(res['paymentMethod'], 'cash');
  });

  test('Invoice 5 by phone only: فاتورة لرقم 01012345678 بمبلغ 300 كاش', () async {
    final res = await service.extractData(
      text: 'فاتورة لرقم 01012345678 بمبلغ 300 كاش',
      target: ExtractionTarget.invoice,
    );

    expect(res['patientPhone'], '01012345678');
    expect(res['patientName'], isNull);
    expect(res['totalAmount'], 300.0);
    expect(res['paidAmount'], 300.0);
    expect(res['paymentMethod'], 'cash');
  });

  test('Invoice 6 with صاحب الرقم: فاتورة للمريض صاحب الرقم 01112233445 كشف 200 جنيه فيزا', () async {
    final res = await service.extractData(
      text: 'فاتورة للمريض صاحب الرقم 01112233445 كشف 200 جنيه فيزا',
      target: ExtractionTarget.invoice,
    );
    expect(res['patientPhone'], '01112233445');
    expect(res['patientName'], isNull);
    expect(res['totalAmount'], 200.0);
    expect(res['paidAmount'], 200.0);
    expect(res['paymentMethod'], 'card');
  });

  test('Invoice 7 with both name and phone: فاتورة للمريض أحمد علي صاحب الرقم 01099887766 بمبلغ 350 كاش', () async {
    final res = await service.extractData(
      text: 'فاتورة للمريض أحمد علي صاحب الرقم 01099887766 بمبلغ 350 كاش',
      target: ExtractionTarget.invoice,
    );

    expect(res['patientName'], 'أحمد علي');
    expect(res['patientPhone'], '01099887766');
    expect(res['totalAmount'], 350.0);
    expect(res['paidAmount'], 350.0);
    expect(res['paymentMethod'], 'cash');
  });

  test('Invoice 8: اعمل فاتورة لمريض احمد محمد بقيمه 100 جنيه', () async {
    final res = await service.extractData(
      text: 'اعمل فاتورة لمريض احمد محمد بقيمه 100 جنيه',
      target: ExtractionTarget.invoice,
    );

    expect(res['patientName'], 'احمد محمد');
    expect(res['totalAmount'], 100.0);
    expect(res['paidAmount'], 100.0);
    expect(res['paymentMethod'], 'cash');
  });

  test('Invoice 9 by phone without name: اعمل فاتورة للمريض 01012345678 بقيمه 100 جنيه', () async {
    final res = await service.extractData(
      text: 'اعمل فاتورة للمريض 01012345678 بقيمه 100 جنيه',
      target: ExtractionTarget.invoice,
    );

    expect(res['patientPhone'], '01012345678');
    expect(res['patientName'], isNull);
    expect(res['totalAmount'], 100.0);
    expect(res['paidAmount'], 100.0);
    expect(res['paymentMethod'], 'cash');
  });

  test('Invoice 10 spoken phone: فاتورة لرقم زيرو عشرة تسعة تسعة تمانية سبعة ستة خمسة اربعة تلاتة كشف 150', () async {
    final res = await service.extractData(
      text: 'فاتورة لرقم زيرو عشرة تسعة تسعة تمانية سبعة ستة خمسة اربعة تلاتة كشف 150',
      target: ExtractionTarget.invoice,
    );

    expect(res['patientPhone'], '01099876543');
    expect(res['patientName'], isNull);
    expect(res['totalAmount'], 150.0);
    expect(res['paidAmount'], 150.0);
  });
}
