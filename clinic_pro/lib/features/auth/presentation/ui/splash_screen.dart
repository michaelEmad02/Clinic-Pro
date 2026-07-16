import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/strings/app_strings.dart';
import '../../../../core/constants/staff_roles.dart';
import '../manager/auth_cubit.dart';
import '../manager/auth_state.dart';
import 'dart:ui' as ui;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _dotController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        context.read<AuthCubit>().checkAuthStatus();
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _dotController.dispose();
    super.dispose();
  }

  Widget _buildLoadingDot(int index) {
    return AnimatedBuilder(
      animation: _dotController,
      builder: (context, child) {
        final double delay = index * 0.16;
        final double progress = (_dotController.value - delay) % 1.0;
        final double effectiveProgress = progress < 0 ? 1.0 + progress : progress;
        
        double scale = 0.0;
        if (effectiveProgress < 0.4) {
          scale = effectiveProgress / 0.4; // 0 to 1
        } else if (effectiveProgress < 0.8) {
          scale = 1.0 - ((effectiveProgress - 0.4) / 0.4); // 1 to 0
        }

        return Transform.scale(
          scale: scale,
          child: Container(
            width: 12,
            height: 12,
            margin: const EdgeInsets.symmetric(horizontal: 4),
            decoration: const BoxDecoration(
              color: AppColors.primary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthAuthenticated) {
          final role = state.user.role;
          if (role == StaffRoles.owner) {
            context.go(RouteConstants.ownerDashboard);
          } else if (role == StaffRoles.doctor) {
            context.go(RouteConstants.doctorDashboard);
          } else if (role == StaffRoles.secretary) {
            context.go(RouteConstants.secretaryDashboard);
          } else {
            context.go(RouteConstants.login);
          }
        } else if (state is AuthUnauthenticated) {
          context.go(RouteConstants.login);
        }
      },
      child: Scaffold(
        backgroundColor: context.surfaceColor,
        body: Stack(
          children: [
            // Blurred Background Circles
            Positioned(
              top: -128,
              right: -128,
              child: _buildBlurCircle(context),
            ),
            Positioned(
              bottom: -128,
              left: -128,
              child: _buildBlurCircle(context),
            ),
            
            // Central Content Area
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  AnimatedBuilder(
                    animation: _pulseAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: _pulseAnimation.value,
                        child: Opacity(
                          opacity: 2 - _pulseAnimation.value,
                          child: Container(
                            width: 96,
                            height: 96,
                            margin: const EdgeInsets.only(bottom: 16),
                            decoration: BoxDecoration(
                              color: context.primaryLightColor,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 4,
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.medical_services,
                              size: 48,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  
                  // Typography
                  Text(
                    'ClinicPro',
                    style: AppTextStyles.headlineLarge(context).copyWith(
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppStrings.smartManagement,
                    style: AppTextStyles.bodyLarge(context).copyWith(
                      color: context.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            
            // Bottom Loading Indicator
            Align(
              alignment: Alignment.bottomCenter,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 48),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    _buildLoadingDot(0),
                    _buildLoadingDot(1),
                    _buildLoadingDot(2),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBlurCircle(BuildContext context) {
    return Container(
      width: 384,
      height: 384,
      decoration: BoxDecoration(
        color: context.primaryLightColor,
        shape: BoxShape.circle,
      ),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 40, sigmaY: 40),
        child: Container(color: Colors.transparent),
      ),
    );
  }
}
