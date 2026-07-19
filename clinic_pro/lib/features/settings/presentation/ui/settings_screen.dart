import 'package:clinic_pro/features/auth/presentation/manager/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/constants/staff_roles.dart';
import '../manager/settings_cubit.dart';
import 'doctor_settings_screen.dart';
import 'owner_settings_screen.dart';
import 'secretary_settings_screen.dart';

class SettingsScreen extends StatelessWidget {
  final StaffRoles role;
  final bool showBottomNav;

  const SettingsScreen(
      {super.key, this.role = StaffRoles.doctor, this.showBottomNav = false});

  @override
  Widget build(BuildContext context) {
    var userId = context.read<AuthCubit>().state.user?.id ?? '';
    return BlocProvider(
      create: (_) => sl<SettingsCubit>()..loadSettings(role, userId),
      child: _buildScreen(),
    );
  }

  Widget _buildScreen() {
    switch (role) {
      case StaffRoles.owner:
        return OwnerSettingsScreen(showBottomNav: showBottomNav);
      case StaffRoles.secretary:
        return SecretarySettingsScreen(showBottomNav: showBottomNav);
      case StaffRoles.doctor:
      default:
        return DoctorSettingsScreen(showBottomNav: showBottomNav);
    }
  }
}
