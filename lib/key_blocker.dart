import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class KeyBlocker extends StatefulWidget {
  final Widget child;

  const KeyBlocker({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  State<KeyBlocker> createState() => _KeyBlockerState();
}

class _KeyBlockerState extends State<KeyBlocker> {
  final FocusNode _focusNode = FocusNode();

  final Set<LogicalKeyboardKey> _pressedKeys = {};

 @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _focusNode.requestFocus();
    FocusManager.instance.addListener(() {
      if (!_focusNode.hasFocus) {
        _focusNode.requestFocus();
      }
    });
  });
}


  KeyEventResult _onKey(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      _pressedKeys.add(event.logicalKey);
    } else if (event is KeyUpEvent) {
      _pressedKeys.remove(event.logicalKey);
    }

    final isCtrl = _pressedKeys.contains(LogicalKeyboardKey.controlLeft) ||
        _pressedKeys.contains(LogicalKeyboardKey.controlRight);

    final isShift = _pressedKeys.contains(LogicalKeyboardKey.shiftLeft) ||
        _pressedKeys.contains(LogicalKeyboardKey.shiftRight);

    final isAlt = _pressedKeys.contains(LogicalKeyboardKey.altLeft) ||
        _pressedKeys.contains(LogicalKeyboardKey.altRight);

    final key = event.logicalKey;

    if (event is KeyDownEvent) {
      if (key == LogicalKeyboardKey.f5 ||
          (isCtrl && key == LogicalKeyboardKey.keyR) ||
          (isCtrl && key == LogicalKeyboardKey.keyU) ||
          (isCtrl && isShift && key == LogicalKeyboardKey.keyI) ||
          (isCtrl && isShift && key == LogicalKeyboardKey.keyC) ||
          (isAlt && key == LogicalKeyboardKey.tab) ||
          (isAlt && key == LogicalKeyboardKey.f4)) {
        debugPrint('🔒 Blocked key: ${key.debugName}');
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }

  void _onPointerDown(PointerDownEvent event) {
    debugPrint('🖱️ Click detected at: ${event.position}');
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _onPointerDown,
      child: Focus(
        focusNode: _focusNode,
        autofocus: true,
        onKeyEvent: _onKey,
        child: widget.child,
      ),
    );
  }
}


