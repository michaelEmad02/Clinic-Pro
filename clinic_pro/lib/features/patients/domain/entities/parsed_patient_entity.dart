// ────────────────────────────────────────────────────────
// ParsedPatientEntity — كيان بيانات المريض المستخرجة من الصوت
// يمثل نتيجة تحليل الجملة المنطوقة الخاصة بتسجيل أو تعديل مريض
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class ParsedPatientEntity extends Equatable {
  /// اسم المريض المستخرج
  final String? name;

  /// رقم الهاتف أو الجوال
  final String? phone;

  /// الجنس (male أو female)
  final String? gender;

  /// العمر بالسنوات إن ذُكر
  final int? age;

  /// تاريخ الميلاد المحسوب أو المستخرج
  final DateTime? birthDate;

  /// الحساسية المرضية أو الدوائية
  final String? allergies;

  /// الأمراض المزمنة
  final String? chronicConditions;

  /// العنوان أو محل الإقامة
  final String? address;

  /// فصيلة الدم
  final String? bloodType;

  const ParsedPatientEntity({
    this.name,
    this.phone,
    this.gender,
    this.age,
    this.birthDate,
    this.allergies,
    this.chronicConditions,
    this.address,
    this.bloodType,
  });

  @override
  List<Object?> get props => [
        name,
        phone,
        gender,
        age,
        birthDate,
        allergies,
        chronicConditions,
        address,
        bloodType,
      ];
}
