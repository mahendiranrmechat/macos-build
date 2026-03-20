import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:psglotto/model/game.dart' as g;
import 'package:psglotto/model/user_result_3d.dart';
import 'package:psglotto/params/claim_all_params.dart';
import 'package:psglotto/params/claim_params_2d.dart';
import 'package:psglotto/provider/lotto_clock_provider.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/settings_services/shared_preferences.dart';
import 'package:psglotto/view/utils/success_layout.dart';
import 'package:psglotto/view/widgets/home/my_lotteries_3d/ticket_view_page_3d.dart';
import 'package:psglotto/view/widgets/result/draw_result_view_2d.dart';
import 'package:psglotto/view/widgets/result/draw_result_view_3d.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:series_2d/utils/game_data_constant.dart';
import '../../../../params/draw_result_params.dart';
import '../../../../params/user_results_params.dart';
import '../../../../provider/providers.dart';
import '../../../../utils/exception_handler.dart';
import '../../../utils/constants.dart';
import '../../../utils/helper.dart';
import '../../loading_overlay.dart';
import '../../my_lotteries/my_lotteries_game_type.dart';

import '../../snackbar.dart';
import 'package:pdf/widgets.dart' as pw;

class WonView3D extends ConsumerStatefulWidget {
  final int categoryId;
  const WonView3D({Key? key, required this.categoryId}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _WonView3DState createState() => _WonView3DState();
}

class _WonView3DState extends ConsumerState<WonView3D> {
  // DateTime now =
  //     DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  // late DateTime _startDate = now;
  // DateTime _endDate = DateTime(DateTime.now().year, DateTime.now().month,
  //     DateTime.now().day, 23, 59, 59);

  late DateTime _startDate;
  late DateTime _endDate;

  String searchedStartDate = "";
  String searchedEndDate = "";
  bool claimAllEnable = false;
  String gameId = "";
  int pageNo = 1;
  List<bool> disableClaimButton = [];
  String dropdownValue = 'Unclaimed';
  int claimStatus = 2;
  num unClaimedPrice = 0;
  int unClaimedTickets = 0;
  double totalWinPrice = 0.0;
  String previousDropSelection = "Unclaimed";
  // List of items in our dropdown menu
  var items = [
    1,
  ];

  List<Result> results = [];
  bool isLoading = false;
  bool showLoadingOverlay = false;
  Printer? defaultPrinter;

  final preferenceService = PreferencesServices();
  var selectedPaperSize = PaperSelect.Size57;
  List<Printer> printers = [];
  List<String> options = ['2 Inc', '3 Inc'];
  String optionPrintType = '2 Inc';
  @override
  void initState() {
    super.initState();
    populateFileds();
    setupPrinter();

    initializeDates();
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

  void populateFileds() async {
    final settings = await preferenceService.getSettings();
    setState(() {
      selectedPaperSize = settings.paperSelect;
      if (selectedPaperSize == PaperSelect.Size57) {
        optionPrintType = '2 Inc';
      } else {
        optionPrintType = '3 Inc';
      }

      if (kDebugMode) {
        print("Checking print value: ${settings.isBarcode}");
      }
      isBarcode = settings.isBarcode;
    });
  }

  void setupPrinter() async {
    if (Platform.isWindows) {
      printers = await Printing.listPrinters();
      for (var element in printers) {
        if (element.isDefault == true) {
          defaultPrinter = element;
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<g.GameList>> gameAsyncData =
        ref.watch(gameProvider(widget.categoryId));
    return Stack(
      children: [
        SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
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

                  // String formatWithMicroseconds(DateTime dateTime) {
                  //   final datePart =
                  //       DateFormat("yyyy-MM-dd").format(dateTime);

                  //   return datePart;
                  // }

// Show DateRangePicker
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
                          const SizedBox(
                            width: 10.0,
                          ),
                          Container(
                            height: 30,
                            padding: const EdgeInsets.all(4.0),
                            decoration: BoxDecoration(
                              color: kScaffoldBackgroundColor,
                              borderRadius: BorderRadius.circular(4.0),
                            ),
                            child: Center(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: dropdownValue,
                                  icon: Icon(Icons.arrow_downward,
                                      color: kPrimarySeedColor),
                                  // iconSize: 24,
                                  // elevation: 16,
                                  // style: const TextStyle(fontSize: 16),
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
                crossAxisAlignment: CrossAxisAlignment.start,
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
                                      ? const SizedBox(
                                          width: 20,
                                        )
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
                                              claimAllEnable = false;
                                              if (previousDropSelection !=
                                                  dropdownValue) {
                                                pageNo = 1;
                                              }
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
                  Platform.isAndroid
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            "UnClaimed Tickets : $unClaimedTickets",
                            style: const TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w600),
                          ),
                        )
                      : const SizedBox.shrink(),
                  Platform.isAndroid
                      ? Padding(
                          padding: const EdgeInsets.only(left: 8.0, top: 4.0),
                          child: Text(
                            "UnClaimed Price: ${unClaimedPrice.floor()}",
                            style: const TextStyle(
                                fontSize: 16.0, fontWeight: FontWeight.w600),
                          ),
                        )
                      : const SizedBox.shrink(),
                  Container(
                    color: Colors.transparent,
                    height: 50,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8.0, top: 2.0),
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
                                ? MediaQuery.of(context).size.width * 0.2
                                : MediaQuery.of(context).size.width * 0.3,
                            child: Column(
                              children: [
                                const SizedBox(
                                  height: 20,
                                ),
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
                                              if (value.errorCode == 0) {
                                                // ignore: unused_result
                                                ref.refresh(balanceProvider);
                                                ScaffoldMessenger.of(context)
                                                    .hideCurrentSnackBar();
                                                showSuccess(
                                                    context,
                                                    "Claim Success!",
                                                    "Congratulations! You've won ${unClaimedPrice.floor()} Points",
                                                    "Your Updated Current Balance: ${value.balance!.floor()}",
                                                    showText: false);
                                                if (mounted) {
                                                  results.clear();
                                                  setState(() {
                                                    showLoadingOverlay = false;
                                                    claimAllEnable = false;
                                                    unClaimedPrice = 0;
                                                    unClaimedTickets = 0;
                                                  });
                                                }

                                                // wonProviderCallFunction();
                                              }
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
                          itemCount: results.length,
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemBuilder: (context, index) => Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Container(
                              color: Colors.grey.withOpacity(0.1),
                              height: 155,
                              // color: Colors.green,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    color: Colors.transparent,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                            "Game Name: ${results[index].gameName}"),
                                        Text(
                                            "Draw ID : ${results[index].drawPlayGroupId}"),
                                        Text(
                                          "Barcode: ${results[index].barCode}",
                                        ),
                                        Text(
                                          "Play Points: ${results[index].ticketPrice.toStringAsFixed(0)}",
                                        ),
                                        Text(
                                          "Win Points: ${results[index].winPrice.toStringAsFixed(0)}",
                                        ),
                                        Text(
                                          "Jackpot Win Points: ${results[index].jackpotPrice.toStringAsFixed(0)}",
                                        ),
                                        Text(
                                          "Total Win Points: ${results[index].totalWinPrice.toStringAsFixed(0)}",
                                        ),

                                        // Text(results[index].ticketNo.toString()),
                                        Text(
                                            "Draw Time : ${results[index].time}"),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    width:
                                        MediaQuery.of(context).size.width * 0.3,
                                    color: Colors.transparent,
                                    child: Center(
                                      child: ElevatedButton(
                                          onPressed: () async {
                                            bool networkStatus = await Helper
                                                .checkNetworkConnection();
                                            if (networkStatus) {
                                              for (int i = 0;
                                                  i < results.length;
                                                  i++) {
                                                for (int j = 0;
                                                    j <
                                                        results[i]
                                                            .ticketNo
                                                            .length;
                                                    j++) {
                                                  debugPrint(
                                                      "Befre navigationg : ${results[i].ticketNo[j].typeId}");
                                                }
                                              }

                                              await ref
                                                  .read(
                                                drawResult3DProvider(
                                                  DrawResultParams(
                                                    categoryId: 2,
                                                    gameId:
                                                        results[index].gameId,
                                                    drawId:
                                                        results[index].drawId,
                                                  ),
                                                ).future,
                                              )
                                                  .then((drawResult) {
                                                setState(() {
                                                  showLoadingOverlay = false;
                                                });

                                                return Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TicketViewPage3D(
                                                      playPoints: results[index]
                                                          .ticketPrice,
                                                      winPrice: results[index]
                                                          .winPrice,
                                                      jackpotPrice:
                                                          results[index]
                                                              .jackpotPrice,
                                                      totalWinPrice:
                                                          results[index]
                                                              .totalWinPrice,
                                                      resultShow: false,
                                                      barcode: results[index]
                                                          .barCode,
                                                      purchaseTime:
                                                          results[index]
                                                              .purchaseTime,
                                                      gameName: results[index]
                                                          .gameName,
                                                      drawTime:
                                                          results[index].time,
                                                      drawPlayGroupId:
                                                          results[index]
                                                              .drawPlayGroupId,
                                                      username: userName,
                                                      ticketNo: results[index]
                                                          .ticketNo,
                                                      drawResult:
                                                          drawResult, // Pass the entire DrawResult2D here,
                                                      showWinNo:
                                                          true, // Pass the fetched drawResult here
                                                    ),
                                                  ),
                                                );
                                              }).onError((error, stackTrace) {
                                                if (!mounted) {
                                                  return;
                                                }
                                                setState(() {
                                                  showLoadingOverlay = false;
                                                });
                                                showSnackBar(
                                                    context, error.toString());

                                                return ExceptionHandler
                                                    .showSnack(
                                                        errorCode:
                                                            error.toString(),
                                                        context: context);
                                              });
                                            } else {
                                              // ignore: use_build_context_synchronously
                                              showSnackBar(context,
                                                  "Check your internet connection");
                                            }

                                            // for (var result in results) {
                                            //   if (result.drawId ==
                                            //       results[index].drawId) {

                                            //   }
                                            // }
                                          },
                                          child: const Text("View")),
                                    ),
                                  ),
                                  SizedBox(
                                    width:
                                        MediaQuery.of(context).size.width * 0.2,
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
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
                                                drawResult2DProvider(
                                                  DrawResultParams(
                                                    categoryId: 2,
                                                    gameId:
                                                        results[index].gameId,
                                                    drawId:
                                                        results[index].drawId,
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
                                                        DrawResultView3D(
                                                      gameId:
                                                          results[index].gameId,
                                                      gameName: results[index]
                                                          .gameName,
                                                      drawTime:
                                                          results[index].time,
                                                      drawId: results[index]
                                                          .drawPlayGroupId,
                                                      drawResult: value.results,
                                                    ),
                                                  ),
                                                );
                                              }).onError((error, stackTrace) {
                                                if (!mounted) {
                                                  return;
                                                }
                                                setState(() {
                                                  showLoadingOverlay = false;
                                                });
                                                showSnackBar(
                                                    context, error.toString());

                                                return ExceptionHandler
                                                    .showSnack(
                                                        errorCode:
                                                            error.toString(),
                                                        context: context);
                                              });
                                            } else {
                                              // ignore: use_build_context_synchronously
                                              showSnackBar(context,
                                                  "Check your internet connection");
                                            }
                                          },
                                          child: const Text("Result"),
                                        ),
                                        ElevatedButton(
                                          onPressed: results[index].claim == 0
                                              ? () async {
                                                  try {
                                                    bool networkStatus =
                                                        await Helper
                                                            .checkNetworkConnection();
                                                    if (networkStatus) {
                                                      // Capture the current time as claim time
                                                      final DateTime claimTime =
                                                          DateTime.now();
                                                      String
                                                          formattedClaimTime =
                                                          DateFormat(
                                                                  'yyyy-MM-dd hh:mm:ss a')
                                                              .format(
                                                                  claimTime);

                                                      setState(() {
                                                        showLoadingOverlay =
                                                            true;
                                                        results[index].claim =
                                                            1;
                                                      });

                                                      var claimParams =
                                                          ClaimParams2D(
                                                        gameId: results[index]
                                                            .gameId,
                                                        categoryId:
                                                            widget.categoryId,
                                                        drawId: results[index]
                                                            .drawId,
                                                        ticketId: results[index]
                                                            .ticketId,
                                                        fromDate: _startDate
                                                            .millisecondsSinceEpoch,
                                                        toDate: _endDate
                                                            .millisecondsSinceEpoch,
                                                      );

                                                      debugPrint(
                                                          "Claiming with params: $claimParams");

                                                      var value = await ref
                                                          .read(claimProvider2d(
                                                                  claimParams)
                                                              .future);

                                                      debugPrint(
                                                          "Claim result: unClaimedTickets=${value.unClaimedTickets}, "
                                                          "unClaimedPrice=${value.unClaimedPrice}, balance=${value.balance}");

                                                      if (!mounted) return;

                                                      setState(() {
                                                        showLoadingOverlay =
                                                            false;
                                                        unClaimedTickets = value
                                                                .unClaimedTickets ??
                                                            0;
                                                        unClaimedPrice = value
                                                                .unClaimedPrice ??
                                                            0.0;
                                                        claimAllEnable = results
                                                            .any((result) =>
                                                                result.claim ==
                                                                0);
                                                      });

                                                      // ignore: unused_result
                                                      ref.refresh(
                                                          balanceProvider);
                                                      // ignore: use_build_context_synchronously
                                                      ScaffoldMessenger.of(
                                                              // ignore: use_build_context_synchronously
                                                              context)
                                                          .hideCurrentSnackBar();

                                                      showSuccess(
                                                        // ignore: use_build_context_synchronously
                                                        context,
                                                        "Claim Success!",
                                                        "Congratulations! You've won ${results[index].totalWinPrice.floor()} Points",
                                                        "Your Updated Current Balance: ${value.balance?.floor() ?? 0}",
                                                        normalPoints:
                                                            "Normal Win Points: ${results[index].winPrice.floor()}",
                                                        jackpotPoints:
                                                            "Jackpot Win Points: ${results[index].jackpotPrice.floor()}",
                                                        showText: results[index]
                                                                .jackpotPrice !=
                                                            0,
                                                      );

                                                      // Pass the claim time to onCheckPrint
                                                      onCheckPrint(
                                                        results: results,
                                                        share: false,
                                                        index: index,
                                                        winPoints:
                                                            results[index]
                                                                .winPrice
                                                                .floor(),
                                                        playPoints:
                                                            results[index]
                                                                .ticketPrice
                                                                .floor(),
                                                        totalClaimPoints:
                                                            results[index]
                                                                .totalWinPrice
                                                                .floor(),
                                                        claimTime:
                                                            formattedClaimTime, // Pass the formatted claim time here
                                                        jackpotWinPoints:
                                                            results[index]
                                                                .jackpotPrice
                                                                .floor(),
                                                        drawId: results[index]
                                                            .drawPlayGroupId,
                                                        barcodeId:
                                                            results[index]
                                                                .barCode,
                                                      );
                                                    } else {
                                                      // ignore: use_build_context_synchronously
                                                      showSnackBar(context,
                                                          "Check your internet connection");
                                                    }
                                                  } catch (error, stackTrace) {
                                                    debugPrint(
                                                        "Error in claiming: $stackTrace");

                                                    if (!mounted) return;

                                                    setState(() {
                                                      showLoadingOverlay =
                                                          false;
                                                      // results[index].claim =
                                                      //     0; // Reset claim status on failure
                                                    });

                                                    showFailed(
                                                      // ignore: use_build_context_synchronously
                                                      context,
                                                      "Claim Failed",
                                                      "We're sorry, your claim was unsuccessful.",
                                                      "Reason: $error",
                                                    );
                                                  }
                                                }
                                              : null,
                                          child: const Text("Claim"),
                                        )
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
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
          items = [];
          isLoading = true;
        });
        await ref
            .watch(wonProvider3d(UserResultsParams(
          claimStatus: claimStatus,
          categoryId: widget.categoryId,
          gameId: ref.watch(filterMyLotteriesProvider),
          fromDate: (_startDate.millisecondsSinceEpoch),
          toDate: (_endDate.millisecondsSinceEpoch),
          resultType: 3,
          page: pageNo - 1,
        )).future)
            .then((value) {
          setState(() {
            previousDropSelection = dropdownValue;
            unClaimedTickets = value.unClaimedTickets;
            unClaimedPrice = value.unClaimedPrice;
            if (value.totalPages != 0) {
              items = List<int>.generate(value.totalPages, (i) => i + 1);
            }

            searchedStartDate = DateFormat('dd-MM-yyyy').format(_startDate);
            searchedEndDate = DateFormat('dd-MM-yyyy').format(_endDate);
            results = value.results;
            // Sort results by purchaseTime in descending order (most recent first)
            results.sort((a, b) {
              DateTime aTime =
                  DateFormat("yyyy-MM-dd hh:mm:ss a").parse(a.time);
              DateTime bTime =
                  DateFormat("yyyy-MM-dd hh:mm:ss a").parse(b.time);
              return bTime.compareTo(aTime); // Descending order
            });
            isLoading = false;

            claimAllEnable = results.any((result) => result.claim == 0);
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

  Future<void> wonProviderCallFunction() async {
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
        .refresh(wonProvider3d(userResultSearchParams).future)
        .then((value) => setState(() {
              results = value.results;
            }))
        .onError((error, stackTrace) {
      ExceptionHandler.showSnack(errorCode: error.toString(), context: context);
    });
  }

  void onCheckPrint(
      {required List<Result> results,
      required bool share,
      required int index,
      required int winPoints,
      required String claimTime,
      required int playPoints,
      required int totalClaimPoints,
      required int jackpotWinPoints,
      required String drawId,
      required String barcodeId}) async {
    const double globalFontSize = 9.0; // Increased font size for better clarity
    final font = await PdfGoogleFonts
        .notoSansRegular(); // Using a bold font for better visibility

    final pdf = pw.Document(
        version: PdfVersion.pdf_1_5); // Higher PDF version for quality

    String userName = SharedPref.instance.getString("username") ?? "-";

    // Conditionally include Normal Win Points and Jackpot Win Points based on jackpotWinPoints value
    String address = jackpotWinPoints == 0
        ? 'Retailer: $userName\r\nDraw Id: $drawId\r\nBarcode Id: $barcodeId\r\nClaim Time: $claimTime \r\nPlay Points: $playPoints \r\nTotal Claim Points: $totalClaimPoints'
        : 'Retailer: $userName\r\nDraw Id: $drawId\r\nBarcode Id: $barcodeId\r\nClaim Time: $claimTime \r\nPlay Points: $playPoints \r\nNormal Win Points: $winPoints \r\nJackpot Win Points: $jackpotWinPoints \r\nTotal Claim Points: $totalClaimPoints';

    pdf.addPage(pw.MultiPage(
      pageFormat: PdfPageFormat
          .a4, // A4 format to ensure high quality (adjust based on your paper size)
      margin: pw.EdgeInsets.only(
          left: selectedPaperSize == PaperSelect.Size57 ? 0 : 12),
      build: (final context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(currentName,
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text('(For Amusement Purpose Only)',
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text("Game name: ${results[index].gameName}",
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text(address,
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
          ],
        ),
        pw.SizedBox(
          width: 100,
          height: 40,
          child: pw.BarcodeWidget(
              barcode: pw.Barcode.code128(), data: results[index].barCode!),
        ),
        pw.Text(
          '**Ticket not for sale**',
          style: pw.TextStyle(fontSize: globalFontSize, font: font),
        ),
      ],
    ));

    if (!share) {
      if (Platform.isAndroid) {
        Printing.layoutPdf(onLayout: (format) async => pdf.save());
      } else {
        await Printing.directPrintPdf(
            printer: defaultPrinter!, onLayout: (format) async => pdf.save());
      }
    } else {
      final bytes = await pdf.save();
      Printing.sharePdf(bytes: bytes);
    }
  }
}
