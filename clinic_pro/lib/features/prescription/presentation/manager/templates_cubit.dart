import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../domain/entities/drug_entity.dart';
import '../../domain/entities/prescription_template_entity.dart';
import '../../domain/usecases/templates_usecases.dart';
import 'templates_state.dart';

@injectable
class TemplatesCubit extends Cubit<TemplatesState> {
  final GetTemplatesUseCase _getTemplatesUseCase;
  final AddTemplateUseCase _addTemplateUseCase;
  final EditTemplateUseCase _editTemplateUseCase;
  final DeleteTemplateUseCase _deleteTemplateUseCase;

  TemplatesCubit(
    this._getTemplatesUseCase,
    this._addTemplateUseCase,
    this._editTemplateUseCase,
    this._deleteTemplateUseCase,
  ) : super(TemplatesInitial());

  Future<void> loadTemplates() async {
    emit(TemplatesLoading());
    final doctorId = AppConstants.activeDoctorId.isNotEmpty
        ? AppConstants.activeDoctorId
        : 'u-doc-1';
    final result = await _getTemplatesUseCase(doctorId);

    result.fold(
      (failure) => emit(TemplatesError(failure.message)),
      (templatesList) {
        final List<Map<String, dynamic>> templatesRaw = templatesList.map((t) {
          final itemsRaw = t.items.map((item) {
            return {
              'id': item.id,
              'template_id': item.templateId,
              'drug_id': item.drugId,
              'frequency': item.frequency,
              'duration': item.duration,
              'is_prn': item.isPrn,
              'timing': item.timing,
              'trade_name': item.drug?.tradeName ?? AppStrings.unknownDrug,
              'generic_name': item.drug?.genericName ?? '',
            };
          }).toList();

          return {
            'id': t.id,
            'doctor_id': t.doctorId,
            'name': t.name,
            'user_count': t.userCount,
            'items': itemsRaw,
          };
        }).toList();

        emit(TemplatesLoaded(templates: templatesRaw));
      },
    );
  }

  /// تصفية القوالب بالبحث النصي (محلي على الـ state)
  void search(String query) {
    if (state is TemplatesLoaded) {
      final loaded = state as TemplatesLoaded;
      emit(loaded.copyWith(searchQuery: query.isEmpty ? null : query));
    }
  }



  /// إضافة قالب روشتة جديد مع أدويته عبر الخدمة السحابية
  Future<void> addTemplate(String name, List<Map<String, dynamic>> drugs) async {
    if (state is! TemplatesLoaded) return;
    final loaded = state as TemplatesLoaded;

    final items = drugs.map((drug) {
      return PrescriptionTemplateItemEntity(
        id: '',
        templateId: '',
        drugId: drug['drug_id'] as String,
        frequency: drug['frequency'] as int?,
        duration: drug['duration'] as int?,
        timing: drug['timing'] as String?,
        isPrn: drug['is_prn'] as bool? ?? false,
      );
    }).toList();

    final doctorId = AppConstants.activeDoctorId.isNotEmpty
        ? AppConstants.activeDoctorId
        : 'u-doc-1';

    final template = PrescriptionTemplateEntity(
      id: '',
      doctorId: doctorId,
      name: name,
      userCount: 0,
      items: items,
    );

    final result = await _addTemplateUseCase(template, doctorId);

    result.fold(
      (failure) => emit(TemplatesError(failure.message)),
      (newTemplate) {
        final newTemplateRaw = {
          'id': newTemplate.id,
          'doctor_id': newTemplate.doctorId,
          'name': newTemplate.name,
          'user_count': newTemplate.userCount,
          'items': drugs,
        };
        emit(loaded.copyWith(templates: [...loaded.templates, newTemplateRaw]));
      },
    );
  }

  /// حذف قالب وجميع أدويته المرتبطة من الخدمة السحابية
  Future<void> deleteTemplate(String id) async {
    if (state is! TemplatesLoaded) return;
    final loaded = state as TemplatesLoaded;

    final result = await _deleteTemplateUseCase(id);

    result.fold(
      (failure) => emit(TemplatesError(failure.message)),
      (_) {
        final updatedList = loaded.templates.where((t) => t['id'] != id).toList();
        emit(loaded.copyWith(templates: updatedList));
      },
    );
  }

  /// تعديل قالب روشتة موجود وتحديث قائمة أدويته عبر الخدمة السحابية
  Future<void> editTemplate(String id, String name, List<Map<String, dynamic>> drugs) async {
    if (state is! TemplatesLoaded) return;

    final items = drugs.map((drug) {
      return PrescriptionTemplateItemEntity(
        id: '',
        templateId: id,
        drugId: drug['drug_id'] as String,
        frequency: drug['frequency'] as int?,
        duration: drug['duration'] as int?,
        timing: drug['timing'] as String?,
        isPrn: drug['is_prn'] as bool? ?? false,
      );
    }).toList();

    final doctorId = AppConstants.activeDoctorId.isNotEmpty
        ? AppConstants.activeDoctorId
        : 'u-doc-1';

    final template = PrescriptionTemplateEntity(
      id: id,
      doctorId: doctorId,
      name: name,
      items: items,
    );

    final result = await _editTemplateUseCase(template);

    result.fold(
      (failure) => emit(TemplatesError(failure.message)),
      (_) async {
        // إعادة تحميل القوالب لضمان تطابق البيانات
        await loadTemplates();
      },
    );
  }
}
