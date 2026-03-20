// //Drawn Value giver for 2D game

// import 'dart:async';

// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:psglotto/services/api_service.dart';
// import 'package:psglotto/view/widgets/home/lotto_card.dart';

// import '../../../../provider/providers.dart';

// class TimeForGame extends ConsumerStatefulWidget {
//   final int time;

//   const TimeForGame({required this.time, Key? key}) : super(key: key);

//   @override
//   ConsumerState<TimeForGame> createState() => _TimeForGameState();
// }

// class _TimeForGameState extends ConsumerState<TimeForGame> {
//   Timer? timer;
//   late String countdownDays;
//   late String countdownHours;
//   late String countdownMinutes;
//   late String countdownSeconds;
//   late Duration difference;

//   CountDownTimerFormat format = CountDownTimerFormat.daysHoursMinutesSeconds;

//   Duration timeDiff = DateTime.fromMillisecondsSinceEpoch(
//           InitGameOthersProvider.getInitGameOthers()['currentTime'])
//       .difference(DateTime.now());
//   String type = "";
//   String drawId = "";
//   String gameId = "";

//   @override
//   void initState() {
//     _startTimer();

//     super.initState();
//     setState(() {
//       timeDiff = DateTime.fromMillisecondsSinceEpoch(
//               InitGameOthersProvider.getInitGameOthers()['currentTime'])
//           .difference(DateTime.now());
//       type = InitGameOthersProvider.getInitGameOthers()['gameName'] ?? "-";
//       drawId = InitGameOthersProvider.getInitGameOthers()['drawId'] ?? "-";
//       gameId = InitGameOthersProvider.getInitGameOthers()['gameId'] ?? "-";
//     });
//   }

//   @override
//   void dispose() {
//     if (timer != null) {
//       timer!.cancel();
//     }
//     super.dispose();
//   }

//   void _startTimer() {
//     if (DateTime.fromMillisecondsSinceEpoch(widget.time).isBefore(DateTime.now()
//         .add(DateTime.fromMillisecondsSinceEpoch(
//                 InitGameOthersProvider.getInitGameOthers()['currentTime'])
//             .difference(DateTime.now())))) {
//       difference = Duration.zero;
//     } else {
//       difference = DateTime.fromMillisecondsSinceEpoch(widget.time)
//           .difference(DateTime.now().add(timeDiff));
//     }

//     countdownDays = _durationToStringDays(difference);
//     countdownHours = _durationToStringHours(difference);
//     countdownMinutes = _durationToStringMinutes(difference);
//     countdownSeconds = _durationToStringSeconds(difference);

//     if (difference == Duration.zero) {
//       // if (widget.onEnd != null) {
//       //   widget.onEnd!();
//       // }
//     } else {
//       timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//         difference = DateTime.fromMillisecondsSinceEpoch(widget.time)
//             .difference(DateTime.now().add(timeDiff));
//         setState(() {
//           countdownDays = _durationToStringDays(difference);
//           countdownHours = _durationToStringHours(difference);
//           countdownMinutes = _durationToStringMinutes(difference);
//           countdownSeconds = _durationToStringSeconds(difference);
//         });
//         if (difference <= Duration.zero) {
//           timer.cancel();
//           //   if (widget.onEnd != null) {
//           //     widget.onEnd!();
//           //   }
//         }
//       });
//     }
//   }

//   /// Convert [Duration] in days to String for UI.
//   String _durationToStringDays(Duration duration) {
//     return _twoDigits(duration.inDays, "days").toString();
//   }

//   /// Convert [Duration] in hours to String for UI.
//   String _durationToStringHours(Duration duration) {
//     if (format == CountDownTimerFormat.hoursMinutesSeconds ||
//         format == CountDownTimerFormat.hoursMinutes ||
//         format == CountDownTimerFormat.hoursOnly) {
//       return _twoDigits(duration.inHours, "hours");
//     } else {
//       return _twoDigits(duration.inHours.remainder(24), "hours").toString();
//     }
//   }

//   /// Convert [Duration] in minutes to String for UI.
//   String _durationToStringMinutes(Duration duration) {
//     if (format == CountDownTimerFormat.minutesSeconds ||
//         format == CountDownTimerFormat.minutesOnly) {
//       return _twoDigits(duration.inMinutes, "minutes");
//     } else {
//       return _twoDigits(duration.inMinutes.remainder(60), "minutes");
//     }
//   }

//   /// Convert [Duration] in seconds to String for UI.
//   String _durationToStringSeconds(Duration duration) {
//     if (format == CountDownTimerFormat.secondsOnly) {
//       return _twoDigits(duration.inSeconds, "seconds");
//     } else {
//       return _twoDigits(duration.inSeconds.remainder(60), "seconds");
//     }
//   }

//   /// When the selected [CountDownTimerFormat] is leaving out the last unit, this function puts the UI value of the unit before up by one.
//   ///
//   /// This is done to show the currently running time unit.
//   String _twoDigits(int n, String unitType) {
//     switch (unitType) {
//       case "minutes":
//         if (format == CountDownTimerFormat.daysHoursMinutes ||
//             format == CountDownTimerFormat.hoursMinutes ||
//             format == CountDownTimerFormat.minutesOnly) {
//           if (difference > Duration.zero) {
//             n++;
//           }
//         }
//         if (n >= 10) return "$n";
//         return "0$n";
//       case "hours":
//         if (format == CountDownTimerFormat.daysHours ||
//             format == CountDownTimerFormat.hoursOnly) {
//           if (difference > Duration.zero) {
//             n++;
//           }
//         }
//         if (n >= 10) return "$n";
//         return "0$n";
//       case "days":
//         if (format == CountDownTimerFormat.daysOnly) {
//           if (difference > Duration.zero) {
//             n++;
//           }
//         }
//         if (n >= 10) return "$n";
//         return "0$n";
//       default:
//         if (n >= 10) return "$n";
//         return "0$n";
//     }
//   }

//   String checkPlural(String type, String count) {
//     int parsedCount = int.tryParse(count) ?? 00;
//     String result = "";

//     /// find if the value of the parsedCount is greater than 01
//     /// if true add s to the end of string

//     if (parsedCount > 01) {
//       result = "$count ${type}s";
//     } else {
//       result = "$count $type";
//     }
//     return result;
//   }

//   String getCountDown() {
//     if (countdownDays != "00") {
//       return "${checkPlural("day", countdownDays)} ${checkPlural("hr", countdownHours)}";
//     } else if (countdownDays == "00" && countdownHours != "00") {
//       return "${checkPlural("hr", countdownHours)} ${checkPlural("min", countdownMinutes)}";
//     } else if (countdownMinutes == "00" && countdownSeconds != "00") {
//       return checkPlural("sec", countdownSeconds);
//     } else if (countdownMinutes != "00") {
//       return "${checkPlural("min", countdownMinutes)} ${checkPlural("sec", countdownSeconds)}";
//     } else {
//       return "To be drawn";
//     }
//   }

//   Future<void> getInitGameOthers(
//       {int? categoryId,
//       String? gameId,
//       String? drawId,
//       WidgetRef? widgetRef}) async {
//     ApiService().getInitGameOthers(
//         categoryId: categoryId!,
//         gameId: gameId!,
//         drawId: drawId!,
//         ref: widgetRef);
//   }

//   void nameChange(WidgetRef ref, String value) async {
//     ref.read(drawStartTimeNotifier.notifier).updateName(value);
//   }

//   //create Blink effect
//   Timer? _timer;
//   bool _show = false;
//   void timerFun() {
//     _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
//       setState(() {
//         _show = !_show;
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Text(
//           getCountDown(),
//           style: const TextStyle(
//             color: Colors.white,
//             fontWeight: FontWeight.w700,
//           ),
//         ),
//       ],
//     );
//   }
// }
