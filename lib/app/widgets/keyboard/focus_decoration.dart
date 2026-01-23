import 'package:flutter/material.dart';

/// Standard focus indicator decoration using a left border.
///
/// Returns a BoxDecoration with a left border that shows the primary color
/// when focused, transparent otherwise.
///
/// Usage:
/// ```dart
/// Container(
///   decoration: focusDecoration(colorScheme, isFocused: _isFocused),
///   child: ...
/// )
/// ```
BoxDecoration focusDecoration(ColorScheme scheme, {required bool isFocused}) {
  return BoxDecoration(
    border: Border(
      left: BorderSide(
        color: isFocused ? scheme.primary : Colors.transparent,
        width: 3,
      ),
    ),
  );
}

/// Decoration for grid/card items with a full border when focused.
BoxDecoration focusCardDecoration(
  ColorScheme scheme, {
  required bool isFocused,
  required bool isSelected,
  double borderRadius = 8,
}) {
  return BoxDecoration(
    color: isSelected
        ? scheme.primaryContainer
        : scheme.surfaceContainerHighest,
    borderRadius: BorderRadius.circular(borderRadius),
    border: Border.all(
      color: isFocused
          ? scheme.primary
          : isSelected
              ? scheme.primary
              : scheme.outline.withValues(alpha: 0.2),
      width: isFocused || isSelected ? 2 : 1,
    ),
    boxShadow: isFocused
        ? [
            BoxShadow(
              color: scheme.primary.withValues(alpha: 0.3),
              blurRadius: 4,
              spreadRadius: 1,
            ),
          ]
        : null,
  );
}

/// Background color for focused list rows.
Color? focusRowColor(ColorScheme scheme, {required bool isFocused, required bool isSelected}) {
  if (isSelected) {
    return scheme.primaryContainer.withValues(alpha: 0.3);
  }
  if (isFocused) {
    return scheme.primaryContainer.withValues(alpha: 0.15);
  }
  return null;
}
