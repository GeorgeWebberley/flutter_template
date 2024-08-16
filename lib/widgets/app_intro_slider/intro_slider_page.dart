import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/lottie_controller.dart';

class IntroSliderPage extends StatelessWidget {
  const IntroSliderPage(
      {Key? key,
      this.backgroundColor = AppColors.quaternary,
      this.backgroundGradient,
      this.backgroundImage,
      this.image,
      required this.title,
      required this.description,
      this.nextButton,
      this.lottieFile,
      this.optionalChild,
      this.foregroundColor})
      : super(key: key);

  final Color? backgroundColor;
  final Gradient? backgroundGradient;
  final String? backgroundImage;
  final Image? image;
  final String title;
  final String description;
  final Widget? optionalChild;
  final Widget? nextButton;
  final LottieController? lottieFile;
  final Color? foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: backgroundGradient ??
              (backgroundColor != null
                  ? LinearGradient(colors: [backgroundColor!, backgroundColor!])
                  : null),
          image: backgroundImage != null
              ? DecorationImage(
                  colorFilter: ColorFilter.mode(
                      Colors.black.withOpacity(0.4), BlendMode.darken),
                  image: AssetImage(backgroundImage!),
                  fit: BoxFit.cover,
                )
              : null),
      child: Center(
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              const SizedBox(
                height: AppPading.page,
              ),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: foregroundColor ?? Colors.black,
                    fontFamily: 'Times New Roman',
                    fontSize: 40,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: AppPading.large,
              ),
              // Image takes preference, then lottiefile
              image ?? lottieFile ?? Container(),
              const SizedBox(
                height: AppPading.page * 2,
              ),
              SizedBox(
                height: 80,
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: foregroundColor ?? Colors.black,
                  ),
                ).h5(),
              ),
              if (optionalChild != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppPading.page * 2),
                  child: optionalChild!,
                )
            ],
          ),
        ),
      ),
    );
  }
}
