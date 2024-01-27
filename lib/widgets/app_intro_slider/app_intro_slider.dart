import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/models/user_data.dart';
import 'package:flutter_firebase_template/screens/logged_in/user_profile.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/dialogs.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/app_intro_slider/intro_slider_page.dart';
import 'package:flutter_firebase_template/widgets/app_intro_slider/page_indicator.dart';
import 'package:flutter_firebase_template/widgets/lottie_controller.dart';
import 'package:flutter_firebase_template/widgets/wrapper.dart';

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
  String _username = "";
  String _friendUsername = "";
  final double _imageHeight = 150;
  final _usernameFormKey = GlobalKey<FormState>();
  final _friendFormKey = GlobalKey<FormState>();
  bool _formFieldTouched = false;
  bool _loading = false;
  String _friendError = "";
  bool _userCreated = false;

  @override
  Widget build(BuildContext context) {
    UserService _userService = UserService(uid: widget.user.uid);

    _sliderPages = [
      IntroSliderPage(
          backgroundImage: "assets/images/background.jpg",
          title: "Welcome to",
          description: "Let's get started",
          image: Image.asset(
            "assets/images/logo.png",
            height: _imageHeight,
          ),
          nextButton: TextButton(
            onPressed: () async {
              await _controller.animateToPage(_currentPage + 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
            },
            child: const Text("START",
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w400,
                    color: Colors.white)),
          )),
      IntroSliderPage(
        backgroundColor: AppColors.secondary,
        title: "Username",
        description: _userCreated
            ? "You created an awesome, unique username!"
            : "Please enter a unique username. This is how your friends will identify you (This cannot be changed later).",
        lottieFile: LottieController(
            repeat: false,
            location: 'assets/lottie/movie.json',
            height: _imageHeight),
        optionalChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPading.page),
          child: _userCreated
              ? Text(
                  _username.toUpperCase(),
                  style: const TextStyle(color: Colors.white),
                ).h1()
              : StreamBuilder<QuerySnapshot>(
                  stream: (_username != "")
                      ? _userService.checkUsername(username: _username)
                      : null,
                  builder: (context, snapshot) {
                    bool usernameIsTaken =
                        snapshot.data != null && snapshot.data!.docs.isNotEmpty;

                    bool usernameIsInvalid = !isValidUsername(_username);

                    bool usernameIsGood =
                        !usernameIsTaken && !usernameIsInvalid;

                    String? errorMessage = usernameIsInvalid
                        ? 'Username must be at least 3 characters and consist of only letters and numbers.'
                        : usernameIsTaken
                            ? "Username is taken"
                            : null;

                    return Form(
                      key: _usernameFormKey,
                      child: Column(
                        children: [
                          TextFormField(
                            decoration: textInputDecoration.copyWith(
                                hintText: 'Username',
                                suffixIcon: _formFieldTouched
                                    ? usernameIsGood
                                        ? const Icon(
                                            Icons.check,
                                            color: AppColors.secondary,
                                          )
                                        : const Icon(
                                            Icons.close,
                                            color: AppColors.danger,
                                          )
                                    : null),
                            onChanged: (value) {
                              setState(() {
                                _formFieldTouched = true;
                                _username = value.toLowerCase();
                              });
                            },
                          ),
                          if (errorMessage != null && _formFieldTouched)
                            Container(
                              padding: const EdgeInsets.only(top: 5),
                              width: double.infinity,
                              child: Text(
                                errorMessage,
                                textAlign: TextAlign.end,
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                          const SizedBox(
                            height: AppPading.page,
                          ),
                          AppButton(
                            onPressed: usernameIsGood
                                ? () async {
                                    try {
                                      setState(() {
                                        _formFieldTouched = false;
                                      });
                                      await _userService.setUsername(
                                          username: _username.toLowerCase());

                                      await _userService.createUserDbEntry(
                                        username: _username.toLowerCase(),
                                        email: widget.user.email,
                                        firstName: widget.user.firstName,
                                        lastName: widget.user.lastName,
                                        imageUrl: widget.user.imageUrl,
                                        providers: widget.user.providers,
                                      );

                                      await _controller.animateToPage(
                                          _currentPage + 1,
                                          duration:
                                              const Duration(milliseconds: 300),
                                          curve: Curves.ease);

                                      setState(() {
                                        _userCreated = true;
                                      });
                                    } catch (error) {
                                      showToast(
                                          context: context,
                                          message:
                                              'Error setting username: $error',
                                          color: AppColors.danger);
                                      setState(() {
                                        _formFieldTouched = true;
                                      });
                                    }
                                  }
                                : null,
                            text: 'Confirm',
                            color: AppColors.quaternary,
                          )
                        ],
                      ),
                    );
                  }),
        ),
      ),
      IntroSliderPage(
        backgroundColor: AppColors.quaternary,
        title: "FRIENDS",
        description:
            "Add your first friend by entering their username (optional).",
        lottieFile: LottieController(
            repeat: true,
            location: 'assets/lottie/popcorn.json',
            height: _imageHeight),
        nextButton: TextButton(
          onPressed: () async {
            if (!_userCreated) {
              await _controller.animateToPage(_currentPage - 1,
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease);
              showToast(
                  context: context,
                  message: 'You must set a username before continuing',
                  color: AppColors.danger);
            } else {
              // For now, navigate to account (until finished implementing home page)
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const Wrapper()),
              );
            }
          },
          child: const Text("SKIP",
              style: TextStyle(
                  fontWeight: FontWeight.w400,
                  color: Colors.white,
                  fontSize: 18)),
        ),
        optionalChild: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPading.page),
          child: Form(
            key: _friendFormKey,
            child: Column(
              children: [
                TextFormField(
                  decoration: textInputDecoration.copyWith(hintText: 'Search'),
                  validator: (value) =>
                      value!.isEmpty ? 'Enter a username' : null,
                  onChanged: (value) {
                    setState(() {
                      _friendUsername = value;
                    });
                  },
                ),
                if (_friendError != "")
                  Container(
                    padding: const EdgeInsets.only(top: 5),
                    width: double.infinity,
                    child: Text(
                      _friendError,
                      textAlign: TextAlign.end,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                const SizedBox(
                  height: AppPading.page,
                ),
                AppButton(
                  loading: _loading,
                  onPressed: () async {
                    if (_friendFormKey.currentState!.validate()) {
                      setState(() {
                        _loading = true;
                      });

                      UserData? _currentUser =
                          await UserService(uid: widget.user.uid).getUserData();

                      if (_currentUser == null) {
                        await _controller.animateToPage(_currentPage - 1,
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.ease);
                        showToast(
                            context: context,
                            message:
                                'You must set a username before being able to add friends',
                            color: AppColors.danger);
                      } else {
                        UserData? _friend =
                            await UserService(uid: widget.user.uid)
                                .findUserByUsername(_friendUsername);

                        if (_friend != null) {
                          await Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserProfile(
                                      friendId: _friend.uid,
                                      currentUser: _currentUser,
                                    )),
                          );
                          Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => const Wrapper()));
                        } else {
                          setState(() {
                            _friendError = 'No friend found with that username';
                            _loading = false;
                          });
                        }
                      }
                    }
                    setState(() {
                      _loading = false;
                    });
                  },
                  text: 'Add',
                  color: AppColors.secondary,
                )
              ],
            ),
          ),
        ),
      ),
    ];

    return Stack(children: [
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
    ]);
  }
}
