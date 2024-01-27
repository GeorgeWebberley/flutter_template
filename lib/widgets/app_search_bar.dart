import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar(
      {Key? key,
      required this.onChanged,
      this.hintText = 'Search',
      this.suffixText,
      this.suffixOnPress})
      : super(key: key);
  final Function(String) onChanged;
  final String hintText;
  final String? suffixText;
  final void Function()? suffixOnPress;

  @override
  Widget build(BuildContext context) {
    return Form(
        child: TextFormField(
            cursorColor: AppColors.secondary,
            style: const TextStyle(color: AppColors.secondary),
            initialValue: '',
            decoration: InputDecoration(
              suffixIcon: suffixText != null
                  ? SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        onPressed: suffixOnPress,
                        child: Text(
                          suffixText!,
                          style: const TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                  topRight: AppBorderRadius.large.topRight,
                                  bottomRight:
                                      AppBorderRadius.large.bottomRight)),
                          primary: AppColors.secondary,
                        ),
                      ),
                    )
                  : null,
              hintText: hintText,
              hintStyle: TextStyle(color: AppColors.primary.withOpacity(0.5)),
              enabledBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.large,
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 2,
                  )),
              focusColor: AppColors.secondary,
              focusedBorder: OutlineInputBorder(
                  borderRadius: AppBorderRadius.large,
                  borderSide: const BorderSide(
                    color: AppColors.secondary,
                    width: 3,
                  )),
            ),
            onChanged: onChanged));
  }
}
