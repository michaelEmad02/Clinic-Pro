// ────────────────────────────────────────────────────────
// UseCase: جلب اشتراك المالك الحالي
// ────────────────────────────────────────────────────────

import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/error/failures.dart';
import '../../../subscriptions/domain/entities/subscription_entity.dart';
import '../repositories/i_settings_repository.dart';

@injectable
class GetSubscriptionUseCase {
  final ISettingsRepository _repository;
  GetSubscriptionUseCase(this._repository);

  Future<Either<Failure, SubscriptionEntity?>> call(String ownerId) {
    return _repository.getSubscription(ownerId);
  }
}
