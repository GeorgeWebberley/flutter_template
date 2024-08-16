import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';

InputDecoration textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    hintStyle: TextStyle(
        color: AppColors.primary.withOpacity(0.5),
        fontFamily: 'Poppins',
        fontWeight: FontWeight.w400),
    filled: true,
    enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
      color: Colors.transparent,
      width: 1,
    )),
    focusedBorder: OutlineInputBorder(
        borderSide:
            BorderSide(color: AppColors.primary.withOpacity(0.8), width: 2)));
