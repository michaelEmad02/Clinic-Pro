// ────────────────────────────────────────────────────────
// تنفيذ خدمة التخزين عبر Supabase Storage
// يتعامل مع رفع وحذف الملفات وجلب الروابط العامة
// ────────────────────────────────────────────────────────

import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'i_storage_service.dart';

@LazySingleton(as: IStorageService)
class SupabaseStorageService implements IStorageService {
  final SupabaseClient _client;

  SupabaseStorageService(this._client);

  @override
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required Uint8List fileBytes,
    String? contentType,
  }) async {
    // رفع الملف إلى المسار المحدد (يُستبدل تلقائياً إن كان موجوداً)
    await _client.storage.from(bucket).uploadBinary(
          path,
          fileBytes,
          fileOptions: FileOptions(
            upsert: true,
            contentType: contentType ?? 'image/jpeg',
          ),
        );

    // إرجاع الرابط العام بعد الرفع
    return getPublicUrl(bucket: bucket, path: path);
  }

  @override
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    await _client.storage.from(bucket).remove([path]);
  }

  @override
  String getPublicUrl({
    required String bucket,
    required String path,
  }) {
    return _client.storage.from(bucket).getPublicUrl(path);
  }
}
