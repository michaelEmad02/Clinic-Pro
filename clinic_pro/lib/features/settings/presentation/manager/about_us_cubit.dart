// ─────────────────────────────────────────
// هذا الملف مسؤول عن جلب معلومات الشركة لشاشة "من نحن"
// ─────────────────────────────────────────

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../plans_and_subscriptions/domain/usecases/subscriptions_usecases.dart';
import 'about_us_state.dart';

@injectable
class AboutUsCubit extends Cubit<AboutUsState> {
  final GetCompanyInfoUseCase _getCompanyInfoUseCase;

  AboutUsCubit(this._getCompanyInfoUseCase) : super(AboutUsInitial());

  /// جلب معلومات الشركة
  Future<void> loadCompanyInfo() async {
    emit(AboutUsLoading());

    final result = await _getCompanyInfoUseCase();

    result.fold(
      (failure) => emit(AboutUsError(failure.message)),
      (companyInfo) => emit(AboutUsLoaded(companyInfo)),
    );
  }
}
