import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:roundcheckbox/roundcheckbox.dart';

class AppCheckbox extends StatefulWidget {
  const AppCheckbox({
    super.key,
    required this.label,
    required this.initialValue,
    required this.onChanged,
  });

  final String label;
  final bool initialValue;
  final Function(bool) onChanged;

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  late bool? value;

  @override
  void initState() {
    super.initState();
    value = widget.initialValue;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Flexible(
          child: Text(
            widget.label,
            style: TextStyle(
              fontWeight: FontWeight.w400,
              color: Colors.black87,
            ),
          ).h5(),
        ),

        GestureDetector(
          onTap: () {
            setState(() {
              value = !(value ?? false);
            });
            widget.onChanged(value!);
          },
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 5),
            decoration: BoxDecoration(
              gradient:
                  value == true ? AppGradients.buttonPrimaryGradient : null,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.primary, width: 3),
              boxShadow: value == true
                  ? [
                      BoxShadow(
                        color: Colors.blue.withOpacity(0.2),
                        spreadRadius: 2,
                        blurRadius: 5,
                        offset: Offset(0, 3),
                      ),
                    ]
                  : null,
            ),
            child: Padding(
                padding: EdgeInsets.all(8.0), // Adjust padding as needed
                child: Icon(Icons.check,
                    color: value == true ? Colors.white : Colors.transparent)),
          ),
        )
        // RoundCheckBox(

        //     isChecked: value,
        //     onTap: (newValue) {
        //       setState(() {
        //         value = newValue;
        //       });
        //     })
      ],
    );
  }
}
