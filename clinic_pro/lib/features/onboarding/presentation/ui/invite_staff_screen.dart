import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/staff_roles.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/i_cloud_service.dart';
import '../manager/onboarding_cubit.dart';
import '../manager/onboarding_state.dart';
import 'widgets/progress_indicator_bar.dart';
import 'widgets/invite_form_row.dart';
import 'widgets/invited_staff_list.dart';

/// شاشة دعوة الموظفين — تستخدم في خطوة الـ Onboarding أو من داخل إدارة الطاقم الطبي
class InviteStaffScreen extends StatefulWidget {
  final bool isOnboarding;

  const InviteStaffScreen({
    super.key,
    this.isOnboarding = true,
  });

  @override
  State<InviteStaffScreen> createState() => _InviteStaffScreenState();
}

class _InviteStaffScreenState extends State<InviteStaffScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  
  StaffRoles _selectedRole = StaffRoles.doctor;
  
  List<Map<String, dynamic>> _clinics = [];
  String? _selectedClinicId;
  
  List<Map<String, dynamic>> _doctors = [];
  String? _selectedDoctorId;

  /// قائمة الموظفين المدعوين في هذه الجلسة قبل الإرسال النهائي
  final List<InvitedStaffItem> _invitedStaff = [];
  bool _isLoadingData = true;

  @override
  void initState() {
    super.initState();
    _loadClinicsAndDoctors();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  /// تحميل العيادات والأطباء من قاعدة البيانات الافتراضية
  Future<void> _loadClinicsAndDoctors() async {
    try {
      final clinics = await sl<ICloudService>().select(table: 'clinics');
      setState(() {
        _clinics = clinics;
        if (clinics.isNotEmpty) {
          _selectedClinicId = clinics.first['id'] as String;
        }
      });

      if (_selectedClinicId != null) {
        await _loadDoctorsForClinic(_selectedClinicId!);
      }
    } catch (_) {
      // التعامل مع الخطأ بصمت في البيئة الوهمية
    } finally {
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  /// تحميل الأطباء لعيادة محددة لتصفية حقل الطبيب المسؤول
  Future<void> _loadDoctorsForClinic(String clinicId) async {
    try {
      final staff = await sl<ICloudService>().select(
        table: 'clinic_staff',
        eq: {'clinic_id': clinicId, 'role': 'doctor'},
      );
      final userIds = staff.map((s) => s['user_id'] as String).toList();
      
      final allUsers = await sl<ICloudService>().select(table: 'users');
      final clinicDocs = allUsers.where((u) => userIds.contains(u['id'])).toList();
      
      setState(() {
        _doctors = clinicDocs;
        _selectedDoctorId = clinicDocs.isNotEmpty ? clinicDocs.first['id'] as String : null;
      });
    } catch (_) {}
  }

  /// إضافة موظف جديد إلى القائمة المؤقتة
  void _addInvitee() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();

    if (name.isEmpty) {
      _showError('الرجاء إدخال اسم الموظف الكامل');
      return;
    }

    if (email.isEmpty || !email.contains('@')) {
      _showError('الرجاء إدخال بريد إلكتروني صحيح');
      return;
    }

    // التحقق من عدم التكرار
    final alreadyExists = _invitedStaff.any((s) => s.email == email);
    if (alreadyExists) {
      _showError('هذا البريد مضاف مسبقاً في القائمة');
      return;
    }

    final clinicName = _clinics.firstWhere((c) => c['id'] == _selectedClinicId)['name'] as String? ?? 'العيادة';
    
    String? doctorName;
    if (_selectedRole == StaffRoles.secretary && _selectedDoctorId != null) {
      doctorName = _doctors.firstWhere((d) => d['id'] == _selectedDoctorId)['name'] as String?;
    }

    setState(() {
      _invitedStaff.add(InvitedStaffItem(
        name: name,
        email: email,
        role: _selectedRole,
        clinicId: _selectedClinicId ?? 'c-1',
        clinicName: clinicName,
        doctorId: _selectedRole == StaffRoles.secretary ? _selectedDoctorId : null,
        doctorName: doctorName,
      ));
      _nameController.clear();
      _emailController.clear();
    });
  }

  void _removeInvitee(int index) {
    setState(() {
      _invitedStaff.removeAt(index);
    });
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: AppColors.danger,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// إرسال الدعوات وحفظها في قاعدة البيانات السحابية الوهمية
  Future<void> _onSendInvitations() async {
    if (_invitedStaff.isEmpty) {
      _onSkip();
      return;
    }

    setState(() {
      _isLoadingData = true;
    });

    final cloudService = sl<ICloudService>();
    final now = DateTime.now();

    // حفظ كل دعوة في قاعدة البيانات الوهمية
    for (final staff in _invitedStaff) {
      final dbRole = staff.role == StaffRoles.doctor ? 'doctor' : 'secretary';
      
      await cloudService.insert(
        table: 'invitations',
        data: {
          'clinic_id': staff.clinicId,
          'owner_id': 'u-owner-1',
          'email': staff.email,
          'name': staff.name,
          'role': dbRole,
          'status': 'pending',
          'created_at': now.toIso8601String(),
          'expires_at': now.add(const Duration(days: 7)).toIso8601String(),
        },
      );

      // إذا كان هناك ربط بين سكرتير وطبيب، ننشئ جدول الربط أيضاً
      if (dbRole == 'secretary' && staff.doctorId != null) {
        // ننشئ حساب موظف سكرتارية وهمي مفعل مباشرة للتأثير الفوري بالربط
        final newSecId = 'u-sec-gen-${now.millisecondsSinceEpoch}';
        await cloudService.insert(
          table: 'users',
          data: {
            'id': newSecId,
            'name': staff.name,
            'email': staff.email,
            'role': 'secretary',
          },
        );
        await cloudService.insert(
          table: 'clinic_staff',
          data: {
            'clinic_id': staff.clinicId,
            'user_id': newSecId,
            'role': 'secretary',
            'is_active': true,
          },
        );
        await cloudService.insert(
          table: 'doctor_secretary_schedule',
          data: {
            'doctor_id': staff.doctorId!,
            'secretary_id': newSecId,
            'clinic_id': staff.clinicId,
            'is_active': true,
            'created_at': now.toIso8601String(),
          },
        );
      }
    }

    if (widget.isOnboarding) {
      if (mounted) {
        context.read<OnboardingCubit>().inviteStaff(_invitedStaff.map((e) => e.email).toList());
      }
    } else {
      if (mounted) {
        context.pop();
      }
    }
  }

  void _onSkip() {
    if (widget.isOnboarding) {
      context.go(RouteConstants.ownerDashboard);
    } else {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<OnboardingCubit, OnboardingState>(
      listener: (context, state) {
        if (state is OnboardingStaffInvited && widget.isOnboarding) {
          context.go(RouteConstants.ownerDashboard);
        }
      },
      builder: (context, state) {
        final isLoading = state is OnboardingLoading || _isLoadingData;

        return Scaffold(
          backgroundColor: AppColors.background,
          body: SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.screenEdgeH,
                  vertical: AppConstants.spaceXl,
                ),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 480),
                  child: Container(
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppConstants.radiusCard),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Header
                        _buildHeader(context),

                        // Form & Content
                        if (_isLoadingData)
                          const Padding(
                            padding: EdgeInsets.all(AppConstants.spaceLg),
                            child: Center(child: CircularProgressIndicator()),
                          )
                        else
                          _buildContent(context),

                        // Footer
                        _buildFooter(context, isLoading),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Material(
                color: AppColors.surfaceContainerLow,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => _onSkip(),
                  customBorder: const CircleBorder(),
                  child: const Padding(
                    padding: EdgeInsets.all(6),
                    child: Icon(
                      Icons.arrow_forward,
                      size: 20,
                      color: AppColors.textHint,
                    ),
                  ),
                ),
              ),
              if (widget.isOnboarding)
                const Expanded(
                  child: ProgressIndicatorBar(
                    step: 3,
                    totalSteps: 3,
                    title: '',
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppConstants.spaceMd),
          Text(
            'دعوة الفريق',
            style: AppTextStyles.headlineLarge(context).copyWith(
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: AppConstants.spaceXs),
          Text(
            'قم بدعوة زملائك في العيادة للانضمام إلى النظام بصلاحيات محددة.',
            style: AppTextStyles.bodyMedium(context).copyWith(
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.spaceLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InviteFormRow(
            nameController: _nameController,
            emailController: _emailController,
            selectedRole: _selectedRole,
            onRoleChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedRole = val;
                });
              }
            },
            clinics: _clinics,
            selectedClinicId: _selectedClinicId,
            onClinicChanged: (val) {
              if (val != null) {
                setState(() {
                  _selectedClinicId = val;
                });
                _loadDoctorsForClinic(val);
              }
            },
            doctors: _doctors,
            selectedDoctorId: _selectedDoctorId,
            onDoctorChanged: (val) {
              setState(() {
                _selectedDoctorId = val;
              });
            },
            onAdd: _addInvitee,
          ),
          const SizedBox(height: AppConstants.spaceLg),
          InvitedStaffList(
            items: _invitedStaff,
            onRemove: _removeInvitee,
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context, bool isLoading) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.spaceLg,
        0,
        AppConstants.spaceLg,
        AppConstants.spaceLg,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ElevatedButton(
            onPressed: isLoading ? null : _onSendInvitations,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppConstants.radiusButton),
              ),
              elevation: 0,
            ),
            child: isLoading
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.send, size: 20),
                      const SizedBox(width: AppConstants.spaceSm),
                      Text(
                        'إرسال الدعوات',
                        style: AppTextStyles.headlineSmall(context).copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
          ),
          if (widget.isOnboarding) ...[
            const SizedBox(height: AppConstants.spaceSm),
            TextButton(
              onPressed: isLoading ? null : _onSkip,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                padding: const EdgeInsets.symmetric(vertical: 10),
              ),
              child: Text(
                'تخطي الآن',
                style: AppTextStyles.bodyMedium(context).copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
