import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/providers/local_storage_provider.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/fade_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/app_navigation.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/app_intro_slider/intro_slider_page.dart';
import 'package:flutter_firebase_template/widgets/app_intro_slider/page_indicator.dart';
import 'package:flutter_firebase_template/widgets/lottie_controller.dart';
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
  bool _formFieldTouched = false;
  bool _userCreated = false;

  @override
  Widget build(BuildContext context) {
    UserService _userService = UserService(uid: widget.user.uid);

    _sliderPages = [
      IntroSliderPage(
        backgroundColor: Colors.transparent,
        title: "Welcome to",
        description: "Are you ready to begin your Nutriveat journey?",
        optionalChild: AppButton(
            text: "Start",
            onPressed: () async {
              await _controller.animateToPage(_currentPage + 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            }),
        image: Image.asset(
          "assets/images/logo.png",
          height: _imageHeight,
        ),
      ),
      IntroSliderPage(
        backgroundColor: Colors.transparent,
        title: "Culinary Creator",
        description:
            "Discover delicious recipes crafted just for you! Let our AI whip up personalized dishes tailored to your lifestyle and dietary goals.",
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
        title: "Smooth Checkout",
        description:
            "No more searching for ingredients—everything you need is already in your basket, making checkout a breeze!",
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
        title: "Smart Training Plans",
        description:
            "Experience workouts crafted by AI to match your unique goals and lifestyle. Fitness has never been so personal!",
        lottieFile: LottieController(
            repeat: false,
            location: 'assets/lottie/exercise.json',
            height: _imageHeight),
        optionalChild: AppButton(
            text: "Get Started!",
            onPressed: () async {
              await Provider.of<LocalStorageProvider?>(context, listen: false)!
                  .set(
                      key: "${widget.user.uid}-${LocalStorageKeys.hasVisited}",
                      value: "true");
              Navigator.pushReplacement(
                context,
                FadeNavigator(
                    builder: (context, _, __) => const AppNavigation()),
              );
            }),
      ),
    ];

    return Scaffold(
      body: Container(
        padding: const EdgeInsets.all(AppPading.page),
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
              return _sliderPages[index];
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
