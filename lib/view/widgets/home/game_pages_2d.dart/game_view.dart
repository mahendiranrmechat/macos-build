// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/params/buy_ticket_others_params.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/utils/keyboard_shortcut.dart';
import 'package:psglotto/view/utils/claim_with_barcode.dart';
import 'package:psglotto/view/widgets/home/game_pages_2d.dart/game_value.dart';
import 'package:psglotto/view/widgets/home/purchase_status_view/purchase_status_v2diew_web.dart';
import 'package:psglotto/view/widgets/home/purchase_status_view/purchased_status_2dview.dart';
import 'package:psglotto/view/widgets/loading_overlay.dart';
import 'package:psglotto/view/widgets/snackbar.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:shimmer/shimmer.dart';
import '../../../../services/api_service.dart';
import '../../../../update_value_2d_game.dart/init_game_others_notifier.dart';
import '../../../../utils/exception_handler.dart';
import '../../../../utils/game_constant.dart';
import '../../../utils/constants.dart';
import '../../../utils/helper.dart';
import '../../loading_overlay_custome.dart';
import '../game_time_helper_widgets/tab_border_color.dart';
import '../game_time_helper_widgets/tab_color.dart';
import '../game_time_helper_widgets/top_widget.dart';

class GameView extends ConsumerStatefulWidget {
  final int categoryId;
  final String drawId;
  final String gamName;
  final List<String> nextDrawList;
  final List<dynamic> results;
  final List<dynamic> types;
  final int? drawStartTime;
  final int? betCloseTime;
  final double? userBalance;
  const GameView(
      {required this.drawId,
      required this.categoryId,
      required this.gamName,
      required this.nextDrawList,
      required this.results,
      required this.types,
      required this.userBalance,
      required this.betCloseTime,
      required this.drawStartTime,
      Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _GameViewState createState() => _GameViewState();
}

class _GameViewState extends ConsumerState<GameView> {
  //controller
  List<TextEditingController> numberInputList = [];

  // TextEditingController randomNumberController = TextEditingController();
  TextEditingController nextDrawController = TextEditingController();
  TextEditingController qtyControllerText = TextEditingController();

  // late AnimationController _animationController;
  // late Animation _animation;
  String drawId = "";
  bool showLoadingOverlay = false;
  bool resultOverlay = false;

//Random number
  Random rnd = Random();
  List randomListValue = [];

  int repeatingValue = 0;
  int totalPoint = 0;
  int totalQty = 0;
  int qytController = 1;

  bool setBlocker = false;
  int drawStartTime = 0;
  String drawID = "";
  double userBalance = 0;

  List<int> randomNumberController = [5, 10, 25, 50, 75];

  double? screenWidth;

  String localVariable = "12";

  //ticket byeValue
  List<Map<String, dynamic>> buyticket = [];
  List<Map<String, dynamic>> buyticketForReq = [];
  List lastDrawResult = [];
  bool screenSizeChanger = false;
  bool autoPrint = true;

  //focus keys
  List<FocusNode> focusNodes = [];
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  @override
  void initState() {
    super.initState();
    initialClear();
    addgameValue();
    getLastDrawResult();
//increament the focus
    // Initialize focus nodes
    for (int i = 0; i < showTextList["result"].length; i++) {
      focusNodes.add(FocusNode());
    }
    balanceProvider;
    qtyControllerText.text = "1"; // Setting the initial value for the field.
    drawId = widget.drawId;
    for (int i = 0; i < 121; i++) {
      numberInputList.add(TextEditingController());
    }
  }

  void addgameValue() {
    List<dynamic> types = InitGameOthersProvider.getInitGameOthers()['types'];

    for (int i = 0; i < types.length; i++) {
      String typeName = types[i]['typeName'].toString();
      num gamePoint = types[i]['price'];
      int typeId = types[i]['typeId'];
      Map<String, dynamic> gameEntry = {
        "gameName": typeName,
        "typeId": typeId,
        "gamePoint": gamePoint,
        "gameQty": 0,
        "totalPoint": 0,
      };

      gameValue.add(gameEntry);
    }
  }

  //asign game value
  Future<void> onRefresh() async {
    // ignore: unused_result
    ref.refresh(game2dProvider);
  }

  void getLastDrawResult() async {
    setState(() {
      resultOverlay = true;
    });

    await ApiService.getLastDrawResult(
      gameID: "2d",
      categoryID: 2,
    ).then((value) {
      setState(() {
        resultOverlay = false;
      });

      if (value != null) {
        setResults(value["results"]);
        setState(() {
          drawStartTime = value['drawStartTime'];
        });
      }
    }).onError((error, stackTrace) {
      if (!mounted) {
        return;
      }
      setState(() {
        resultOverlay = false;
      });
      ExceptionHandler.showSnack(errorCode: error.toString(), context: context);
    });
  }

  void setResults(List results) {
    ref.read(drawStartTimeNotifier.notifier).updatedResult(results);
  }

  @override
  void dispose() {
    super.dispose();
    onResetGameConstant();
  }

  void setReshresh(bool refresh) {
    ref.read(drawStartTimeNotifier.notifier).updateRefresh(refresh);
  }

  //! show ticket price
  bool showTicketPrice = false;

  @override
  Widget build(BuildContext context) {
    screenWidth =
        MediaQuery.of(context).size.width / MediaQuery.of(context).size.height -
            0.10;
    final initGameValue = ref.watch(drawStartTimeNotifier);

    // ignore: unused_local_variable
    final AsyncValue gameAsyncData = ref.watch(game2dProvider);

    return Scaffold(
        body: RefreshIndicator(
      onRefresh: () {
        return onRefresh();
      },
      child: gameAsyncData.when(data: <InitGameOthersNew>(game2dProvider) {
        screenSizeChanger =
            MediaQuery.of(context).size.width < 1400 ? true : false;
        final AsyncValue balance = ref.watch(balanceProvider);
        return Stack(children: [
          Column(
            children: [
              Container(
                color: Colors.transparent,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height *
                    0.055, //change 0.50 to 0.52 //changed 06 => 05
                child: TopGameWidget(
                  ref: ref,
                ),
              ),
              AbsorbPointer(
                absorbing: initGameValue.setBloack == true ? true : false,
                child: Shortcuts(
                  shortcuts: const <ShortcutActivator, Intent>{
                    SingleActivator(LogicalKeyboardKey.tab): TabIntent(),
                    SingleActivator(LogicalKeyboardKey.f1): ClaimIntent()
                  },
                  child: Actions(
                    actions: {
                      TabIntent:
                          CallbackAction<TabIntent>(onInvoke: (intent) => null),
                      ClaimIntent:
                          CallbackAction<ClaimIntent>(onInvoke: (intent) => null
                              // ClaimDialogHelper.showClaimDialog(context)
                              )
                    },
                    child: Focus(
                      autofocus: true,
                      child: Stack(
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                //it takes 80 center % height of the screen
                                width: MediaQuery.of(context).size.width,
                                height:
                                    MediaQuery.of(context).size.height * 0.810,
                                color: Colors.white54,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 2,
                                      child: Stack(
                                        children: [
                                          Container(
                                            margin: const EdgeInsets.only(
                                                left: 10, top: 10, bottom: 10),
                                            width: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.7,
                                            height: MediaQuery.of(context)
                                                    .size
                                                    .height *
                                                0.8,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              color: kPrimarySeedColor,
                                            ),
                                            child: Column(
                                              children: [
                                                //tab Bar
                                                Container(
                                                  margin: const EdgeInsets.only(
                                                      left: 10,
                                                      right: 10,
                                                      top: 10),
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.65,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.08,
                                                  color: Colors.transparent,
                                                  child: ListView.builder(
                                                      scrollDirection:
                                                          Axis.horizontal,
                                                      itemCount:
                                                          widget.types.length,
                                                      physics:
                                                          const NeverScrollableScrollPhysics(),
                                                      itemBuilder:
                                                          (context, index) {
                                                        return GestureDetector(
                                                          onTap: () {
                                                            betInputValue(
                                                                index);
                                                          },
                                                          child: Wrap(
                                                            children: [
                                                              Container(
                                                                alignment:
                                                                    Alignment
                                                                        .center,
                                                                width: screenSizeChanger
                                                                    ? MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.63 /
                                                                        10
                                                                    : MediaQuery.of(context)
                                                                            .size
                                                                            .width *
                                                                        0.65 /
                                                                        10,
                                                                height: MediaQuery.of(
                                                                            context)
                                                                        .size
                                                                        .height *
                                                                    0.08,
                                                                decoration: BoxDecoration(
                                                                    border: Border(
                                                                      top: BorderSide(
                                                                          width: screenSizeChanger
                                                                              ? 3.0
                                                                              : 5.0,
                                                                          color: selectedIndex == index
                                                                              ? TabBorderColor().tabBorderColors[index]
                                                                              : Colors.transparent),
                                                                      left: BorderSide(
                                                                          width: screenSizeChanger
                                                                              ? 3.0
                                                                              : 5.0,
                                                                          color: selectedIndex == index
                                                                              ? TabBorderColor().tabBorderColors[index]
                                                                              : Colors.transparent),
                                                                      right: BorderSide(
                                                                          style: BorderStyle
                                                                              .solid,
                                                                          width: screenSizeChanger
                                                                              ? 3.0
                                                                              : 5.0,
                                                                          color: selectedIndex == index
                                                                              ? TabBorderColor().tabBorderColors[index]
                                                                              : Colors.transparent),
                                                                    ),
                                                                    // borderRadius: const BorderRadius.only(
                                                                    //     topLeft: Radius.circular(5),
                                                                    //     topRight: Radius.circular(5)),
                                                                    color: selectedIndex == index ? TabColor().tabColors[index] : TabColor().tabColors[index],
                                                                    boxShadow: [
                                                                      BoxShadow(
                                                                        color: selectedIndex ==
                                                                                index
                                                                            ? Colors.black
                                                                            : Colors.transparent,
                                                                        blurRadius:
                                                                            10.0, // soften the shadow
                                                                        spreadRadius:
                                                                            5.0, //extend the shadow
                                                                        offset:
                                                                            const Offset(
                                                                          0.0, // Move to right 5  horizontally
                                                                          0.0, // Move to bottom 5 Vertically
                                                                        ),
                                                                      )
                                                                    ]),
                                                                child: Center(
                                                                    child:
                                                                        SizedBox(
                                                                  width: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .width *
                                                                      0.060,
                                                                  child: Center(
                                                                      child:
                                                                          AutoSizeText(
                                                                    InitGameOthersProvider.getInitGameOthers()['types'][index]
                                                                            [
                                                                            'typeName']
                                                                        .toString(),
                                                                    style: const TextStyle(
                                                                        // fontSize: screenSizeChanger
                                                                        //     ? 9
                                                                        //     : 15,
                                                                        color: Colors.black,
                                                                        fontWeight: FontWeight.bold),
                                                                    maxLines: 1,
                                                                    minFontSize:
                                                                        screenSizeChanger
                                                                            ? 10
                                                                            : 15,
                                                                    maxFontSize:
                                                                        screenSizeChanger
                                                                            ? 10
                                                                            : 20,
                                                                  )),
                                                                )),
                                                              ),
                                                            ],
                                                          ),
                                                        );
                                                      }),
                                                ),
                                                //Tab container view
                                                //unwanted flex
                                                Expanded(
                                                  flex: 1,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 10.0,
                                                            right: 10.0,
                                                            bottom: 10.0),
                                                    child: Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.7,
                                                      height:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .height *
                                                              0.66,
                                                      decoration: BoxDecoration(
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .only(
                                                            bottomLeft:
                                                                Radius.circular(
                                                                    10),
                                                            bottomRight:
                                                                Radius.circular(
                                                                    10),
                                                          ),
                                                          border: Border.all(
                                                            color: TabBorderColor()
                                                                    .tabBorderColors[
                                                                selectedIndex],
                                                            width:
                                                                screenSizeChanger
                                                                    ? 2.0
                                                                    : 5.0,
                                                          ),
                                                          color: Colors.white),
                                                      child:
                                                          RawKeyboardListener(
                                                        focusNode: FocusNode(),
                                                        onKey: (RawKeyEvent
                                                            event) {
                                                          if (event
                                                              is RawKeyDownEvent) {
                                                            if (event
                                                                    .logicalKey ==
                                                                LogicalKeyboardKey
                                                                    .arrowRight) {
                                                              _moveFocus(1);
                                                            } else if (event
                                                                    .logicalKey ==
                                                                LogicalKeyboardKey
                                                                    .arrowLeft) {
                                                              _moveFocus(-1);
                                                            } else if (event
                                                                    .logicalKey ==
                                                                LogicalKeyboardKey
                                                                    .arrowUp) {
                                                              _moveFocus(-11);
                                                            } else if (event
                                                                    .logicalKey ==
                                                                LogicalKeyboardKey
                                                                    .arrowDown) {
                                                              _moveFocus(11);
                                                            }
                                                          }
                                                        },
                                                        child: Form(
                                                          key: _formKey,
                                                          child:
                                                              GridView.builder(
                                                            physics:
                                                                const NeverScrollableScrollPhysics(),
                                                            itemCount:
                                                                showTextList[
                                                                        "result"]!
                                                                    .toList()
                                                                    .length,
                                                            gridDelegate:
                                                                SliverGridDelegateWithFixedCrossAxisCount(
                                                              childAspectRatio:
                                                                  screenWidth!,
                                                              // mainAxisSpacing:
                                                              //     0.0, // changed values 1.0 => 0.0
                                                              // crossAxisSpacing:
                                                              //     0.0,
                                                              crossAxisCount:
                                                                  11,
                                                            ),
                                                            itemBuilder:
                                                                (context,
                                                                    index) {
                                                              // print("Index = $index");
                                                              return Material(
                                                                color: Colors
                                                                    .transparent,
                                                                child: InkWell(
                                                                  hoverColor: index ==
                                                                          0
                                                                      ? Colors
                                                                          .transparent
                                                                      : numberInputList[index]
                                                                              .text
                                                                              .isEmpty
                                                                          ? Colors
                                                                              .black
                                                                          : Colors
                                                                              .red,
                                                                  onTap: () {
                                                                    /*
                                                                                            setState(
                                                                        () {
                                                                      if (index !=
                                                                          0) {
                                                                        String
                                                                            currentInputValue =
                                                                            numberInputList[index].text;
                                                                        int currentValue = currentInputValue.isNotEmpty
                                                                            ? int.parse(currentInputValue)
                                                                            : 0;

                                                                        // Use qtyController.text as the initial value
                                                                        int initialIncrement = qtyControllerText.text.isNotEmpty
                                                                            ? int.parse(qtyControllerText.text)
                                                                            : 1;

                                                                        int incrementedValue =
                                                                            currentValue +
                                                                                initialIncrement;

                                                                        if (incrementedValue >
                                                                            100) {
                                                                          incrementedValue =
                                                                              100;
                                                                        }

                                                                        numberInputList[index].text =
                                                                            incrementedValue.toString();
                                                                      }
                                                                    });

                                                                    ticketConfirm();



                                                                    */

                                                                    handleBetting(
                                                                        true,
                                                                        index);
                                                                  },
                                                                  onSecondaryTap:
                                                                      () {
                                                                    if (numberInputList[
                                                                            index]
                                                                        .text
                                                                        .isNotEmpty) {
                                                                      handleBetting(
                                                                          false,
                                                                          index);
                                                                    }
                                                                  },
                                                                  child:
                                                                      Container(
                                                                    color: TabColor()
                                                                        .tabColors[
                                                                            selectedIndex]
                                                                        .withOpacity(
                                                                            0.5),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceEvenly,
                                                                      children: [
                                                                        index ==
                                                                                0
                                                                            ? Column(
                                                                                children: [
                                                                                  AutoSizeText(
                                                                                    "Andhar",
                                                                                    style: const TextStyle(
                                                                                      color: Colors.red,
                                                                                      fontWeight: FontWeight.bold,
                                                                                    ),
                                                                                    maxLines: 1,
                                                                                    minFontSize: screenSizeChanger ? 10 : 15,
                                                                                    maxFontSize: screenSizeChanger ? 10 : 20,
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    "Bhahar",
                                                                                    style: const TextStyle(
                                                                                      fontWeight: FontWeight.bold,
                                                                                      color: Colors.green,
                                                                                    ),
                                                                                    maxLines: 1,
                                                                                    minFontSize: screenSizeChanger ? 10 : 15,
                                                                                    maxFontSize: screenSizeChanger ? 10 : 20,
                                                                                  )
                                                                                ],
                                                                              )
                                                                            : AutoSizeText(
                                                                                showTextList["result"]![index]['titile'].toString(),
                                                                                style: TextStyle(color: showTextList["result"]![index]['color'], fontWeight: showTextList["result"]![index]['titile'][0] == "A" || showTextList["result"]![index]['titile'][0] == "B" ? FontWeight.bold : FontWeight.w700, fontSize: screenSizeChanger ? 10 : 20),
                                                                                maxLines: 1,
                                                                                minFontSize: 8,
                                                                              ),
                                                                        //? Text input field
                                                                        index ==
                                                                                0
                                                                            ? const SizedBox()
                                                                            : Container(
                                                                                width: sizeInputWidth(context),
                                                                                height: sizeInputHeight(context),
                                                                                decoration: BoxDecoration(
                                                                                    border: Border.all(color: numberInputList[index].text.isNotEmpty ? kPrimarySeedColor! : Colors.black),
                                                                                    borderRadius: BorderRadius.circular(2),
                                                                                    gradient: LinearGradient(begin: Alignment.bottomCenter, end: Alignment.topCenter, stops: const [
                                                                                      0.3,
                                                                                      0.9
                                                                                    ], colors: [
                                                                                      numberInputList[index].text.isNotEmpty ? const Color(0xffDDAC17) : Colors.white70,
                                                                                      numberInputList[index].text.isNotEmpty ? const Color(0xffFFFA8A) : Colors.grey
                                                                                    ])),
                                                                                child: ticketBettingField(index),
                                                                              ),

                                                                        // if( showTextList["result"]![index]['titile'].toString().contains("9"))
                                                                      ],
                                                                    ),
                                                                  ),
                                                                ),
                                                              );
                                                            },
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 5,
                                            right: screenSizeChanger ? 3 : 0,
                                            child: Container(
                                              width: screenSizeChanger
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.575
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      0.590,
                                              height:
                                                  15, // Set the height as needed
                                              color: Colors
                                                  .transparent, // Color for the bottom layer
                                              child: ListView.builder(
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemCount: 10,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    hoverColor: TabColor()
                                                            .rowcolumnColor[
                                                        selectedIndex],
                                                    onSecondaryTap: () {
                                                      seriesSelection(
                                                          index, 1, true);
                                                    },
                                                    onTap: () {
                                                      seriesSelection(
                                                          index, 1, false);
                                                      debugPrint(
                                                          "Index from : $index");
                                                    },
                                                    child: Container(
                                                      width: screenSizeChanger
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.575 /
                                                              10
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              0.590 /
                                                              10,
                                                      height: 15,
                                                      decoration:
                                                          const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          topRight:
                                                              Radius.circular(
                                                                  20),
                                                        ),
                                                        color: Colors
                                                            .transparent, // Set the button background color
                                                      ),
                                                      child: Image.asset(
                                                        "Assets/images/arrow-up.png",
                                                        fit: BoxFit.contain,
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            bottom: 23,
                                            right: -5,
                                            child: Container(
                                              width:
                                                  15, // Set the width as needed
                                              height: screenSizeChanger
                                                  ? MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.590
                                                  : MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.62,
                                              color: Colors
                                                  .transparent, // Set the background color as needed
                                              child: ListView.builder(
                                                itemCount: 10,
                                                itemBuilder: (context, index) {
                                                  return InkWell(
                                                    hoverColor: TabColor()
                                                            .rowcolumnColor[
                                                        selectedIndex],
                                                    onSecondaryTap: () {
                                                      seriesSelection(
                                                          index, 0, true);
                                                    },
                                                    onTap: () {
                                                      seriesSelection(
                                                          index, 0, false);
                                                      debugPrint(
                                                          "Index from : $index");
                                                    },
                                                    child: Container(
                                                      width: 15,
                                                      height: screenSizeChanger
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.590 /
                                                              10
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.62 /
                                                              10,
                                                      decoration:
                                                          const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                          topLeft:
                                                              Radius.circular(
                                                                  20),
                                                          bottomLeft:
                                                              Radius.circular(
                                                                  20),
                                                        ),
                                                        color: Colors
                                                            .transparent, // Set the button background color
                                                      ),
                                                      child: Transform.rotate(
                                                        angle: -pi /
                                                            2, // Rotate the image 90 degrees counter-clockwise (pi/2 radians)
                                                        child: Image.asset(
                                                          "Assets/images/arrow-up.png",
                                                          fit: BoxFit.contain,
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    //Row and Colunm selection

                                    Expanded(
                                      flex: 1,
                                      child: MouseRegion(
                                        onExit: (event) {
                                          setState(() {
                                            showTicketPrice = false;
                                          });
                                        },
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10, bottom: 10, left: 10),
                                          child: Stack(
                                            alignment: Alignment.center,
                                            children: [
                                              Positioned(
                                                  top:
                                                      10, // Adjust the top and left values as needed
                                                  left:
                                                      -2, // Adjust the top and left values as needed
                                                  child: Tooltip(
                                                    message: "Price Structure",
                                                    child: InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          showTicketPrice =
                                                              !showTicketPrice;
                                                        });
                                                      },
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .width *
                                                            0.020,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.05,
                                                        decoration: BoxDecoration(
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10)),
                                                            color:
                                                                kPrimarySeedColor),
                                                        child: Center(
                                                          child: Icon(
                                                            showTicketPrice
                                                                ? Icons
                                                                    .arrow_forward_ios
                                                                : Icons
                                                                    .arrow_back_ios,
                                                            color: Colors.white,
                                                            size: 15,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  )),
                                              Container(
                                                // margin: const EdgeInsets.all(10),
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    0.3,
                                                height: MediaQuery.of(context)
                                                        .size
                                                        .height *
                                                    0.8,
                                                decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.transparent,
                                                ),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      height: screenSizeChanger
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.5
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.460,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color:
                                                            kPrimarySeedColor,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(10.0),
                                                        child: showTicketPrice
                                                            ? Container(
                                                                color: Colors
                                                                    .transparent,
                                                                child: Column(
                                                                  children: [
                                                                    Container(
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.080,
                                                                      color: Colors
                                                                          .black,
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          const Expanded(
                                                                              flex: 3,
                                                                              child: Center(
                                                                                child: AutoSizeText(
                                                                                  "Games Name",
                                                                                  style: TextStyle(
                                                                                    color: Colors.white,
                                                                                    fontWeight: FontWeight.bold,
                                                                                  ),
                                                                                  maxLines: 1,
                                                                                  minFontSize: 8,
                                                                                  maxFontSize: 20,
                                                                                ),
                                                                              )),
                                                                          const Expanded(
                                                                              flex: 2,
                                                                              child: Center(
                                                                                child: AutoSizeText(
                                                                                  "Play Points",
                                                                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                                  maxLines: 1,
                                                                                  minFontSize: 8,
                                                                                  maxFontSize: 20,
                                                                                ),
                                                                              )),
                                                                          Expanded(
                                                                              flex: 5,
                                                                              child: Container(
                                                                                color: Colors.black,
                                                                                child: const Column(children: [
                                                                                  AutoSizeText(
                                                                                    "Win Points",
                                                                                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                                                                    maxLines: 1,
                                                                                    minFontSize: 8,
                                                                                    maxFontSize: 20,
                                                                                  ),
                                                                                  Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                                    children: [
                                                                                      AutoSizeText(
                                                                                        "Single",
                                                                                        style: TextStyle(color: Colors.white),
                                                                                        maxLines: 1,
                                                                                        minFontSize: 5,
                                                                                        maxFontSize: 20,
                                                                                      ),
                                                                                      AutoSizeText(
                                                                                        "Double",
                                                                                        style: TextStyle(color: Colors.white),
                                                                                        maxLines: 1,
                                                                                        minFontSize: 5,
                                                                                        maxFontSize: 20,
                                                                                      )
                                                                                    ],
                                                                                  )
                                                                                ]),
                                                                              ))
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    Expanded(
                                                                      child:
                                                                          Center(
                                                                        child:
                                                                            Container(
                                                                          color:
                                                                              const Color(0xFF6969A5),
                                                                          child: ListView.builder(
                                                                              physics: const NeverScrollableScrollPhysics(),
                                                                              itemCount: InitGameOthersProvider.getInitGameOthers() == null ? 0 : InitGameOthersProvider.getInitGameOthers()['types']!.toList().length,
                                                                              itemBuilder: (context, index) {
                                                                                return Container(
                                                                                  width: MediaQuery.of(context).size.width * 0.180,
                                                                                  height: screenSizeChanger ? MediaQuery.of(context).size.height * 0.380 / 10 : MediaQuery.of(context).size.height * 0.360 / 10,
                                                                                  color: TabColor().tabColors[index],
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                    children: [
                                                                                      Expanded(
                                                                                        flex: 3,
                                                                                        child: SizedBox(
                                                                                          width: MediaQuery.of(context).size.width * 0.080,
                                                                                          child: Center(
                                                                                            child: AutoSizeText(
                                                                                              InitGameOthersProvider.getInitGameOthers()['types'][index]['typeName'].toString(),
                                                                                              textAlign: TextAlign.justify,
                                                                                              style: const TextStyle(
                                                                                                color: Colors.white,
                                                                                              ),
                                                                                              maxLines: 1,
                                                                                              minFontSize: 8,
                                                                                              maxFontSize: 20,
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                        flex: 2,
                                                                                        child: SizedBox(
                                                                                          width: MediaQuery.of(context).size.width * 0.040,
                                                                                          child: Center(
                                                                                            child: Text(
                                                                                              InitGameOthersProvider.getInitGameOthers()['types'][index]['price'].toString(),
                                                                                              style: const TextStyle(
                                                                                                color: Colors.white,
                                                                                                fontWeight: FontWeight.w500,
                                                                                                shadows: [
                                                                                                  Shadow(
                                                                                                    blurRadius: 4.0,
                                                                                                    color: Colors.black,
                                                                                                    offset: Offset(0.0, 0.0),
                                                                                                  ),
                                                                                                ],
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                      Expanded(
                                                                                          flex: 5,
                                                                                          child: SizedBox(
                                                                                            child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [
                                                                                              singleDoubleValue(index, "90"),
                                                                                              singleDoubleValue(index, "900"),
                                                                                            ]),
                                                                                          ))
                                                                                    ],
                                                                                  ),
                                                                                );
                                                                              }),
                                                                        ),
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              )
                                                            : Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceBetween,
                                                                children: [
                                                                  Container(
                                                                      width: screenSizeChanger
                                                                          ? MediaQuery.of(context).size.width *
                                                                              0.170
                                                                          : MediaQuery.of(context).size.width *
                                                                              0.180,
                                                                      height: MediaQuery.of(context)
                                                                              .size
                                                                              .height *
                                                                          0.50,
                                                                      color: Colors
                                                                          .black,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          //right side top
                                                                          /*
                                                                          Container(
                                                                            width:
                                                                                MediaQuery.of(context).size.width * 0.180,
                                                                            height:
                                                                                MediaQuery.of(context).size.height * 0.051,
                                                                            color:
                                                                                Colors.black,
                                                                            child:
                                                                                Row(
                                                                              children: [
                                                                                dashBoardTitile(context, 0.060, "TICKETS"), //60
                                                                                dashBoardTitile(context, 0.030, "QTY"), //40
                                                                                dashBoardTitile(context, 0.040, "POINTS"), //50
                                                                                dashBoardTitile(context, 0.020, ""), //50
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          //right side center
                                                                          Center(
                                                                            child:
                                                                                Container(
                                                                              height: screenSizeChanger ? MediaQuery.of(context).size.height * 0.350 : MediaQuery.of(context).size.height * 0.322,
                                                                              color: const Color(0xFF6969A5),
                                                                              child: ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  itemCount: InitGameOthersProvider.getInitGameOthers() == null ? 0 : InitGameOthersProvider.getInitGameOthers()['types']!.toList().length,
                                                                                  itemBuilder: (context, index) {
                                                                                    return Container(
                                                                                      width: MediaQuery.of(context).size.width * 0.180,
                                                                                      height: screenSizeChanger ? MediaQuery.of(context).size.height * 0.350 / 10 : MediaQuery.of(context).size.height * 0.322 / 10,
                                                                                      color: TabColor().tabColors[index],
                                                                                      child: Row(
                                                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                        children: [
                                                                                          SizedBox(
                                                                                            width: MediaQuery.of(context).size.width * 0.060,
                                                                                            child: Align(
                                                                                              alignment: Alignment.centerLeft,
                                                                                              child: AutoSizeText(
                                                                                                InitGameOthersProvider.getInitGameOthers()['types'][index]['typeName'].toString(),
                                                                                                textAlign: TextAlign.justify,
                                                                                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                                                                                                maxLines: 1,
                                                                                                minFontSize: screenSizeChanger ? 8 : 15,
                                                                                                maxFontSize: 25,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: screenSizeChanger ? MediaQuery.of(context).size.width * 0.030 : MediaQuery.of(context).size.width * 0.040,
                                                                                            child: Align(
                                                                                              alignment: Alignment.centerLeft,
                                                                                              child: AutoSizeText(
                                                                                                gameValue[index]['gameQty'].toString(),
                                                                                                style: const TextStyle(
                                                                                                  color: Colors.white,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontSize: 8,
                                                                                                  shadows: [
                                                                                                    Shadow(
                                                                                                      blurRadius: 4.0,
                                                                                                      color: Colors.black,
                                                                                                      offset: Offset(0.0, 0.0),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                maxLines: 1,
                                                                                                minFontSize: screenSizeChanger ? 8 : 15,
                                                                                                maxFontSize: 25,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: screenSizeChanger ? MediaQuery.of(context).size.width * 0.030 : MediaQuery.of(context).size.width * 0.020,
                                                                                            //update total qty and points
                                                                                            child: Align(
                                                                                              alignment: Alignment.centerLeft,
                                                                                              child: AutoSizeText(
                                                                                                "${gameValue[index]['gameQty'] * int.parse(InitGameOthersProvider.getInitGameOthers()['types'][index]['price'].toString().split(".")[0])}  ",
                                                                                                style: const TextStyle(
                                                                                                  color: Colors.white,
                                                                                                  fontWeight: FontWeight.w500,
                                                                                                  fontSize: 8,
                                                                                                  shadows: [
                                                                                                    Shadow(
                                                                                                      blurRadius: 4.0,
                                                                                                      color: Colors.black,
                                                                                                      offset: Offset(0.0, 0.0),
                                                                                                    ),
                                                                                                  ],
                                                                                                ),
                                                                                                maxLines: 1,
                                                                                                minFontSize: screenSizeChanger ? 8 : 15,
                                                                                                maxFontSize: 25,
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                          SizedBox(
                                                                                            width: screenSizeChanger ? MediaQuery.of(context).size.width * 0.020 : MediaQuery.of(context).size.width * 0.040,
                                                                                            //update total qty and points
                                                                                            child: Align(alignment: Alignment.centerLeft, child: IconButton(onPressed: () {}, icon: const Icon(Icons.delete))),
                                                                                          ),
                                                                                        ],
                                                                                      ),
                                                                                    );
                                                                                  }),
                                                                            ),
                                                                          ),
                                                                        
                                                                          //right side bottom
                                                                          Expanded(
                                                                            child:
                                                                                Container(
                                                                              color: Colors.black,
                                                                              child: Row(
                                                                                // mainAxisAlignment:
                                                                                //     MainAxisAlignment.spaceAround,
                                                                                children: [
                                                                                  dashBoardTitile(context, 0.070, "TOTAL"),
                                                                                  dashBoardTitile(context, 0.040, totalQty.toString()),
                                                                                  dashBoardTitile(context, 0.020, totalPoint.toString()),
                                                                                  SizedBox(
                                                                                    width: MediaQuery.of(context).size.width * 0.040,
                                                                                    //update total qty and points
                                                                                    child: Center(
                                                                                        child: IconButton(
                                                                                            onPressed: () {},
                                                                                            icon: const Icon(
                                                                                              Icons.delete,
                                                                                              color: Colors.white,
                                                                                            ))),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          )

                                                                          
                                                                            */
                                                                          Container(
                                                                            height:
                                                                                MediaQuery.of(context).size.height * 0.051,
                                                                            color:
                                                                                Colors.black,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                                                                              children: [
                                                                                dashBoardTitile(context, 3, "TICKETS"),
                                                                                dashBoardTitile(context, 1, "QTY"),
                                                                                dashBoardTitile(context, 2, "POINTS"),
                                                                                dashBoardTitile(context, 2, "DELETE"),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Expanded(
                                                                              flex: 8,
                                                                              child: Container(
                                                                                color: Colors.white,
                                                                                child: Center(
                                                                                  child: Container(
                                                                                    height: screenSizeChanger ? MediaQuery.of(context).size.height * 0.350 : MediaQuery.of(context).size.height * 0.322,
                                                                                    color: const Color(0xFF6969A5),
                                                                                    child: ListView.builder(
                                                                                        physics: const NeverScrollableScrollPhysics(),
                                                                                        itemCount: InitGameOthersProvider.getInitGameOthers() == null ? 0 : InitGameOthersProvider.getInitGameOthers()['types']!.toList().length,
                                                                                        itemBuilder: (context, index) {
                                                                                          return Container(
                                                                                            width: MediaQuery.of(context).size.width * 0.180,
                                                                                            height: screenSizeChanger ? MediaQuery.of(context).size.height * 0.350 / 10 : MediaQuery.of(context).size.height * 0.322 / 10,
                                                                                            color: TabColor().tabColors[index],
                                                                                            child: Row(
                                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                                              children: [
                                                                                                Expanded(
                                                                                                  flex: 3,
                                                                                                  child: Align(
                                                                                                    alignment: Alignment.center,
                                                                                                    child: AutoSizeText(
                                                                                                      InitGameOthersProvider.getInitGameOthers()['types'][index]['typeName'].toString(),
                                                                                                      textAlign: TextAlign.justify,
                                                                                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
                                                                                                      maxLines: 1,
                                                                                                      minFontSize: screenSizeChanger ? 8 : 15,
                                                                                                      maxFontSize: 25,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                Expanded(
                                                                                                  flex: 1,
                                                                                                  child: Align(
                                                                                                    alignment: Alignment.center,
                                                                                                    child: AutoSizeText(
                                                                                                      gameValue[index]['gameQty'].toString(),
                                                                                                      style: const TextStyle(
                                                                                                        color: Colors.white,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontSize: 8,
                                                                                                        shadows: [
                                                                                                          Shadow(
                                                                                                            blurRadius: 4.0,
                                                                                                            color: Colors.black,
                                                                                                            offset: Offset(0.0, 0.0),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      maxLines: 1,
                                                                                                      minFontSize: screenSizeChanger ? 8 : 15,
                                                                                                      maxFontSize: 25,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                Expanded(
                                                                                                  flex: 2,
                                                                                                  //update total qty and points
                                                                                                  child: Align(
                                                                                                    alignment: Alignment.center,
                                                                                                    child: AutoSizeText(
                                                                                                      "${gameValue[index]['gameQty'] * int.parse(InitGameOthersProvider.getInitGameOthers()['types'][index]['price'].toString().split(".")[0])}  ",
                                                                                                      style: const TextStyle(
                                                                                                        color: Colors.white,
                                                                                                        fontWeight: FontWeight.w500,
                                                                                                        fontSize: 8,
                                                                                                        shadows: [
                                                                                                          Shadow(
                                                                                                            blurRadius: 4.0,
                                                                                                            color: Colors.black,
                                                                                                            offset: Offset(0.0, 0.0),
                                                                                                          ),
                                                                                                        ],
                                                                                                      ),
                                                                                                      maxLines: 1,
                                                                                                      minFontSize: screenSizeChanger ? 8 : 15,
                                                                                                      maxFontSize: 25,
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                Expanded(
                                                                                                  flex: 2,
                                                                                                  child: Align(
                                                                                                    alignment: Alignment.topCenter,
                                                                                                    child: SizedBox(
                                                                                                      child: IconButton(
                                                                                                          onPressed: () {
                                                                                                            clearValue(index);
                                                                                                          },
                                                                                                          icon: Icon(
                                                                                                            Icons.delete,
                                                                                                            color: Colors.white,
                                                                                                            size: screenSizeChanger ? 14 : 20,
                                                                                                          )),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          );
                                                                                        }),
                                                                                  ),
                                                                                ),
                                                                              )),
                                                                          Container(
                                                                            color:
                                                                                Colors.black,
                                                                            height:
                                                                                MediaQuery.of(context).size.height * 0.065,
                                                                            child:
                                                                                Row(
                                                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                                              children: [
                                                                                dashBoardTitile(context, 3, "TOTAL"),
                                                                                dashBoardTitile(context, 1, totalQty.toString()),
                                                                                dashBoardTitile(context, 2, totalPoint.toString()),
                                                                                Expanded(
                                                                                  flex: 2,

                                                                                  //update total qty and points
                                                                                  child: Center(
                                                                                    child: IconButton(
                                                                                        onPressed: () {
                                                                                          clearAllValue();
                                                                                        },
                                                                                        icon: const Icon(
                                                                                          Icons.delete,
                                                                                          color: Color.fromARGB(255, 233, 95, 86),
                                                                                          size: 22,
                                                                                        )),
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                  Container(
                                                                      width: MediaQuery.of(context)
                                                                              .size
                                                                              .width *
                                                                          0.10,
                                                                      color: Colors
                                                                          .black,
                                                                      child:
                                                                          Column(
                                                                        children: [
                                                                          Stack(
                                                                            children: [
                                                                              initGameValue.refreshBool
                                                                                  ? Shimmer.fromColors(
                                                                                      baseColor: Colors.transparent,
                                                                                      highlightColor: Colors.yellow,
                                                                                      child: Container(
                                                                                        height: MediaQuery.of(context).size.height * 0.051,
                                                                                        color: Colors.black,
                                                                                      ))
                                                                                  : const SizedBox.shrink(),
                                                                              Container(
                                                                                height: MediaQuery.of(context).size.height * 0.051,
                                                                                color: Colors.transparent,
                                                                                child: Center(
                                                                                  child: Row(
                                                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                                                    children: [
                                                                                      AutoSizeText(
                                                                                        "RESULT",
                                                                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                                                                        maxLines: 1,
                                                                                        minFontSize: screenSizeChanger ? 12 : 15,
                                                                                        maxFontSize: 25,
                                                                                      ),

                                                                                      /*
initGameValue.refreshBool
                                                                                          ? RefreshButton(
                                                                                              refreshFunction: () {
                                                                                                setReshresh(false);
                                                                                                getLastDrawResult();
                                                                                              },
                                                                                            )
                                                                                          :


                                                                                      */
                                                                                      IconButton(
                                                                                          onPressed: () {
                                                                                            setReshresh(false);
                                                                                            getLastDrawResult();
                                                                                          },
                                                                                          icon: Icon(
                                                                                            Icons.refresh,
                                                                                            size: screenSizeChanger ? 14 : 20,
                                                                                            color: Colors.white,
                                                                                          ))
                                                                                    ],
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                          Stack(
                                                                            children: [
                                                                              Container(
                                                                                height: screenSizeChanger ? MediaQuery.of(context).size.height * 0.350 : MediaQuery.of(context).size.height * 0.322,
                                                                                color: Colors.grey[300],
                                                                                child: ListView.builder(
                                                                                  physics: const NeverScrollableScrollPhysics(),
                                                                                  itemCount: initGameValue.results.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    return Container(
                                                                                      height: screenSizeChanger ? MediaQuery.of(context).size.height * 0.0350 : MediaQuery.of(context).size.height * 0.0320,
                                                                                      color: TabColor().tabColors[index].withOpacity(0.2),
                                                                                      child: Center(
                                                                                        child: SizedBox(
                                                                                          width: MediaQuery.of(context).size.width * 0.180,
                                                                                          height: MediaQuery.of(context).size.height * 0.0322,
                                                                                          child: Align(
                                                                                            alignment: index.isEven ? Alignment.centerLeft : Alignment.centerRight,
                                                                                            child: Container(
                                                                                              margin: EdgeInsets.symmetric(
                                                                                                horizontal: screenSizeChanger ? 20 : 40,
                                                                                              ),
                                                                                              height: MediaQuery.of(context).size.width * 0.50,
                                                                                              width: MediaQuery.of(context).size.height * 0.05,
                                                                                              decoration: BoxDecoration(
                                                                                                borderRadius: BorderRadius.circular(50),
                                                                                                color: TabColor().tabColors[index],
                                                                                              ),
                                                                                              child: Center(
                                                                                                child: AutoSizeText(
                                                                                                  initGameValue.results[index]['winNo'].toString(),
                                                                                                  style: const TextStyle(
                                                                                                    fontSize: 10,
                                                                                                    color: Colors.white,
                                                                                                    fontWeight: FontWeight.bold,
                                                                                                    shadows: [
                                                                                                      Shadow(
                                                                                                        blurRadius: 4.0,
                                                                                                        color: Colors.black,
                                                                                                        offset: Offset(0.0, 0.0),
                                                                                                      ),
                                                                                                    ],
                                                                                                  ),
                                                                                                  minFontSize: 15,
                                                                                                  maxFontSize: 20,
                                                                                                  maxLines: 1,
                                                                                                ),
                                                                                              ),
                                                                                            ),
                                                                                          ),
                                                                                        ),
                                                                                      ),
                                                                                    );
                                                                                  },
                                                                                ),
                                                                              ),
                                                                              if (resultOverlay)
                                                                                Container(
                                                                                  height: screenSizeChanger ? MediaQuery.of(context).size.height * 0.350 : MediaQuery.of(context).size.height * 0.322,
                                                                                  color: Colors.grey[300],
                                                                                  child: const Center(
                                                                                    child: CircularProgressIndicator(),
                                                                                  ),
                                                                                )
                                                                            ],
                                                                          ),
                                                                          Container(
                                                                            color:
                                                                                Colors.black,
                                                                            child:
                                                                                FractionalTranslation(
                                                                              translation: const Offset(-0.0, 0.2),
                                                                              child: Column(
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                mainAxisAlignment: MainAxisAlignment.center,
                                                                                children: [
                                                                                  AutoSizeText(
                                                                                    Helper.epocToMMddYYYYhhMMaa(drawStartTime).split(',').last,
                                                                                    maxLines: 1,
                                                                                    minFontSize: 10,
                                                                                    maxFontSize: 25,
                                                                                    style: TextStyle(color: Colors.white, fontSize: screenSizeChanger ? 10 : 15, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                  AutoSizeText(
                                                                                    Helper.epocToMMddYYYY(drawStartTime),
                                                                                    maxLines: 1,
                                                                                    minFontSize: 10,
                                                                                    maxFontSize: 25,
                                                                                    style: TextStyle(color: Colors.white, fontSize: screenSizeChanger ? 10 : 15, fontWeight: FontWeight.bold),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                            ),
                                                                          ),
                                                                        ],
                                                                      )),
                                                                ],
                                                              ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.3,
                                                      height: screenSizeChanger
                                                          ? MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.250
                                                          : MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              0.3,
                                                      decoration: BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(10),
                                                        color:
                                                            kPrimarySeedColor,
                                                      ),
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(8.0),
                                                        child: Column(
                                                            children: [
                                                              Column(
                                                                children: [
                                                                  Container(
                                                                    height:
                                                                        screenSizeChanger
                                                                            ? 20
                                                                            : 30,
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      borderRadius: BorderRadius.only(
                                                                          topLeft: Radius.circular(
                                                                              10),
                                                                          topRight:
                                                                              Radius.circular(10)),
                                                                      color: Colors
                                                                          .black,
                                                                    ),
                                                                    child: const Center(
                                                                        child: AutoSizeText(
                                                                      "QUICK PICK",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontSize:
                                                                              20,
                                                                          fontWeight:
                                                                              FontWeight.w700),
                                                                      maxLines:
                                                                          1,
                                                                      minFontSize:
                                                                          15,
                                                                    )),
                                                                  ),
                                                                  Container(
                                                                    height:
                                                                        screenSizeChanger
                                                                            ? 30
                                                                            : 40,
                                                                    decoration:
                                                                        BoxDecoration(
                                                                      borderRadius: const BorderRadius
                                                                          .only(
                                                                          bottomLeft: Radius.circular(
                                                                              10),
                                                                          bottomRight:
                                                                              Radius.circular(10)),
                                                                      color: Colors
                                                                          .green
                                                                          .shade300,
                                                                    ),
                                                                    child: Row(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .spaceBetween,
                                                                      children: [
                                                                        Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceEvenly,
                                                                          children: [
                                                                            const Text(
                                                                              "Qty",
                                                                              style: TextStyle(fontWeight: FontWeight.bold),
                                                                            ),
                                                                            Container(
                                                                                width: MediaQuery.of(context).size.width * 0.070,
                                                                                height: 30,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: BorderRadius.circular(2),
                                                                                  color: Colors.white.withOpacity(0.2),
                                                                                ),
                                                                                child: Row(
                                                                                  children: [
                                                                                    SizedBox(
                                                                                        width: MediaQuery.of(context).size.width * 0.040,
                                                                                        height: 30,
                                                                                        child: TextFormField(
                                                                                            autofocus: true,
                                                                                            textAlignVertical: TextAlignVertical.center,
                                                                                            textAlign: TextAlign.center,
                                                                                            controller: qtyControllerText,
                                                                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                            inputFormatters: [
                                                                                              FilteringTextInputFormatter.digitsOnly,
                                                                                              LengthLimitingTextInputFormatter(3),
                                                                                            ],
                                                                                            onChanged: (value) {
                                                                                              setState(() {
                                                                                                if (value.isEmpty) {
                                                                                                  qtyControllerText.text = "1";
                                                                                                  qytController = 1;
                                                                                                } else if (int.parse(value) > 100) {
                                                                                                  qytController = 100;
                                                                                                  qtyControllerText.text = "100";
                                                                                                  qtyControllerText.selection = TextSelection.fromPosition(TextPosition(offset: qtyControllerText.text.length));
                                                                                                } else if (int.parse(value) < 1 || value == "001" || value == "01" || value == "011") {
                                                                                                  qytController = 1;
                                                                                                  qtyControllerText.text = "1";
                                                                                                  qtyControllerText.selection = TextSelection.fromPosition(TextPosition(offset: qtyControllerText.text.length));
                                                                                                } else {
                                                                                                  qytController = int.parse(qtyControllerText.text);
                                                                                                }
                                                                                              });
                                                                                            },

                                                                                            // onChanged: (value) {
                                                                                            //   setState(() {
                                                                                            //     if (int.parse(value) > 100) {
                                                                                            //       qytController = 100;
                                                                                            //       qtyControllerText.text = "100";
                                                                                            //       qtyControllerText.selection = TextSelection.fromPosition(TextPosition(offset: qtyControllerText.text.length));
                                                                                            //     } else if (int.parse(value) < 1 || value == "001" || value == "01" || value == "011") {
                                                                                            //       qytController = 1;
                                                                                            //       qtyControllerText.text = "1";
                                                                                            //       qtyControllerText.selection = TextSelection.fromPosition(TextPosition(offset: qtyControllerText.text.length));
                                                                                            //     } else {
                                                                                            //       qytController = int.parse(qtyControllerText.text);
                                                                                            //     }
                                                                                            //   });
                                                                                            // },
                                                                                            decoration: const InputDecoration(
                                                                                              contentPadding: EdgeInsets.only(left: 5, bottom: 5),
                                                                                              border: OutlineInputBorder(),
                                                                                            ))),
                                                                                    SizedBox(
                                                                                      width: MediaQuery.of(context).size.width * 0.008,
                                                                                    ),
                                                                                    SizedBox(
                                                                                      width: screenSizeChanger ? 15 : 20,
                                                                                      height: 30,
                                                                                      child: Column(children: [
                                                                                        InkWell(
                                                                                          onTap: () {
                                                                                            setState(() {
                                                                                              if (qytController <= 99) {
                                                                                                qytController++;
                                                                                                qtyControllerText.text = (qytController).toString();
                                                                                              }
                                                                                            });
                                                                                          },
                                                                                          child: const Icon(
                                                                                            Icons.add,
                                                                                            size: 15,
                                                                                            color: Colors.green,
                                                                                          ),
                                                                                        ),
                                                                                        InkWell(
                                                                                          onTap: () {
                                                                                            setState(() {
                                                                                              if (qytController >= 2) {
                                                                                                qytController--;
                                                                                                qtyControllerText.text = (qytController).toString();
                                                                                              }
                                                                                            });
                                                                                          },
                                                                                          child: const Icon(
                                                                                            Icons.minimize,
                                                                                            size: 15,
                                                                                            color: Colors.red,
                                                                                          ),
                                                                                        )
                                                                                      ]),
                                                                                    )
                                                                                  ],
                                                                                )),
                                                                          ],
                                                                        ),
                                                                        // Align(
                                                                        //   alignment: Alignment
                                                                        //       .bottomCenter,
                                                                        //   child:
                                                                        //       Transform(
                                                                        //     transform: Matrix4.rotationZ(
                                                                        //         screenSizeChanger
                                                                        //             ? 3.1415 *
                                                                        //                 1.5
                                                                        //             : 0), // Rotate 270 degrees
                                                                        //     child:
                                                                        //         FractionalTranslation(
                                                                        //       translation: Offset(
                                                                        //           screenSizeChanger
                                                                        //               ? -0.3
                                                                        //               : 0.1,
                                                                        //           screenSizeChanger
                                                                        //               ? -0.2
                                                                        //               : -0.4), // Adjust the vertical offset as needed
                                                                        //       child:

                                                                        //     ),
                                                                        //   ),
                                                                        // ),
                                                                        AutoSizeText(
                                                                          "Random",
                                                                          style: TextStyle(
                                                                              fontSize: screenSizeChanger ? 10 : 15,
                                                                              fontWeight: FontWeight.bold),
                                                                          maxLines:
                                                                              1,
                                                                          minFontSize:
                                                                              8,
                                                                          maxFontSize:
                                                                              15,
                                                                        ),

                                                                        Expanded(
                                                                          child: SizedBox(
                                                                              height: screenSizeChanger ? 25 : 30,
                                                                              child: ListView.builder(
                                                                                  scrollDirection: Axis.horizontal,
                                                                                  itemCount: randomNumberController.length,
                                                                                  itemBuilder: (context, index) {
                                                                                    return Padding(
                                                                                      padding: const EdgeInsets.all(2.0),
                                                                                      child: InkWell(
                                                                                        onTap: () {
                                                                                          setState(() {
                                                                                            for (int i = 0; i < numberInputList.length; i++) {
                                                                                              numberInputList[i].clear();
                                                                                            }
                                                                                            getRandomNumber(randomList.toList(), randomNumberController[index]);
                                                                                          });
                                                                                        },
                                                                                        child: Container(
                                                                                            decoration: BoxDecoration(
                                                                                              borderRadius: BorderRadius.circular(5),
                                                                                              color: Colors.yellow,
                                                                                            ),
                                                                                            width: screenSizeChanger ? MediaQuery.of(context).size.width * 0.100 / 5 : MediaQuery.of(context).size.width * 0.140 / 5,
                                                                                            child: Center(
                                                                                              child: AutoSizeText(
                                                                                                randomNumberController[index].toString(),
                                                                                                style: TextStyle(color: Colors.black, fontSize: screenSizeChanger ? 10 : 15, fontWeight: FontWeight.bold),
                                                                                                maxFontSize: 15,
                                                                                                minFontSize: 8,
                                                                                              ),
                                                                                            )),
                                                                                      ),
                                                                                    );
                                                                                  })),
                                                                        ),
                                                                      ],
                                                                    ),
                                                                  ),
                                                                  !screenSizeChanger
                                                                      ? const SizedBox(
                                                                          height:
                                                                              20,
                                                                        )
                                                                      : const SizedBox
                                                                          .shrink(),
                                                                  Center(
                                                                    child:
                                                                        Column(
                                                                      children: [
                                                                        Padding(
                                                                          padding: const EdgeInsets
                                                                              .only(
                                                                              left: 8,
                                                                              right: 8,
                                                                              top: 8),
                                                                          child:
                                                                              Row(
                                                                            mainAxisAlignment:
                                                                                MainAxisAlignment.spaceAround,
                                                                            children: [
                                                                              yellowButton("JODI"),
                                                                              yellowButton("ODD"),
                                                                              yellowButton("EVEN"),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                        !screenSizeChanger
                                                                            ? const SizedBox(
                                                                                height: 20,
                                                                              )
                                                                            : const SizedBox.shrink(),
                                                                        Center(
                                                                          child:
                                                                              AutoSizeText(
                                                                            "SERIES",
                                                                            style:
                                                                                const TextStyle(color: Colors.white, fontWeight: FontWeight.w500),
                                                                            maxFontSize:
                                                                                25,
                                                                            minFontSize: screenSizeChanger
                                                                                ? 10
                                                                                : 20,
                                                                            maxLines:
                                                                                1,
                                                                          ),
                                                                        ),

                                                                        !screenSizeChanger
                                                                            ? const SizedBox(
                                                                                height: 10,
                                                                              )
                                                                            : const SizedBox.shrink(),
                                                                        Wrap(
                                                                          alignment:
                                                                              WrapAlignment.start, // Align buttons to the start of the row
                                                                          spacing:
                                                                              2.0, // Adjust spacing between buttons
                                                                          children: List.generate(
                                                                              10,
                                                                              (index) {
                                                                            return Container(
                                                                              width: MediaQuery.of(context).size.width * 0.250 / 10,
                                                                              // Adjust this value
                                                                              height: MediaQuery.of(context).size.height * 0.0280, // Adjust this value
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: BorderRadius.circular(10),
                                                                                color: Colors.yellow,
                                                                              ),
                                                                              child: InkWell(
                                                                                onTap: () {
                                                                                  setState(() {
                                                                                    for (int j = 0; j < showTextList["result"]!.toList().length; j++) {
                                                                                      numberInputList[j].clear();
                                                                                      if (kDebugMode) {
                                                                                        print(showTextList["result"][j]['titile']);
                                                                                      }

                                                                                      if (showTextList["result"][j]['titile'].toString().contains('$index') && !showTextList["result"][j]['titile'].toString().contains("A") && !showTextList["result"][j]['titile'].toString().contains("B")) {
                                                                                        numberInputList[j].text = qytController.toString();
                                                                                        showTextList["result"]![j]['qty'] = int.parse(qytController.toString());
                                                                                      }
                                                                                    }
                                                                                    ticketConfirm();
                                                                                  });
                                                                                },
                                                                                child: SizedBox(
                                                                                  child: Center(
                                                                                    child: Text(
                                                                                      index.toString(),
                                                                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                                                                    ),
                                                                                  ),
                                                                                ),
                                                                              ),
                                                                            );
                                                                          }),
                                                                        ),

                                                                        // Row(
                                                                        //   mainAxisAlignment:
                                                                        //       MainAxisAlignment.spaceAround,
                                                                        //   children: [...generateNumberButton()],
                                                                        // ),
                                                                      ],
                                                                    ),
                                                                  )
                                                                ],
                                                              )
                                                            ]),
                                                      ),
                                                    )
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Container(
                                  height: MediaQuery.of(context).size.height *
                                      0.130,
                                  color: Colors.transparent,
                                  child: Column(
                                    children: [
                                      Expanded(
                                          child: Container(
                                        color: Colors.transparent,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              "Tickets: ${totalQty.toString()} ",
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              children: [
                                                const Icon(
                                                  Icons.stars_sharp,
                                                  size: 16,
                                                ),
                                                const SizedBox(
                                                  width: 4,
                                                ),
                                                Text(
                                                  totalPoint.toString(),
                                                  style: const TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      )),
                                      Expanded(
                                          flex: 2,
                                          child: Container(
                                            color: Colors.transparent,
                                            child: Row(
                                              children: [
                                                Expanded(
                                                    flex: 4,
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: Column(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .start,
                                                        children: [
                                                          Text(
                                                            SharedPref.instance
                                                                    .getString(
                                                                        "username") ??
                                                                "-",
                                                            style: const TextStyle(
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold),
                                                          ),
                                                          Row(
                                                            children: [
                                                              const Text(
                                                                "Balance :",
                                                                style: TextStyle(
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .bold),
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              const Icon(
                                                                Icons
                                                                    .stars_sharp,
                                                                size: 16,
                                                              ),
                                                              const SizedBox(
                                                                width: 4,
                                                              ),
                                                              InkWell(
                                                                onTap: () {
                                                                  screenSizeChanger
                                                                      // ignore: unused_result
                                                                      ? ref.refresh(
                                                                          balanceProvider)
                                                                      : null;
                                                                },
                                                                child: balance
                                                                    .when(data:
                                                                        (balance) {
                                                                  setState(() {
                                                                    userBalance =
                                                                        balance;
                                                                  });
                                                                  // return Text(" ${balance.toStringAsFixed(2)}");
                                                                  return Text(
                                                                    balance
                                                                        .toStringAsFixed(
                                                                            2),
                                                                    style: const TextStyle(
                                                                        fontWeight:
                                                                            FontWeight.bold),
                                                                  );
                                                                }, error:
                                                                        (e, s) {
                                                                  return const Text(
                                                                      "-");
                                                                }, loading: () {
                                                                  return const SizedBox(
                                                                    width: 50.0,
                                                                    child:
                                                                        LinearProgressIndicator(),
                                                                  );
                                                                }),
                                                              ),
                                                              screenSizeChanger
                                                                  ? const SizedBox
                                                                      .shrink()
                                                                  : IconButton(
                                                                      onPressed: () =>
                                                                          ref.refresh(
                                                                              balanceProvider),
                                                                      icon:
                                                                          const Icon(
                                                                        Icons
                                                                            .refresh,
                                                                      ))
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    )),
                                                Expanded(
                                                    flex: screenSizeChanger
                                                        ? 3
                                                        : 2,
                                                    child: Container(
                                                      color: Colors.transparent,
                                                      child: Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          ClaimWithBarcode(
                                                              categoryId: widget
                                                                  .categoryId,
                                                              gameName: widget
                                                                  .gamName),
                                                          const SizedBox(
                                                            width: 5.0,
                                                          ),
                                                          SizedBox(
                                                            height: 32.0,
                                                            child:
                                                                ElevatedButton(
                                                              onPressed:
                                                                  () async {
                                                                if (totalPoint <=
                                                                    userBalance) {
                                                                  bool
                                                                      networkStatus =
                                                                      await Helper
                                                                          .checkNetworkConnection();
                                                                  if (buyticketForReq
                                                                      .isNotEmpty) {
                                                                    if (qytController >
                                                                        0) {
                                                                      if (networkStatus) {
                                                                        setState(
                                                                            () {
                                                                          showLoadingOverlay =
                                                                              true;
                                                                        });

                                                                        await ref.read(buyTicketOthersProvider(BuyTicketOthersParams(drawId: initGameValue.drawId, gameId: "2d", types: buyticketForReq
                                                                            //return null when i send this req
                                                                            )).future).then((value) {
                                                                          if (value.errorCode ==
                                                                              0) {
                                                                            if (mounted) {
                                                                              setState(() {
                                                                                showLoadingOverlay = false;
                                                                              });
                                                                            }

                                                                            // ignore: unused_result
                                                                            ref.refresh(balanceProvider);
                                                                            if (kIsWeb) {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => PurchasedTicket2DGameWeb(
                                                                                    gameValue: value.tickets![0].types!, // Assuming types is a List<Type>
                                                                                    totalPoints: value.tickets![0].ticketPrice!.toDouble(),
                                                                                    totalQty: value.tickets![0].ticketCount!,
                                                                                    ticketPrice: value.tickets![0].ticketPrice!.toDouble(),
                                                                                    gameName: value.tickets![0].gameName!,
                                                                                    drawId: value.tickets![0].drawId!,
                                                                                    barCode: value.tickets![0].barCode!,
                                                                                    price: value.tickets![0].price!.toDouble(),
                                                                                    ticketCount: value.tickets![0].ticketCount!,
                                                                                    drawStartTime: value.tickets![0].drawStartTime!,
                                                                                    internalRefNo: value.tickets![0].internalRefNo!,
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            } else {
                                                                              Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                  builder: (context) => PurchasedTicket2DGame(
                                                                                    autoPrint: autoPrint,
                                                                                    gameValue: value.tickets![0].types!, // Assuming types is a List<Type>
                                                                                    totalPoints: value.tickets![0].ticketPrice!.toDouble(),
                                                                                    totalQty: value.tickets![0].ticketCount!,
                                                                                    ticketPrice: value.tickets![0].ticketPrice!.toDouble(),
                                                                                    gameName: value.tickets![0].gameName!,
                                                                                    drawId: value.tickets![0].drawId!,
                                                                                    barCode: value.tickets![0].barCode!,
                                                                                    price: value.tickets![0].price!.toDouble(),
                                                                                    ticketCount: value.tickets![0].ticketCount!,
                                                                                    drawStartTime: value.tickets![0].drawStartTime!,
                                                                                    internalRefNo: value.tickets![0].internalRefNo!,
                                                                                  ),
                                                                                ),
                                                                              );
                                                                            }
                                                                            clearAllValue();
                                                                          } else {
                                                                            setState(() {
                                                                              showLoadingOverlay = false;
                                                                            });

                                                                            showSnackBar(context,
                                                                                "Please select ticket");
                                                                          }
                                                                        }).onError((error, stackTrace) {
                                                                          debugPrint(
                                                                              error.toString());
                                                                          setState(
                                                                              () {
                                                                            showLoadingOverlay =
                                                                                false;
                                                                          });

                                                                          showSnackBar(
                                                                              context,
                                                                              error.toString());

                                                                          ExceptionHandler.showSnack(
                                                                              errorCode: error.toString(),
                                                                              context: context);
                                                                        });
                                                                      } else {
                                                                        setState(
                                                                            () {
                                                                          showLoadingOverlay =
                                                                              false;
                                                                        });

                                                                        if (!mounted) {
                                                                          return;
                                                                        }
                                                                        showSnackBar(
                                                                            // ignore: use_build_context_synchronously
                                                                            context,
                                                                            "Check your internet connection");
                                                                      }
                                                                    } else {
                                                                      // ignore: use_build_context_synchronously
                                                                      showSnackBar(
                                                                          // ignore: use_build_context_synchronously
                                                                          context,
                                                                          "Check qty atleast one");
                                                                    }
                                                                  } else {
                                                                    // ignore: use_build_context_synchronously
                                                                    showSnackBar(
                                                                        // ignore: use_build_context_synchronously
                                                                        context,
                                                                        "Please select ticket");
                                                                  }
                                                                } else {
                                                                  showSnackBar(
                                                                      context,
                                                                      "Insufficient Balance");
                                                                }
                                                              },
                                                              child: const Text(
                                                                "QUICK BUY",
                                                                style:
                                                                    TextStyle(
                                                                  fontSize:
                                                                      14.0,
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                          Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .only(
                                                                    left: 10),
                                                            child: Row(
                                                              children: [
                                                                const Text(
                                                                  'Print',
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                                Switch(
                                                                  value:
                                                                      autoPrint,
                                                                  activeColor:
                                                                      kPrimarySeedColor,
                                                                  onChanged: (bool
                                                                      value) {
                                                                    // Handle switch state change
                                                                    setState(
                                                                        () {
                                                                      autoPrint =
                                                                          value;
                                                                    });
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      // child: Row(
                                                      //   mainAxisAlignment:
                                                      //       MainAxisAlignment
                                                      //           .spaceBetween,
                                                      //   children: [

                                                      //     // SizedBox(
                                                      //     //   height: 32.0,
                                                      //     //   child:
                                                      //     //       ElevatedButton(
                                                      //     //     onPressed: () {
                                                      //     //       //clearValue();
                                                      //     //     },
                                                      //     //     child: const Text(
                                                      //     //       "Clear",
                                                      //     //       style:
                                                      //     //           TextStyle(
                                                      //     //         fontSize:
                                                      //     //             14.0,
                                                      //     //       ),
                                                      //     //     ),
                                                      //     //   ),
                                                      //     // ),
                                                      //     // SizedBox(
                                                      //     //   height: 32.0,
                                                      //     //   child:
                                                      //     //       ElevatedButton(
                                                      //     //     onPressed: () {
                                                      //     //       clearAllValue();
                                                      //     //     },
                                                      //     //     child: const Text(
                                                      //     //       "Clear All",
                                                      //     //       style:
                                                      //     //           TextStyle(
                                                      //     //         fontSize:
                                                      //     //             14.0,
                                                      //     //       ),
                                                      //     //     ),
                                                      //     //   ),
                                                      //     // ),

                                                      //   ],
                                                      // ),
                                                    )),
                                              ],
                                            ),
                                          ))
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          if (initGameValue.setBloack)
                            Center(child: CustomeBlocker(
                              callbackClear: () {
                                clearAllValue();
                              },
                            )),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // bottomContainer(context),
            ],
          ),

          if (showLoadingOverlay || initGameValue.setDrawBlocker)
            Center(child: MyOverlay(overlayFucntion: () {
              clearAllValue();
            })),
          // if (initGameValue.setBloack) const Center(child: CustomeBlocker()),
        ]);
      }, error: (Object error, e) {
        SchedulerBinding.instance.addPostFrameCallback((_) {
          ExceptionHandler.showSnack(
              errorCode: error.toString(), context: context);
        });

        return const Center(
          child: Text("Something went wrong"),
        );
      }, loading: () {
        return Scaffold(
          appBar: AppBar(
            title: const Center(child: Text('2D Game')),
          ),
          body: const Center(
            child: MyOverlay(),
          ),
        );
      }),
    ));
  }

  void seriesSelection(int index, int operand, bool isSecondaryTap) {
    return setState(() {
      for (int j = 0; j < showTextList["result"]!.toList().length; j++) {
        String indexString = index.toString();
        if (kDebugMode) {
          print(showTextList["result"][j]['titile']);
        }

        if (showTextList["result"][j]['titile']
                .toString()
                .contains(indexString) &&
            !showTextList["result"][j]['titile'].toString().contains("A") &&
            !showTextList["result"][j]['titile'].toString().contains("B") &&
            showTextList["result"][j]['titile'][operand] == index.toString()) {
          if (isSecondaryTap) {
            // Reduce the value on secondary tap
            if (numberInputList[j].text.isNotEmpty) {
              int currentValue = int.parse(numberInputList[j].text);
              int newValue = currentValue - qytController;
              numberInputList[j].text =
                  (newValue > 0 ? newValue : '').toString();
            }
          } else {
            // Increase the value on primary tap
            if (numberInputList[j].text.isNotEmpty) {
              if (int.parse(numberInputList[j].text) + qytController > 100) {
                numberInputList[j].text = "100";
              } else {
                numberInputList[j].text =
                    "${int.parse(numberInputList[j].text) + qytController}";
              }
            } else {
              numberInputList[j].text = qytController.toString();
              showTextList["result"]![j]['qty'] =
                  int.parse(qytController.toString());
            }
          }
        }
      }

      ticketConfirm();
    });
  }

  // final focusNode = FocusNode();
  // numberInputList[index].addListener(() {
  //   if (focusNode.hasFocus) {
  //     // Set the cursor position when the text changes
  //     numberInputList[index].selection = TextSelection.fromPosition(
  //       TextPosition(offset: numberInputList[index].text.length),
  //     );
  //   }
  // });
  TextFormField ticketBettingField(int index) {
    return TextFormField(
      focusNode: focusNodes[index],
      keyboardType: TextInputType.number,
      textAlignVertical:
          screenSizeChanger ? TextAlignVertical.top : TextAlignVertical.bottom,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: screenSizeChanger ? 14 : 18,
        color: Colors.white,
        fontWeight: FontWeight.bold,
        shadows: const [
          Shadow(
            blurRadius: 4.0,
            color: Colors.black,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(3),
      ],
      textInputAction: TextInputAction.next,
      onChanged: (value) {
        setState(() {
          // Validate the input before parsing
          if (value.isEmpty) {
            // Handle empty input
            showTextList["result"]![index]['qty'] = 0;
          } else {
            try {
              int parsedValue = int.parse(value);
              // Handle valid input
              gameValue[selectedIndex]['totalPoint'] = 0;
              showTextList["result"]![index]['qty'] = parsedValue;

              if (parsedValue < 1 ||
                  value == "001" ||
                  value == "011" ||
                  value == "01") {
                numberInputList[index].text = "1";
              } else if (parsedValue > 100) {
                numberInputList[index].text = "100";
                numberInputList[index].selection = TextSelection.fromPosition(
                    TextPosition(offset: numberInputList[index].text.length));
              }
            } catch (e) {
              // Handle invalid input (non-numeric characters)
              // For example, you might want to show an error message or reset the field
              numberInputList[index].text = "";
            }
          }
        });

        ticketConfirm();
      },
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.only(bottom: 20),
        fillColor: numberInputList[index].text.isNotEmpty
            ? kPrimarySeedColor
            : Colors.black12,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
              color: numberInputList[index].text.isNotEmpty
                  ? kPrimarySeedColor!
                  : Colors.black12),
        ),
      ),
      controller: numberInputList[index],
    );
  }

  void _moveFocus(int delta) {
    // Find the index of the currently focused field value
    int currentIndex = focusNodes.indexWhere((node) => node.hasFocus);

    if (currentIndex != -1) {
      // Find the value of the currently focused field
      String currentValue = showTextList["result"][currentIndex]["titile"];

      // Find the index of the current value in the list
      int currentValueIndex = showTextList["result"]
          .indexWhere((element) => element["titile"] == currentValue);

      // Calculate the next index
      int nextIndex = currentValueIndex + delta;

      // Skip certain indices
      if (shouldSkipIndex(currentValue, delta)) {
        return;
      }
      // Restrict upward movement
      if (delta < 0 && shouldRestrictUpward(currentValue, delta)) {
        return;
      }

      // Ensure the next index is within bounds
      if (nextIndex >= 0 && nextIndex < showTextList["result"].length) {
        FocusScope.of(context).requestFocus(focusNodes[nextIndex]);
      }
    }
  }

  bool shouldRestrictUpward(String currentValue, int delta) {
    // Add your logic to determine if upward movement should be restricted
    // For example, if currentValue is "B0" and delta is negative, restrict upward movement
    return currentValue == "B0" && delta < 0;
  }

  bool shouldSkipIndex(String value, int delta) {
    // Define conditions to skip specific indices
    if (value == "A0" && delta < 0) {
      // Skip when moving left from A0
      return true;
    } else if (value == "99" && delta > 0) {
      // Skip when moving right from 99
      return true;
    }
    // Add more conditions as needed
    return false;
  }

  void betInputValue(int index) {
    return setState(() {
      selectedIndex = index;

      for (int i = 0; i < numberInputList.length; i++) {
        numberInputList[i].clear();
      }

      //buy ticket for loop
      for (int i = 0; i < buyticket.length; i++) {
        if (buyticket[i]['typeId'] == selectedIndex + 1) {
          for (int j = 0;
              j < buyticket[i]['betTypes']['1'].toList().length;
              j++) {
            numberInputList[int.parse(buyticket[i]['betTypes']['1'][j]
                        .toString()
                        .split('-')[2])]
                    .text =
                buyticket[i]['betTypes']['1'][j].toString().split('-')[1];
          }

          //Bahar type
          for (int k = 0;
              k < buyticket[i]['betTypes']['2'].toList().length;
              k++) {
            numberInputList[int.parse(buyticket[i]['betTypes']['2'][k]
                        .toString()
                        .split('-')[2])]
                    .text =
                buyticket[i]['betTypes']['2'][k].toString().split('-')[1];
          }

          // 00 - 99 type
          for (int L = 0;
              L < buyticket[i]['betTypes']['3'].toList().length;
              L++) {
            numberInputList[int.parse(buyticket[i]['betTypes']['3'][L]
                        .toString()
                        .split('-')[2])]
                    .text =
                buyticket[i]['betTypes']['3'][L].toString().split('-')[1];
          }
        }
        //
      }
    });
  }

  double sizeInputWidth(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    if (screenWidth < 1400) {
      if (screenWidth >= 1300) {
        return 45;
      } else if (screenWidth >= 1200) {
        return 40;
      } else if (screenWidth >= 1100) {
        return 35;
      } else if (screenWidth >= 1000) {
        return 30;
      } else if (screenWidth >= 900) {
        return 30;
      } else if (screenWidth >= 800) {
        return 30;
      } else if (screenWidth >= 700) {
        return 30;
      } else {
        return 10;
      }
    } else {
      return 60; // Default value when screenWidth is 1400 or greater
    }
  }

  double sizeInputHeight(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    if (screenHeight > 1400) {
      return 45;
    } else if (screenHeight >= 1200) {
      return 40;
    } else if (screenHeight >= 1100) {
      return 40;
    } else if (screenHeight >= 1000) {
      return 40;
    } else if (screenHeight >= 900) {
      return 40;
    } else if (screenHeight >= 800) {
      return 30;
    } else if (screenHeight >= 700) {
      return 30; // Decreased value for smaller screens
    } else if (screenHeight >= 600) {
      return 28; // Further decreased value for even smaller screens
    } else {
      return 25; // Default value when screenHeight is 600 or smaller
    }
  }

  Text singleDoubleValue(int index, String value) {
    return Text(
      value,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w500,
        shadows: [
          Shadow(
            blurRadius: 4.0,
            color: Colors.black,
            offset: Offset(0.0, 0.0),
          ),
        ],
      ),
    );
  }

  //color index for color
  int selectedIndex = 0;

  Expanded dashBoardTitile(BuildContext context, int flex, String titile) {
    return Expanded(
      flex: flex,
      child: Align(
        alignment: Alignment.center,
        child: AutoSizeText(
          titile,
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 8),
          maxLines: 1,
          minFontSize: screenSizeChanger ? 8 : 15,
          maxFontSize: 25,
        ),
      ),
    );
  }

  //Yello Button
  Container yellowButton(
    String titile,
  ) {
    return Container(
      width: screenSizeChanger ? 60 : 100,
      height: screenSizeChanger ? 20 : 30,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          stops: [0.10, 0.5],
          colors: [
            Color.fromARGB(255, 244, 114, 54),
            Colors.yellow,
          ],
        ),
        borderRadius: BorderRadius.circular(10),
        color: Colors.yellow,
      ),
      child: ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent),
          onPressed: () {
            setState(() {
              for (int i = 0; i < numberInputList.length; i++) {
                numberInputList[i].clear();
                if (qytController.toString().isNotEmpty && titile == "JODI") {
                  for (int j = 0;
                      j < showTextList['result'].toList().length;
                      j++) {
                    if (showTextList['result'][j]['titile'].toString()[0] ==
                        showTextList['result'][j]['titile'].toString()[1]) {
                      numberInputList[j].text = qytController.toString();
                    }
                  }

                  gameValue[selectedIndex]['gameQty'] =
                      int.parse(qytController.toString()) * 119;
                } else if (qytController.toString().isNotEmpty &&
                    titile == "ODD") {
                  for (int j = 1;
                      j < showTextList['result'].toList().length;
                      j++) {
                    if (int.parse(showTextList['result'][j]['titile']
                            .toString()[1]
                            .toString())
                        .isOdd) {
                      if (showTextList['result'][j]['titile'].toString()[0] !=
                              "A" &&
                          showTextList['result'][j]['titile'].toString()[0] !=
                              "B") {
                        numberInputList[j].text = qytController.toString();
                      }
                    }
                  }
                } else if (qytController.toString().isNotEmpty &&
                    titile == "EVEN") {
                  for (int j = 1;
                      j < showTextList['result'].toList().length;
                      j++) {
                    if (int.parse(showTextList['result'][j]['titile']
                            .toString()[1]
                            .toString())
                        .isEven) {
                      if (showTextList['result'][j]['titile'].toString()[0] !=
                              "A" &&
                          showTextList['result'][j]['titile'].toString()[0] !=
                              "B") {
                        numberInputList[j].text = qytController.toString();
                      }
                    }
                  }
                } else {
                  showLoadingOverlay = true;
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      showLoadingOverlay = false;
                    });
                  });
                }
              }
              ticketConfirm(); //All ODD and EVEN
            });
          },
          child: AutoSizeText(
            titile,
            style: const TextStyle(
                color: Colors.black, fontWeight: FontWeight.bold),
            maxLines: 1,
            maxFontSize: 15,
            minFontSize: 8,
          )),
    );
  }

  //random  number genarator
  getRandomNumber(List list, int index) {
    randomList.shuffle();
    randomListValue = randomList.take(index).toList();

    for (int rNumber = 0; rNumber < numberInputList.length; rNumber++) {
      for (int i = 0; i < randomListValue.length; i++) {
        for (int j = 0; j < showTextList['result'].toList().length; j++) {
          if (showTextList['result'][j]['titile'] == randomListValue[i]) {
            numberInputList[j].text = qytController.toString();
          }
        }
      }
    }
    ticketConfirm();
  }

  void clearAllValue() {
    return setState(() {
      qytController = 1;
      // randomNumberController.clear();
      //# number input list clear
      for (int i = 0; i < numberInputList.length; i++) {
        numberInputList[i].clear();
      }
      //# total dashboart clear
      for (int i = 0; i < gameValue.length; i++) {
        gameValue[i]['gameQty'] = 0;
        gameValue[i]['totalPoint'] = 0;
      }
      totalPoint = 0;
      totalQty = 0;
      buyticket.clear();
      buyticketForReq.clear();
      // gameShowTicket.clear();
      qtyControllerText.text = "1";
    });
  }

  void clearValue(int index) {
    return setState(() {
      // # total dashboard clear
      for (int i = 0; i < gameValue.length; i++) {
        if (gameValue[i]["typeId"] == index + 1) {
          gameValue[i]['gameQty'] = 0;
          gameValue[i]['totalPoint'] = 0;
        }
      }

      buyticket.removeWhere((element) => element["typeId"] == index + 1);
      buyticketForReq.removeWhere((element) => element["typeId"] == index + 1);

      if (selectedIndex + 1 == index + 1) {
        // Clear all number inputs
        for (int i = 0; i < numberInputList.length; i++) {
          numberInputList[i].clear();
        }
      }

      qytController = 1;
      // randomNumberController.clear();
      // # number input list clear
      qtyControllerText.text = "1";
      totalCalculator();
    });
  }

  void initialClear() {
    for (int i = 0; i < gameValue.length; i++) {
      gameValue[i]['gameQty'] = 0;
      gameValue[i]['totalPoint'] = 0;
    }
  }

//ticket confirm value
  void ticketConfirm() {
    List typeOne = [];
    List typeTwo = [];
    List typeThree = [];
    List typeOneForReq = [];
    List typeTwoForReq = [];
    List typeThreeForReq = [];

    // RegExp exp = RegExp(r"(\D+)(\d+)");
    return setState(() {
      bool exists = false;

      for (int i = 0; i < showTextList["result"].toList().length; i++) {
        if (numberInputList[i].text.isNotEmpty) {
          // print(showTextList["result"][i]['qty']);
          if (showTextList["result"][i]['titile'].toString().contains("A")) {
            typeOne.add(
                "${showTextList["result"][i]['titile'][1]}-${numberInputList[i].text}-$i");

            //## $$ no need
            typeOneForReq.add(
                "${showTextList["result"][i]['titile'][1]}-${numberInputList[i].text}");
          } else if (showTextList["result"][i]['titile']
              .toString()
              .contains("B")) {
            typeTwo.add(
                "${showTextList["result"][i]['titile']}-${numberInputList[i].text}-$i");

            //## $$ no need
            typeTwoForReq.add(
                "${showTextList["result"][i]['titile'][1]}-${numberInputList[i].text}");
          } else {
            typeThree.add(
                "${showTextList["result"][i]['titile']}-${numberInputList[i].text}-$i");

            //## $$ no need
            typeThreeForReq.add(
                "${showTextList["result"][i]['titile']}-${numberInputList[i].text}");
          }
        }
      }

      if (buyticket.isEmpty) {
        buyticket.add({
          "typeId": selectedIndex + 1,
          "typeName": InitGameOthersProvider.getInitGameOthers()['types']
                  [selectedIndex]['typeName']
              .toString(),
          "betTypes": {
            "1": typeOne, //single - andar
            "2": typeTwo, //single - bahar
            "3": typeThree //double
          }
        });
        buyticketForReq.add({
          "typeId": selectedIndex + 1,
          "typeName": InitGameOthersProvider.getInitGameOthers()['types']
                  [selectedIndex]['typeName']
              .toString(),
          "betTypes": {
            "1": typeOneForReq.join(","), //single - andar
            "2": typeTwoForReq.join(","), //single - bahar
            "3": typeThreeForReq.join(",") //double
          }
        });
      } else {
        typeMatch:
        for (int type = 0; type < buyticket.length; type++) {
          int containesIndex = selectedIndex + 1;
          if (containesIndex == buyticket[type]['typeId']) {
            exists = true;
            //updateALl value

            buyticket[type]["betTypes"] = {
              "1": typeOne, //single - andar
              "2": typeTwo, //single - bahar
              "3": typeThree //double
            };

            break typeMatch;
          }
        }
        typeMatchR:
        for (int type = 0; type < buyticketForReq.length; type++) {
          if (kDebugMode) {}
          int containesIndex = selectedIndex + 1;
          if (containesIndex == buyticketForReq[type]['typeId']) {
            exists = true;
            //updateALl value

            buyticketForReq[type]["betTypes"] = {
              "1": typeOneForReq.join(","), //single - andar
              "2": typeTwoForReq.join(","), //single - bahar
              "3": typeThreeForReq.join(",") //double
            };

            break typeMatchR;
          }
        }

        if (!exists) {
          buyticket.add({
            "typeId": selectedIndex + 1,
            "typeName": InitGameOthersProvider.getInitGameOthers()['types']
                    [selectedIndex]['typeName']
                .toString(),
            "betTypes": {
              "1": typeOne, //single - andar
              "2": typeTwo, //single - bahar
              "3": typeThree //double
            }
          });
          buyticketForReq.add({
            "typeId": selectedIndex + 1,
            "typeName": InitGameOthersProvider.getInitGameOthers()['types']
                    [selectedIndex]['typeName']
                .toString(),
            "betTypes": {
              "1": typeOneForReq.join(","), //single - andar
              "2": typeTwoForReq.join(","), //single - bahar
              "3": typeThreeForReq.join(",") //double
            }
          });
        }
      }

      // if (kDebugMode) {
      //   print(buyticketForReq.toString());
      // }

      //# update game value
      totalCalculator();
    });
  }

  void totalCalculator() {
    int sum1 = 0;
    int sum2 = 0;
    int sum3 = 0;

    for (var ticket in buyticket) {
      List betType1 = ticket['betTypes']['1'];
      for (var betType in betType1) {
        String andhar = betType.split("-")[1];
        if (ticket['typeId'] == selectedIndex + 1) {
          sum1 += int.parse(andhar);
        }
      }
      List betType2 = ticket['betTypes']['2'];
      for (var betType in betType2) {
        String bharar = betType.split("-")[1];
        if (ticket['typeId'] == selectedIndex + 1) {
          sum2 += int.parse(bharar);
        }
      }
      List betType3 = ticket['betTypes']['3'];
      for (var betType in betType3) {
        String double = betType.split("-")[1];
        if (ticket['typeId'] == selectedIndex + 1) {
          sum3 += int.parse(double);
        }
      }
    }
    //Qty add
    for (int total = 0; total < gameValue.length; total++) {
      if (selectedIndex == total) {
        gameValue[total]['gameQty'] = sum1 + sum2 + sum3;
        gameValue[total]['totalPoint'] = gameValue[total]['gameQty'] *
            InitGameOthersProvider.getInitGameOthers()['types'][total]['price']
                .toInt();
      }
    }

    //total Qty and totalPoints
    List totalQtyPoints = gameValue; //# convert map to list
    totalQty = 0;
    totalPoint = 0;
    for (var tQP in totalQtyPoints) {
      totalQty += int.parse(tQP['gameQty'].toString());
      totalPoint += int.parse(tQP['totalPoint'].toString());
    }
  }

  void handleBetting(bool isIncrease, int index) {
    setState(() {
      if (index != 0) {
        String currentInputValue = numberInputList[index].text;
        int currentValue =
            currentInputValue.isNotEmpty ? int.parse(currentInputValue) : 0;

        // Use qtyController.text as the initial value
        int initialIncrement = qtyControllerText.text.isNotEmpty
            ? int.parse(qtyControllerText.text)
            : 1;

        int changeAmount = isIncrease ? initialIncrement : -initialIncrement;
        int updatedValue = currentValue + changeAmount;

        // Ensure the value stays between empty and 100
        if (isIncrease) {
          updatedValue = updatedValue.clamp(1, 100);
        } else {
          updatedValue = updatedValue.clamp(0, 100);
        }

        // Set to empty if the updated value is less than 1
        numberInputList[index].text =
            (updatedValue >= 1 ? updatedValue : '').toString();
      }
    });

    ticketConfirm();
  }

  clearBetValue() {}
}

Future<void> getBuyTicketOthers(
    {String? gameId, String? drawId, List<Map<String, dynamic>>? types}) async {
  ApiService()
      .getBuyticketOthers(gameId: gameId!, drawId: drawId!, types: types!);
}

//Reset game constant variable

void onResetGameConstant() {
  GameConstant.nextDrawBlocker = false;
}

class Refrese extends StateNotifier<DateTime> {
  // 1. initialize with current time
  Refrese() : super(DateTime.now()) {
    // 2. create a timer that fires every second
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      // 3. update the state with the current time
      state = DateTime.now();
    });
  }

  late final Timer _timer;

  // 4. cancel the timer when finished
  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }
}
