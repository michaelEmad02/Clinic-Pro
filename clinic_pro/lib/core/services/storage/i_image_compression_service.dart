import 'dart:io';

abstract class IImageCompressionService {
  /// ضغط وتقليل حجم الصورة مع تغيير أبعادها محلياً
  /// [imageFile] هو الملف الأصلي المختار
  /// [targetWidth] العرض المطلوب
  /// [targetHeight] الارتفاع المطلوب
  /// [quality] جودة الضغط المطلوبة (من 1 إلى 100)
  /// يُرجع الملف الجديد المضغوط المؤقت.
  Future<File> compressImage({
    required File imageFile,
    int targetWidth = 300,
    int targetHeight = 300,
    int quality = 75,
  });

  /// ضغط مستند أو فحص طبي (تحليل / أشعة) مع الحفاظ على الأبعاد الأصلية ووضوح النصوص
  Future<File> compressDocumentImage({
    required File imageFile,
    int maxWidth = 1600,
    int maxHeight = 2000,
    int quality = 80,
  });
}
