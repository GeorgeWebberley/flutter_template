import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class NumberInput extends StatefulWidget {
  const NumberInput(
      {super.key,
      required this.onChanged,
      required this.label,
      this.initialValue,
      this.minValue = 0});

  final ValueChanged<int> onChanged;
  final String label;
  final int? initialValue;
  final int? minValue;

  @override
  State<NumberInput> createState() => _NumberInputState();
}

class _NumberInputState extends State<NumberInput> {
  late int value;
  late int minValue;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    value = widget.initialValue ?? widget.minValue ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.label,
          style: TextStyle(
            fontWeight: FontWeight.w400,
            color: Colors.black87,
          ),
        ).h5(),
        Spacer(),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            gradient: value == widget.minValue
                ? null
                : AppGradients.buttonPrimaryGradient,
            color: value == widget.minValue ? Colors.grey[200] : null,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: value == widget.minValue
                    ? Colors.grey.withOpacity(0.2)
                    : Colors.blue.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            onPressed: value == widget.minValue
                ? null
                : () {
                    setState(() {
                      value--;
                      widget.onChanged(value);
                    });
                  },
            icon: Icon(Icons.remove,
                color: value == widget.minValue
                    ? Colors.black.withOpacity(0.5)
                    : Colors.white),
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            "$value",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.symmetric(horizontal: 5),
          decoration: BoxDecoration(
            gradient: AppGradients.buttonPrimaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                spreadRadius: 2,
                blurRadius: 5,
                offset: Offset(0, 3),
              ),
            ],
          ),
          child: IconButton(
            onPressed: () {
              setState(() {
                value++;
                widget.onChanged(value);
              });
            },
            icon: Icon(Icons.add, color: Colors.white),
          ),
        )
      ],
    );
  }

  Widget _buildIconButton(IconData icon, VoidCallback onPressed) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 5),
      decoration: BoxDecoration(
        color: Colors.blueAccent,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.2),
            spreadRadius: 2,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white),
      ),
    );
  }
}
