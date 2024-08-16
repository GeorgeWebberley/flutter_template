import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class DetailTile extends StatelessWidget {
  const DetailTile(
      {Key? key,
      required this.title,
      required this.value,
      this.onPressed,
      this.icon})
      : super(key: key);

  final String title;
  final String value;
  final void Function()? onPressed;
  final Icon? icon;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPressed,
      child: Ink(
        child: Container(
          padding: const EdgeInsets.all(AppPading.large),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: AppBorderRadius.small,
              boxShadow: [AppBoxShadow.small]),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                          style: const TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.secondary))
                      .h4(),
                  const SizedBox(
                    height: AppPading.small,
                  ),
                  value == ""
                      ? Text("Tap to update",
                              style: TextStyle(
                                  color: AppColors.primary.withOpacity(0.6),
                                  fontStyle: FontStyle.italic))
                          .h5()
                      : Text(value,
                              style: const TextStyle(color: AppColors.primary))
                          .h5(),
                ],
              ),
              if (icon != null) icon!
              // const Icon(
              //   Icons.arrow_forward,
              //   color: AppColors.secondary,
              // )
            ],
          ),
        ),
      ),
    );
  }
}
