import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MyOverlay extends StatefulWidget {
  final Function? overlayFucntion;
  const MyOverlay({this.overlayFucntion, Key? key}) : super(key: key);

  @override
  State<MyOverlay> createState() => _MyOverlayState();
}

class _MyOverlayState extends State<MyOverlay> {
  @override
  void initState() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (widget.overlayFucntion != null) {
        widget.overlayFucntion!();
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    const blur = 6.0; // 1.0 - very subtle, 9.0 - very strong blur

    return AbsorbPointer(
      absorbing: true,
      child: Container(
        alignment: Alignment.center,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          child: Container(
            padding: const EdgeInsets.all(16 / 2),
            height: 250,
            width: 250,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.0),
            ),
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Lottie.asset(
                  "assets/animations/loading.json",
                  height: 180,
                  width: 180,
                ),
                const SizedBox(
                  height: 16 / 2,
                ),
                const Text(
                  "Loading please wait",
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
