import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/lottie_controller.dart';

class IntroSliderPage extends StatelessWidget {
  const IntroSliderPage(
      {Key? key,
      this.backgroundColor = AppColors.quaternary,
      this.backgroundImage,
      this.image,
      required this.title,
      required this.description,
      this.nextButton,
      this.lottieFile,
      this.optionalChild})
      : super(key: key);

  final Color? backgroundColor;
  final String? backgroundImage;
  final Image? image;
  final String title;
  final String description;
  final Widget? optionalChild;
  final Widget? nextButton;
  final LottieController? lottieFile;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(AppPading.page),
        decoration: BoxDecoration(
            color: backgroundColor,
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
                  title.toUpperCase(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'Roboto',
                      fontSize: 35,
                      fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: AppPading.page,
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
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w500),
                  ),
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
      ),
    );
  }
}
