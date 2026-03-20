import 'dart:async';
import 'dart:io';

import 'package:auto_size_text/auto_size_text.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:psglotto/utils/game_constant.dart';
import 'package:psglotto/view/utils/constants.dart';
// import 'package:psglotto/view/utils/custom_layout.dart';
import '../../../../params/init_game_others_params.dart';
import '../../../../provider/providers.dart';
import '../../../../services/api_service.dart';
import '../../../../update_value_2d_game.dart/init_game_others_notifier.dart';
import '../../../../utils/exception_handler.dart';
import '../../../utils/helper.dart';
import '../../snackbar.dart';
import '../lotto_card.dart';

class TopGameWidget extends ConsumerStatefulWidget {
  final WidgetRef ref;

  const TopGameWidget({required this.ref, Key? key}) : super(key: key);

  @override
  ConsumerState<TopGameWidget> createState() => _TopGameWidgetState();
}

class _TopGameWidgetState extends ConsumerState<TopGameWidget> {
//# Time baesd value
  Timer? timer;
  late String countdownDays;
  late String countdownHours;
  late String countdownMinutes;
  late String countdownSeconds;
  late Duration difference;

  CountDownTimerFormat format = CountDownTimerFormat.daysHoursMinutesSeconds;

  Duration timeDiff = DateTime.fromMillisecondsSinceEpoch(
          InitGameOthersProvider.getInitGameOthers()['currentTime'])
      .difference(DateTime.now());
  String type = "";
  String drawId = "";
  String gameId = "";
  String initDrawID = "";
  bool checkBlocker = false;

  List nextDrawList = [];
  int selectedTime =
      InitGameOthersProvider.getInitGameOthers()['drawStartTime'];
  int dropDownTime = 0;
  bool updatedDrawTime = false;

  int timeStamp = InitGameOthersProvider.getInitGameOthers()['drawStartTime'];
  int timeDIff = InitGameOthersProvider.getInitGameOthers()['currentTime'];

  @override
  void initState() {
    if (!mounted) {
      timer!.cancel();
    } else {
      _startTimer();
    }

    setState(() {
      checkBlocker = false;
      dropDownTime =
          InitGameOthersProvider.getInitGameOthers()['drawStartTime'];

      type = InitGameOthersProvider.getInitGameOthers()['gameName'] ?? "-";
      drawId = InitGameOthersProvider.getInitGameOthers()['drawId'] ?? "-";
      gameId = InitGameOthersProvider.getInitGameOthers()['gameId'] ?? "-";

      for (int i = 0;
          i <
              InitGameOthersProvider.getInitGameOthers()['nextDrawList']
                  .toList()
                  .length;
          i++) {
        nextDrawList.add(Helper.epocToMMddYYYYhhMMaa(
                InitGameOthersProvider.getInitGameOthers()['nextDrawList'][i]
                    ['drawStartTime'])
            .toString());
      }
      Future.delayed(const Duration(microseconds: 50), () {
        setReshresh(false);
      });

      Timer(
        const Duration(milliseconds: 2),
        () {
          updateDrawId(drawId);
          setResults(InitGameOthersProvider.getInitGameOthers()['results']);
        },
      );
    });

    // Start the timer for the first time
    startTimerInit();

    super.initState();
  }

  int diffOftime() {
    int drawStartTimeInMilliseconds =
        InitGameOthersProvider.getInitGameOthers()['drawStartTime'];
    int betCloseTimeInMilliseconds =
        InitGameOthersProvider.getInitGameOthers()['betCloseTime'];
    int diffSeconds = 0;
    DateTime drawStartTime =
        DateTime.fromMillisecondsSinceEpoch(drawStartTimeInMilliseconds);
    DateTime betCloseTime =
        DateTime.fromMillisecondsSinceEpoch(betCloseTimeInMilliseconds);
    Duration difference = drawStartTime.difference(betCloseTime);
    diffSeconds = difference.inSeconds;
    return diffSeconds;
  }

  void startTimerInit() {
    if (kDebugMode) {
      print("Start action running");
    }
    // Set the remaining time to the initial value
    Duration timeDiffeRence = DateTime.fromMillisecondsSinceEpoch(timeStamp)
        .difference(DateTime.now().add(timeDiff));
    int remainingTime = timeDiffeRence.inSeconds;

    // Start the timer
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      // Subtract 1 second from the remaining time
      remainingTime--;

      // If the remaining time is zero, stop the timer
      if (remainingTime <= 0) {
        //print("start time again");
        timer.cancel();
      }

      // If the remaining time is 60 seconds or less, start the new action
      if (remainingTime <= diffOftime() && checkBlocker == false) {
        if (InitGameOthersProvider.getInitGameOthers()['nextDrawList'][0]
                ['drawId'] ==
            drawId) {
          Future.delayed(const Duration(microseconds: 50), () {
            if (mounted) {
              setBlock(true);
              setState(() {
                updatedDrawTime = false;
                checkBlocker = true;
              });
            }
          });
        } else {
          Future.delayed(const Duration(microseconds: 50), () {
            if (mounted) {
              setState(() {
                updatedDrawTime = true;
                checkBlocker = true;
              });
            }
          });
        }

        GameConstant.timerSet(remainingTime);

        Future.delayed(Duration(seconds: remainingTime),
            () => startNewActionCurrent(remainingTime));

        // Cancel the timer to stop it from firing again
        timer.cancel();
      }
    });
  }

  void startNewActionCurrent(int remainingTime) {
    if (mounted) {
      Future.delayed(const Duration(seconds: 1),
          () => drawInitAgain(remainingTime, context));
    }
  }

  @override
  void dispose() {
    if (!mounted) {
      timer!.cancel();
      _startTimer();
      startTimerInit();
    }
    super.dispose();
  }

  void _startTimer() {
    if (DateTime.fromMillisecondsSinceEpoch(selectedTime).isBefore(
        DateTime.now().add(DateTime.fromMillisecondsSinceEpoch(
                InitGameOthersProvider.getInitGameOthers()['currentTime'])
            .difference(DateTime.now())))) {
      difference = Duration.zero;
    } else {
      difference = DateTime.fromMillisecondsSinceEpoch(selectedTime)
          .difference(DateTime.now().add(timeDiff));
    }

    countdownDays = _durationToStringDays(difference);
    countdownHours = _durationToStringHours(difference);
    countdownMinutes = _durationToStringMinutes(difference);
    countdownSeconds = _durationToStringSeconds(difference);

    if (difference == Duration.zero) {
      timer!.cancel();
    }

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      difference = DateTime.fromMillisecondsSinceEpoch(selectedTime)
          .difference(DateTime.now().add(timeDiff));
      if (!mounted) {
        timer.cancel();
      } else {
        setState(() {
          countdownDays = _durationToStringDays(difference);
          countdownHours = _durationToStringHours(difference);
          countdownMinutes = _durationToStringMinutes(difference);
          countdownSeconds = _durationToStringSeconds(difference);
        });
      }
      if (difference <= Duration.zero) {
        timer.cancel();
      }
    });
  }

  /// Convert [Duration] in days to String for UI.
  String _durationToStringDays(Duration duration) {
    return _twoDigits(duration.inDays, "days").toString();
  }

  /// Convert [Duration] in hours to String for UI.
  String _durationToStringHours(Duration duration) {
    if (format == CountDownTimerFormat.hoursMinutesSeconds ||
        format == CountDownTimerFormat.hoursMinutes ||
        format == CountDownTimerFormat.hoursOnly) {
      return _twoDigits(duration.inHours, "hours");
    } else {
      return _twoDigits(duration.inHours.remainder(24), "hours").toString();
    }
  }

  /// Convert [Duration] in minutes to String for UI.
  String _durationToStringMinutes(Duration duration) {
    if (format == CountDownTimerFormat.minutesSeconds ||
        format == CountDownTimerFormat.minutesOnly) {
      return _twoDigits(duration.inMinutes, "minutes");
    } else {
      return _twoDigits(duration.inMinutes.remainder(60), "minutes");
    }
  }

  /// Convert [Duration] in seconds to String for UI.
  String _durationToStringSeconds(Duration duration) {
    if (format == CountDownTimerFormat.secondsOnly) {
      return _twoDigits(duration.inSeconds, "seconds");
    } else {
      return _twoDigits(duration.inSeconds.remainder(60), "seconds");
    }
  }

  /// When the selected [CountDownTimerFormat] is leaving out the last unit, this function puts the UI value of the unit before up by one.
  String _twoDigits(int n, String unitType) {
    switch (unitType) {
      case "minutes":
        if (format == CountDownTimerFormat.daysHoursMinutes ||
            format == CountDownTimerFormat.hoursMinutes ||
            format == CountDownTimerFormat.minutesOnly) {
          if (difference > Duration.zero) {
            n++;
          }
        }
        if (n >= 10) return "$n";
        return "0$n";
      case "hours":
        if (format == CountDownTimerFormat.daysHours ||
            format == CountDownTimerFormat.hoursOnly) {
          if (difference > Duration.zero) {
            n++;
          }
        }
        if (n >= 10) return "$n";
        return "0$n";
      case "days":
        if (format == CountDownTimerFormat.daysOnly) {
          if (difference > Duration.zero) {
            n++;
          }
        }
        if (n >= 10) return "$n";
        return "0$n";
      default:
        if (n >= 10) return "$n";
        return "0$n";
    }
  }

  String checkPlural(String type, String count) {
    int parsedCount = int.tryParse(count) ?? 00;
    String result = "";
    if (parsedCount > 01) {
      result = "$count ${type}s";
    } else {
      result = "$count $type";
    }
    return result;
  }

  String getCountDown() {
    if (countdownDays != "00") {
      return "${checkPlural("day", countdownDays)} ${checkPlural("hr", countdownHours)}";
    } else if (countdownDays == "00" && countdownHours != "00") {
      return "${checkPlural("hr", countdownHours)} ${checkPlural("min", countdownMinutes)}";
    } else if (countdownMinutes == "00" && countdownSeconds != "00") {
      return checkPlural("sec", countdownSeconds);
    } else if (countdownMinutes != "00") {
      return "${checkPlural("min", countdownMinutes)} ${checkPlural("sec", countdownSeconds)}";
    } else {
      return "To be drawn";
    }
  }

  Future<void> getInitGameOthers(
      {int? categoryId, String? gameId, String? drawId}) async {
    ApiService().getInitGameOthers(
        categoryId: categoryId!, gameId: gameId!, drawId: drawId!);
  }

  void setBlock(bool setBlock) {
    if (mounted) {
      widget.ref.read(drawStartTimeNotifier.notifier).updateBlock(setBlock);
    }
  }

  //# refresh bool
  void setReshresh(bool refresh) {
    widget.ref.read(drawStartTimeNotifier.notifier).updateRefresh(refresh);
  }

  void drawBLocker(bool drawBlocker) {
    widget.ref
        .read(drawStartTimeNotifier.notifier)
        .updatedDrawBlocker(drawBlocker);
  }

  void setResults(List results) {
    widget.ref.read(drawStartTimeNotifier.notifier).updatedResult(results);
  }

  bool screenSizeChanger = false;

  @override
  Widget build(BuildContext context) {
    screenSizeChanger = MediaQuery.of(context).size.width < 1400 ? true : false;
    final AsyncValue gameAsyncData = ref.watch(game2dProvider);
    return WillPopScope(
      onWillPop: () async {
        setBlock(false);
        checkBlocker = false;
        ref.refresh(lobbyProvider);
        ref.refresh(balanceProvider);
        return true;
      },
      child: Platform.isWindows || Platform.isMacOS
          ? gameAsyncData.when(
              data: <InitGameOthersNew>(game2dProvider) {
                return Container(
                  color: kPrimarySeedColor!,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const BackButton(
                        color: Colors.white,
                      ),
                      AutoSizeText(
                        InitGameOthersProvider.getInitGameOthers() != null
                            ? InitGameOthersProvider.getInitGameOthers()[
                                'gameName']
                            : "-",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      SizedBox(
                        width: MediaQuery.of(context).size.width < 700
                            ? MediaQuery.of(context).size.width * 0.009
                            : MediaQuery.of(context).size.width * 0.01,
                      ),
                      Container(
                          width: MediaQuery.of(context).size.width < 1000
                              ? MediaQuery.of(context).size.width * 0.250
                              : MediaQuery.of(context).size.width * 0.170,
                          height: MediaQuery.of(context).size.height * 0.06,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white.withOpacity(0.3)),
                          child: DropdownSearch<String>(
                            selectedItem:
                                Helper.epocToMMddYYYYhhMMaa(dropDownTime),
                            items: List.from(nextDrawList),
                            popupProps: const PopupProps.menu(
                                constraints: BoxConstraints(maxHeight: 250)),
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                                    baseStyle: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold)),
                            onChanged: (newValue) async {
                              setState(() {
                                drawBLocker(true);
                                checkBlocker = false;
                                setBlock(false);
                                if (timer != null) {
                                  timer!.cancel();
                                }
                              });

                              for (int i = 0; i < nextDrawList.length; i++) {
                                if (nextDrawList[i] == newValue) {
                                  for (int j = 0;
                                      j <
                                          InitGameOthersProvider
                                                      .getInitGameOthers()[
                                                  'nextDrawList']
                                              .toList()
                                              .length;
                                      j++) {
                                    if (j == i) {
                                      drawId = InitGameOthersProvider
                                              .getInitGameOthers()[
                                          'nextDrawList'][j]['drawId'];
                                      initDrawID = InitGameOthersProvider
                                              .getInitGameOthers()[
                                          'nextDrawList'][j]['drawId'];
                                      if (kDebugMode) {
                                        print(drawId);
                                      }
                                      selectedTime = InitGameOthersProvider
                                              .getInitGameOthers()[
                                          'nextDrawList'][j]['drawStartTime'];
                                      dropDownTime = InitGameOthersProvider
                                              .getInitGameOthers()[
                                          'nextDrawList'][j]['drawStartTime'];

                                      updateDrawId(drawId);
                                      _startTimer();
                                      startTimerInit();
                                    }
                                  }
                                }
                              }

                              bool networkStatus =
                                  await Helper.checkNetworkConnection();
                              if (networkStatus) {
                                await ref
                                    .read(initGameOthersProvider(
                                            InitGameOthersParams(
                                                gameId: gameId,
                                                categoryId: 2,
                                                drawPlayGroupId:
                                                    InitGameOthersProvider
                                                            .getInitGameOthers()[
                                                        'drawPlayGroupId'], //return null when i send this req
                                                drawId: drawId))
                                        .future)
                                    .then((value) {
                                  if (value.status == 1) {
                                    if (mounted) {
                                      setState(() {
                                        drawBLocker(false);
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      drawBLocker(false);
                                    });

                                    showSnackBar(context,
                                        "Sorry, the isn't available. Please refresh");
                                  }
                                }).onError((error, stackTrace) {
                                  setState(() {
                                    drawBLocker(false);
                                  });

                                  ExceptionHandler.showSnack(
                                      errorCode: error.toString(),
                                      context: context);
                                });
                              } else {
                                setState(() {
                                  drawBLocker(false);
                                });

                                if (!mounted) return;
                                showSnackBar(
                                    context, "Check your internet connection");
                              }
                            },
                          )),
                      SizedBox(
                        width: MediaQuery.of(context).size.width * 0.01,
                      ),
                      Column(
                        // crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 5),
                              child: Center(
                                child: AutoSizeText(
                                  'Time to Draw',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                      fontSize: screenSizeChanger ? 10 : 15),
                                  maxLines: 1,
                                  minFontSize: 10,
                                  maxFontSize: 15,
                                ),
                              ),
                            ),
                          ),
                          //need to change update
                          // TimeForGame(time: selectedTime!)

                          Center(
                              child: AutoSizeText(
                            getCountDown(),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: screenSizeChanger ? 10 : 15),
                            maxLines: 1,
                            minFontSize: 10,
                            maxFontSize: 20,
                          ))
                        ],
                      ),
                      const Spacer(),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () {
                              setReshresh(true);
                              // setBlock(true);
                              // GameConstant.timerSet(timeDiffeRence.inSeconds + 10);
                            },
                            child: AutoSizeText(
                              'Next Draw ',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: screenSizeChanger ? 10 : 15),
                              maxLines: 1,
                              minFontSize: 10,
                              maxFontSize: 20,
                            ),
                          ),
                          AutoSizeText(
                            Helper.epocToMMddYYYYhhMMaa(
                                InitGameOthersProvider.getInitGameOthers()[
                                        'nextDrawList'][0]["drawStartTime"] ??
                                    0),
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: screenSizeChanger ? 10 : 15),
                            maxLines: 1,
                            minFontSize: 10,
                            maxFontSize: 20,
                          ),
                        ],
                      ),
                      const SizedBox(
                        width: 20.0,
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 10),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                // setBlock(false);
                                setReshresh(false);
                              },
                              child: AutoSizeText(
                                'Current time',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w700,
                                    fontSize: screenSizeChanger ? 10 : 15),
                                maxLines: 1,
                                minFontSize: 10,
                                maxFontSize: 20,
                              ),
                            ),
                            const SizedBox(
                              child: CurrentTime(),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
              error: (Object error, StackTrace? stackTrace) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  ExceptionHandler.showSnack(
                      errorCode: error.toString(), context: context);
                });

                return const Center(
                  child: Text("Something went wrong"),
                );
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            )
          : gameAsyncData.when(
              data: <InitGameOthersNew>(game2dProvider) {
                return SizedBox(
                  child: Row(
                    children: [
                      SizedBox(
                          width: MediaQuery.of(context).size.width * 0.50,
                          child: Row(
                            children: [
                              const BackButton(
                                color: Colors.white,
                              ),
                              // IconButton(
                              //     onPressed: () {
                              //       Navigator.pop(context);
                              //     },
                              //     icon: const Icon((Icons.arrow_back),
                              //         color: Colors.white)),
                              const Text(
                                "2D",
                                style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                              const SizedBox(
                                width: 2,
                              ),
                              const Icon(Icons.timer,
                                  size: 20, color: Colors.white),
                              Center(
                                child: Text(getCountDown(),
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 12)),
                              ),
                            ],
                          )),
                      Container(
                          width: MediaQuery.of(context).size.width * 0.50,
                          height: MediaQuery.of(context).size.height * 0.045,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(5),
                              color: Colors.white.withOpacity(0.3)),
                          child: DropdownSearch<String>(
                            selectedItem:
                                Helper.epocToMMddYYYYhhMMaa(dropDownTime),
                            items: List.from(nextDrawList),
                            popupProps: const PopupProps.menu(
                                constraints: BoxConstraints(maxHeight: 250)),
                            dropdownDecoratorProps:
                                const DropDownDecoratorProps(
                                    baseStyle: TextStyle(
                                        color: Colors.white,
                                        fontSize: 11,
                                        fontWeight: FontWeight.bold)),
                            onChanged: (newValue) async {
                              //new value aaded
                              setState(() {
                                drawBLocker(true);
                                checkBlocker = false;
                                setBlock(false);
                                if (timer != null) {
                                  timer!.cancel();
                                }
                              });

                              for (int i = 0; i < nextDrawList.length; i++) {
                                if (nextDrawList[i] == newValue) {
                                  for (int j = 0;
                                      j <
                                          InitGameOthersProvider
                                                      .getInitGameOthers()[
                                                  'nextDrawList']
                                              .toList()
                                              .length;
                                      j++) {
                                    if (j == i) {
                                      drawId = InitGameOthersProvider
                                              .getInitGameOthers()[
                                          'nextDrawList'][j]['drawId'];
                                      initDrawID = InitGameOthersProvider
                                              .getInitGameOthers()[
                                          'nextDrawList'][j]['drawId'];
                                      if (kDebugMode) {
                                        print(drawId);
                                      }
                                      selectedTime = InitGameOthersProvider
                                              .getInitGameOthers()[
                                          'nextDrawList'][j]['drawStartTime'];
                                      dropDownTime = InitGameOthersProvider
                                              .getInitGameOthers()[
                                          'nextDrawList'][j]['drawStartTime'];

                                      updateDrawId(drawId);
                                      _startTimer();
                                      startTimerInit();
                                    }
                                  }
                                }
                              }

                              bool networkStatus =
                                  await Helper.checkNetworkConnection();
                              if (networkStatus) {
                                await ref
                                    .read(initGameOthersProvider(
                                            InitGameOthersParams(
                                                gameId: gameId,
                                                categoryId: 2,
                                                drawPlayGroupId:
                                                    InitGameOthersProvider
                                                            .getInitGameOthers()[
                                                        'drawPlayGroupId'], //return null when i send this req
                                                drawId: drawId))
                                        .future)
                                    .then((value) {
                                  if (value.status == 1) {
                                    if (mounted) {
                                      setState(() {
                                        drawBLocker(false);
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      drawBLocker(false);
                                    });

                                    showSnackBar(context,
                                        "Sorry, the isn't available. Please refresh");
                                  }
                                }).onError((error, stackTrace) {
                                  setState(() {
                                    drawBLocker(false);
                                  });

                                  ExceptionHandler.showSnack(
                                      errorCode: error.toString(),
                                      context: context);
                                });
                              } else {
                                setState(() {
                                  drawBLocker(false);
                                });

                                if (!mounted) return;
                                showSnackBar(
                                    context, "Check your internet connection");
                              }
                            },
                          )),
                    ],
                  ),
                );
              },
              error: (Object error, StackTrace? stackTrace) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  ExceptionHandler.showSnack(
                      errorCode: error.toString(), context: context);
                });

                return const Center(
                  child: Text("Something went wrong"),
                );
              },
              loading: () {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
            ),
    );
  }

//get Game Init Again ==============||
  Future<void> drawInitAgain(int timeDiffeRence, BuildContext context) async {
    if (kDebugMode) {
      print("Comming inside drawInitAgain");
    }
    bool networkStatus = await Helper.checkNetworkConnection();
    if (networkStatus) {
      await ref
          .read(initGameOthersProvider(InitGameOthersParams(
        gameId: InitGameOthersProvider.getInitGameOthers()['gameId'],
        categoryId: InitGameOthersProvider.getInitGameOthers()['categoryId'],
        drawPlayGroupId: InitGameOthersProvider.getInitGameOthers()[
            'drawPlayGroupId'], //return null when i send this req
        drawId: "",
      )).future)
          .then((value) {
        if (value.status == 1) {
          //set refresh effect
          Future.delayed(const Duration(seconds: 10), () {
            setReshresh(true);
          });
          // timer!.cancel();
          widgetRebuildCondition();
          setBlock(false);

          setState(() {
            checkBlocker = false;
          });
          startTimerInit();
        } else {
          setBlock(false);
          setState(() {
            checkBlocker = false;
          });

          showSnackBar(context, "Sorry, the isn't available. Please refresh");
          startTimerInit();
        }
      }).onError((error, stackTrace) {
        timer!.cancel();
        Future.delayed(const Duration(microseconds: 10), () {
          setBlock(false);
        });

        ExceptionHandler.showSnack(
            errorCode: error.toString(), context: context);
      });
    } else {
      setBlock(false);
      setState(() {
        checkBlocker = false;
      });

      if (!mounted) return;
      showSnackBar(context, "Check your internet connection");
    }
  }

  void widgetRebuildCondition() {
    setState(() {
      nextDrawList.clear();
      timeStamp = InitGameOthersProvider.getInitGameOthers()['drawStartTime'];
      if (updatedDrawTime != true) {
        selectedTime =
            InitGameOthersProvider.getInitGameOthers()['drawStartTime'];
        dropDownTime =
            InitGameOthersProvider.getInitGameOthers()['drawStartTime'];

        drawId = InitGameOthersProvider.getInitGameOthers()['drawId'];
        updateDrawId(drawId);
      }

      // nextDrawList.removeAt(0);
      for (int i = 0;
          i <
              InitGameOthersProvider.getInitGameOthers()['nextDrawList']
                  .toList()
                  .length;
          i++) {
        nextDrawList.add(Helper.epocToMMddYYYYhhMMaa(
                InitGameOthersProvider.getInitGameOthers()['nextDrawList'][i]
                    ['drawStartTime'])
            .toString());
      }
    });
    setResults(InitGameOthersProvider.getInitGameOthers()['results']);

    _startTimer();
  }

  void updateDrawId(String drawId) {
    widget.ref.read(drawStartTimeNotifier.notifier).updateDrawId(drawId);
  }

  void updateDrawStartTime(int time) {
    widget.ref.read(drawStartTimeNotifier.notifier).updateDrawStartTime(time);
  }
}

class CurrentTime extends ConsumerStatefulWidget {
  const CurrentTime({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _CurrentTimeState createState() => _CurrentTimeState();
}

class _CurrentTimeState extends ConsumerState<CurrentTime> {
  // Note: StateNotifierProvider has *two* type annotations
  final clockProvider = StateNotifierProvider<Clock, DateTime>((ref) {
    return Clock();
  });

  bool screenSizeChanger = false;
  @override
  Widget build(BuildContext context) {
    screenSizeChanger = MediaQuery.of(context).size.width < 1400 ? true : false;
    final currentTime = ref.watch(clockProvider);
    final timeFormatted =
        DateFormat('dd/MM/yyyy, hh:mm aaa').format(currentTime);
    // DateFormat.Hms().format(currentTime);

    return SizedBox(
      child: AutoSizeText(
        timeFormatted,
        style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: screenSizeChanger ? 10 : 15),
        maxLines: 1,
        minFontSize: 10,
      ),
    );
  }
}

class Clock extends StateNotifier<DateTime> {
  // 1. initialize with current time
  Clock() : super(DateTime.now()) {
    // 2. create a timer that fires every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // 3. update the state with the current time
      state = DateTime.now();
    });
  }

  // ignore: unused_field
  late final Timer _timer;

  // 4. cancel the timer when finished
}
