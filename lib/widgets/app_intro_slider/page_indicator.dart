import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

class PageIndicator extends AnimatedWidget {
  final PageController controller;
  final int pageCount;
  const PageIndicator(
      {Key? key, required this.controller, required this.pageCount})
      : super(listenable: controller, key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ListView.builder(
              shrinkWrap: true,
              itemCount: pageCount,
              scrollDirection: Axis.horizontal,
              itemBuilder: (context, index) {
                return _createPageIndicator(index);
              })
        ],
      ),
    );
  }

  Widget _createPageIndicator(index) {
    double w = 10;
    double h = 10;
    Color color = Colors.grey;

    if (controller.page == index) {
      color = AppColors.tertiary;
      h = 13;
      w = 13;
    }

    return SizedBox(
      height: 26,
      width: 26,
      child: Center(
        child: AnimatedContainer(
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
          margin: const EdgeInsets.all(5),
          width: w,
          height: h,
          duration: const Duration(milliseconds: 300),
        ),
      ),
    );
  }
}
