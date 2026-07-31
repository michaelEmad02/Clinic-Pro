import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:nqs_website/constant/colors.dart';

class TopLoader {
  static  final SizedBox _container = SizedBox(
    width: 35,
    height: 35,
    child:
        Center(child: LoadingAnimationWidget.threeArchedCircle(
        color: Mycolor().maincolor,
        size: 120,
      ),),
  );

  static void startLoading(BuildContext context) {
    showDialog(
      barrierColor: Colors.black54,
      barrierDismissible: false,
      context: context,
      builder: (context) => _container,
    );
  }

  static void stopLoading(BuildContext context) {
    Navigator.of(context).pop();
  }
}
