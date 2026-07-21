// ────────────────────────────────────────────────────────
// واجهة خدمة التخزين (IStorageService)
// تفصل بين منطق التطبيق ومكتبة Supabase Storage
// ────────────────────────────────────────────────────────

import 'dart:typed_data';

abstract class IStorageService {
  /// رفع ملف إلى Supabase Storage وإرجاع الرابط العام (Public URL)
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  });

  /// حذف ملف من Supabase Storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  });

  /// جلب الرابط العام لملف مخزن
  String getPublicUrl({
    required String bucket,
    required String path,
  });
}
