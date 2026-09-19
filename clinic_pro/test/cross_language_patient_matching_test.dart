import 'package:clinic_pro/core/utils/arabic_text_helper.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Cross-Language Name Matching Tests (Arabic <-> English)', () {
    test('Arabic to English: أحمد محمد <-> Ahmed Mohamed', () {
      expect(ArabicTextHelper.isSameOrMatchingName('Ahmed Mohamed', 'أحمد محمد'), isTrue);
      expect(ArabicTextHelper.isSameOrMatchingName('أحمد محمد', 'Ahmed Mohamed'), isTrue);
      expect(ArabicTextHelper.isSameOrMatchingName('Ahmad Mohammed', 'احمد محمد'), isTrue);
    });

    test('Arabic to English: سارة علي <-> Sarah Ali', () {
      expect(ArabicTextHelper.isSameOrMatchingName('Sarah Ali', 'سارة علي'), isTrue);
      expect(ArabicTextHelper.isSameOrMatchingName('Sara Aly', 'ساره علي'), isTrue);
    });

    test('Arabic to English: مايكل عماد <-> Michael Emad', () {
      expect(ArabicTextHelper.isSameOrMatchingName('Michael Emad', 'مايكل عماد'), isTrue);
      expect(ArabicTextHelper.isSameOrMatchingName('مايكل عماد', 'Michael Imad'), isTrue);
    });

    test('Arabic to English: مصطفى كامل <-> Mostafa Kamel', () {
      expect(ArabicTextHelper.isSameOrMatchingName('Mostafa Kamel', 'مصطفى كامل'), isTrue);
      expect(ArabicTextHelper.isSameOrMatchingName('Mustafa Kamil', 'مصطفي كامل'), isTrue);
    });

    test('Arabic to English: يوسف حسن <-> Youssef Hassan', () {
      expect(ArabicTextHelper.isSameOrMatchingName('Youssef Hassan', 'يوسف حسن'), isTrue);
      expect(ArabicTextHelper.isSameOrMatchingName('Yousef Hasan', 'يوسف حسن'), isTrue);
    });

    test('Arabic to English: مينا فادي <-> Mina Fady', () {
      expect(ArabicTextHelper.isSameOrMatchingName('Mina Fady', 'مينا فادي'), isTrue);
      expect(ArabicTextHelper.isSameOrMatchingName('Mina Fadi', 'مينا فادي'), isTrue);
    });

    test('Arabic to English: بيتر جورج <-> Peter George', () {
      expect(ArabicTextHelper.isSameOrMatchingName('Peter George', 'بيتر جورج'), isTrue);
    });

    test('Sub-name match: أحمد محمد matches Ahmed Mohamed Ali', () {
      expect(ArabicTextHelper.isSameOrMatchingName('Ahmed Mohamed Ali', 'أحمد محمد'), isTrue);
    });

    test('Non-matching names return false', () {
      expect(ArabicTextHelper.isSameOrMatchingName('Ahmed Mohamed', 'محمود السيد'), isFalse);
      expect(ArabicTextHelper.isSameOrMatchingName('Sarah Ali', 'منى حسن'), isFalse);
      expect(ArabicTextHelper.isSameOrMatchingName('Peter George', 'مينا كمال'), isFalse);
    });
  });
}
