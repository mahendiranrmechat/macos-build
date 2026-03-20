import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:psglotto/view/utils/custom_layout.dart';

class RefreshButton extends ConsumerStatefulWidget {
  final Function refreshFunction;
  const RefreshButton({required this.refreshFunction, Key? key})
      : super(key: key);

  @override
  ConsumerState<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends ConsumerState<RefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late Animation animation;
  Color topColor = const Color(0xFFFFFFFF);
  Color bottomColor = const Color.fromARGB(255, 228, 221, 8);

  @override
  void initState() {
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));
    animationController.repeat();

    animation =
        CurvedAnimation(parent: animationController, curve: Curves.easeIn)
          ..addListener(() {
            setState(() {});
          });

    super.initState();
  }

  @override
  void dispose() {
    animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
          decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.transparent,
              boxShadow: [
                BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: animation.value,
                    spreadRadius: animation.value)
              ]),
          child: RotationTransition(
            turns: animationController,
            child: IconButton(
                onPressed: () {
                  widget.refreshFunction();
                },
                icon: Icon(
                  Icons.refresh,
                  color: Platform.isWindows || Platform.isMacOS
                      ? Colors.white
                      : Colors.black,
                  size: 20,
                )),
          )
          //  const Icon(
          //   Icons.refresh,
          //   color: Colors.white,
          // ),
          ),
    );
  }
}


/*
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RefreshButton extends ConsumerStatefulWidget {
  final Function refreshFunction;
  final bool screenSizeChanger;

  const RefreshButton(
      {required this.screenSizeChanger,
      required this.refreshFunction,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<RefreshButton> createState() => _RefreshButtonState();
}

class _RefreshButtonState extends ConsumerState<RefreshButton>
    with SingleTickerProviderStateMixin {
  late AnimationController animationController;
  late List<Color> rippleColors;
  final int numberOfLines = 3; // Set the number of lines

  @override
  void initState() {
    super.initState();
    animationController =
        AnimationController(vsync: this, duration: const Duration(seconds: 2));

    rippleColors = [
      Colors.blue, // Color for the first line
      Colors.green, // Color for the second line
      Colors.red, // Color for the third line
    ];

    animationController.repeat(reverse: true);
    animationController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: CustomPaint(
        painter: RipplePainter(animationController.value, rippleColors),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              widget.refreshFunction();
            },
            borderRadius: BorderRadius.circular(30.0),
            child: Container(
              padding: widget.screenSizeChanger
                  ? const EdgeInsets.all(5.0)
                  : const EdgeInsets.all(15.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.1),
                    blurRadius: 5.0,
                    spreadRadius: 2.0,
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.refresh,
                  color: Platform.isWindows || Platform.isMacOS
                      ? Colors.white
                      : Colors.black,
                  size: widget.screenSizeChanger
                      ? 16
                      : 20, // Adjust the size of the icon
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class RipplePainter extends CustomPainter {
  final double animationValue;
  final List<Color> colors;

  RipplePainter(this.animationValue, this.colors);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint();

    for (int i = 0; i < colors.length; i++) {
      final double alpha =
          (255 * (1.0 - animationValue)).clamp(0, 255).toDouble();
      final Color rippleColor = colors[i].withAlpha(alpha.toInt());

      paint.color = rippleColor;
      paint.strokeWidth = 2.0;
      paint.style = PaintingStyle.stroke;

      canvas.drawCircle(size.center(Offset.zero),
          size.width * (i + 1) / (3 * colors.length), paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}




*/