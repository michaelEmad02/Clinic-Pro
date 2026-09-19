import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/services/regex_voice_extraction_service_impl.dart';
import 'package:clinic_pro/core/utils/arabic_text_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = RegexVoiceExtractionServiceImpl();

  test('User case 1: مريض اسمه احمد محمد عمره 30 سنه فصيلة دمه A plus', () async {
    final result = await service.extractData(
      text: 'مريض اسمه احمد محمد عمره 30 سنه فصيلة دمه A plus',
      target: ExtractionTarget.patient,
    );

    expect(result['name'], 'احمد محمد');
    expect(result['age'], 30);
    expect(result['bloodType'], 'A+');
    expect(result['gender'], 'male');
  });

  test('User case 2: فصيلة الدم o- with multiple patient details', () async {
    final result = await service.extractData(
      text: 'مريض اسمه احمد محمد عمره 30 فصيلة الدم o- وعنده سكر وساكن في المعادي',
      target: ExtractionTarget.patient,
    );

    expect(result['name'], 'احمد محمد');
    expect(result['age'], 30);
    expect(result['bloodType'], 'O-');
    expect(result['chronicConditions'], contains('سكري'));
    expect(result['address'], contains('المعادي'));
  });

  test('All standalone and spoken variants of O- are recognized', () {
    final variants = [
      'o-',
      'O-',
      'o -',
      'O -',
      'O negative',
      'o minus',
      'او سالب',
      'أو سالب',
      'او ناقص',
      'أو ناقص',
      'او ماينس',
      'او ماينص',
      'او نيجاتيف',
      'او نيجاتف',
      'سالب او',
      'سالب أو',
      'فصيلة الدم o-',
      'فصيلة دمه o-',
      'فصيلته o-',
      'فصيلة دم أو سالب',
      'فصيلة الدم او ناقص',
    ];

    for (final v in variants) {
      final res = ArabicTextHelper.extractBloodType(v);
      expect(res?.bloodType, 'O-', reason: 'Failed on variant: "$v"');
    }
  });

  test('Patient with phone number and other blood types', () async {
    final result = await service.extractData(
      text: 'سجل مريض جديد اسمه أحمد طارق تليفونه 01012345678 عمره 35 فصيلة دمه بي موجب وعنده حساسية من البنسلين',
      target: ExtractionTarget.patient,
    );

    expect(result['name'], 'أحمد طارق');
    expect(result['phone'], '01012345678');
    expect(result['age'], 35);
    expect(result['bloodType'], 'B+');
    expect(result['allergies'], 'البنسلين');
  });

  test('Female patient with AB negative and chronic conditions', () async {
    final result = await service.extractData(
      text: 'مريضة اسمها سارة إبراهيم عمرها 24 سنة فصيلة دمها اي بي سالب وعندها سكر وضغط',
      target: ExtractionTarget.patient,
    );

    expect(result['name'], 'سارة إبراهيم');
    expect(result['gender'], 'female');
    expect(result['bloodType'], 'AB-');
    expect(result['chronicConditions'], contains('سكري'));
    expect(result['chronicConditions'], contains('ضغط دم'));
  });
}
