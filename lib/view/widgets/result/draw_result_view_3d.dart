import 'package:flutter/material.dart';
import 'package:data_table_2/data_table_2.dart'; // Import the package
import 'package:psglotto/model/draw_result_2d.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:series_2d/presentation/logic_screen/betting_logic.dart';
import 'package:series_2d/presentation/logic_screen/three_d_series_logic.dart';
import 'package:series_2d/utils/constants.dart';
import 'package:series_2d/utils/custom_clip_design.dart';
import 'package:series_2d/utils/custom_widget.dart';
import 'package:series_2d/utils/game_data_constant.dart';

class DrawResultView3D extends StatefulWidget {
  final String gameId;
  final String gameName;
  final String drawTime;
  final String drawId;
  final List<Result> drawResult;

  const DrawResultView3D({
    required this.gameId,
    required this.gameName,
    required this.drawTime,
    required this.drawId,
    required this.drawResult,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DrawResultView3DState createState() => _DrawResultView3DState();
}

class _DrawResultView3DState extends State<DrawResultView3D> {
  late double screenWidth;
  late double screenHeight;
  late double average;

  Map<String, Map<String, List<TicketNo>>> groupedResults = {};

  @override
  void initState() {
    super.initState();
    _groupResults();
  }

  // void _groupResults() {
  //   for (var result in widget.drawResult) {
  //     for (var ticket in result.ticketNos) {
  //       if (!groupedResults.containsKey(ticket.typeName)) {
  //         groupedResults[ticket.typeName] = {};
  //       }

  //       if (!groupedResults[ticket.typeName]!.containsKey(result.name)) {
  //         groupedResults[ticket.typeName]![result.name] = [];
  //       }

  //       groupedResults[ticket.typeName]![result.name]!.add(ticket);
  //     }
  //   }
  // }
  void _groupResults() {
    for (var result in widget.drawResult) {
      for (var ticket in result.ticketNos) {
        String jackpotType =
            ticket.jackpotType ?? ''; // Or provide a default value if null

        // Create a new key combining typeName and jackpotType
        String key = '${ticket.typeName}-$jackpotType';

        // Ensure the groupedResults contains the new combined key
        if (!groupedResults.containsKey(key)) {
          groupedResults[key] = {};
        }

        // Ensure the groupedResults for the specific result name exists
        if (!groupedResults[key]!.containsKey(result.name)) {
          groupedResults[key]![result.name] = [];
        }

        // Add the ticket into the group
        groupedResults[key]![result.name]!.add(ticket);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    average = screenWidth + screenHeight;
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Results"),
        centerTitle: true,
        actions: [CustomCloseButton()],
      ),
      body: Column(
        children: [
          // Header with Game ID and Draw Time
          Container(
            width: screenWidth,
            padding: const EdgeInsets.all(16.0),
            color: Colors.green.shade300,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Left-aligned Draw ID
                customText(
                  average: average,
                  fontColor: Colors.black,
                  fontSize: 150,
                  fontWeight: FontWeight.bold,
                  value:
                      "Draw ID : ${widget.drawId}                                        ",
                ),

                // Centered Game Name
                customText(
                  average: average,
                  fontColor: Colors.black,
                  fontSize: 150,
                  fontWeight: FontWeight.bold,
                  value: "Game Name: ${widget.gameName}",
                ),

                // Right-aligned Draw Time
                customText(
                  average: average,
                  fontColor: Colors.black,
                  fontSize: 150,
                  fontWeight: FontWeight.bold,
                  value: "Draw Time : ${widget.drawTime}",
                ),
              ],
            ),
          ),
          SizedBox(
            height: screenHeight * 0.1,
          ),
          // Results Table - Adjust to 80% of screen height and width
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Container(
                    color: Colors.white,
                    width: screenWidth * 0.9, // 80% of screen width

                    child: DataTable2(
                      horizontalMargin: 1,
                      minWidth: 600,
                      fixedColumnsColor: Colors
                          .transparent, // Fixed columns color (applies to the entire column)
                      fixedLeftColumns: 1, // Fix only the first column

                      columnSpacing: 02.0, // Column spacing
                      headingRowHeight:
                          screenHeight * 0.060, // Increase header height
                      dataRowHeight: screenHeight * 0.20, // Row height

                      headingRowColor: WidgetStateProperty.resolveWith(
                          (states) => primaryColor),
                      border: TableBorder.all(
                          color: const Color.fromARGB(
                              255, 5, 5, 5)), // Custom border color

                      columns: [
                        DataColumn2(
                          fixedWidth: screenWidth * 0.040,
                          // size: ColumnSize.L,
                          label:
                              const Text('', style: TextStyle(fontSize: 18.0)),
                        ),
                        ..._getBetTypeHeaders(), // Dynamic headers based on bet types
                      ],
                      rows: _getRows(), // Your dynamic rows
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  List<DataColumn2> _getBetTypeHeaders() {
    // Cache the instance of ThreeDSeriesLogic
    final threeDSeriesLogic = ThreeDSeriesLogic();

    Set<int> winTypeIds = {};

    // Collect unique winTypeIds from drawResult
    for (var result in widget.drawResult) {
      winTypeIds.add(result.winTypeId);
    }

    return winTypeIds.map((winTypeId) {
      // Get display name from map based on winTypeId, fallback to empty string
      debugPrint("checking values : $gameTypeSelection3dConfig");
      String displayName =
          threeDSeriesLogic.gameTypeSelectionMap[winTypeId] ?? '';
      // If winTypeId == 3, add 'BOX6' manually
      if (winTypeId == 3) {
        displayName = 'BOX6';
      }
      // Find the corresponding name from drawResult for this winTypeId
      String betType = widget.drawResult
          .firstWhere(
            (result) => result.winTypeId == winTypeId,
          )
          .name;

      debugPrint(
          "Checking winTypeId: $winTypeId, betType: $betType, displayName: $displayName");

      return DataColumn2(
        label: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              customText(
                average: average,
                fontColor: Colors.white,
                fontSize: 130,
                fontWeight: FontWeight.bold,
                value: betType,
              ),
              customText(
                average: average,
                fontColor: Colors.white,
                fontSize: 150,
                fontWeight: FontWeight.normal,
                value: "($displayName)",
              ),
            ],
          ),
        ),
      );
    }).toList();
  }

  // Rows method with dynamic first column color
  List<DataRow> _getRows() {
    List<DataRow> rows = [];
    groupedResults.forEach((typeName, betTypesMap) {
      debugPrint("Checking groupedResults $groupedResults ");
      List<DataCell> cells = [
        DataCell(
          Container(
            width: double.infinity, // Ensures full column width
            height: screenHeight * 0.20, // Matches row height
            color: getColorbyBrandName(
                typeName.split("-").first), // Dynamically apply color

            // alignment: Alignment.center,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                customText(
                  average: average,
                  fontColor: Colors.white,
                  fontSize: 60,
                  fontWeight: FontWeight.bold,
                  value: typeName.split("-").first,
                ),
                const SizedBox(height: 8.0),
                SpikedCircle(
                  backgroundColor: Colors.transparent,
                  color: Colors.black,
                  size: 50,
                  imageAsset:
                      BettingLogic().getImagePath(typeName.split("-").last),
                ),
                const SizedBox(height: 8.0),
              ],
            ),
          ),
        ),
        ..._getBetTypeResults(betTypesMap),
      ];
      rows.add(DataRow(cells: cells));
    });
    return rows;
  }

  List<DataCell> _getBetTypeResults(Map<String, List<TicketNo>> betTypesMap) {
    List<DataCell> cells = [];
    betTypesMap.forEach((betType, tickets) {
      cells.add(
        DataCell(
          Center(
            // Ensures everything is centered in the cell
            child: Wrap(
              alignment: WrapAlignment.center, // Centers children horizontally
              spacing:
                  average / 2000, // Adjust horizontal space between numbers
              runSpacing: average / 2000, // Adjust vertical space between rows
              children: tickets.map((ticket) {
                // Split the winNo into individual numbers
                List<Widget> numberWidgets =
                    ticket.winNo.split(',').map((number) {
                  return Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: SizedBox(
                      width: screenWidth * 0.050, // Adjust width
                      height: screenHeight * 0.06, // Adjust height
                      child: Card(
                        elevation: 4.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Center(
                          // Ensures text is centered in the card
                          child: customText(
                            average: average,
                            fontColor: Colors.black,
                            fontSize: 70,
                            fontWeight: FontWeight.bold,
                            value: number,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList();

                return Center(
                  // Centers the Wrap inside each ticket entry
                  child: Wrap(
                    alignment: WrapAlignment.center, // Centers elements
                    spacing: average / 2000,
                    runSpacing: average / 2000,
                    children: numberWidgets,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    });
    return cells;
  }
}
