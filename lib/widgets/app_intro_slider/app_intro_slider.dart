import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/providers/local_storage_provider.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/fade_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/app_navigation.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/app_intro_slider/intro_slider_page.dart';
import 'package:flutter_firebase_template/widgets/app_intro_slider/page_indicator.dart';
import 'package:flutter_firebase_template/widgets/lottie_controller.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_settings/tutorial.dart';
import 'package:provider/provider.dart';

class AppIntroSlider extends StatefulWidget {
  const AppIntroSlider({Key? key, required this.user}) : super(key: key);
  final AppUser user;

  @override
  State<AppIntroSlider> createState() => _AppIntroSliderState();
}

class _AppIntroSliderState extends State<AppIntroSlider> {
  final PageController _controller = PageController();
  List<IntroSliderPage> _sliderPages = [];
  int _currentPage = 0;
  final double _imageHeight = 220;

  @override
  Widget build(BuildContext context) {
    _sliderPages = [
      IntroSliderPage(
        backgroundColor: Colors.transparent,
        title: "Welcome",
        description:
            "Thank you for joining Nutriveat.\n\n Are you ready to begin your journey? Let's get you started!",
        optionalChild: AppButton(
            text: "Start",
            onPressed: () async {
              await _controller.animateToPage(_currentPage + 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            }),
        image: Image.asset(
          "assets/images/logo_medium_2.png",
          height: _imageHeight,
        ),
      ),
      IntroSliderPage(
        backgroundColor: Colors.transparent,
        title: "Tailored Meal Plans",
        description:
            "Nutriveat crafts meal plans specifically designed to meet your dietary preferences and needs. Every meal is deliciously suited just for you!",
        lottieFile: LottieController(
            repeat: false,
            location: 'assets/lottie/cook.json',
            height: _imageHeight),
        optionalChild: AppButton(
            text: "Continue",
            onPressed: () async {
              await _controller.animateToPage(_currentPage + 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            }),
      ),
      IntroSliderPage(
        backgroundColor: Colors.transparent,
        title: "Shopping Made Easy",
        description:
            "Once you've selected your preferred dishes, we will create a shopping list containing all the essential ingredients.",
        lottieFile: LottieController(
            repeat: false,
            location: 'assets/lottie/fruit_basket.json',
            height: _imageHeight),
        optionalChild: AppButton(
            text: "Continue",
            onPressed: () async {
              await _controller.animateToPage(_currentPage + 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            }),
      ),
      IntroSliderPage(
        backgroundColor: Colors.transparent,
        title: "Step-By-Step Recipes",
        description:
            "Every dish is accompanied by a simple to follow recipe, offering step-by-step instructions for crafting each meal. It's very straightforward!",
        lottieFile: LottieController(
            repeat: false,
            location: 'assets/lottie/cook_book.json',
            height: _imageHeight),
        optionalChild: AppButton(
            text: "Get Started!",
            onPressed: () async {
              Navigator.pushReplacement(
                context,
                FadeNavigator(
                  builder: (context, _, __) => const Tutorial(),
                ),
              );
            }),
      ),
    ];

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: AppGradients.backgroundGradient,
        ),
        child: Stack(children: [
          PageView.builder(
            controller: _controller,
            itemCount: _sliderPages.length,
            // physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
            },
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.all(AppPading.page),
                child: _sliderPages[index],
              );
            },
          ),
          Positioned(
            bottom: 0,
            left: AppPading.small,
            right: AppPading.small,
            child: SizedBox(
              height: 50,
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: PageIndicator(
                      controller: _controller,
                      pageCount: _sliderPages.length,
                    ),
                  ),
                  Align(
                      alignment: Alignment.bottomRight,
                      child: _sliderPages[_currentPage].nextButton)
                ],
              ),
            ),
          )
        ]),
      ),
    );
  }
}
