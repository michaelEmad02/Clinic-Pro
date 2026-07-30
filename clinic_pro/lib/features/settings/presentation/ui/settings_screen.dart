import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/constants/staff_roles.dart';
import '../manager/settings_cubit.dart';
import 'doctor_settings_screen.dart';
import 'owner_settings_screen.dart';
import 'secretary_settings_screen.dart';

class SettingsScreen extends StatefulWidget {
  final StaffRoles role;
  final bool showBottomNav;

  const SettingsScreen({
    super.key,
    this.role = StaffRoles.doctor,
    this.showBottomNav = false,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  void initState() {
    super.initState();
    // تحميل الإعدادات باستخدام الـ Cubit الجلوبال العام المشترك
    // final userId = context.read<AuthCubit>().state.user?.id ?? '';
    // context.read<SettingsCubit>().loadSettings(widget.role, userId);
  }

  @override
  Widget build(BuildContext context) {
    return _buildScreen();
  }

  Widget _buildScreen() {
    switch (widget.role) {
      case StaffRoles.owner:
        return OwnerSettingsScreen(showBottomNav: widget.showBottomNav);
      case StaffRoles.secretary:
        return SecretarySettingsScreen(showBottomNav: widget.showBottomNav);
      case StaffRoles.doctor:
      default:
        return DoctorSettingsScreen(showBottomNav: widget.showBottomNav);
    }
  }
}
