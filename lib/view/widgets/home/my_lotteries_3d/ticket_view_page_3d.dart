import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/model/draw_result_3d.dart';
import 'package:psglotto/model/user_result_3d.dart' as ur;
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:series_2d/presentation/logic_screen/betting_logic.dart';
import 'package:series_2d/utils/constants.dart';
import 'package:series_2d/utils/custom_clip_design.dart';

class TicketViewPage3D extends ConsumerWidget {
  final String drawPlayGroupId;
  final String gameName;
  final String username;
  final double playPoints;
  final double winPrice;
  final double jackpotPrice;
  final double totalWinPrice;
  final bool resultShow;
  final String purchaseTime;
  final String drawTime;
  final String barcode;
  final List<ur.TicketNo> ticketNo;
  final DrawResult3D? drawResult; // Optional
  final bool showWinNo;

  const TicketViewPage3D({
    Key? key,
    required this.drawPlayGroupId,
    required this.gameName,
    required this.username,
    required this.playPoints,
    required this.winPrice,
    required this.jackpotPrice,
    required this.totalWinPrice,
    required this.resultShow,
    required this.purchaseTime,
    required this.drawTime,
    required this.barcode,
    required this.ticketNo,
    required this.showWinNo,
    this.drawResult,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double average = screenWidth + screenHeight;

    // Group tickets by typeName
    final groupedTickets = groupTicketsByTypeName(ticketNo);

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text("View Ticket")),
        actions: [CustomCloseButton()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            height: 178,
            color: Colors.green[300],
            child: Padding(
              padding: const EdgeInsets.all(5),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        topHeadValues("Draw ID", drawPlayGroupId),
                        topHeadValues("Game Name", gameName),
                        topHeadValues("Player Name", username),
                        topHeadValues(
                            "Play Points", playPoints.floor().toString()),
                        topHeadValues(
                            "Win Points", winPrice.floor().toString()),
                        topHeadValues("Jackpot Win Points",
                            jackpotPrice.floor().toString()),
                        topHeadValues("Total Win Points",
                            totalWinPrice.floor().toString()),
                        resultShow
                            ? Row(
                                children: [
                                  boxShowExample(Colors.blue, "-Bet No"),
                                  boxShowExample(Colors.amberAccent, "-Win No"),
                                ],
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        AutoSizeText(
                          "Purchase Time: $purchaseTime",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxFontSize: 20,
                          minFontSize: 10,
                          maxLines: 1,
                        ),
                        AutoSizeText(
                          "Draw Time: $drawTime",
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxFontSize: 20,
                          minFontSize: 10,
                          maxLines: 1,
                        ),
                        BarcodeWidget(
                          width: 150,
                          height: 55,
                          data: barcode,
                          barcode: Barcode.fromType(BarcodeType.Code128),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            flex: 2,
            child: ListView.builder(
              itemCount: groupedTickets.entries.length,
              itemBuilder: (context, index) {
                final entry = groupedTickets.entries.elementAt(index);
                final typeName = entry.key;
                final tickets = entry.value;

                // Check if drawResult is null or not, and if results is null
                final jackpotType = (drawResult?.results ?? [])
                    .expand((result) => result.ticketNos)
                    .firstWhere(
                      (ticket) => ticket.typeName == typeName,
                      orElse: () => TicketNo(
                        typeId: 0,
                        typeName: '',
                        winNo: '',
                        jackpotType: 'N/A', // Default value if not found
                        jackpotPrice: 0.0,
                      ),
                    )
                    .jackpotType;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            "$typeName (${tickets[0].price.toStringAsFixed(0)}) ",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          if (showWinNo)
                            const Text(
                              "Jackpot: ",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                          if (showWinNo)
                            SpikedCircle(
                              backgroundColor: Colors.transparent,
                              color: Colors.black,
                              size: 30,
                              imageAsset:
                                  BettingLogic().getImagePath(jackpotType),
                            ),
                        ],
                      ),
                      Wrap(
                        spacing: 8.0,
                        runSpacing: 8.0,
                        children: tickets.map((ticket) {
                          return buildTicketCard(ticket, average, typeName);
                        }).toList(),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Helper to group tickets by typeName
  Map<String, List<ur.TicketNo>> groupTicketsByTypeName(
      List<ur.TicketNo> tickets) {
    final Map<String, List<ur.TicketNo>> grouped = {};
    for (var ticket in tickets) {
      grouped.putIfAbsent(ticket.typeName, () => []).add(ticket);
    }
    return grouped;
  }

  Widget buildTicketCard(
      ur.TicketNo ticket, double average, String typeNameGroup) {
    // Ensure drawResult is not null, otherwise showWinNo is false
    List<Map<String, dynamic>> winNos = drawResult != null
        ? getWinningNumbers(
            drawResult!) // List of winning numbers with their winTypeId
        : []; // If drawResult is null, empty list will be used
    // ignore: unused_local_variable
    bool isHighlightedning = winNos.isNotEmpty;

    return Wrap(
      spacing: 8.0, // Space between items horizontally
      runSpacing: 8.0, // Space between rows
      children: ticket.betTypes.entries.expand((entry) {
        final betTypeId = entry.key;
        final numbers = entry.value;
        final typeName = getTypeName(betTypeId);

        // Separate numeric and non-numeric keys
        final numericKeys =
            numbers.keys.where((key) => int.tryParse(key) != null).toList();
        final nonNumericKeys =
            numbers.keys.where((key) => int.tryParse(key) == null).toList();

        // Sort only the numeric keys
        numericKeys.sort((a, b) => int.parse(a).compareTo(int.parse(b)));

        // Combine sorted numeric keys and non-numeric keys (non-numeric will stay in original order)
        final sortedKeys = [...numericKeys, ...nonNumericKeys];

        return sortedKeys.map((num) {
          final qty = getQuantity(num);

          // Use the updated isHighlightedningNumber function to check if the number is a winning number
          bool isHighlighted = isHighlightedningNumber(
              num,
              winNos,
              typeNameGroup,
              int.parse(betTypeId)); // Check if the number is winning

          return Container(
            width: 80, // Adjust width for responsiveness
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: Colors.grey[200],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Top container for number
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: isHighlighted
                              ? const Color.fromARGB(
                                  100, 0, 0, 0) // Shadow color when highlighted
                              : Colors
                                  .transparent, // No shadow when not highlighted
                          blurRadius:
                              isHighlighted ? 5 : 0, // Shadow blur radius
                          offset:
                              Offset(0, isHighlighted ? 3 : 0), // Shadow offset
                        ),
                      ],
                      color: isHighlighted ? Colors.amberAccent : primaryColor,
                      gradient: isHighlighted
                          ? const LinearGradient(
                              colors: [
                                Colors.yellow,
                                Color.fromARGB(255, 218, 198, 22)
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            )
                          : null),
                  child: Center(
                    child: Text(
                      num,
                      style: TextStyle(
                        fontWeight:
                            isHighlighted ? FontWeight.bold : FontWeight.normal,
                        color: isHighlighted
                            ? Colors.white
                            : Colors.white60, // Text color
                      ),
                    ),
                  ),
                ),
                // Middle container for typeName
                Container(
                  width: double.infinity,
                  color: getColorbyBrandName(typeNameGroup),
                  padding: const EdgeInsets.all(5),
                  child: Center(
                    child: Text(
                      typeName,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ),
                // Bottom container for qty
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(10),
                      bottomRight: Radius.circular(10),
                    ),
                    color: Colors.orange,
                  ),
                  child: Center(
                    child: Text(
                      "${numbers[num]}", // Directly fetch the value from numbers map
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList();
      }).toList(),
    );
  }

  List<Map<String, dynamic>> getWinningNumbers(DrawResult3D? drawResult) {
    // Return an empty list if drawResult is null
    if (drawResult == null) return [];

    List<Map<String, dynamic>> winNos = [];
    for (var result in drawResult.results) {
      for (var ticketNo in result.ticketNos) {
        winNos.add({
          'winNo': ticketNo.winNo,
          'typeName': ticketNo.typeName,
          'winTypeId':
              result.winTypeId, // Correctly extract winTypeId from GameResult
          'jackpotType': ticketNo.jackpotType
        });

        // Debug print for each winning number and its associated winTypeId
        // debugPrint(
        //     "Ticket winNo: ${ticketNo.winNo}, Associated winTypeId: ${result.winTypeId} ,Associated TypeName: ${ticketNo.typeName}  ");
      }
    }
    return winNos;
  }
  bool isHighlightedningNumber(String betNumber, List<Map<String, dynamic>> winNos, String typeNameGroup, int winTypeId) {
  final normalizedBetNumber = betNumber.padLeft(3, '0');

  // Iterate through all winning numbers
  for (var winNoData in winNos) {
    if (winNoData['typeName'] == typeNameGroup && winNoData['winTypeId'] == winTypeId) {
      final winNumbers = winNoData['winNo'].split(',');

      for (var winNumber in winNumbers) {
        final normalizedWinNoPattern = winNumber.replaceAll('*', '.').padLeft(3, '0');

        // Check if the normalized betNumber matches the pattern using RegExp
        if (RegExp('^$normalizedWinNoPattern\$').hasMatch(normalizedBetNumber)) {
          return true; // Winning number found for the correct typeName and winTypeId
        }
      }
    }
  }
  return false; // No match found
}


  // bool isHighlightedningNumber(String betNumber,
  //     List<Map<String, dynamic>> winNos, String typeNameGroup, int winTypeId) {
  //   final normalizedBetNumber = betNumber.replaceAll('*', '').padLeft(3, '0');

  //   // Iterate through all winning numbers
  //   for (var winNoData in winNos) {
  //     // debugPrint(
  //     //     "Checking conditions: ${winNoData['typeName']} == $typeNameGroup, ${winNoData['winTypeId']} == $winTypeId");

  //     // Check if the typeName and winTypeId both match
  //     if (winNoData['typeName'] == typeNameGroup &&
  //         winNoData['winTypeId'] == winTypeId) {
  //       // Normalize the winNo and check if it contains the betNumber
  //       final winNumbers = winNoData['winNo'].split(',');

  //       for (var winNumber in winNumbers) {
  //         final normalizedWinNo = winNumber.replaceAll('*', '').padLeft(3, '0');

  //         // Check if the normalized betNumber matches the winning number
  //         if (normalizedWinNo == normalizedBetNumber) {
  //           return true; // Winning number found for the correct typeName and winTypeId
  //         }
  //       }
  //     }
  //   }
  //   return false; // No match found
  // }

  AutoSizeText topHeadValues(String headline, String value) {
    return AutoSizeText(
      "$headline : $value",
      style: const TextStyle(fontWeight: FontWeight.bold),
      maxFontSize: 20,
      minFontSize: 8,
      maxLines: 1,
    );
  }

  Widget boxShowExample(Color color, String label) {
    return Container(
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.only(right: 5),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
    );
  }

  String getTypeName(String betTypeId) {
    switch (betTypeId) {
      case '1':
        return 'STR';
      case '2':
        return 'BOX3';
      case '3':
        return 'BOX6';
      case '4':
        return 'FP';
      case '5':
        return 'BP';
      case '6':
        return 'SP';
      case '7':
        return 'AP';
      default:
        return 'Unknown';
    }
  }

  int getQuantity(String num) {
    final parts = num.split('-');
    return parts.length == 3 ? int.parse(parts[2]) : 1;
  }
}
