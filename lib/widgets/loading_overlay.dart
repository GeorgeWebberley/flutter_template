import 'package:flutter/material.dart';
import 'package:flutter_firebase_template/theme/colours.dart';
import 'package:flutter_firebase_template/theme/padding.dart';
import 'package:flutter_firebase_template/theme/text.dart';

class LoadingOverlay extends StatelessWidget {
  const LoadingOverlay({
    super.key,
    required this.loading,
    required this.child,
    this.message,
  });

  final bool loading;
  final Widget child;
  final String? message;

  @override
  Widget build(BuildContext context) {
    return AbsorbPointer(
      absorbing: loading,
      child: Stack(
        children: [
          Opacity(opacity: loading ? 0.5 : 1, child: child),
          if (loading)
            Positioned.fill(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (message != null)
                      Padding(
                        padding:
                            const EdgeInsets.only(bottom: AppPading.medium),
                        child: Text(message!).h4(),
                      ),
                    const CircularProgressIndicator(color: AppColors.primary),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
