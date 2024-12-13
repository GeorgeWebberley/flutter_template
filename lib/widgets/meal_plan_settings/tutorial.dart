import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/fade_navigator.dart';
import 'package:flutter_firebase_template/shared/navigation.dart/slide_navigator.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/widgets/app_navigation.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_settings/diet_setting.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_settings/diet_summary.dart';
import 'package:flutter_firebase_template/widgets/talking_vito.dart';

class Tutorial extends StatefulWidget {
  const Tutorial({super.key});

  @override
  _TutorialState createState() => _TutorialState();
}

class _TutorialState extends State<Tutorial> {
  bool _moveToBottom = false;
  int stage = 0;
  int requirementIndex = 4;
  int allergyIndex = 7;
  int toolIndex = 10;
  int tastesIndex = 13;
  int extrasIndex = 16;
  int summaryIndex = 17;
  List<String?> messages = [
    "Hello! My name is Chef Vito, and I will be your personal assistant on the Nutriveat journey.",
    "Together we will make your meal planning, cooking and shopping a breeze! Shall we get started?",
    null,
    "First, do you have any dietary requirements that I should be aware of?",
    null,
    "Perfect! You can always update these later in your profile.",
    "Next, I want to record your allergies so I know what to avoid when working as your assistant.",
    null,
    "Thanks, for the information! I have saved it to your profile.",
    "Now, what kitchen tools do you have?",
    null,
    "Fantastic, I am sure we can come up with some delicious meals.",
    "So that I can get an understanding of what you like, which of these meals tickles your tastebuds?",
    null,
    "Thanks for the info!",
    "Before I wrap things up for now, is there anything else you would like to add? This can anything, such as likes/dislikes, goals, budgets or anything you can think of! I will try to incorporate as much of it into my planning as possible.",
    null,
    // null,
    "Great! Just check that we have all the correct details and then we can get started!",
  ];

  List<String> allergies = [];
  List<String> requirements = [];
  List<String> tools = [];
  List<String> tastes = [];
  List<String> extras = [];

  // List<String> allergies = ["fish", "cheese"];
  // List<String> requirements = ["vegan", "no dairy"];
  // List<String> tools = ["oven", "blender"];
  // List<String> tastes = ["burgers"];
  // List<String> extras = ["limited budget"];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    bool isQuestion = stage == requirementIndex ||
        stage == toolIndex ||
        stage == allergyIndex ||
        stage == tastesIndex ||
        stage == extrasIndex;

    return Container(
      decoration:
          const BoxDecoration(gradient: AppGradients.backgroundGradient),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: isQuestion
                ? [
                    TextButton(
                        onPressed: () {
                          setState(() {
                            stage++;
                            if (stage < messages.length - 1) {
                              stage++;
                            }
                          });
                        },
                        child: const Row(
                          children: [
                            Text(
                              "Skip",
                              style: TextStyle(color: AppColors.primary),
                            ),
                            SizedBox(
                              width: AppPading.small,
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              size: 20,
                              color: AppColors.primary,
                            )
                          ],
                        ))
                  ]
                : null,
            leading: stage > 0
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: _onBack,
                  )
                : Container()),
        body: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
                AppPading.page, 0, AppPading.page, AppPading.page),
            child: Column(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: messages[stage] != null ? _onContinue : null,
                    child: Container(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.ease,
                            left: 0,
                            right: 0,
                            bottom: _moveToBottom
                                ? 0
                                : size.height / 2 -
                                    100, // Move between middle and bottom
                            child: AnimatedOpacity(
                              opacity: isQuestion ? 0 : 1.0,
                              duration: const Duration(milliseconds: 300),
                              child: TalkingVito(
                                key: UniqueKey(),
                                text: messages[stage],
                                onContinue: _onContinue,
                              ),
                            ),
                          ),

                          Positioned.fill(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 300),
                              child:

                                  // DietSummary(
                                  //   tools: tools,
                                  //   requirements: requirements,
                                  //   tastes: tastes,
                                  //   allergies: allergies,
                                  //   extras: extras,
                                  //   key: const ValueKey('meal_plan_summary'),
                                  // )

                                  (stage == requirementIndex - 1 ||
                                          stage == requirementIndex ||
                                          stage == requirementIndex + 1)
                                      ? Align(
                                          key: const ValueKey(
                                              'meal_plan_requirements'),
                                          alignment: Alignment.topCenter,
                                          child: AbsorbPointer(
                                            absorbing:
                                                stage != requirementIndex,
                                            child: AnimatedOpacity(
                                              duration: const Duration(
                                                  milliseconds: 300),
                                              opacity:
                                                  stage == requirementIndex - 1
                                                      ? 0.3
                                                      : 1,
                                              child: DietSetting(
                                                title: "Requirements",
                                                subtitle:
                                                    "Select your dietary requirements. This does not include allergies, which we will cover next!",
                                                values: [
                                                  "vegetarian",
                                                  "vegan",
                                                  "pescatarian",
                                                  "gluten-free",
                                                  "lactose-free",
                                                  "dairy-free",
                                                  "kosher",
                                                  "halal",
                                                  "paleo",
                                                  "keto",
                                                ],
                                                onSave: (values) {
                                                  setState(() {
                                                    requirements = values;
                                                  });
                                                  _onContinue();
                                                },
                                                initialValues: requirements,
                                              ),
                                            ),
                                          ),
                                        )
                                      : (stage == allergyIndex - 1 ||
                                              stage == allergyIndex ||
                                              stage == allergyIndex + 1)
                                          ? Align(
                                              key: const ValueKey(
                                                  'meal_plan_allergies'),
                                              alignment: Alignment.topCenter,
                                              child: AbsorbPointer(
                                                absorbing:
                                                    stage != allergyIndex,
                                                child: AnimatedOpacity(
                                                  duration: const Duration(
                                                      milliseconds: 300),
                                                  opacity:
                                                      stage == allergyIndex - 1
                                                          ? 0.3
                                                          : 1,
                                                  child: DietSetting(
                                                    title: "Allergies",
                                                    subtitle:
                                                        "Select all that apply. If you don't see your allergy simply add it using the + button!",
                                                    values: [
                                                      "peanuts",
                                                      "shellfish",
                                                      "gluten",
                                                      "eggs",
                                                      "soy",
                                                    ],
                                                    allowExtra: true,
                                                    onSave: (values) {
                                                      setState(() {
                                                        allergies = values;
                                                      });
                                                      _onContinue();
                                                    },
                                                    initialValues: allergies,
                                                  ),
                                                ),
                                              ),
                                            )
                                          : (stage == toolIndex - 1 ||
                                                  stage == toolIndex ||
                                                  stage == toolIndex + 1)
                                              ? Align(
                                                  key: const ValueKey(
                                                      'meal_plan_tools'),
                                                  alignment:
                                                      Alignment.topCenter,
                                                  child: AbsorbPointer(
                                                    absorbing:
                                                        stage != toolIndex,
                                                    child: AnimatedOpacity(
                                                      duration: const Duration(
                                                          milliseconds: 300),
                                                      opacity:
                                                          stage == toolIndex - 1
                                                              ? 0.3
                                                              : 1,
                                                      child: DietSetting(
                                                        title: "Kitchen Tools",
                                                        subtitle:
                                                            "Select all that apply! If we are missing anything add it with the + button!",
                                                        values: [
                                                          "oven",
                                                          "microwave",
                                                          "sous vide",
                                                          "slow cooker",
                                                          "pressure cooker",
                                                          "food processor",
                                                          "air fryer",
                                                        ],
                                                        allowExtra: true,
                                                        onSave: (values) {
                                                          setState(() {
                                                            tools = values;
                                                          });
                                                          _onContinue();
                                                        },
                                                        initialValues: tools,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : (stage == tastesIndex ||
                                                      stage == tastesIndex + 1)
                                                  ? Align(
                                                      key: const ValueKey(
                                                          'meal_plan_tastes'),
                                                      alignment:
                                                          Alignment.topCenter,
                                                      child: DietSetting(
                                                        title: "Likes",
                                                        subtitle:
                                                            "Select some meals that you would enjoy eating.",
                                                        values: [
                                                          "spaghetti bolognese",
                                                          "chicken curry",
                                                          "beef tacos",
                                                          "margherita pizza",
                                                          "sushi rolls",
                                                          "lasagna",
                                                          "pad thai",
                                                          "caesar salad",
                                                          "grilled cheese sandwich",
                                                          "roast chicken",
                                                          "fish and chips",
                                                          "ramen",
                                                          "hamburgers",
                                                          "chicken alfredo",
                                                          "pulled pork sandwich",
                                                          "vegetable stir fry",
                                                          "shrimp scampi",
                                                          "fried rice",
                                                          "chicken fajitas",
                                                          "moussaka",
                                                          "lentil soup",
                                                          "falafel wrap",
                                                          "quinoa salad",
                                                          "vegan burrito bowl",
                                                          "tofu stir fry",
                                                          "eggplant parmesan",
                                                          "mushroom risotto",
                                                          "greek salad",
                                                          "chickpea curry",
                                                          "avocado toast",
                                                          "vegan shepherd's pie",
                                                        ],
                                                        onSave: (values) {
                                                          setState(() {
                                                            tastes = values;
                                                          });
                                                          _onContinue();
                                                        },
                                                        initialValues: tastes,
                                                      ),
                                                    )
                                                  : (stage == extrasIndex - 1 ||
                                                          stage ==
                                                              extrasIndex ||
                                                          stage ==
                                                              extrasIndex + 1)
                                                      ? Align(
                                                          key: const ValueKey(
                                                              'meal_plan_extras'),
                                                          alignment: Alignment
                                                              .topCenter,
                                                          child: AbsorbPointer(
                                                            absorbing: stage !=
                                                                extrasIndex,
                                                            child:
                                                                AnimatedOpacity(
                                                              duration:
                                                                  const Duration(
                                                                      milliseconds:
                                                                          300),
                                                              opacity: stage ==
                                                                      extrasIndex -
                                                                          1
                                                                  ? 0.3
                                                                  : 1,
                                                              child:
                                                                  DietSetting(
                                                                title:
                                                                    "Additions",
                                                                subtitle:
                                                                    "Add any additional requirements you might have. This can anything, such as likes/dislikes, goals, budgets or anything you can think of! I will try to incorporate as much of it into my planning as possible.",
                                                                values: [],
                                                                allowExtra:
                                                                    true,
                                                                onSave:
                                                                    (values) {
                                                                  setState(() {
                                                                    extras =
                                                                        values;
                                                                  });
                                                                  _onContinue();
                                                                },
                                                                initialValues:
                                                                    extras,
                                                              ),
                                                            ),
                                                          ),
                                                        )
                                                      : const SizedBox
                                                          .shrink(), // Use this to remove the widget completely when it's invisible
                            ),
                          ),
                          // if (stage == toolIndex || stage == toolIndex + 1)
                          //   Positioned.fill(
                          //     child: AnimatedOpacity(
                          //         opacity:
                          //             (stage == toolIndex || stage == toolIndex + 1)
                          //                 ? 1.0
                          //                 : 0.0,
                          //         duration: const Duration(milliseconds: 300),
                          //         child: MealPlanAllergies(
                          //           onContinue: _onContinue,
                          //         )),
                          //   ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onContinue() async {
    if (stage == messages.length - 1) {
      Navigator.push(
        context,
        SlideNavigator(
            builder: (context, _, __) => Container(
                  decoration: const BoxDecoration(
                      gradient: AppGradients.backgroundGradient),
                  child: DietSummary(
                    isTutorial: true,
                    tools: tools,
                    requirements: requirements,
                    tastes: tastes,
                    allergies: allergies,
                    extras: extras,
                    onProceed: (
                        {required List<String> tools,
                        required List<String> requirements,
                        required List<String> tastes,
                        required List<String> allergies,
                        required List<String> extras}) async {
                      // Not needed, since we now store hasCompletedTutorial in the database instead
                      // AppUser user = Provider.of<AppUser>(context, listen: false);
                      // await Provider.of<LocalStorageProvider?>(context,
                      //         listen: false)!
                      //     .set(
                      //         key: "${user.uid}-${LocalStorageKeys.hasVisited}",
                      //         value: "true");

                      await Navigator.pushReplacement(
                        context,
                        FadeNavigator(
                            builder: (context, _, __) => const AppNavigation()),
                      );
                    },
                  ),
                )),
      );
      // navigate to summary page
    } else if (stage == 1) {
      setState(() {
        stage++;
        _moveToBottom =
            true; // Triggers the animation to move the widget to the bottom
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        stage++;
      });
    } else {
      setState(() {
        stage++;
      });
    }
  }

  void _onBack() async {
    if (stage == 3) {
      setState(() {
        stage--;
        _moveToBottom =
            false; // Triggers the animation to move the widget to the bottom
      });
      await Future.delayed(const Duration(milliseconds: 1000));
      setState(() {
        stage--;
      });
    } else {
      setState(() {
        stage--;
      });
    }
  }
}
