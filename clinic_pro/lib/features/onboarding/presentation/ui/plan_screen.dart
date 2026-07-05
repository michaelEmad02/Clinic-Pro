import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/themes/app_colors.dart';
import '../../../../core/themes/app_text_styles.dart';
import '../../../../core/constants/route_constants.dart';
import '../../../../core/di/injection_container.dart';
import '../../../../core/services/i_cloud_service.dart';
import 'widgets/progress_indicator_bar.dart';
import 'widgets/plan_card.dart';

class PlanScreen extends StatefulWidget {
  const PlanScreen({super.key});

  @override
  State<PlanScreen> createState() => _PlanScreenState();
}

class _PlanScreenState extends State<PlanScreen> {
  String _selectedBillingCycle = 'monthly'; // 'monthly', 'yearly', 'lifetime'
  Map<String, dynamic>? _selectedPlan;
  List<Map<String, dynamic>> _plans = [];
  List<Map<String, dynamic>> _plansFeatures = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPlansData();
  }

  Future<void> _fetchPlansData() async {
    try {
      final cloudService = sl<ICloudService>();
      final plans = await cloudService.select(table: 'plans');
      final features = await cloudService.select(table: 'plans_features');
      
      setState(() {
        _plans = plans;
        _plansFeatures = features;
        // Default select 'pro' plan if present, else basic
        _selectedPlan = plans.firstWhere((p) => p['name'] == 'pro', orElse: () => plans.first);
        _isLoading = false;
      });
    } catch (_) {
      setState(() => _isLoading = false);
    }
  }

  Map<String, dynamic>? _getFeaturesForPlan(String planId) {
    if (_plansFeatures.isEmpty) return null;
    final list = _plansFeatures.where((f) => f['plan_id'] == planId);
    return list.isNotEmpty ? list.first : null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1024),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Progress Indicator
                        const SizedBox(
                          width: 896,
                          child: ProgressIndicatorBar(
                            step: 1,
                            totalSteps: 3,
                            title: 'اختيار الخطة',
                          ),
                        ),
                        const SizedBox(height: 32),
                        
                        // Header
                        Text(
                          'اختر خطتك',
                          style: AppTextStyles.headlineLarge(context),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'اكتشف الباقة التي تناسب حجم عيادتك وتطلعاتك.',
                          style: AppTextStyles.bodyLarge(context).copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),

                        // Toggle: شهري | سنوي | مدى الحياة
                        Center(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.surfaceVariant.withOpacity(0.5),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            padding: const EdgeInsets.all(4),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _buildCycleButton('monthly', 'شهري'),
                                _buildCycleButton('yearly', 'سنوي'),
                                _buildCycleButton('lifetime', 'مدى الحياة'),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 40),
                        
                        // Pricing Cards Container
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final basicPlan = _plans.firstWhere((p) => p['name'] == 'basic', orElse: () => {});
                            final proPlan = _plans.firstWhere((p) => p['name'] == 'pro', orElse: () => {});
                            final entPlan = _plans.firstWhere((p) => p['name'] == 'enterprise', orElse: () => {});

                            if (constraints.maxWidth > 800) {
                              return Row(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  if (basicPlan.isNotEmpty) Expanded(child: _buildPlanCardWidget(basicPlan)),
                                  const SizedBox(width: 24),
                                  if (proPlan.isNotEmpty) Expanded(child: _buildPlanCardWidget(proPlan)),
                                  const SizedBox(width: 24),
                                  if (entPlan.isNotEmpty) Expanded(child: _buildPlanCardWidget(entPlan)),
                                ],
                              );
                            } else {
                              return Column(
                                children: [
                                  if (basicPlan.isNotEmpty) ...[
                                    _buildPlanCardWidget(basicPlan),
                                    const SizedBox(height: 24),
                                  ],
                                  if (proPlan.isNotEmpty) ...[
                                    _buildPlanCardWidget(proPlan),
                                    const SizedBox(height: 24),
                                  ],
                                  if (entPlan.isNotEmpty) _buildPlanCardWidget(entPlan),
                                ],
                              );
                            }
                          },
                        ),
                        
                        const SizedBox(height: 48),
                        
                        // Main Action Button
                        Center(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 400),
                            child: ElevatedButton(
                              onPressed: () {
                                // Navigate to create clinic
                                context.go(RouteConstants.onboardingClinic);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.onPrimary,
                                padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 4,
                                shadowColor: AppColors.primaryContainer.withOpacity(0.4),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  RichText(
                                    text: TextSpan(
                                      style: AppTextStyles.headlineMedium(context).copyWith(
                                        color: AppColors.onPrimary,
                                      ),
                                      children: const [
                                        TextSpan(text: 'ابدأ التجربة المجانية '),
                                        TextSpan(
                                          text: '14',
                                          style: TextStyle(
                                            fontFamily: 'Inter',
                                            fontWeight: FontWeight.w700,
                                          ),
                                        ),
                                        TextSpan(text: ' يوم'),
                                      ],
                                    ),
                                  ),
                                  const Spacer(),
                                  const Icon(Icons.arrow_back), // Arrow pointing left in RTL
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildCycleButton(String key, String label) {
    final active = _selectedBillingCycle == key;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedBillingCycle = key);
      },
      child: Container(
        decoration: BoxDecoration(
          color: active ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          label,
          style: AppTextStyles.bodyMedium(context).copyWith(
            color: active ? AppColors.primary : AppColors.textSecondary,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _buildPlanCardWidget(Map<String, dynamic> plan) {
    final planId = plan['id'] as String;
    final planName = plan['name'] as String;
    
    // Title mapping
    String displayTitle = 'الأساسية';
    if (planName == 'pro') displayTitle = 'الاحترافية';
    if (planName == 'enterprise') displayTitle = 'المؤسسات';

    // Price depending on cycle
    double rawPrice = 7.0;
    String subText = '/ شهرياً';
    if (_selectedBillingCycle == 'yearly') {
      rawPrice = (plan['yearly_price'] ?? 70.0) as double;
      subText = '/ سنوياً';
    } else if (_selectedBillingCycle == 'lifetime') {
      rawPrice = (plan['lifetime_price'] ?? 155.0) as double;
      subText = ' مدى الحياة';
    } else {
      rawPrice = (plan['monthly_price'] ?? 7.0) as double;
    }
    
    final displayPrice = '\$${rawPrice.toString().replaceAll('.0', '')}';
    final isSelected = _selectedPlan?['id'] == planId;

    // Get features
    final featuresMap = _getFeaturesForPlan(planId);
    List<PlanFeature> planFeaturesList = [];
    if (featuresMap != null) {
      final maxClinics = featuresMap['max_clinics'];
      final maxStaff = featuresMap['max_staff'];
      final maxPatients = featuresMap['max_patients'];

      planFeaturesList.add(PlanFeature(text: 'دعم حتى $maxClinics عيادات نشطة'));
      planFeaturesList.add(PlanFeature(text: 'دعم حتى $maxStaff من طاقم العمل'));
      planFeaturesList.add(PlanFeature(text: 'دعم حتى $maxPatients مريض مسجل'));

      final jsonFeatures = featuresMap['features'];
      if (jsonFeatures is Map<String, dynamic>) {
        jsonFeatures.forEach((key, val) {
          if (val is List && val.length >= 2) {
            final valMap = val[0];
            final titleMap = val[1];
            if (valMap is Map && titleMap is Map) {
              final active = valMap['value'] == true;
              final title = titleMap['title'] as String?;
              if (title != null) {
                planFeaturesList.add(PlanFeature(text: title, included: active));
              }
            }
          }
        });
      }
    }

    return PlanCard(
      title: displayTitle,
      price: displayPrice,
      priceSubtext: subText,
      isFeatured: planName == 'pro',
      badgeText: planName == 'pro' ? 'الأكثر طلباً' : null,
      features: planFeaturesList,
      buttonText: isSelected ? 'تم تحديد الباقة' : 'اختيار الخطة',
      onSelect: () {
        setState(() {
          _selectedPlan = plan;
        });
      },
    );
  }
}
