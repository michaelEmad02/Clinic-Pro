import 'package:flutter/material.dart';
import '../themes/app_colors.dart';
import '../utils/responsive_helper.dart';
import '../../features/settings/presentation/ui/widgets/shared_settings_widgets.dart';

/// ودجت الحاوية الرئيسية للتطبيق بدعم الاستجابة (Responsive Scaffold)
/// تقوم بتبديل الـ BottomNavigationBar على الهاتف إلى NavigationRail جانبي على التابلت والكمبيوتر
class AppResponsiveScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? bottomNavigationBar;
  final int selectedIndex;
  final ValueChanged<int>? onDestinationSelected;
  final List<NavigationRailDestination>? destinations;

  const AppResponsiveScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.bottomNavigationBar,
    this.selectedIndex = 0,
    this.onDestinationSelected,
    this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveHelper.isMobile(context);

    if (isMobile) {
      return Scaffold(
        appBar: appBar,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    return Scaffold(
      appBar: appBar,
      body: Row(
        children: [
          AppNavigationRail(
            selectedIndex: selectedIndex,
            onDestinationSelected: onDestinationSelected,
            destinations: destinations,
          ),
          VerticalDivider(
            width: 1,
            thickness: 0.5,
            color: context.borderColor,
          ),
          Expanded(
            child: body,
          ),
        ],
      ),
    );
  }
}
