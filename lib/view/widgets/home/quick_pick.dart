import 'package:flutter/material.dart';
import '../../utils/constants.dart';

class QuickPicksWidget extends StatefulWidget {
  final String title;
  final String subtitle;
  final String onlytitile;
  final Widget icon;
  final IconData? iconData;

  const QuickPicksWidget({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.onlytitile,
    required this.icon,
    this.iconData,
  }) : super(key: key);

  @override
  _QuickPicksWidgetState createState() => _QuickPicksWidgetState();
}

class _QuickPicksWidgetState extends State<QuickPicksWidget> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        margin: const EdgeInsets.all(8.0),
        padding: const EdgeInsets.all(8.0),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isHovered ? kPrimarySeedColor!.withOpacity(0.8) : kPrimarySeedColor!,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: isHovered
              ? [BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))]
              : [],
        ),
        transform: Matrix4.identity()..scale(isHovered ? 1.05 : 1.0),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (widget.iconData != null)
                Icon(
                  widget.iconData,
                  color: Colors.white,
                  size: 14.0,
                ),
              if (widget.iconData != null)
                const SizedBox(
                  width: 5.0,
                ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.title,
                    style: const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                  Row(
                    children: [
                      Text(
                        widget.onlytitile,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      SizedBox(
                        width: 10,
                        height: 10,
                        child: widget.icon,
                      ),
                      const SizedBox(
                        width: 2,
                      ),
                      Text(
                        widget.subtitle,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12.0,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
