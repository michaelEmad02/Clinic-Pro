import 'dart:io';
import 'package:image/image.dart' as img;
import 'package:injectable/injectable.dart';
import 'i_image_compression_service.dart';
import 'package:path_provider/path_provider.dart';

@LazySingleton(as: IImageCompressionService)
class ImageCompressionService implements IImageCompressionService {
  @override
  Future<File> compressImage({
    required File imageFile,
    int targetWidth = 300,
    int targetHeight = 300,
    int quality = 75,
  }) async {
    try {
      // 1. قراءة الملف من الذاكرة
      final bytes = await imageFile.readAsBytes();
      
      // 2. فك ترميز الصورة
      final image = img.decodeImage(bytes);
      if (image == null) return imageFile;

      // 3. تصغير أبعاد الصورة مع الحفاظ على الأبعاد والتوسيط
      final resizedImage = img.copyResizeCropSquare(
        image,
        size: targetWidth,
      );

      // 4. ضغط الصورة كصيغة JPEG بجودة محددة
      final compressedBytes = img.encodeJpg(resizedImage, quality: quality);

      // 5. حفظ الصورة المؤقتة في مجلد الكاش الخاص بالتطبيق
      final tempDir = await getTemporaryDirectory();
      final compressedFile = File(
        '${tempDir.path}/compressed_${DateTime.now().millisecondsSinceEpoch}.jpg',
      );
      
      await compressedFile.writeAsBytes(compressedBytes);
      return compressedFile;
    } catch (e) {
      // في حالة حدوث خطأ نرجع الملف الأصلي لحماية سير التطبيق
      return imageFile;
    }
  }
}
