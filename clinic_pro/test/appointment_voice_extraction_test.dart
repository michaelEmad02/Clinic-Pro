import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/services/regex_voice_extraction_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final service = RegexVoiceExtractionServiceImpl();

  test('Appointment 1: احجز موعد للمريض أحمد محمد بكرة الساعة 5 مساءً كشف عادي', () async {
    final res = await service.extractData(
      text: 'احجز موعد للمريض أحمد محمد بكرة الساعة 5 مساءً كشف عادي',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'أحمد محمد');
    expect(res['type'], 'examination');
    expect(res['visitTypeHint'], 'كشف');
    expect(res['isUrgent'], isFalse);
    expect(res['timeHour'], 17);
    expect(res['timeMinute'], 0);
    expect(res['timeString'], '17:00');

    final now = DateTime.now();
    final expectedTomorrow = DateTime(now.year, now.month, now.day + 1);
    final date = res['date'] as DateTime?;
    expect(date, isNotNull);
    expect(date!.year, expectedTomorrow.year);
    expect(date.month, expectedTomorrow.month);
    expect(date.day, expectedTomorrow.day);
  });

  test('Appointment 2: حجز للمريضة سارة علي يوم السبت الساعة 10 الصبح استشارة', () async {
    final res = await service.extractData(
      text: 'حجز للمريضة سارة علي يوم السبت الساعة 10 الصبح استشارة',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'سارة علي');
    expect(res['type'], 'consultation');
    expect(res['visitTypeHint'], 'استشارة');
    expect(res['isUrgent'], isFalse);
    expect(res['timeHour'], 10);
    expect(res['timeMinute'], 0);
    expect(res['timeString'], '10:00');

    final date = res['date'] as DateTime?;
    expect(date, isNotNull);
    expect(date!.weekday, DateTime.saturday);
  });

  test('Appointment 3: موعد مستعجل للمريض 01012345678 اليوم الساعة 4 ونص طوارئ', () async {
    final res = await service.extractData(
      text: 'موعد مستعجل للمريض 01012345678 اليوم الساعة 4 ونص طوارئ',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientPhone'], '01012345678');
    expect(res['patientName'], isNull);
    expect(res['isUrgent'], isTrue);
    expect(res['type'], 'emergency');
    expect(res['timeHour'], 16);
    expect(res['timeMinute'], 30);
    expect(res['timeString'], '16:30');

    final now = DateTime.now();
    final date = res['date'] as DateTime?;
    expect(date, isNotNull);
    expect(date!.year, now.year);
    expect(date.month, now.month);
    expect(date.day, now.day);
  });

  test('Appointment 4: احجز لمريض Peter بعد بكرة الساعة 7 بالليل يشتكي من ألم بالأسنان', () async {
    final res = await service.extractData(
      text: 'احجز لمريض Peter بعد بكرة الساعة 7 بالليل يشتكي من ألم بالأسنان',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'Peter');
    expect(res['timeHour'], 19);
    expect(res['timeMinute'], 0);
    expect(res['timeString'], '19:00');
    expect(res['notes'], 'ألم بالأسنان');

    final now = DateTime.now();
    final expectedAfterTomorrow = DateTime(now.year, now.month, now.day + 2);
    final date = res['date'] as DateTime?;
    expect(date, isNotNull);
    expect(date!.year, expectedAfterTomorrow.year);
    expect(date.month, expectedAfterTomorrow.month);
    expect(date.day, expectedAfterTomorrow.day);
  });

  test('Appointment 5 with spoken numbers: احجز للمريض مايكل عماد كشف يوم التلات الساعة اتنين ونص الظهر', () async {
    final res = await service.extractData(
      text: 'احجز للمريض مايكل عماد كشف يوم التلات الساعة اتنين ونص الظهر',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'مايكل عماد');
    expect(res['type'], 'examination');
    expect(res['timeHour'], 14);
    expect(res['timeMinute'], 30);

    final date = res['date'] as DateTime?;
    expect(date, isNotNull);
    expect(date!.weekday, DateTime.tuesday);
  });

  test('Appointment 6: موعد كشف للمريض محمود عبد الرحمن يوم 15/10 الساعة ستة وربع المغرب', () async {
    final res = await service.extractData(
      text: 'موعد كشف للمريض محمود عبد الرحمن يوم 15/10 الساعة ستة وربع المغرب',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'محمود عبد الرحمن');
    expect(res['type'], 'examination');
    expect(res['timeHour'], 18);
    expect(res['timeMinute'], 15);

    final date = res['date'] as DateTime?;
    expect(date, isNotNull);
    expect(date!.month, 10);
    expect(date.day, 15);
  });

  test('Appointment 7: كشف مستعجل لا يفعل isUrgent ولكن يختار نوع الزيارة كشف مستعجل', () async {
    final res = await service.extractData(
      text: 'احجز كشف مستعجل للمريض عمر طارق اليوم الساعة 6 إلا ربع',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'عمر طارق');
    expect(res['isUrgent'], isFalse); // كشف مستعجل لا يفعل isUrgent
    expect(res['visitTypeHint'], 'كشف مستعجل');
    expect(res['type'], 'urgent_examination');
    expect(res['timeHour'], 17);
    expect(res['timeMinute'], 45);

    final now = DateTime.now();
    final date = res['date'] as DateTime?;
    expect(date, isNotNull);
    expect(date!.day, now.day);
  });

  test('Appointment 8 by phone: احجز لمريض 01112233445 كشف', () async {
    final res = await service.extractData(
      text: 'احجز لمريض 01112233445 كشف',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientPhone'], '01112233445');
    expect(res['patientName'], isNull);
    expect(res['type'], 'examination');
  });

  test('Appointment 9 spoken phone: احجز لرقم زيرو عشرة تسعة تسعة تمانية سبعة ستة خمسة اربعة تلاتة موعد كشف', () async {
    final res = await service.extractData(
      text: 'احجز لرقم زيرو عشرة تسعة تسعة تمانية سبعة ستة خمسة اربعة تلاتة موعد كشف',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientPhone'], '01099876543');
    expect(res['patientName'], isNull);
    expect(res['type'], 'examination');
  });

  test('Appointment 10 with except 20 mins: احجز للمريض كريم يوسف الساعة 7 إلا ثلث', () async {
    final res = await service.extractData(
      text: 'احجز للمريض كريم يوسف الساعة 7 إلا ثلث',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'كريم يوسف');
    expect(res['timeHour'], 18);
    expect(res['timeMinute'], 40);
  });

  test('Appointment 11 with symptoms notes: احجز لمريض خالد حسن بكرة الساعة 6 عنده حساسية صدرية', () async {
    final res = await service.extractData(
      text: 'احجز لمريض خالد حسن بكرة الساعة 6 عنده حساسية صدرية',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'خالد حسن');
    expect(res['timeHour'], 18);
    expect(res['notes'], 'حساسية صدرية');
  });

  test('Appointment 12 English sentence: Book appointment for Michael Emad tomorrow at 4 pm', () async {
    final res = await service.extractData(
      text: 'Book appointment for Michael Emad tomorrow at 4 pm',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'Michael Emad');
    expect(res['timeHour'], 16);
    expect(res['timeMinute'], 0);
  });

  test('Appointment 13 كلمة مريض قبل الاسم بدون موعد أو حجز: مريض أحمد محمد كشف بكرة الساعة 5', () async {
    final res = await service.extractData(
      text: 'مريض أحمد محمد كشف بكرة الساعة 5',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'أحمد محمد');
    expect(res['type'], 'examination');
    expect(res['visitTypeHint'], 'كشف');
    expect(res['timeHour'], 17);
  });

  test('Appointment 14 كلمة مريضة قبل الاسم بدون موعد أو حجز: مريضة سارة علي استشارة يوم السبت', () async {
    final res = await service.extractData(
      text: 'مريضة سارة علي استشارة يوم السبت',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'سارة علي');
    expect(res['type'], 'consultation');
    expect(res['visitTypeHint'], 'استشارة');
  });

  test('Appointment 15 حالة طارئة تفعل isUrgent: حالة طارئة لمريض أحمد مصطفى اليوم الساعة 4', () async {
    final res = await service.extractData(
      text: 'حالة طارئة لمريض أحمد مصطفى اليوم الساعة 4',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'أحمد مصطفى');
    expect(res['isUrgent'], isTrue);
    expect(res['timeHour'], 16);
  });

  test('Appointment 16 كشف مستعجل مع حالة طارئة: كشف مستعجل حالة طارئة للمريض محمود حسن', () async {
    final res = await service.extractData(
      text: 'كشف مستعجل حالة طارئة للمريض محمود حسن',
      target: ExtractionTarget.appointment,
    );

    expect(res['patientName'], 'محمود حسن');
    expect(res['visitTypeHint'], 'كشف مستعجل');
    expect(res['isUrgent'], isTrue);
  });
}

