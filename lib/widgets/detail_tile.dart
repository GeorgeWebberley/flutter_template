import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class DetailTile extends StatelessWidget {
  const DetailTile({
    Key? key,
    required this.title,
    this.onPressed,
    this.icon,
    this.iconColor = AppColors.secondary,
    this.loading = false,
  }) : super(key: key);

  final String title;
  final void Function()? onPressed;
  final IconData? icon;
  final Color? iconColor;
  final bool? loading;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: loading == true ? null : onPressed,
      child: Ink(
        child: Container(
          padding: const EdgeInsets.all(AppPading.large),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(right: AppPading.large),
                  child: Container(
                    padding: const EdgeInsets.all(AppPading.small),
                    decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: iconColor!.withOpacity(0.15)),
                    child: Icon(icon, color: iconColor),
                  ),
                ),
              Expanded(
                child: Text(title,
                    style: const TextStyle(
                      fontWeight: FontWeight.w400,
                    )).h5(),
              ),
              // Spacer(),
              loading == true
                  ? const CircularProgressIndicator(
                      color: AppColors.primary,
                    )
                  : onPressed != null
                      ? Icon(Icons.arrow_forward_ios,
                          size: AppPading.page,
                          color: Colors.black.withOpacity(0.8))
                      : const SizedBox(),
            ],
          ),
        ),
      ),
    );
  }
}
