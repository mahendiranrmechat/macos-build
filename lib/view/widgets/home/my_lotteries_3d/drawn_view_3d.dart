import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:psglotto/provider/lotto_clock_provider.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/widgets/home/my_lotteries_2d/my_lotteries_game_type_2d.dart';

import 'package:psglotto/model/game.dart' as g;
import 'package:psglotto/view/widgets/home/my_lotteries_3d/ticket_view_page_3d.dart';
import 'package:psglotto/view/widgets/result/draw_result_view_3d.dart';
import 'package:series_2d/utils/game_data_constant.dart';

import '../../../../model/user_result_3d.dart';
import '../../../../params/draw_result_params.dart';
import '../../../../params/user_results_params.dart';
import '../../../../provider/providers.dart';
import '../../../utils/constants.dart';
import '../../../utils/helper.dart';
import '../../loading_overlay.dart';
import '../../snackbar.dart';

class DrawnView3D extends ConsumerStatefulWidget {
  final int categoryId;
  const DrawnView3D({required this.categoryId, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DrawnView3DState createState() => _DrawnView3DState();
}

class _DrawnView3DState extends ConsumerState<DrawnView3D> {
  late DateTime _startDate;
  late DateTime _endDate;

  String searchedStartDate = "";
  String searchedEndDate = "";

  int pageNo = 1;

  // List of items in our dropdown menu
  var items = [
    1,
  ];

  List<Result> results = [];
  bool isLoading = false;
  bool showLoadingOverlay = false;
  @override
  void initState() {
    initializeDates();
    super.initState();
  }

  void initializeDates() {
    // Convert lottoCurrentTimeServer to DateTime
    DateTime lottoDateTime =
        DateTime.fromMillisecondsSinceEpoch(lottoCurrentTimeServer);

    // Initialize _startDate and _endDate
    _startDate =
        DateTime(lottoDateTime.year, lottoDateTime.month, lottoDateTime.day);
    _endDate = DateTime(
        lottoDateTime.year, lottoDateTime.month, lottoDateTime.day, 23, 59, 59);
    // Clear the filter on initialization
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(filterMyLotteriesProvider.notifier).clear();
    // });
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<g.GameList>> gameAsyncData =
        ref.watch(gameProvider(widget.categoryId));
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(color: Colors.white),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Type",
                      style: TextStyle(
                          fontSize: 16.0, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 10.0,
                    ),
                    gameAsyncData.when(data: (data) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (data.isNotEmpty &&
                            ref.read(filterMyLotteriesProvider).isEmpty) {
                          ref
                              .read(filterMyLotteriesProvider.notifier)
                              .setResultFilter(data.first.gameId ?? "-");
                        }
                      });

                      return Wrap(
                        children: [
                          ...data.map(
                            (e) => MyLotteriesGameTypeWidget2D(
                              gameName: e.gameName ?? "-",
                              gameId: e.gameId ?? '-',
                            ),
                          ),
                        ],
                      );
                    }, error: (error, s) {
                      ExceptionHandler.showSnack(
                          errorCode: error.toString(), context: context);
                      return const Text("Something went wrong");
                    }, loading: () {
                      return const CircularProgressIndicator();
                    }),
                  ],
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              GestureDetector(
                onTap: () async {
                  final lottoDateTime = DateTime.fromMillisecondsSinceEpoch(
                      lottoCurrentTimeServer);
                  final adjustedLottoDateTime =
                      lottoDateTime.subtract(const Duration(days: 29));

                  final picked = await showDateRangePicker(
                      context: context,
                      lastDate: lottoDateTime,
                      firstDate: adjustedLottoDateTime,
                      currentDate: lottoDateTime);
                  if (picked != null) {
                    setState(() {
                      _startDate = picked.start;
                      _endDate = DateTime(picked.end.year, picked.end.month,
                          picked.end.day, 23, 59, 59);
                    });
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Draw date",
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      Row(
                        children: [
                          const Text("From"),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: kScaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Text(
                                DateFormat('dd-MM-yyyy').format(_startDate)),
                          ),
                          const SizedBox(
                            width: 10.0,
                          ),
                          const Text("-"),
                          const SizedBox(
                            width: 10.0,
                          ),
                          Container(
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: kScaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child:
                                Text(DateFormat('dd-MM-yyyy').format(_endDate)),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          setState(() {
                            pageNo = 1;
                          });
                          searchResult();
                        },
                        child: const Text("Search"),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "Result for [$searchedStartDate - $searchedEndDate]",
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              width: 20,
                            ),
                            items.length < 2
                                ? const SizedBox.shrink()
                                : DropdownButton(
                                    value: pageNo,
                                    items: items.map((int items) {
                                      return DropdownMenuItem(
                                        value: items,
                                        child: Text(items.toString()),
                                      );
                                    }).toList(),
                                    onChanged: (int? newValue) {
                                      setState(() {
                                        pageNo = newValue!;
                                      });
                                      searchResult();
                                    },
                                  ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.6,
                          child: Text(
                            "Total number of Records : ${results.length} - Page $pageNo",
                            style: const TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  results.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              // ignore: deprecated_member_use
                              color: Colors.grey.withOpacity(0.1),
                              height: 100,
                              // color: Colors.green,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Game Name : ${results[index].gameName}"),
                                        Text(
                                            "Draw Id : ${results[index].drawPlayGroupId}"),
                                        Text(
                                            "Barcode : ${results[index].barCode}"),
                                        Text(
                                            "Play Points : ${results[index].ticketPrice.toStringAsFixed(0)}"),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        // Text(results[index].ticketNo.toString()),
                                        Text(
                                            "Draw Time : ${results[index].time}"),
                                      ],
                                    ),
                                    const SizedBox(),
                                    SizedBox(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Center(
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    bool networkStatus =
                                                        await Helper
                                                            .checkNetworkConnection();
                                                    if (networkStatus) {
                                                      await ref
                                                          .read(
                                                        drawResult3DProvider(
                                                          DrawResultParams(
                                                            categoryId: 2,
                                                            gameId:
                                                                results[index]
                                                                    .gameId,
                                                            drawId:
                                                                results[index]
                                                                    .drawId,
                                                          ),
                                                        ).future,
                                                      )
                                                          .then((drawResult) {
                                                        setState(() {
                                                          showLoadingOverlay =
                                                              false;
                                                        });

                                                        return Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                TicketViewPage3D(
                                                              playPoints: results[
                                                                      index]
                                                                  .ticketPrice,
                                                              winPrice:
                                                                  results[index]
                                                                      .winPrice,
                                                              jackpotPrice:
                                                                  results[index]
                                                                      .jackpotPrice,
                                                              totalWinPrice:
                                                                  results[index]
                                                                      .totalWinPrice,
                                                              resultShow: false,
                                                              barcode:
                                                                  results[index]
                                                                      .barCode,
                                                              purchaseTime:
                                                                  results[index]
                                                                      .purchaseTime,
                                                              gameName:
                                                                  results[index]
                                                                      .gameName,
                                                              drawTime:
                                                                  results[index]
                                                                      .time,
                                                              drawPlayGroupId:
                                                                  results[index]
                                                                      .drawPlayGroupId,
                                                              username:
                                                                  userName,
                                                              ticketNo:
                                                                  results[index]
                                                                      .ticketNo,
                                                              drawResult:
                                                                  drawResult, // Pass the entire DrawResult2D here,
                                                              showWinNo:
                                                                  true, // Pass the fetched drawResult here
                                                            ),
                                                          ),
                                                        );
                                                      }).onError((error,
                                                              stackTrace) {
                                                        if (!mounted) {
                                                          return;
                                                        }
                                                        setState(() {
                                                          showLoadingOverlay =
                                                              false;
                                                        });
                                                        // ignore: use_build_context_synchronously
                                                        showSnackBar(context,
                                                            error.toString());

                                                        return ExceptionHandler
                                                            .showSnack(
                                                                errorCode: error
                                                                    .toString(),
                                                                // ignore: use_build_context_synchronously
                                                                context:
                                                                    context);
                                                      });
                                                    } else {
                                                      // ignore: use_build_context_synchronously
                                                      showSnackBar(context,
                                                          "Check your internet connection");
                                                    }
                                                  },
                                                  child: const Text(
                                                      "View Tickets"))),
                                          Center(
                                              child: ElevatedButton(
                                                  onPressed: () async {
                                                    bool networkStatus =
                                                        await Helper
                                                            .checkNetworkConnection();
                                                    if (networkStatus) {
                                                      setState(() {
                                                        showLoadingOverlay =
                                                            true;
                                                      });
                                                      await ref
                                                          .read(
                                                        drawResult2DProvider(
                                                          DrawResultParams(
                                                            categoryId: 2,
                                                            gameId:
                                                                results[index]
                                                                    .gameId!,
                                                            drawId:
                                                                results[index]
                                                                    .drawId!,
                                                          ),
                                                        ).future,
                                                      )
                                                          .then((value) {
                                                        setState(() {
                                                          showLoadingOverlay =
                                                              false;
                                                        });

                                                        return Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                            builder: (context) =>
                                                                DrawResultView3D(
                                                              gameId:
                                                                  results[index]
                                                                      .gameId!,
                                                              gameName: results[
                                                                      index]
                                                                  .gameName!,
                                                              drawTime:
                                                                  results[index]
                                                                      .time!,
                                                              drawId: results[
                                                                      index]
                                                                  .drawPlayGroupId!,
                                                              drawResult:
                                                                  value.results,
                                                            ),
                                                          ),
                                                        );
                                                      }).onError((error,
                                                              stackTrace) {
                                                        if (!mounted) {
                                                          return;
                                                        }
                                                        setState(() {
                                                          showLoadingOverlay =
                                                              false;
                                                        });
                                                        // ignore: use_build_context_synchronously
                                                        showSnackBar(context,
                                                            error.toString());

                                                        return ExceptionHandler
                                                            .showSnack(
                                                                errorCode: error
                                                                    .toString(),
                                                                // ignore: use_build_context_synchronously
                                                                context:
                                                                    context);
                                                      });
                                                    } else {
                                                      // ignore: use_build_context_synchronously
                                                      showSnackBar(context,
                                                          "Check your internet connection");
                                                    }
                                                  },
                                                  child: const Text("Result"))),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          itemCount: results.length,
                        )
                      : isLoading
                          ? const Center(
                              child: CircularProgressIndicator(),
                            )
                          : const SizedBox.shrink(),
                ],
              ),
            ],
          ),
        ),
        if (showLoadingOverlay) const MyOverlay(),
      ],
    );
  }

  void searchResult() async {
    bool networkStatus = await Helper.checkNetworkConnection();
    if (networkStatus) {
      results = [];
      if (ref.watch(filterMyLotteriesProvider).isNotEmpty) {
        setState(() {
          isLoading = true;
          items = [];
        });
        await ref
            .watch(drawnProvider3d(UserResultsParams(
          claimStatus: 0,
          categoryId: widget.categoryId,
          gameId: ref.watch(filterMyLotteriesProvider),
          fromDate: (_startDate.millisecondsSinceEpoch),
          toDate: (_endDate.millisecondsSinceEpoch),
          page: pageNo - 1,
          resultType: 2,
        )).future)
            .then((value) {
          if (!mounted) {
            return;
          }

          setState(() {
            if (value.totalPages != 0) {
              items = List<int>.generate(value.totalPages!, (i) => i + 1);
            }

            searchedStartDate = DateFormat('dd-MM-yyyy').format(_startDate);
            searchedEndDate = DateFormat('dd-MM-yyyy').format(_endDate);

            // Assign the results to the results list
            results = value.results!;

            // Sort results by purchaseTime in ascending order (oldest first)
            // Sort results by purchaseTime in descending order (most recent first)

            results.sort((a, b) {
              DateTime aTime =
                  DateFormat("yyyy-MM-dd hh:mm:ss a").parse(a.time!);
              DateTime bTime =
                  DateFormat("yyyy-MM-dd hh:mm:ss a").parse(b.time!);
              return bTime.compareTo(aTime); // Descending order
            });

            isLoading = false;
          });
        }).onError((error, stackTrace) {
          // Handle errors
          if (!mounted) {
            return;
          }
          ExceptionHandler.showSnack(
              errorCode: error.toString(), context: context);
          setState(() {
            isLoading = false;
          });
        });
      } else {
        if (!mounted) return;

        showSnackBar(context, "Please select a game type before searching");
      }
    } else {
      if (!mounted) return;
      showSnackBar(context, "Check your internet connection");
    }
  }
}
