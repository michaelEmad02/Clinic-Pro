// ─────────────────────────────────────────
// هذا الملف يدير حالات شاشة "من نحن" (AboutUsState)
// ─────────────────────────────────────────

import 'package:equatable/equatable.dart';
import '../../../plans_and_subscriptions/domain/entities/company_info_entity.dart';

abstract class AboutUsState extends Equatable {
  const AboutUsState();

  @override
  List<Object?> get props => [];
}

class AboutUsInitial extends AboutUsState {}

class AboutUsLoading extends AboutUsState {}

class AboutUsLoaded extends AboutUsState {
  final CompanyInfoEntity companyInfo;

  const AboutUsLoaded(this.companyInfo);

  @override
  List<Object?> get props => [companyInfo];
}

class AboutUsError extends AboutUsState {
  final String message;

  const AboutUsError(this.message);

  @override
  List<Object?> get props => [message];
}
