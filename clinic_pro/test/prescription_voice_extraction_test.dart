import 'package:clinic_pro/core/services/i_voice_extraction_service.dart';
import 'package:clinic_pro/core/services/regex_voice_extraction_service_impl.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late RegexVoiceExtractionServiceImpl service;

  setUp(() {
    service = RegexVoiceExtractionServiceImpl();
  });

  final sampleDrugs = [
    {
      'id': 'drug-1',
      'trade_name': 'Augmentin 1g',
      'generic_name': 'Amoxicillin / Clavulanic Acid',
      'category': 'Antibiotic',
    },
    {
      'id': 'drug-2',
      'trade_name': 'Panadol Extra',
      'generic_name': 'Paracetamol',
      'category': 'Analgesic',
    },
    {
      'id': 'drug-3',
      'trade_name': 'Cataflam 50mg',
      'generic_name': 'Diclofenac Potassium',
      'category': 'NSAID',
    },
    {
      'id': 'drug-4',
      'trade_name': 'كونجستال',
      'generic_name': 'Paracetamol / Pseudoephedrine',
      'category': 'Cold and Flu',
    },
  ];

  final sampleTemplates = [
    {
      'id': 'tmpl-1',
      'name': 'نزلات البرد والإنفلونزا',
    },
    {
      'id': 'tmpl-2',
      'name': 'Hypertension Protocol',
    },
  ];

  group('Prescription Voice Extraction Tests', () {
    test('Extracts diagnosis, follow-up, and drugs with dosages in Arabic (cross-language matching with English drugs in DB)', () async {
      const text = 'التشخيص التهاب رئوي حاد اكتب أوجمنتين مرتين يوميا بعد الأكل لمدة 7 أيام و بنادول عند اللزوم الاستشارة بعد أسبوع ملاحظات الراحة التامة وشرب السوائل';

      final result = await service.extractData(
        text: text,
        target: ExtractionTarget.prescription,
        extraContext: {
          'drugs': sampleDrugs,
          'templates': sampleTemplates,
        },
      );

      expect(result['diagnosis'], 'التهاب رئوي حاد');
      expect(result['nextVisitDays'], 7);
      expect(result['clearNextVisitDays'], false);
      expect(result['notes'], contains('الراحة التامة'));

      final drugs = result['drugs'] as List<Map<String, dynamic>>;
      expect(drugs.length, 2);

      // 1st drug: Augmentin (matched from spoken "أوجمنتين")
      expect(drugs[0]['id'], 'drug-1');
      expect(drugs[0]['tradeName'], 'Augmentin 1g');
      expect(drugs[0]['doseFrequency'], 2);
      expect(drugs[0]['doseTiming'], 'after_meal');
      expect(drugs[0]['doseDuration'], 7);
      expect(drugs[0]['isPrn'], false);

      // 2nd drug: Panadol (matched from spoken "بنادول")
      expect(drugs[1]['id'], 'drug-2');
      expect(drugs[1]['isPrn'], true);
      expect(drugs[1]['doseFrequency'], isNull);
    });

    test('Extracts prescription in English with cross-language drug and template matching', () async {
      const text = 'Diagnosis: Acute Bronchitis. Prescribe Augmentin twice daily after meal for 7 days, and Panadol as needed. Follow up in two weeks. Notes: Drink plenty of warm liquids.';

      final result = await service.extractData(
        text: text,
        target: ExtractionTarget.prescription,
        extraContext: {
          'drugs': sampleDrugs,
          'templates': sampleTemplates,
        },
      );

      expect(result['diagnosis'], 'Acute Bronchitis.');
      expect(result['nextVisitDays'], 14);
      expect(result['notes'], contains('Drink plenty of warm liquids'));

      final drugs = result['drugs'] as List<Map<String, dynamic>>;
      expect(drugs.length, 2);
      expect(drugs[0]['id'], 'drug-1');
      expect(drugs[0]['doseFrequency'], 2);
      expect(drugs[0]['doseTiming'], 'after_meal');
      expect(drugs[0]['doseDuration'], 7);

      expect(drugs[1]['id'], 'drug-2');
      expect(drugs[1]['isPrn'], true);
    });

    test('Template matching when doctor says "قالب نزلات البرد"', () async {
      const text = 'تطبيق قالب نزلات البرد والإنفلونزا الاستشارة بعد أسبوعين';

      final result = await service.extractData(
        text: text,
        target: ExtractionTarget.prescription,
        extraContext: {
          'drugs': sampleDrugs,
          'templates': sampleTemplates,
        },
      );

      expect(result['appliedTemplateId'], 'tmpl-1');
      expect(result['appliedTemplateName'], 'نزلات البرد والإنفلونزا');
      expect(result['nextVisitDays'], 14);
    });

    test('Template matching when English template name is spoken in English or Arabic', () async {
      const text = 'استخدم قالب Hypertension Protocol';

      final result = await service.extractData(
        text: text,
        target: ExtractionTarget.prescription,
        extraContext: {
          'drugs': sampleDrugs,
          'templates': sampleTemplates,
        },
      );

      expect(result['appliedTemplateId'], 'tmpl-2');
      expect(result['appliedTemplateName'], 'Hypertension Protocol');
    });

    test('Does NOT match template accidentally when template word is NOT used', () async {
      const text = 'التشخيص نزلات البرد اكتب كونجستال قرص 3 مرات يوميا بعد الاكل';

      final result = await service.extractData(
        text: text,
        target: ExtractionTarget.prescription,
        extraContext: {
          'drugs': sampleDrugs,
          'templates': sampleTemplates,
        },
      );

      expect(result['appliedTemplateId'], isNull);
      expect(result['diagnosis'], 'نزلات البرد');

      final drugs = result['drugs'] as List<Map<String, dynamic>>;
      expect(drugs.length, 1);
      expect(drugs[0]['id'], 'drug-4');
      expect(drugs[0]['doseFrequency'], 3);
      expect(drugs[0]['doseTiming'], 'after_meal');
    });

    test('Handles cancellation of follow up (بدون استشارة)', () async {
      const text = 'التشخيص سليم تماما بدون استشارة';

      final result = await service.extractData(
        text: text,
        target: ExtractionTarget.prescription,
        extraContext: {
          'drugs': sampleDrugs,
          'templates': sampleTemplates,
        },
      );

      expect(result['clearNextVisitDays'], true);
      expect(result['nextVisitDays'], isNull);
    });

    test('Cross language: doctor speaks Arabic for Arabic DB drug "كونجستال"', () async {
      const text = 'اكتب كونجستال 3 مرات في اليوم قبل الأكل لمدة 5 أيام';

      final result = await service.extractData(
        text: text,
        target: ExtractionTarget.prescription,
        extraContext: {
          'drugs': sampleDrugs,
        },
      );

      final drugs = result['drugs'] as List<Map<String, dynamic>>;
      expect(drugs.length, 1);
      expect(drugs[0]['id'], 'drug-4');
      expect(drugs[0]['doseFrequency'], 3);
      expect(drugs[0]['doseTiming'], 'before_meal');
      expect(drugs[0]['doseDuration'], 5);
    });

    test('Cross language: doctor speaks "كتافلام" for "Cataflam 50mg"', () async {
      const text = 'اكتب كتافلام قرص بعد الاكل عند اللزوم';

      final result = await service.extractData(
        text: text,
        target: ExtractionTarget.prescription,
        extraContext: {
          'drugs': sampleDrugs,
        },
      );

      final drugs = result['drugs'] as List<Map<String, dynamic>>;
      expect(drugs.length, 1);
      expect(drugs[0]['id'], 'drug-3');
      expect(drugs[0]['isPrn'], true);
      expect(drugs[0]['doseTiming'], 'after_meal');
    });
  });
}
