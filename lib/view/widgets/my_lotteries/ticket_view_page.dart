import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/params/draw_result_params.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/model/user_result_2d.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:series_2d/presentation/logic_screen/betting_logic.dart';
import 'package:series_2d/utils/custom_clip_design.dart';
import '../home/game_time_helper_widgets/tab_color.dart';
import '../../../model/draw_result_2d.dart' as r;

// ignore: must_be_immutable
class TicketViewPage extends ConsumerStatefulWidget {
  double winPrice;
  double jackpotPrice;
  double totalWinPrice;
  double playPoints;
  String gameId;
  String barcode;
  String gameName;
  String purchaseTime;
  List<Result> result;
  double price;
  String drawId;
  String drawPlayGroupId;
  String drawTime;

  int selectionIndex;
  List<TicketNo> ticketNo;
  bool resultShow;
  bool showWinNoHeader;

  TicketViewPage({
    required this.winPrice,
    required this.jackpotPrice,
    required this.totalWinPrice,
    required this.playPoints,
    required this.gameId,
    required this.resultShow,
    required this.barcode,
    required this.purchaseTime,
    required this.gameName,
    required this.drawTime,
    required this.drawId,
    required this.drawPlayGroupId,
    required this.result,
    required this.ticketNo,
    required this.price,
    required this.selectionIndex,
    required this.showWinNoHeader,
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<TicketViewPage> createState() => _TicketViewPageState();
}

class _TicketViewPageState extends ConsumerState<TicketViewPage> {
  List<Map<String, dynamic>> drawList = [];
  List<dynamic> ticketNos = [];

  List<Map<String, dynamic>> updatedResult = [];
  List<Map<String, dynamic>> updatedWinTypes = [];
  List newObj = [];
  String? drawId;
  List<r.Result> results = [];
  List<r.TicketNo> ticketNumbers = [];
  String username = "";
  @override
  void initState() {
    super.initState();

    // Initialize updatedResult and updatedWinTypes lists
    updatedResult = [];
    updatedWinTypes = [];

    for (var result in widget.result) {
      if (result.drawPlayGroupId == widget.drawPlayGroupId &&
          result.barCode == widget.barcode) {
        for (var winName in result.winName!) {
          debugPrint("Check win types : $winName");
          Map<String, dynamic> modifiedWinTypes =
              {}; // Initialize inside the loop
          for (var key in winName["winTypes"].keys) {
            var value = winName["winTypes"][key];
            if (key == "1" && result.gameName == "2D") {
              debugPrint("game name: ${result.gameName}");
              // ignore: prefer_interpolation_to_compose_strings
              value = "A" + value;
            } else if (key == "2") {
              // ignore: prefer_interpolation_to_compose_strings
              value = "B" + value;
            }
            modifiedWinTypes[key] = value;
            debugPrint("key : $key  modifiedWinTypes : $modifiedWinTypes");
          }
          updatedWinTypes.add({
            "typeName": winName["typeName"],
            "winTypes": modifiedWinTypes,
            "jackpotType": winName["jackpotType"],
          });
          debugPrint(updatedWinTypes.toString());
        }
      }
    }

    if (widget.resultShow) {
      getResult();
    }

    setState(() {
      username = SharedPref.instance.getString("username") ?? "-";
    });

    newObj = widget.result[widget.selectionIndex].ticketNo!;

    for (var ticketNo in newObj) {
      Map<String, dynamic> modifiedBetTypes = {};
      String modifiedTypeName = ticketNo.typeName;

      // Process betTypes
      ticketNo.betTypes!.forEach((key, value) {
        if (value.isNotEmpty) {
          Map<String, dynamic> modifiedValues = {};
          value.forEach((innerKey, innerValue) {
            if (key == "1" &&
                widget.result[widget.selectionIndex].gameName! == "2D") {
              modifiedValues["A$innerKey"] = innerValue;
            } else if (key == "2") {
              modifiedValues["B$innerKey"] = innerValue;
            } else {
              modifiedValues[innerKey] = innerValue;
            }
          });
          if (modifiedValues.isNotEmpty) {
            modifiedBetTypes[key] = modifiedValues;
          }
        }
      });

      // Process winTypes
      Map<String, dynamic> correspondingWinTypes = {};
      String correspondingJackpotType = "";
      for (var winType in updatedWinTypes) {
        if (winType["typeName"] == modifiedTypeName) {
          correspondingWinTypes = winType["winTypes"];
          correspondingJackpotType = winType["jackpotType"];
          break;
        }
      }

      if (modifiedBetTypes.isNotEmpty) {
        bool found = false;
        for (var typeCheck in updatedResult) {
          if (typeCheck["typeId"] == ticketNo.typeId &&
              typeCheck["typeName"] == modifiedTypeName) {
            // Entry with the same typeId and typeName found
            found = true;
            // Update the existing entry
            typeCheck["price"] = ticketNo.price;
            typeCheck["betTypes"] = modifiedBetTypes;
            typeCheck["winTypes"] = correspondingWinTypes;
            typeCheck["jackpotType"] = correspondingJackpotType;
            break; // Exit the loop since the entry is found and updated
          }
        }
        // If the entry was not found, add a new entry
        if (!found) {
          updatedResult.add({
            "typeId": ticketNo.typeId,
            "typeName": modifiedTypeName,
            "price": ticketNo.price,
            "betTypes": modifiedBetTypes,
            "winTypes": correspondingWinTypes,
            "jackpotType": correspondingJackpotType,
          });
        }
      }
    }

    debugPrint("This is updated result : $updatedResult");

    for (int i = 0; i < widget.result.length; i++) {
      debugPrint("This is new result : ${widget.result[i].ticketNo}");
    }
  }

  bool screenSizeChanger = false;

  void getResult() async {
    await ref
        .read(
      drawResult2DProvider(
        DrawResultParams(
          categoryId: 2,
          gameId: widget.gameId,
          drawId: widget.drawId,
        ),
      ).future,
    )
        .then((value) {
      setState(() {
        results = value.results;

        // Extracting List<TicketNo> from results and storing in a separate list
        ticketNumbers = results
            .map((result) => result.ticketNos)
            .expand((ticketNos) => ticketNos)
            .take(10) // Limit to the first 10 elements
            .toList();
      });
    }).onError((error, stackTrace) {
      return ExceptionHandler.showSnack(
          errorCode: error.toString(), context: context);
    });
  }

  @override
  Widget build(BuildContext context) {
    screenSizeChanger = MediaQuery.of(context).size.width < 1400 ? true : false;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("View Ticket")),
        actions: [CustomCloseButton()],
      ),
      // ignore: unnecessary_null_comparison
      body: updatedResult.isNotEmpty && getJackPotWin != null
          ? Column(
              children: [
                Container(
                    height: 178,
                    color: Colors.green[300],
                    child: Padding(
                      padding: EdgeInsets.all(screenSizeChanger ? 2 : 5),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      topHeadValues(
                                          "Draw ID", widget.drawPlayGroupId),
                                      topHeadValues(
                                          "Game Name", widget.gameName),
                                      topHeadValues("Player Name", username),
                                      topHeadValues("Play Points",
                                          widget.playPoints.floor().toString()),
                                      topHeadValues("Win Points",
                                          widget.winPrice.floor().toString()),
                                      topHeadValues(
                                          "Jackpot Win Points",
                                          widget.jackpotPrice
                                              .floor()
                                              .toString()),
                                      topHeadValues(
                                          "Total Win Points",
                                          widget.totalWinPrice
                                              .floor()
                                              .toString()),
                                      widget.resultShow
                                          ? Row(
                                              children: [
                                                boxShowExample(
                                                    kPrimarySeedColor!,
                                                    "-Bet No"),
                                                boxShowExample(
                                                    Colors.amberAccent,
                                                    "-Win No"),
                                              ],
                                            )
                                          : const SizedBox.shrink()
                                    ],
                                  )),
                              Expanded(
                                  flex: 1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceAround,
                                    children: [
                                      AutoSizeText(
                                        "Purchase Time : ${widget.purchaseTime}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxFontSize: 20,
                                        minFontSize: 10,
                                        maxLines: 1,
                                      ),
                                      AutoSizeText(
                                        "Draw Time : ${widget.drawTime}",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxFontSize: 20,
                                        minFontSize: 10,
                                        maxLines: 1,
                                      ),
                                      BarcodeWidget(
                                          width: 150,
                                          height: 55,
                                          data: widget.barcode,
                                          barcode: Barcode.fromType(
                                              BarcodeType.Code128))
                                    ],
                                  )),
                            ],
                          ),
                          widget.resultShow && Platform.isAndroid
                              ? Expanded(
                                  flex: 2,
                                  child: Center(
                                    child: Wrap(
                                      spacing: screenSizeChanger ? 1.0 : 5,
                                      runSpacing: screenSizeChanger ? 5 : 10,
                                      children: ticketNumbers
                                          .asMap()
                                          .entries
                                          .map((e) {
                                        String ticketNumbers = e.value.winNo;

                                        int index = e.key;
                                        return Container(
                                          width: screenSizeChanger ? 35 : 50,
                                          height: screenSizeChanger ? 35 : 50,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: TabColor().tabColors[index],
                                          ),
                                          child: Center(
                                            child: Text(
                                              ticketNumbers,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                                shadows: [
                                                  Shadow(
                                                    offset: Offset(0.0, 0.0),
                                                    blurRadius: 10.0,
                                                    color: Colors.black,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        );
                                      }).toList(),
                                    ),
                                  ))
                              : const SizedBox.shrink(),
                        ],
                      ),
                    )),
                if (widget.resultShow)
                  getJackpotType(updatedResult[0]['typeName']) != null
                      ? ticketShowCaseWidget(context)
                      : const LinearProgressIndicator(),
                if (!widget.resultShow) ticketShowCaseWidget(context)
              ],
            )
          : const Center(
              child: CircularProgressIndicator(),
            ),
    );
  }

  Expanded ticketShowCaseWidget(BuildContext context) {
    return Expanded(
      flex: 7,
      child: SingleChildScrollView(
        child: Container(
          width: MediaQuery.of(context).size.width,
          color: Colors.transparent,
          child: Column(
            children: [
              for (var index = 0; index < updatedResult.length; index++)
                Padding(
                  padding: const EdgeInsets.all(2.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Text(
                                widget.gameId == "2d-super"
                                    ? "Play"
                                    : updatedResult[index]['typeName'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold)),
                          ),
                          Padding(
                            padding: EdgeInsets.only(left: 5),
                            child: Text(
                              "(${(updatedResult[index]['price'] as double) % 1 == 0 ? (updatedResult[index]['price'] as double).toInt() : updatedResult[index]['price']})",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),

                          // widget.showWinNoHeader
                          //     ?
                          widget.resultShow
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 10),
                                  child: Row(
                                    children: [
                                      Text(
                                        "( Win No: ${getJackPotWin(updatedResult[index]['typeName'])} )",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const SizedBox(
                                          width:
                                              8), // Adds space between elements
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            const TextSpan(
                                              text: "Jackpot: ",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black,
                                              ),
                                            ),
                                            WidgetSpan(
                                              alignment: PlaceholderAlignment
                                                  .middle, // Aligns the image vertically with the text
                                              child: SpikedCircle(
                                                backgroundColor:
                                                    Colors.transparent,
                                                color: Colors.black,
                                                size: 32,
                                                imageAsset:
                                                    BettingLogic().getImagePath(
                                                  getJackpotType(
                                                      updatedResult[index]
                                                          ['typeName'])!,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                )
                              : const SizedBox.shrink()
                        ],
                      ),
                      Container(
                          // height: calculateContainerHeight(
                          //     updatedResult[index]['betTypes']
                          //         .toString()
                          //         .split(",")
                          //         .length),
                          color: Colors.transparent,
                          child: Wrap(
                            spacing: 1.0,
                            runSpacing: 5,
                            children: updatedResult[index]['betTypes']
                                .toString()
                                .split(",")
                                .asMap()
                                .entries
                                .map((betType) {
                              final int i = betType.key;
                              final typeName = updatedResult[index]['typeName'];
                              final ticketType = updatedResult[index]
                                      ['betTypes']
                                  .values
                                  .toString()
                                  .split(",")[i]
                                  .toString()
                                  .split(":")[0]
                                  .toString()
                                  .replaceAll("[", "")
                                  .replaceAll("]", "")
                                  .replaceAll("{", "")
                                  .replaceAll("}", "")
                                  .replaceAll("(", "")
                                  .replaceAll(")", "")
                                  .trim(); // Trim any leading/trailing whitespace
                              // print(
                              //     "Ticket types:${updatedResult[index]['betTypes'].values.toString().split(",")[i].toString().split(":")[0].toString().replaceAll("[", "").replaceAll("]", "").replaceAll("{", "").replaceAll("}", "").replaceAll("(", "").replaceAll(")", "").trim()}");

                              // final isHighlighted =
                              //     updatedWinTypes.any((winType) {
                              //   final winTypes =
                              //       winType['winTypes'] as Map<String, dynamic>;
                              //   final winTypeValues =
                              //       winTypes.values.toList(); // Get the values

                              //   // Check if any of the winType values contains the ticketType
                              //   final isMatched = winTypeValues.any((value) =>
                              //       value.toString().contains("$ticketType-"));

                              //   return winType['typeName'] == typeName &&
                              //       isMatched;
                              // });
                              final isHighlighted =
                                  updatedWinTypes.any((winType) {
                                final winTypes =
                                    winType['winTypes'] as Map<String, dynamic>;
                                final winTypeValues = winTypes.values.toList();

                                // Extract actual winning number from the string
                                final winningNumbers =
                                    winTypeValues.map((value) {
                                  return value
                                      .toString()
                                      .split("-")[0]
                                      .trim(); // Take only the number part
                                }).toList();

                                return winType['typeName'] == typeName &&
                                    winningNumbers
                                        .contains(ticketType); // ✅ exact match
                              });

                              debugPrint(
                                  "Checking Jackpot  : ${updatedResult[index]["jackpotType"]}");

                              return Container(
                                color: Colors.transparent,
                                height:
                                    updatedResult[index]["jackpotType"] == "N"
                                        ? 50
                                        : 75,
                                width: 90,
                                child: Stack(
                                  children: [
                                    Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Padding(
                                            padding: const EdgeInsets.only(
                                                left: 1, right: 1),
                                            child: Container(
                                              width: 60,
                                              height: 20,
                                              decoration: BoxDecoration(
                                                borderRadius:
                                                    const BorderRadius.only(
                                                  topLeft: Radius.circular(5),
                                                  topRight: Radius.circular(5),
                                                ), // Rounded border
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: isHighlighted
                                                        ? const Color.fromARGB(
                                                            100,
                                                            0,
                                                            0,
                                                            0) // Shadow color when highlighted
                                                        : Colors
                                                            .transparent, // No shadow when not highlighted
                                                    blurRadius: isHighlighted
                                                        ? 5
                                                        : 0, // Shadow blur radius
                                                    offset: Offset(
                                                        0,
                                                        isHighlighted
                                                            ? 3
                                                            : 0), // Shadow offset
                                                  ),
                                                ],
                                                gradient: isHighlighted
                                                    ? const LinearGradient(
                                                        colors: [
                                                          Colors.yellow,
                                                          Color.fromARGB(
                                                              255, 218, 198, 22)
                                                        ],
                                                        begin:
                                                            Alignment.topCenter,
                                                        end: Alignment
                                                            .bottomCenter,
                                                      )
                                                    : null,
                                                // No gradient when not highlighted
                                                color: isHighlighted
                                                    ? Colors.amberAccent
                                                    // No solid background color when highlighted
                                                    : kPrimarySeedColor, // Use kPrimarySeedColor when not highlighted
                                              ),
                                              child: Center(
                                                child: Text(
                                                  updatedResult[index]
                                                          ['betTypes']
                                                      .values
                                                      .toString()
                                                      .split(",")[i]
                                                      .toString()
                                                      .split(":")[0]
                                                      .toString()
                                                      .replaceAll("[", "")
                                                      .replaceAll("]", "")
                                                      .replaceAll("{", "")
                                                      .replaceAll("}", "")
                                                      .replaceAll("(", "")
                                                      .replaceAll(")", "")
                                                      .trim(),
                                                  style: TextStyle(
                                                    color: isHighlighted
                                                        ? Colors.white
                                                        : Colors
                                                            .white60, // Text color
                                                    fontWeight: isHighlighted
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 60,
                                            height: 20,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  const BorderRadius.only(
                                                bottomLeft: Radius.circular(5),
                                                bottomRight: Radius.circular(5),
                                              ),
                                              color: getColorByType(
                                                  updatedResult[index]
                                                                  ["typeId"] %
                                                              10 ==
                                                          0
                                                      ? 10
                                                      : updatedResult[index]
                                                              ["typeId"] %
                                                          10),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: isHighlighted
                                                      ? const Color.fromARGB(
                                                          100,
                                                          0,
                                                          0,
                                                          0) // Shadow color when highlighted
                                                      : Colors
                                                          .transparent, // No shadow when not highlighted
                                                  blurRadius: isHighlighted
                                                      ? 5
                                                      : 0, // Shadow blur radius
                                                  offset: Offset(
                                                      0,
                                                      isHighlighted
                                                          ? 3
                                                          : 0), // Shadow offset
                                                ),
                                              ],
                                            ),
                                            child: Center(
                                              child: Text(
                                                updatedResult[index]['betTypes']
                                                    .values
                                                    .toString()
                                                    .split(",")[i]
                                                    .toString()
                                                    .split(":")[1]
                                                    .toString()
                                                    .replaceAll("[", "")
                                                    .replaceAll("]", "")
                                                    .replaceAll("{", "")
                                                    .replaceAll("}", "")
                                                    .replaceAll("(", "")
                                                    .replaceAll(")", "")
                                                    .trim(), // Trim any leading/trailing whitespace
                                                style: TextStyle(
                                                  color: isHighlighted
                                                      ? Colors.white
                                                      : Colors.white70,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    updatedResult[index]["jackpotType"] != "N"
                                            // widget
                                            //                 .result[widget
                                            //                     .selectionIndex]
                                            //                 .ticketNo![
                                            //                     index]
                                            //                 .jackpotType !=
                                            //             "N"
                                            &&
                                            isHighlighted
                                        ? Align(
                                            alignment: Alignment.topRight,
                                            child: SpikedCircle(
                                              backgroundColor:
                                                  Colors.transparent,
                                              color: Colors.black,
                                              size: 32,
                                              imageAsset: BettingLogic()
                                                  .getImagePath(
                                                      updatedResult[index]
                                                          ["jackpotType"]
                                                      // widget
                                                      //   .result[widget
                                                      //       .selectionIndex]
                                                      //   .ticketNo![
                                                      //       index]
                                                      //   .jackpotType!
                                                      ),
                                            ),
                                          )
                                        : const SizedBox.shrink()
                                  ],
                                ),
                              );
                            }).toList(),
                          ))
                    ],
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }

  getJackPotType(String typeName) {
    for (int i = 0; i < results[0].ticketNos.length; i++) {
      //results[0].ticketNos[1].jackpotType
      if (typeName == results[0].ticketNos[i].typeName) {
        return results[0].ticketNos[i].jackpotType;
      }
    }
  }

  String? getJackPotWin(String typeName) {
    if (results.isEmpty || results[0].ticketNos.isEmpty) {
      // Handle the case where results or ticketNos are empty
      debugPrint("No tickets available.");
      return "-";
    }

    for (int i = 0; i < results[0].ticketNos.length; i++) {
      if (typeName == results[0].ticketNos[i].typeName) {
        return results[0].ticketNos[i].winNo;
      }
    }

    // Handle case where no matching typeName is found
    debugPrint("No matching typeName found for: $typeName");
    return "-";
  }

  String? getJackpotType(String typeName) {
    if (results.isEmpty || results[0].ticketNos.isEmpty) {
      // Handle the case where results or ticketNos are empty
      debugPrint("No tickets available.");
      return null;
    }

    for (int i = 0; i < results[0].ticketNos.length; i++) {
      if (typeName == results[0].ticketNos[i].typeName) {
        return results[0].ticketNos[i].jackpotType;
      }
    }

    // Handle case where no matching typeName is found
    debugPrint("No matching typeName found for: $typeName");
    return "-";
  }

  Row boxShowExample(Color color, String exampleName) {
    return Row(
      children: [
        Column(
          children: [
            Container(
              height: 15,
              width: 30,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
                color: color,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.transparent, // No shadow when not highlighted
                    blurRadius: 0, // Shadow blur radius
                    offset: Offset(0, 0), // Shadow offset
                  ),
                ],
              ),
            ),
            Container(
              height: 20,
              width: 30,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                ),
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.transparent, // No shadow when not highlighted
                    blurRadius: 0, // Shadow blur radius
                    offset: Offset(0, 0), // Shadow offset
                  ),
                ],
              ),
            ),
          ],
        ),
        Center(
          child: Text(
            exampleName,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        )
      ],
    );
  }

  AutoSizeText topHeadValues(String headline, String value) {
    return AutoSizeText(
      "$headline : $value",
      style: const TextStyle(fontWeight: FontWeight.bold),
      maxFontSize: 20,
      minFontSize: 8,
      maxLines: 1,
    );
  }
}
