import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/box_shadow.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/lottie_controller.dart';

class TalkingVito extends StatefulWidget {
  const TalkingVito({
    super.key,
    this.text,
    required this.onContinue,
  });

  final String? text;
  final void Function()? onContinue;

  @override
  State<TalkingVito> createState() => _TalkingVitoState();
}

class _TalkingVitoState extends State<TalkingVito> {
  Timer? textTimer;
  String textToDisplay = "";
  bool showContinue = false;
  int punctuationLongWait = 10;
  int punctuationShortWait = 3;
  int punctuationIterations = 0;

  List<String> longWaitPunctuations = [".", "!", "?"];
  List<String> shortWaitPunctuations = [","];

  @override
  void initState() {
    super.initState();
    if (widget.text != null) {
      textTimer = Timer.periodic(const Duration(milliseconds: 20), (_) {
        int nextLength = textToDisplay.length + 1;
        if (nextLength > widget.text!.length) {
          nextLength = widget.text!.length;
        }

        if (textToDisplay.length < widget.text!.length) {
          if (textToDisplay.isEmpty) {
            setState(() {
              textToDisplay = widget.text!.substring(0, nextLength);
            });
            return;
          }
          String finalCharacter = textToDisplay[textToDisplay.length - 1];
          if ((shortWaitPunctuations.contains(finalCharacter)) &&
              (punctuationIterations < punctuationShortWait)) {
            setState(() {
              punctuationIterations++;
            });
          } else if ((longWaitPunctuations.contains(finalCharacter)) &&
              (punctuationIterations < punctuationLongWait)) {
            setState(() {
              punctuationIterations++;
            });
          } else {
            setState(() {
              textToDisplay = widget.text!.substring(0, nextLength);
              punctuationIterations = 0;
            });
          }
        } else {
          setState(() {
            showContinue = true;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    textTimer?.cancel();

    super.dispose();
  }

  void displayAll() {
    if (widget.text != null) {
      setState(() {
        textToDisplay = widget.text!;
      });
      textTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 500,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          if (widget.text != null)
            Positioned(
              bottom: 80,
              left: AppPading.medium,
              right: 0,
              child: Container(
                padding: EdgeInsets.all(AppPading.large),
                decoration: BoxDecoration(
                  boxShadow: [AppBoxShadow.small],
                  borderRadius: AppBorderRadius.large,
                  color: Colors.white,
                ),
                child: Text(textToDisplay).h5(),
              ),
            ),
          const Positioned(
            bottom: 0,
            left: 0,
            child: LottieController(
              location: 'assets/lottie/robot.json',
              height: 100,
              repeat: true,
            ),
          ),
          Positioned(
            bottom: AppPading.small,
            right: AppPading.small,
            child: AnimatedOpacity(
              opacity: showContinue ? 1.0 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: TextButton(
                onPressed: widget.onContinue,
                child: const Text(
                  "Continue",
                  style: TextStyle(color: AppColors.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
