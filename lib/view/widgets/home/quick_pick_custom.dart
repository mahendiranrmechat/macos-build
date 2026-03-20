import 'package:flutter/material.dart';

class QuickPicksWidgetCustom extends StatefulWidget {
  final String text;
  final IconData icon;
  final VoidCallback onPressed;
  final Color backgroundColor;
  final double iconSize;

  const QuickPicksWidgetCustom({
    Key? key,
    required this.text,
    required this.icon,
    required this.onPressed,
    required this.backgroundColor,
    this.iconSize = 24.0,
  }) : super(key: key);

  @override
  _QuickPicksWidgetCustomState createState() => _QuickPicksWidgetCustomState();
}

class _QuickPicksWidgetCustomState extends State<QuickPicksWidgetCustom> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onPressed,
      onHover: (hovering) {
        setState(() {
          isHovered = hovering;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isHovered ? widget.backgroundColor.withOpacity(0.8) : widget.backgroundColor,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: isHovered
              ? [const BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]
              : [],
        ),
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        child: Row(
          children: [
            Icon(
              widget.icon,
              color: Colors.white,
              size: widget.iconSize,
            ),
            const SizedBox(width: 8.0), // Space between icon and text
            Text(
              widget.text,
              style: const TextStyle(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
