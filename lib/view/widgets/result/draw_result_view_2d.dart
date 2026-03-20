import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:psglotto/model/draw_result_2d.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:series_2d/presentation/logic_screen/betting_logic.dart';
import 'package:series_2d/utils/constants.dart';
import 'package:series_2d/utils/custom_clip_design.dart';
import 'package:series_2d/utils/custom_widget.dart';
import 'package:series_2d/utils/game_data_constant.dart';

// ignore: must_be_immutable
class DrawResultView2D extends StatefulWidget {
  List<Result> drawResult = [];
  String drawId;
  final String drawTime;
  final String gameId;
  final String gameName;
  DrawResultView2D({
    required this.gameId,
    required this.gameName,
    required this.drawResult,
    required this.drawId,
    required this.drawTime,
    Key? key,
  }) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DrawResultView2DState createState() => _DrawResultView2DState();
}

class _DrawResultView2DState extends State<DrawResultView2D> {
  ScrollController controller = ScrollController();
  ScrollController controllerNew = ScrollController();

  TextEditingController searchKey = TextEditingController();
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  double average = 0.0;
  final itemkey = GlobalKey();

  Future scrollItem() async {
    final context = itemkey.currentContext!;
    await Scrollable.ensureVisible(context);
  }

  @override
  void initState() {
    // for (var result in widget.drawResult) {}
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    average = screenWidth + screenHeight;

    return Scaffold(
        appBar: AppBar(
          title: const Text("Results"),
          centerTitle: true,
          actions: [CustomCloseButton()],
        ),
        body: widget.gameId == "2d-super"
            ? Container(
                padding: const EdgeInsets.all(8),
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                  child: Stack(
                    children: [
                      // Main Card Content
                      Container(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 12),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.white,
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Two texts in one row
                            row_values(context),
                            const SizedBox(height: 16),
                            // Big number below
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                customText(
                                    value: "Win No: ",
                                    average: average,
                                    fontColor: Colors.black,
                                    fontSize: 100,
                                    fontWeight: FontWeight.bold),
                                customText(
                                    value:
                                        widget.drawResult[0].ticketNos[0].winNo,
                                    average: average,
                                    fontColor: primaryColor,
                                    fontSize: 100,
                                    fontWeight: FontWeight.bold),
                              ],
                            ),
                          ],
                        ),
                      ),

                      // Yellow badge at top-right
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Center(
                          child: Align(
                              alignment: Alignment.topRight,
                              child: SpikedCircle(
                                backgroundColor: Colors.transparent,
                                color: Colors.black,
                                size: 42,
                                imageAsset: BettingLogic().getImagePath(widget
                                    .drawResult[0].ticketNos[0].jackpotType),
                              )),
                        ),
                      )
                    ],
                  ),
                ),
              )
            : Column(
                children: [
                  row_values(context),
                  Expanded(
                    flex: 4,
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * 0.80,
                      color: Colors.transparent,
                      child: widget.gameId == "2d-jackpot"
                          ? Container(
                              color: Colors.transparent,
                              child: Center(
                                child: SizedBox(
                                  width: MediaQuery.of(context).size.width *
                                      0.8, // Adjust width as needed
                                  child: GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(), // Disable scrolling
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount:
                                          10, // Number of items per row
                                      mainAxisSpacing: 4.0,
                                      crossAxisSpacing: 4.0,
                                      childAspectRatio: 2.0, // Adjust as needed
                                    ),
                                    itemCount:
                                        widget.drawResult[0].ticketNos.length,
                                    itemBuilder: (context, index) {
                                      return Card(
                                        elevation: 4.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10.0),
                                        ),
                                        child: Stack(
                                          children: [
                                            Center(
                                              child: customText(
                                                  value: widget.drawResult[0]
                                                      .ticketNos[index].winNo,
                                                  average: average,
                                                  fontColor: Colors.black,
                                                  fontSize: 100,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            widget
                                                        .drawResult[0]
                                                        .ticketNos[index]
                                                        .jackpotType !=
                                                    "N"
                                                ? Align(
                                                    alignment:
                                                        Alignment.topRight,
                                                    child:
                                                        CustomCircleContainer(
                                                      widthRatio: 0.025,
                                                      heightRatio: 0.025,
                                                      backgroundColor:
                                                          Colors.black,
                                                      borderRadius: 60.0,
                                                      imagePath: BettingLogic()
                                                          .getImagePath(widget
                                                              .drawResult[0]
                                                              .ticketNos[index]
                                                              .jackpotType),
                                                    ),
                                                  )
                                                : const SizedBox.shrink(),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                Row(
                                  children: [
                                    titileContainer(
                                        context, "Ticket", Colors.black),
                                    titileContainer(context, "Win No (Double)",
                                        Colors.black),
                                    if (widget.gameId == "2d")
                                      titileContainer(context, "Single - Bahar",
                                          kPrimarySeedColor!),
                                    if (widget.gameId == "2d")
                                      titileContainer(context, "Single - Andar",
                                          Colors.red),
                                  ],
                                ),
                                Container(
                                  width: MediaQuery.of(context).size.width,
                                  height:
                                      MediaQuery.of(context).size.height * 0.70,
                                  color: Colors.white,
                                  child: Row(
                                    children: [
                                      Container(
                                        width: widget.gameId == "2d-series"
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.50
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.70,
                                        color: Colors.transparent,
                                        child: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: widget.drawResult
                                                .length, //widget.drawResult[position]['ticketNos'].length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.065,
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  child: Center(
                                                      child: Text(widget
                                                          .drawResult[0]
                                                          .ticketNos[index]
                                                          .typeName)
                                                      //widget.drawResult[position]['ticketNos'][index][value]),
                                                      ),
                                                ),
                                              );
                                            }),
                                      ),
                                      Container(
                                        width: widget.gameId == "2d-series"
                                            ? MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.50
                                            : MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.25,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.70,
                                        color: Colors.transparent,
                                        child: ListView.builder(
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: widget.drawResult
                                                .length, //widget.drawResult[position]['ticketNos'].length,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.all(2.0),
                                                child: Container(
                                                  width: MediaQuery.of(context)
                                                      .size
                                                      .width,
                                                  height: MediaQuery.of(context)
                                                          .size
                                                          .height *
                                                      0.065,
                                                  color: Colors.grey
                                                      .withOpacity(0.1),
                                                  child: Center(
                                                      child: Text(widget
                                                          .drawResult[0]
                                                          .ticketNos[index]
                                                          .winNo)
                                                      //widget.drawResult[position]['ticketNos'][index][value]),
                                                      ),
                                                ),
                                              );
                                            }),
                                      ),
                                      widget.gameId == "2d"
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.70,
                                              color: Colors.transparent,
                                              child: ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount:
                                                      widget.drawResult.length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.065,
                                                        color: Colors.grey
                                                            .withOpacity(0.1),
                                                        child: Center(
                                                            child: Text(widget
                                                                .drawResult[2]
                                                                .ticketNos[
                                                                    index]
                                                                .winNo)
                                                            //widget.drawResult[position]['ticketNos'][index][value]),
                                                            ),
                                                      ),
                                                    );
                                                  }),
                                            )
                                          : const SizedBox.shrink(),
                                      widget.gameId == "2d"
                                          ? Container(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  0.25,
                                              height: MediaQuery.of(context)
                                                      .size
                                                      .height *
                                                  0.70,
                                              color: Colors.transparent,
                                              child: ListView.builder(
                                                  physics:
                                                      const NeverScrollableScrollPhysics(),
                                                  itemCount: widget.drawResult
                                                      .length, //widget.drawResult[position]['ticketNos'].length,
                                                  itemBuilder:
                                                      (context, index) {
                                                    return Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              2.0),
                                                      child: Container(
                                                        width: MediaQuery.of(
                                                                context)
                                                            .size
                                                            .width,
                                                        height: MediaQuery.of(
                                                                    context)
                                                                .size
                                                                .height *
                                                            0.065,
                                                        color: Colors.grey
                                                            .withOpacity(0.1),
                                                        child: Center(
                                                            child: Text(widget
                                                                .drawResult[1]
                                                                .ticketNos[
                                                                    index]
                                                                .winNo)
                                                            //widget.drawResult[position]['ticketNos'][index][value]),
                                                            ),
                                                      ),
                                                    );
                                                  }),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                    ),
                  )
                ],
              ));
  }

  Container row_values(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.10,
      color: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child:
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          AutoSizeText(
            "Draw ID : ${widget.drawId.toString()}",
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
            maxFontSize: 16,
            minFontSize: 10,
            maxLines: 1,
          ),
          AutoSizeText(
            "Draw Time : ${int.tryParse(widget.drawTime) != null ? Helper.epocToMMddYYYYhhMMaa(int.parse(widget.drawTime)) : widget.drawTime}",
            style: const TextStyle(fontWeight: FontWeight.bold),
            maxFontSize: 16,
            minFontSize: 10,
            maxLines: 1,
          ),
        ]),
      ),
    );
  }

  // Container bodyContainer(BuildContext context, int position, String value) {
  //   return Container(
  //     width: MediaQuery.of(context).size.width * 0.25,
  //     height: MediaQuery.of(context).size.height * 0.70,
  //     color: Colors.transparent,
  //     child: ListView.builder(
  //         physics: const NeverScrollableScrollPhysics(),
  //         itemCount: 10, //widget.drawResult[position]['ticketNos'].length,
  //         itemBuilder: (context, index) {
  //           return Padding(
  //             padding: const EdgeInsets.all(2.0),
  //             child: Container(
  //               width: MediaQuery.of(context).size.width,
  //               height: MediaQuery.of(context).size.height * 0.065,
  //               color: Colors.grey.withOpacity(0.1),
  //               child: Center(
  //                   child: Text(
  //                       widget.drawResult[position].ticketNos[index].typeName)
  //                   //widget.drawResult[position]['ticketNos'][index][value]),
  //                   ),
  //             ),
  //           );
  //         }),
  //   );
  // }

  Container titileContainer(BuildContext context, String titile, Color color) {
    return Container(
      width: widget.gameId == "2d-series"
          ? MediaQuery.of(context).size.width * 0.50
          : MediaQuery.of(context).size.width * 0.25,
      height: MediaQuery.of(context).size.height * 0.05,
      color: Colors.transparent,
      child: Center(
          child: Text(
        titile,
        style: TextStyle(color: color, fontWeight: FontWeight.bold),
      )),
    );
  }
}
