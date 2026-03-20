import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../utils/game_constant.dart';
import '../utils/constants.dart';

class CustomeBlocker extends StatefulWidget {
  final Function callbackClear;
  const CustomeBlocker({required this.callbackClear, Key? key})
      : super(key: key);

  @override
  State<CustomeBlocker> createState() => _CustomeBlockerState();
}

class _CustomeBlockerState extends State<CustomeBlocker> {
  int secs = 0;
  String value = "secs";
  Timer? timer;
  @override
  void initState() {
    super.initState();
    if (mounted) {
      Future.delayed(const Duration(milliseconds: 100), () {
        setState(() {
          secs = GameConstant.timerGet();
        });
        widget.callbackClear();
        startTimer();
      });
    }
  }

  @override
  void dispose() {
    if (mounted) {
      startTimer();
    }
    if (timer != null) {
      timer!.cancel();
    }

    super.dispose();
  }

  void startTimer() {
    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        if (secs > 0) {
          if (mounted) {
            setState(() {
              secs--;
            });
          }
          if (secs < 2) {
            setState(() {
              value = "sec";
            });
          }
        } else {
          if (!mounted) {
            timer.cancel();
          }
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
        child: Container(
          //   filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
          // color: Colors.bl.withOpacity(0.3),
          width: MediaQuery.of(context).size.width,
          height: MediaQuery.of(context).size.height * 0.930,

          alignment: Alignment.center,
          child: Container(
            padding: const EdgeInsets.all(kDefaultPadding / 2),
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
                  height: kDefaultPadding / 2,
                ),
                RichText(
                  text: TextSpan(
                    text: 'Current Draw is inprogress \n',
                    children: [
                      TextSpan(
                        text: secs < 10
                            ? ' Next Draw will starts in 0${secs.toString()} $value'
                            : ' Next Draw will starts in ${secs.toString()} $value',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                    ],
                    style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black),
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
