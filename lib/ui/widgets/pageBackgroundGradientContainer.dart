import 'package:flutter/material.dart';
import 'package:flutterquiz/utils/uiUtils.dart';

class PageBackgroundGradientContainer extends StatelessWidget {
  const PageBackgroundGradientContainer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: UiUtils.buildLinerGradient(
            [
              Theme.of(context).scaffoldBackgroundColor,
              Theme.of(context).canvasColor,
              Theme.of(context).scaffoldBackgroundColor,
            ], // Alignment.centerLeft, Alignment.centerRight
            Alignment.topLeft,
            Alignment.bottomRight),
      ),
    );
  }
}
