// ────────────────────────────────────────────────────────
// ExpensesEntity — كيان المصروف بـ Domain Layer
// يمثل نموذج بيانات المصروف المستقل عن أي تبعيات خارجية
// ────────────────────────────────────────────────────────

import 'package:equatable/equatable.dart';

class ExpensesEntity extends Equatable {
  final String id;
  final String clinicId;
  final String categoryId;
  final String categoryName;
  final String title;
  final double amount;
  final String? notes;
  final String? doctorId; // null = مصروف عام للعيادة، not null = مصروف خاص بالطبيب
  final String createdBy;
  final String? createdByName;
  final DateTime createdAt;

  const ExpensesEntity({
    required this.id,
    required this.clinicId,
    required this.categoryId,
    required this.categoryName,
    required this.title,
    required this.amount,
    this.notes,
    this.doctorId,
    required this.createdBy,
    this.createdByName,
    required this.createdAt,
  });

  /// هل هذا المصروف خاص بطبيب معين؟
  bool get isDoctorExpense => doctorId != null && doctorId!.isNotEmpty;

  /// هل هذا المصروف عام للعيادة/المركز؟
  bool get isClinicExpense => doctorId == null || doctorId!.isEmpty;

  /// تاريخ المصروف المنسق بالعربية
  String get formattedDate {
    final months = [
      'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو',
      'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'
    ];
    return '${createdAt.day} ${months[createdAt.month - 1]} ${createdAt.year}';
  }

  ExpensesEntity copyWith({
    String? id,
    String? clinicId,
    String? categoryId,
    String? categoryName,
    String? title,
    double? amount,
    String? notes,
    String? doctorId,
    String? createdBy,
    String? createdByName,
    DateTime? createdAt,
  }) {
    return ExpensesEntity(
      id: id ?? this.id,
      clinicId: clinicId ?? this.clinicId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      notes: notes ?? this.notes,
      doctorId: doctorId ?? this.doctorId,
      createdBy: createdBy ?? this.createdBy,
      createdByName: createdByName ?? this.createdByName,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        clinicId,
        categoryId,
        categoryName,
        title,
        amount,
        notes,
        doctorId,
        createdBy,
        createdByName,
        createdAt,
      ];
}
