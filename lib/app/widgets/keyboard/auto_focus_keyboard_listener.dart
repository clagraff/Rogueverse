import 'package:flutter/material.dart';

/// A [KeyboardListener] that automatically manages focus and requests
/// focus after the first build.
///
/// This encapsulates the common pattern of:
/// 1. Creating a FocusNode
/// 2. Requesting focus in initState via addPostFrameCallback
/// 3. Disposing the FocusNode in dispose
///
/// If you need to manually request focus later (e.g., after a dialog closes),
/// provide your own [focusNode] - in that case, you are responsible for
/// disposing it.
///
/// Usage (simple case - fully managed):
/// ```dart
/// AutoFocusKeyboardListener(
///   onKeyEvent: _handleKeyEvent,
///   child: MyContent(),
/// )
/// ```
///
/// Usage (with external FocusNode for manual refocus):
/// ```dart
/// final _focusNode = FocusNode(); // You manage disposal
///
/// AutoFocusKeyboardListener(
///   focusNode: _focusNode,
///   onKeyEvent: _handleKeyEvent,
///   child: MyContent(),
/// )
///
/// // Later, to refocus:
/// _focusNode.requestFocus();
/// ```
class AutoFocusKeyboardListener extends StatefulWidget {
  /// The widget below this widget in the tree.
  final Widget child;

  /// Called when a key event occurs.
  final void Function(KeyEvent) onKeyEvent;

  /// Optional external FocusNode.
  ///
  /// If provided, the caller is responsible for disposing it.
  /// If not provided, this widget creates and manages its own.
  final FocusNode? focusNode;

  const AutoFocusKeyboardListener({
    super.key,
    required this.child,
    required this.onKeyEvent,
    this.focusNode,
  });

  @override
  State<AutoFocusKeyboardListener> createState() =>
      _AutoFocusKeyboardListenerState();
}

class _AutoFocusKeyboardListenerState extends State<AutoFocusKeyboardListener> {
  FocusNode? _ownedFocusNode;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_ownedFocusNode ??= FocusNode());

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _effectiveFocusNode.requestFocus();
      }
    });
  }

  @override
  void dispose() {
    _ownedFocusNode?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return KeyboardListener(
      focusNode: _effectiveFocusNode,
      autofocus: true,
      onKeyEvent: widget.onKeyEvent,
      child: widget.child,
    );
  }
}
