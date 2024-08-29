import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class AppTitle extends StatelessWidget {
  const AppTitle({super.key, required this.title, this.subtitle});
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ).h4(),
          if (subtitle != null)
            Padding(
              padding: const EdgeInsets.only(top: AppPading.small),
              child: Text(subtitle!).h5(),
            ),
          const SizedBox(height: AppPading.large),
        ]);
  }
}
