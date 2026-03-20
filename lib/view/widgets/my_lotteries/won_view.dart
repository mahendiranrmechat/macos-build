import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:psglotto/model/user_results.dart' as u;
import 'package:psglotto/params/claim_all_params.dart';
import 'package:psglotto/params/claim_params.dart';
import 'package:psglotto/provider/lotto_clock_provider.dart';
import 'package:psglotto/view/utils/success_layout.dart';

import '../../../params/draw_result_params.dart';
import '../../../params/user_results_params.dart';
import '../../../provider/providers.dart';
import '../../../utils/exception_handler.dart';
import '../../utils/constants.dart';
import '../../utils/helper.dart';
import '../loading_overlay.dart';
import '../result/draw_result_view.dart';
import 'package:psglotto/model/game.dart' as g;

import '../snackbar.dart';
import 'my_lotteries_game_type.dart';

class WonView extends ConsumerStatefulWidget {
  final int categoryId;
  const WonView({Key? key, required this.categoryId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WonViewState createState() => _WonViewState();
}

class _WonViewState extends ConsumerState<WonView> {
  late DateTime _startDate;
  late DateTime _endDate;

  String searchedStartDate = "";
  String searchedEndDate = "";
  bool claimAllEnable = false;
  String dropdownValue = 'Unclaimed';
  int claimStatus = 2;
  num unClaimedPrice = 0;
  num unClaimedTickets = 0;
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
    // // Clear the filter on initialization
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
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              setState(() {
                                pageNo = 1;
                              });
                              searchResult();
                            },
                            child: const Text("Search"),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: Colors.grey[200],
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            child: Center(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: dropdownValue,
                                  icon: Icon(Icons.arrow_downward,
                                      color: kPrimarySeedColor),
                                  iconSize: 24,
                                  elevation: 16,
                                  style: TextStyle(
                                      color: kPrimarySeedColor, fontSize: 16),
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      dropdownValue = newValue!;
                                      if (newValue == "All") {
                                        claimStatus = 0;
                                      } else if (newValue == "Claimed") {
                                        claimStatus = 1;
                                      } else {
                                        claimStatus = 2;
                                      }
                                    });
                                  },
                                  items: <String>['All', 'Claimed', 'Unclaimed']
                                      .map<DropdownMenuItem<String>>(
                                          (String value) {
                                    return DropdownMenuItem<String>(
                                      value: value,
                                      child: Text(
                                        value,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(
                height: 10.0,
              ),
              Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Result for [$searchedStartDate - $searchedEndDate]",
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                        !Platform.isAndroid
                            ? Row(
                                children: [
                                  Text(
                                    "UnClaimed Tickets : $unClaimedTickets",
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  Text(
                                    "UnClaimed Points: ${unClaimedPrice.floor()}",
                                    style: const TextStyle(
                                        fontSize: 16.0,
                                        fontWeight: FontWeight.w600),
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
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  Container(
                    color: Colors.transparent,
                    height: 56,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.6,
                            child: Text(
                              "Total number of Records : ${results.length} - Page $pageNo",
                              style: const TextStyle(
                                  fontSize: 16.0, fontWeight: FontWeight.w600),
                            ),
                          ),
                          SizedBox(
                            width: Platform.isWindows || Platform.isMacOS
                                ? MediaQuery.of(context).size.width * 0.1
                                : MediaQuery.of(context).size.width * 0.3,
                            child: Column(
                              children: [
                                ElevatedButton(
                                  onPressed: claimAllEnable
                                      ? () async {
                                          bool networkStatus = await Helper
                                              .checkNetworkConnection();
                                          if (networkStatus) {
                                            setState(() {
                                              showLoadingOverlay = true;
                                            });

                                            await ref
                                                .read(claimProviderAll(ClaimParamsAll(
                                                        gameId: ref.watch(
                                                            filterMyLotteriesProvider),
                                                        categoryId:
                                                            widget.categoryId,
                                                        fromDate: (_startDate
                                                            .millisecondsSinceEpoch),
                                                        toDate: (_endDate
                                                            .millisecondsSinceEpoch)))
                                                    .future)
                                                .then((value) {
                                              if (mounted) {
                                                //searchResult();
                                                setState(() {
                                                  showLoadingOverlay = false;
                                                  claimAllEnable = false;
                                                });
                                              }
                                              // ignore: unused_result
                                              ref.refresh(balanceProvider);
                                              showSuccess(
                                                  context,
                                                  "Claim Success!",
                                                  "Congratulations! You've won ${unClaimedPrice.floor()} Points",
                                                  "Your Updated Current Balance: ${value.balance!.floor()}",
                                                  showText: false);
                                              results.clear();
                                              setState(() {
                                                unClaimedTickets = 0;
                                                unClaimedPrice = 0;
                                              });
                                              //  wonProviderCallFunction(context);
                                            }).onError((error, stackTrace) {
                                              setState(() {
                                                showLoadingOverlay = false;
                                              });

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
                                        }
                                      : null,
                                  child: const Text("Claim All"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 10.0,
                  ),
                  results.isNotEmpty
                      ? ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
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
                                    Text(
                                        "Game Name: ${results[index].gameName!}"),
                                    Text(
                                        "Draw Id: ${results[index].drawPlayGroupId!}"),
                                    Text(
                                      "Barcode: ${results[index].barCode}",
                                    ),
                                    Text(
                                        "Ticket No: ${results[index].ticketNo}"),
                                    Text(
                                        "Amount Prize: ₹ ${results[index].winPrice}"),
                                    Text(
                                        "Prize Category: ${results[index].winName}"),
                                    Text(
                                      "Draw Time: ${results[index].time!}",
                                    ),
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
                                            setState(() {
                                              showLoadingOverlay = false;
                                            });

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
                                    const SizedBox(
                                      height: 10.0,
                                    ),
                                    ElevatedButton(
                                      onPressed: results[index].claim == 0
                                          ? () async {
                                              bool networkStatus = await Helper
                                                  .checkNetworkConnection();
                                              if (networkStatus) {
                                                setState(() {
                                                  showLoadingOverlay = true;
                                                  results[index].claim = 1;
                                                });

                                                await ref
                                                    .read(claimProvider(
                                                        ClaimParams(
                                                  gameId:
                                                      results[index].gameId!,
                                                  categoryId: widget.categoryId,
                                                  drawId:
                                                      results[index].drawId!,
                                                  ticketId:
                                                      results[index].ticketId!,
                                                  fromDate: (_startDate
                                                      .millisecondsSinceEpoch),
                                                  toDate: (_endDate
                                                      .millisecondsSinceEpoch),
                                                )).future)
                                                    .then((value) {
                                                  if (mounted) {
                                                    setState(() {
                                                      showLoadingOverlay =
                                                          false;
                                                    });
                                                  }
                                                  claimAllEnable = results.any(
                                                      (result) =>
                                                          result.claim == 0);
                                                  // ignore: unused_result
                                                  ref.refresh(balanceProvider);
                                                  showSuccess(
                                                      context,
                                                      "Claim Success!",
                                                      "Congratulations! You've won ${results[index].winPrice!.floor()} Points",
                                                      "Your Updated Current Balance: ${value.balance!.floor()}",
                                                      showText: false);

                                                  // wonProviderCallFunction(
                                                  //     context);
                                                }).onError((error, stackTrace) {
                                                  setState(() {
                                                    showLoadingOverlay = false;
                                                  });

                                                  ExceptionHandler.showSnack(
                                                      errorCode:
                                                          error.toString(),
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
                                            }
                                          : null,
                                      child: const Text("Claim"),
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

  void wonProviderCallFunction(BuildContext context) {
    UserResultsParams userResultSearchParams = UserResultsParams(
      claimStatus: claimStatus,
      categoryId: widget.categoryId,
      gameId: ref.watch(filterMyLotteriesProvider),
      fromDate: (_startDate.millisecondsSinceEpoch),
      toDate: (_endDate.millisecondsSinceEpoch),
      resultType: 3,
      page: pageNo - 1,
    );

    ref
        .refresh(wonProvider(userResultSearchParams).future)
        .then((value) => setState(() {
              results = value.results!;
            }))
        .onError((error, stackTrace) {
      ExceptionHandler.showSnack(errorCode: error.toString(), context: context);
    });
  }

  void searchResult() async {
    bool networkStatus = await Helper.checkNetworkConnection();
    if (networkStatus) {
      results = [];

      if (ref.watch(filterMyLotteriesProvider).isNotEmpty) {
        UserResultsParams userResultSearchParams = UserResultsParams(
          claimStatus: claimStatus,
          categoryId: widget.categoryId,
          gameId: ref.watch(filterMyLotteriesProvider),
          fromDate: (_startDate.millisecondsSinceEpoch),
          toDate: (_endDate.millisecondsSinceEpoch),
          resultType: 3,
          page: pageNo - 1,
        );
        setState(() {
          items = [];
          isLoading = true;
        });
        await ref
            .watch(wonProvider(userResultSearchParams).future)
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
            unClaimedPrice = value.unClaimedPrice ?? 0;
            unClaimedTickets = value.unClaimedTickets ?? 0;
            isLoading = false;
            claimAllEnable = results.any((result) => result.claim == 0);
            if (claimAllEnable) {
              if (kDebugMode) {
                print("claimEnable button working: $claimAllEnable");
              }
            } else {
              if (kDebugMode) {
                print("Not enable");
              }
            }
            for (int i = 0; i < results.length; i++) {
              if (kDebugMode) {
                print(results[i].claim);
              }
            }
          });
        }).onError((error, stackTrace) {
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
