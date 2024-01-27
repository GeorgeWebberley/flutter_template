import 'package:flutter/material.dart';

/// Keeping all application level font styles in one place for easier management.
/// Extends the default Text widget, allowing us to easily apply default styles.
/// Example usage:
///
/// Text(
///    'some text to display'
///    style: TextStyle(Colors.red)).h1();
extension AppText on Text {
  /// The default font weight that is applied. Can still be explicitly set
  static const FontWeight _defaultFontWeight = FontWeight.w300;

  /// For very large headings. Sets font size to 32 and applies default font weight
  Text h1() => _formatText(32);

  /// For large headings. Sets font size to 26 and applies default font weight
  Text h2() => _formatText(26);

  /// For medium headings. Sets font size to 22 and applies default font weight
  Text h3() => _formatText(22);

  /// For small headings. Sets font size to 20 and applies default font weight
  Text h4() => _formatText(20);

  /// For very small headings. Sets font size to 16 and applies default font weight
  Text h5() => _formatText(16);

  /// For paragraph text. Sets font size to 12 and applies default font weight
  Text p() => _formatText(12);

  /// For small font. Sets font size to 8 and applies default font weight
  Text small() => _formatText(8);

  Text _formatText(double size) {
    return Text(
      data!,
      maxLines: maxLines,
      overflow: overflow,
      textAlign: textAlign,
      textDirection: textDirection,
      textHeightBehavior: textHeightBehavior,
      textScaleFactor: textScaleFactor,
      textWidthBasis: textWidthBasis,
      semanticsLabel: semanticsLabel,
      softWrap: softWrap,
      strutStyle: strutStyle,
      locale: locale,
      style: style != null
          ? style!.copyWith(
              fontSize: style!.fontSize ?? size,
              fontWeight: style!.fontWeight ?? _defaultFontWeight)
          : TextStyle(fontSize: size, fontWeight: _defaultFontWeight),
    );
  }
}
