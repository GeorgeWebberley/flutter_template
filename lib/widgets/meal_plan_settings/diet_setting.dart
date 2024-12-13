import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/shared/app_dialog.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/form_fields.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';

class DietSetting extends StatefulWidget {
  const DietSetting({
    super.key,
    required this.onSave,
    required this.initialValues,
    required this.values,
    required this.title,
    required this.subtitle,
    this.allowExtra = false,
    // this.databaseKey, // If database key not provided then won't update the preferences
  });

  final Function(List<String>) onSave;
  final List<String> initialValues;
  final List<String> values;
  final String title;
  final String subtitle;
  final bool allowExtra;
  // final String? databaseKey;

  @override
  State<DietSetting> createState() => _DietSettingState();
}

class _DietSettingState extends State<DietSetting>
    with TickerProviderStateMixin {
  late List<String> _values;

  // Track selected allergies
  List<String> _selectedValues = [];
  bool _isSaving = false;

  // Controller for animations
  late AnimationController _fadeController;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _values = List<String>.from(widget.values);
    for (String value in widget.initialValues) {
      if (!_selectedValues.contains(value.toLowerCase())) {
        _selectedValues.add(value.toLowerCase());
      }
      if (!_values.contains(value.toLowerCase())) {
        _values.add(value.toLowerCase());
      }
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  void _addCustomValue(String tool) {
    setState(() {
      _values.add(tool);
      _selectedValues.add(tool);
    });
  }

  @override
  Widget build(BuildContext context) {
    void onSave() async {
      setState(() {
        _isSaving = true;
      });

      await _fadeController.forward();

      setState(() {
        _values.removeWhere(
          (value) => !_selectedValues.contains(value),
        );
      });

      widget.onSave(_selectedValues);
    }

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
                fontFamily: 'Times New Roman',
                fontSize: 40,
                fontWeight: FontWeight.w500),
          ),
          const SizedBox(
            height: AppPading.large,
          ),
          Text(
            widget.subtitle,
          ).h5(),
          const SizedBox(
            height: AppPading.large,
          ),
          Wrap(
            spacing: 8.0,
            runSpacing: 4.0,
            children: _values.map((tool) {
              final bool isSelected = _selectedValues.contains(tool);
              final double opacity = isSelected || !_isSaving ? 1.0 : 0.0;

              return AbsorbPointer(
                absorbing: _isSaving,
                child: AnimatedOpacity(
                  opacity: opacity,
                  duration: const Duration(milliseconds: 500),
                  child: ChoiceChip(
                    shape: RoundedRectangleBorder(
                      side: BorderSide(color: Colors.transparent),
                      borderRadius: BorderRadius.circular(
                        20,
                      ),
                    ),
                    label: Text(tool),
                    selected: isSelected,
                    selectedColor: AppColors.primary.withOpacity(0.7),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedValues.add(tool);
                        } else {
                          _selectedValues.remove(tool);
                        }
                      });
                    },
                    backgroundColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected
                          ? Colors.white
                          : Colors.black.withOpacity(0.7),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(
            height: AppPading.medium,
          ),
          AnimatedOpacity(
            opacity: !_isSaving ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 300),
            child: Column(
              children: [
                if (widget.allowExtra)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        onPressed: () {
                          addCustomValueDialog(context);
                        },
                        icon: const Icon(Icons.add),
                        color: AppColors.primary,
                      ),
                    ],
                  ),
                const SizedBox(
                  height: AppPading.medium,
                ),
                AppButton(
                  onPressed: onSave,
                  text: "Save",
                ),
                const SizedBox(
                  height: AppPading.page,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void addCustomValueDialog(BuildContext context) {
    String? preference;
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, dialogSetState) {
          return AppDialog(
              content: Form(
                key: formKey,
                child: Column(
                  children: [
                    TextFormField(
                      autocorrect: false,
                      decoration: textInputDecoration.copyWith(
                        errorStyle: const TextStyle(color: Colors.red),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Add ${widget.title}'
                          : null,
                      onChanged: (value) {
                        dialogSetState(() {
                          preference = value;
                        });
                      },
                    ),
                  ],
                ),
              ),
              buttonText: "Add",
              title: "Enter a value",
              onSave: () async {
                if (formKey.currentState!.validate() && preference != null) {
                  try {
                    _addCustomValue(preference!);
                    Navigator.pop(context);
                  } catch (error) {
                    // Handle the error appropriately here
                  }
                }
              });
        });
      },
    );
  }
}
