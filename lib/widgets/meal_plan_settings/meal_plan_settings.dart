import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/shared/app_box.dart';
import 'package:flutter_firebase_template/shared/number_input.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';

class MealPlanSettings extends StatefulWidget {
  const MealPlanSettings({
    super.key,
    required this.onContinue,
    this.initialPeople = 1,
    this.initialBreakfasts = 0,
    this.initialLunches = 0,
    this.initialDinners = 0,
  });

  final int initialPeople;
  final int initialBreakfasts;
  final int initialLunches;
  final int initialDinners;

  final void Function(
      {required int numberOfPeople,
      required int numberOfBreakfasts,
      required int numberOfLunches,
      required int numberOfDinners}) onContinue;

  @override
  State<MealPlanSettings> createState() => _MealPlanSettingsState();
}

class _MealPlanSettingsState extends State<MealPlanSettings> {
  late int people;
  late int breakfasts;
  late int lunches;
  late int dinners;

  @override
  void initState() {
    people = widget.initialPeople;
    breakfasts = widget.initialBreakfasts;
    lunches = widget.initialLunches;
    dinners = widget.initialDinners;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(
          AppPading.page,
          0,
          AppPading.page,
          AppPading.page,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Meal plan settings",
                style: TextStyle(
                    fontFamily: 'Times New Roman',
                    fontSize: 40,
                    fontWeight: FontWeight.w500),
              ),
              const SizedBox(
                height: AppPading.large,
              ),
              Text(
                "Please specify the number of people you want to cook for, along with what type of meals you want to include in your meal plan.",
              ).h5(),
              const SizedBox(
                height: AppPading.large,
              ),
              _buildPeopleInput(),
              const SizedBox(
                height: AppPading.large,
              ),
              _buildMealPlanInput(),
              const SizedBox(
                height: AppPading.page,
              ),
              AppButton(
                disabled: breakfasts + lunches + dinners == 0,
                onPressed: () {
                  widget.onContinue(
                    numberOfPeople: people,
                    numberOfBreakfasts: breakfasts,
                    numberOfLunches: lunches,
                    numberOfDinners: dinners,
                  );
                },
                text: "Continue",
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealPlanInput() {
    return AppBox(
      child: Padding(
        padding: const EdgeInsets.all(AppPading.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(),
            NumberInput(
              label: "Breakfasts",
              initialValue: widget.initialBreakfasts,
              onChanged: (value) {
                setState(() {
                  breakfasts = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppPading.large),
              child: Divider(
                height: 0,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            NumberInput(
              label: "Lunches",
              initialValue: widget.initialLunches,
              onChanged: (value) {
                setState(() {
                  lunches = value;
                });
              },
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: AppPading.large),
              child: Divider(
                height: 0,
                color: Colors.black.withOpacity(0.1),
              ),
            ),
            NumberInput(
              label: "Dinners",
              initialValue: widget.initialDinners,
              onChanged: (value) {
                setState(() {
                  dinners = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPeopleInput() {
    return AppBox(
      child: Padding(
        padding: const EdgeInsets.all(AppPading.large),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(),
            NumberInput(
              label: "People",
              minValue: 1,
              initialValue: widget.initialPeople,
              onChanged: (value) {
                setState(() {
                  people = value;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
