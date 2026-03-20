import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:psglotto/model/user_results.dart' as u;
import 'package:psglotto/provider/lotto_clock_provider.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/widgets/result/draw_result_view.dart';

import '../../../params/draw_result_params.dart';
import '../../../params/user_results_params.dart';
import '../../../provider/providers.dart';
import '../../utils/constants.dart';
import '../../utils/helper.dart';
import 'package:psglotto/model/game.dart' as g;

import '../loading_overlay.dart';
import '../snackbar.dart';
import 'my_lotteries_game_type.dart';

class DrawnView extends ConsumerStatefulWidget {
  final int categoryId;
  const DrawnView({required this.categoryId, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DrawnViewState createState() => _DrawnViewState();
}

class _DrawnViewState extends ConsumerState<DrawnView> {
  late DateTime _startDate;
  late DateTime _endDate;

  String searchedStartDate = "";
  String searchedEndDate = "";

  int pageNo = 1;

  // List of items in our dropdown menu
  var items = [
    1,
  ];
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

  List<u.Results> results = [];
  bool isLoading = false;
  bool showLoadingOverlay = false;
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
                            (e) => MyLotteriesGameTypeWidget(
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Result for [$searchedStartDate - $searchedEndDate]",
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
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
                  ),
                  const SizedBox(
                    height: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width * 0.6,
                      child: Text(
                        "Total number of Records : ${results.length} - Page $pageNo",
                        style: const TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  results.isNotEmpty
                      ? ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) => Container(
                            padding: const EdgeInsets.all(16.0),
                            margin: const EdgeInsets.all(16.0),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(results[index].gameName!),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Text(results[index].drawPlayGroupId!),
                                      ],
                                    ),
                                    Text(
                                        "Ticket No: ${results[index].ticketNo}"),
                                    Text("Draw Time: ${results[index].time!}")
                                  ],
                                ),
                                Column(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () async {
                                        bool networkStatus = await Helper
                                            .checkNetworkConnection();
                                        if (networkStatus) {
                                          setState(() {
                                            showLoadingOverlay = true;
                                          });
                                          await ref
                                              .read(
                                            drawResultProvider(
                                              DrawResultParams(
                                                categoryId: 1,
                                                gameId: results[index].gameId!,
                                                drawId: results[index].drawId!,
                                              ),
                                            ).future,
                                          )
                                              .then((value) {
                                            setState(() {
                                              showLoadingOverlay = false;
                                            });

                                            return Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    DrawResultView(
                                                  drawTime:
                                                      results[index].time!,
                                                  gameName:
                                                      results[index].gameName!,
                                                  drawId: results[index]
                                                      .drawPlayGroupId!,
                                                  results: value.results!,
                                                ),
                                              ),
                                            );
                                          }).onError((error, stackTrace) {
                                            if (!mounted) {
                                              return;
                                            }
                                            ExceptionHandler.showSnack(
                                                errorCode: error.toString(),
                                                context: context);
                                          });
                                        } else {
                                          setState(() {
                                            showLoadingOverlay = false;
                                          });

                                          if (!mounted) return;
                                          // ignore: use_build_context_synchronously
                                          showSnackBar(context,
                                              "Check your internet connection");
                                        }
                                      },
                                      child: const Text("Result"),
                                    ),
                                  ],
                                ),
                              ],
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
        UserResultsParams userResultSearchParams = UserResultsParams(
          claimStatus: 0,
          categoryId: widget.categoryId,
          gameId: ref.watch(filterMyLotteriesProvider),
          fromDate: (_startDate.millisecondsSinceEpoch),
          toDate: (_endDate.millisecondsSinceEpoch),
          resultType: 2,
          page: pageNo - 1,
        );
        setState(() {
          items = [];
          isLoading = true;
        });
        await ref
            .watch(drawnProvider(userResultSearchParams).future)
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
            results = value.results!;

            isLoading = false;
          });
        }).onError((error, stackTrace) {
          if (!mounted) {
            return;
          }
          if (kDebugMode) {
            print(error);
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
