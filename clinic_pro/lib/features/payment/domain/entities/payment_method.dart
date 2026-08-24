// ────────────────────────────────────────────────────────
// طرق الدفع المتاحة عبر بوابة الدفع (PaymentMethod Entity)
// ────────────────────────────────────────────────────────

/// طرق الدفع المتاحة عبر Paymob
enum PaymentMethod {
  card,       // بطاقة بنكية (Visa / Mastercard)
  wallet,     // محفظة إلكترونية (فودافون كاش)
  fawry,      // فوري (كود دفع)
}

/// تمديد لـ PaymentMethod لإضافة خصائص مساعدة
extension PaymentMethodExtension on PaymentMethod {
  /// القيمة النصية المُرسلة للسيرفر
  String get value {
    switch (this) {
      case PaymentMethod.card:
        return 'card';
      case PaymentMethod.wallet:
        return 'wallet';
      case PaymentMethod.fawry:
        return 'fawry';
    }
  }

  /// الاسم المعروض بالعربية
  String get arabicName {
    switch (this) {
      case PaymentMethod.card:
        return 'بطاقة بنكية';
      case PaymentMethod.wallet:
        return 'محفظة إلكترونية';
      case PaymentMethod.fawry:
        return 'فوري';
    }
  }

  /// إنشاء من نص
  static PaymentMethod fromString(String value) {
    switch (value.toLowerCase()) {
      case 'wallet':
        return PaymentMethod.wallet;
      case 'fawry':
        return PaymentMethod.fawry;
      case 'card':
      default:
        return PaymentMethod.card;
    }
  }
}
