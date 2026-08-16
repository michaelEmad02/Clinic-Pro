// ────────────────────────────────────────────────────────
// مصدر البيانات البعيدة للاشتراكات (SubscriptionsRemoteDataSource)
// ────────────────────────────────────────────────────────

import 'package:injectable/injectable.dart';
import '../../../../core/constants/supabase_constants.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../models/plan_model.dart';
import '../models/subscription_model.dart';

abstract class ISubscriptionsRemoteDataSource {
  Future<List<PlanModel>> getPlans();
  Future<SubscriptionModel?> getActiveSubscription(String ownerId);
  Future<SubscriptionModel> requestSubscription(SubscriptionModel model);
  Future<void> updateSubscriptionStatus(String subscriptionId, String status);
  Future<CompanyInfoModel> getCompanyInfo();
  Future<Map<String, int>> getSubscriptionUsage(String ownerId);
}

@LazySingleton(as: ISubscriptionsRemoteDataSource)
class SubscriptionsRemoteDataSource implements ISubscriptionsRemoteDataSource {
  final ICloudService _cloudService;

  SubscriptionsRemoteDataSource(this._cloudService);

  @override
  Future<List<PlanModel>> getPlans() async {
    try {
      final plansRaw = await _cloudService.select(table: SupabaseTables.plans);
      final featuresRaw =
          await _cloudService.select(table: SupabaseTables.plansFeatures);

      final List<PlanModel> plans = [];
      for (final planJson in plansRaw) {
        final planId = planJson['id'] as String;
        final featJson = featuresRaw.firstWhere(
          (f) => f['plan_id'] == planId,
          orElse: () => <String, dynamic>{},
        );
        PlanFeaturesModel? featModel;
        if (featJson.isNotEmpty) {
          featModel = PlanFeaturesModel.fromJson(featJson);
        }
        plans.add(PlanModel.fromJson(planJson, features: featModel));
      }
      return plans;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<SubscriptionModel?> getActiveSubscription(String ownerId) async {
    try {
      final result = await _cloudService.select(
        table: SupabaseTables.subscriptions,
        eq: {'owner_id': ownerId},
      );
      if (result.isEmpty) return null;
      // ترطيب الأخير حسب تاريخ الإنشاء
      result.sort((a, b) =>
          (b['created_at'] as String).compareTo(a['created_at'] as String));
      return SubscriptionModel.fromJson(result.first);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<SubscriptionModel> requestSubscription(SubscriptionModel model) async {
    try {
      // إنشاء سطر جديد بـ status: pending باستخدام نموذج SubscriptionModel

      final inserted = await _cloudService.insert(
        table: SupabaseTables.subscriptions,
        data: model.toJson(),
      );
      return SubscriptionModel.fromJson(inserted);
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<void> updateSubscriptionStatus(
      String subscriptionId, String status) async {
    try {
      await _cloudService.update(
        table: SupabaseTables.subscriptions,
        matchColumn: 'id',
        matchValue: subscriptionId,
        data: {'status': status},
      );
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  @override
  Future<CompanyInfoModel> getCompanyInfo() async {
    try {
      final result =
          await _cloudService.select(table: SupabaseTables.companyInfo);
      if (result.isNotEmpty) {
        return CompanyInfoModel.fromJson(result.first);
      }
      // إرجاع قيمة افتراضية في حالة الشريحة الأولى قبل ملء السجل في الداتا بيز
      return const CompanyInfoModel(
        id: 'default',
        name: 'Clinic Pro Support',
        phone1: '+201000000000',
        whatsApp1: '+201000000000',
      );
    } catch (_) {
      return const CompanyInfoModel(
        id: 'default',
        name: 'Clinic Pro Support',
        phone1: '+201000000000',
        whatsApp1: '+201000000000',
      );
    }
  }

  @override
  Future<Map<String, int>> getSubscriptionUsage(String ownerId) async {
    try {
      // 1. محاولة استدعاء الدالة السريعة RPC Function على السيرفر (طلب واحد ذو أداء فائق)
      final rpcRes = await _cloudService
          .rpc('get_owner_usage', params: {'p_owner_id': ownerId});
      if (rpcRes != null && rpcRes is Map<String, dynamic>) {
        return {
          'clinicsCount': (rpcRes['clinicsCount'] as num?)?.toInt() ?? 0,
          'staffCount': (rpcRes['staffCount'] as num?)?.toInt() ?? 0,
          'patientsCount': (rpcRes['patientsCount'] as num?)?.toInt() ?? 0,
        };
      }
    } catch (_) {
      // الرد التلقائي للتراجع عند عدم توفر الدالة السيرفرية
    }

    try {
      // 2. التراجع المستقر عند الاستعلام المحلي التجميعي
      final clinics = await _cloudService.select(
        table: SupabaseTables.clinics,
        eq: {'owner_id': ownerId},
      );
      final clinicsCount = clinics.length;
      final clinicIds = clinics
          .map((c) => c['id'] as String)
          .where((id) => id.isNotEmpty)
          .toList();

      int staffCount = 0;
      int patientsCount = 0;

      for (final clinicId in clinicIds) {
        final staffRaw = await _cloudService.select(
          table: SupabaseTables.clinicStaff,
          eq: {'clinic_id': clinicId},
        );
        staffCount += staffRaw.length;

        final patientsRaw = await _cloudService.select(
          table: SupabaseTables.patients,
          eq: {'clinic_id': clinicId},
        );
        patientsCount += patientsRaw.length;
      }

      return {
        'clinicsCount': clinicsCount,
        'staffCount': staffCount,
        'patientsCount': patientsCount,
      };
    } catch (e) {
      return {
        'clinicsCount': 0,
        'staffCount': 0,
        'patientsCount': 0,
      };
    }
  }
}
