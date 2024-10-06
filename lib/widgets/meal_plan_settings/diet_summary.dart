import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_firebase_template/models/app_user.dart';
import 'package:flutter_firebase_template/services/user_service.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/app_dialog.dart';
import 'package:flutter_firebase_template/shared/helpers.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';
import 'package:flutter_firebase_template/widgets/meal_plan_settings/diet_setting.dart';
import 'package:provider/provider.dart';

class DietSummary extends StatefulWidget {
  const DietSummary({
    super.key,
    required this.allergies,
    required this.requirements,
    required this.tools,
    required this.tastes,
    required this.extras,
    required this.isTutorial, // If is tutorial we always save their updates. Otherwise we ask them for confirmation.
    required this.onProceed,
    this.onBack,
    this.onRequirementsChanged,
    this.onAllergiesChanged,
    this.onToolsChanged,
    this.onTastesChanged,
    this.onExtrasChanged,
  });

  final List<String> allergies;
  final List<String> requirements;
  final List<String> tools;
  final List<String> tastes;
  final List<String> extras;
  final bool isTutorial;
  final void Function(
      {required List<String> requirements,
      required List<String> allergies,
      required List<String> tools,
      required List<String> tastes,
      required List<String> extras}) onProceed;
  final Future<void> Function()? onBack;

  final Function(List<String>)? onRequirementsChanged;
  final Function(List<String>)? onAllergiesChanged;
  final Function(List<String>)? onToolsChanged;
  final Function(List<String>)? onTastesChanged;
  final Function(List<String>)? onExtrasChanged;

  @override
  State<DietSummary> createState() => _DietSummaryState();
}

class _DietSummaryState extends State<DietSummary> {
  PageController pageController = PageController();
  Widget secondScreen = Container();
  int pageViewIndex = 0;

  late List<String> allergies;
  late List<String> requirements;
  late List<String> tools;
  late List<String> tastes;
  late List<String> extras;

  @override
  void initState() {
    requirements = widget.requirements;
    allergies = widget.allergies;
    tools = widget.tools;
    tastes = widget.tastes;
    extras = widget.extras;

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    AppUser? user = Provider.of<AppUser?>(context);

    Future<void> saveToDatabase() async {
      Map<String, dynamic> updates = {
        "hasCompletedTutorial": true,
      };
      // Save values to database if they have changed OR if it is tutorial (in which case they are all saved)
      if (!listsAreTheSame(requirements, widget.requirements) ||
          widget.isTutorial) {
        updates['requirements'] = requirements;
      }
      if (!listsAreTheSame(allergies, widget.allergies) || widget.isTutorial) {
        updates['allergies'] = allergies;
      }
      if (!listsAreTheSame(tools, widget.tools) || widget.isTutorial) {
        updates['tools'] = tools;
      }
      if (!listsAreTheSame(tastes, widget.tastes) || widget.isTutorial) {
        updates['tastes'] = tastes;
      }
      if (!listsAreTheSame(extras, widget.extras) || widget.isTutorial) {
        updates['extras'] = extras;
      }

      await UserService(uid: user!.uid).updateMultipleUserData(updates);
    }

    Future<void> saveAndProceed() async {
      if (widget.isTutorial) {
        await saveToDatabase();
        widget.onProceed.call(
            requirements: requirements,
            allergies: allergies,
            tools: tools,
            tastes: tastes,
            extras: extras);
      } else if (!listsAreTheSame(requirements, widget.requirements) ||
          !listsAreTheSame(allergies, widget.allergies) ||
          !listsAreTheSame(tools, widget.tools) ||
          !listsAreTheSame(tastes, widget.tastes) ||
          !listsAreTheSame(extras, widget.extras)) {
        await showDialog(
          context: context,
          builder: (context) {
            return AppDialog(
                content: Container(),
                title: "Do you want to also set this as your new default?",
                onCancel: () {
                  widget.onProceed.call(
                      requirements: requirements,
                      allergies: allergies,
                      tools: tools,
                      tastes: tastes,
                      extras: extras);
                },
                onSave: () async {
                  await saveToDatabase();
                  widget.onProceed.call(
                      requirements: requirements,
                      allergies: allergies,
                      tools: tools,
                      tastes: tastes,
                      extras: extras);
                });
          },
        );
      }
    }

    Widget buildSummaryPage() {
      return SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Summary",
              style: TextStyle(
                  fontFamily: 'Times New Roman',
                  fontSize: 40,
                  fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: AppPading.large,
            ),
            const Text(
              "Please check your diet and cooking settings. Are you happy to proceed?",
            ).h5(),
            const SizedBox(
              height: AppPading.large,
            ),
            _buildDropDown(
              title: "Dietary Requirements",
              content: requirements,
              onEdit: () {
                setScreen(DietSetting(
                  title: "Requirements",
                  subtitle:
                      "Select your dietary requirements. This does not include allergies, which we will cover next!",
                  values: const [
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
                  onSave: (newValues) {
                    setState(() {
                      requirements = newValues;
                    });
                    widget.onRequirementsChanged?.call(newValues);
                    backToRoot();
                  },
                  initialValues: requirements,
                ));
              },
            ),
            const SizedBox(
              height: AppPading.large,
            ),
            _buildDropDown(
              title: "Allergies",
              content: allergies,
              onEdit: () {
                setScreen(DietSetting(
                  title: "Allergies",
                  subtitle:
                      "Select all that apply. If you don't see your allergy simply add it using the + button!",
                  values: const [
                    "peanuts",
                    "shellfish",
                    "gluten",
                    "eggs",
                    "soy",
                  ],
                  allowExtra: true,
                  onSave: (newValues) {
                    setState(() {
                      allergies = newValues;
                    });
                    widget.onAllergiesChanged?.call(newValues);
                    backToRoot();
                  },
                  initialValues: allergies,
                ));
              },
            ),
            const SizedBox(
              height: AppPading.large,
            ),
            _buildDropDown(
              title: "Kitchen tools",
              content: tools,
              onEdit: () {
                setScreen(DietSetting(
                  title: "Kitchen Tools",
                  subtitle:
                      "Select all that apply! If we are missing anything add it with the + button!",
                  values: const [
                    "oven",
                    "microwave",
                    "sous vide",
                    "slow cooker",
                    "pressure cooker",
                    "food processor",
                    "air fryer",
                  ],
                  allowExtra: true,
                  onSave: (newValues) {
                    setState(() {
                      tools = newValues;
                    });
                    widget.onToolsChanged?.call(newValues);
                    backToRoot();
                  },
                  initialValues: tools,
                ));
              },
            ),
            const SizedBox(
              height: AppPading.large,
            ),
            _buildDropDown(
              title: "Tastes",
              content: tastes,
              onEdit: () {
                setScreen(DietSetting(
                  title: "Likes",
                  subtitle: "Select some meals that you would enjoy eating.",
                  values: const [
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
                  onSave: (newValues) {
                    setState(() {
                      tastes = newValues;
                    });
                    widget.onTastesChanged?.call(newValues);
                    backToRoot();
                  },
                  initialValues: tastes,
                ));
              },
            ),
            const SizedBox(
              height: AppPading.large,
            ),
            _buildDropDown(
              title: "Extras",
              content: extras,
              onEdit: () {
                setScreen(
                  DietSetting(
                    title: "Additions",
                    subtitle:
                        "Add any additional requirements you might have. This can anything, such as likes/dislikes, goals, budgets or anything you can think of! I will try to incorporate as much of it into my planning as possible.",
                    values: const [],
                    allowExtra: true,
                    onSave: (newValues) {
                      setState(() {
                        extras = newValues;
                      });
                      widget.onExtrasChanged?.call(newValues);
                      backToRoot();
                    },
                    initialValues: extras,
                  ),
                );
              },
            ),
            const SizedBox(
              height: AppPading.page,
            ),
            AppButton(
                onPressed: () {
                  saveAndProceed();
                },
                text: "Proceed"),
            const SizedBox(
              height: AppPading.page,
            ),
          ],
        ),
      );
    }

    List<Widget> screens = [
      Padding(
        padding: const EdgeInsets.fromLTRB(
          AppPading.page,
          0,
          AppPading.page,
          AppPading.page,
        ),
        child: buildSummaryPage(),
      ),
      Padding(
        padding: const EdgeInsets.fromLTRB(
          AppPading.page,
          0,
          AppPading.page,
          AppPading.page,
        ),
        child: secondScreen,
      )
    ];

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: pageViewIndex > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios),
                onPressed: backToRoot,
              )
            : pageViewIndex == 0 && !widget.isTutorial
                ? IconButton(
                    icon: const Icon(Icons.arrow_back_ios),
                    onPressed: () {
                      widget.onBack?.call();
                    },
                  )
                : Container(),
        actions: pageViewIndex == 0
            ? [
                TextButton(
                    onPressed: () {
                      saveAndProceed();
                    },
                    child: const Row(
                      children: [
                        Text(
                          "Proceed",
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
      ),
      body: PageView(
        controller: pageController,
        children: screens,
      ),
    );
  }

  Widget _buildDropDown({
    required String title,
    required List<String> content,
    required void Function() onEdit,
  }) {
    bool expanded = true;

    return StatefulBuilder(builder: (context, dropDownSetState) {
      return GestureDetector(
        onTap: () {
          dropDownSetState(() {
            expanded = !expanded;
          });
        },
        child: AppBox(
          child: Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: AppPading.large, vertical: AppPading.small),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ).h4(),
                    ),
                    Row(
                      children: [
                        AnimatedOpacity(
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 300),
                          opacity: expanded || content.isEmpty ? 1 : 0,
                          child: AbsorbPointer(
                            absorbing: !expanded && content.isNotEmpty,
                            child: IconButton(
                                onPressed: () {
                                  onEdit();
                                },
                                color: AppColors.primary,
                                iconSize: 20,
                                icon: const Icon(Icons.edit)),
                          ),
                        ),
                        AnimatedRotation(
                          curve: Curves.ease,
                          duration: const Duration(milliseconds: 300),
                          turns: expanded ? 0.25 : 0.75,
                          child: const Icon(Icons.chevron_left),
                        ),
                      ],
                    ),
                  ],
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.ease,
                  child: expanded
                      ? Wrap(
                          spacing: 8.0,
                          runSpacing: 4.0,
                          children: content.map((item) {
                            return Chip(
                              shape: RoundedRectangleBorder(
                                side:
                                    const BorderSide(color: Colors.transparent),
                                borderRadius: BorderRadius.circular(
                                  20,
                                ),
                              ),
                              backgroundColor: Colors.grey.withOpacity(0.2),
                              label: Text(
                                item,
                                style: TextStyle(
                                    color: Colors.black.withOpacity(0.8)),
                              ),
                              labelStyle: const TextStyle(
                                color: Colors.white,
                              ),
                            );
                          }).toList(),
                        )
                      : Container(),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  void setScreen(Widget screen) async {
    setState(() {
      secondScreen = screen;
      pageViewIndex = 1;
    });
    await pageController.animateToPage(pageViewIndex,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }

  backToRoot() async {
    setState(() {
      pageViewIndex = 0;
    });
    await pageController.animateToPage(pageViewIndex,
        duration: const Duration(milliseconds: 300), curve: Curves.ease);
  }
}
