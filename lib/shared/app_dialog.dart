import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/border_radius.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';
import 'package:flutter_firebase_template/widgets/buttons/app_button.dart';

class AppDialog extends StatefulWidget {
  const AppDialog({
    super.key,
    this.title,
    this.onSave,
    this.onCancel,
    required this.content,
    this.buttonText = "Save",
    this.cancelButtonText = "Cancel",
    this.loading = false,
  });

  final String? title;
  final void Function()? onSave;
  final void Function()? onCancel;
  final Widget content;
  final String? buttonText;
  final String? cancelButtonText;
  final bool? loading;

  @override
  State<AppDialog> createState() => _AppDialogState();
}

class _AppDialogState extends State<AppDialog> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Dialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          shape: RoundedRectangleBorder(borderRadius: AppBorderRadius.small),
          child: Container(
            decoration: BoxDecoration(
              gradient: AppGradients.backgroundGradientMild,
              borderRadius: AppBorderRadius.small,
            ),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppPading.page),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (widget.title != null)
                        Padding(
                          padding:
                              const EdgeInsets.only(bottom: AppPading.page),
                          child: Text(
                            widget.title!,
                            textAlign: TextAlign.start,
                          ).h4(),
                        ),
                      widget.content,
                      if (widget.onSave != null || widget.onCancel != null)
                        Row(
                          children: [
                            if (widget.onCancel != null)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: AppPading.page),
                                  child: AppButton(
                                    size: widget.onCancel != null &&
                                            widget.onSave != null
                                        ? ButtonSize.small
                                        : ButtonSize.medium,
                                    loading: widget.loading ?? false,
                                    onPressed: () {
                                      widget.onCancel!();
                                    },
                                    text: widget.cancelButtonText,
                                    type: ButtonType.secondary,
                                  ),
                                ),
                              ),
                            if (widget.onCancel != null &&
                                widget.onSave != null)
                              const SizedBox(width: AppPading.medium),
                            if (widget.onSave != null)
                              Expanded(
                                child: Padding(
                                  padding: const EdgeInsets.only(
                                      top: AppPading.page),
                                  child: AppButton(
                                      size: widget.onCancel != null &&
                                              widget.onSave != null
                                          ? ButtonSize.small
                                          : ButtonSize.medium,
                                      loading: widget.loading ?? false,
                                      onPressed: () {
                                        widget.onSave!();
                                      },
                                      text: widget.buttonText!),
                                ),
                              ),
                          ],
                        )
                    ],
                  ),
                ),
                Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ))
              ],
            ),
          ),
        ),
      ],
    );
  }
}
