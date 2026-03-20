import 'dart:io';

import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:psglotto/model/user_result_2d.dart' as ur;
import 'package:psglotto/model/game.dart' as g;
import 'package:psglotto/params/cancel_ticket_params.dart';
import 'package:psglotto/params/cancel_ticket_with_barcode_params.dart';
import 'package:psglotto/provider/lotto_clock_provider.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/settings_services/shared_preferences.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/utils/game_constant.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:series_2d/utils/constants.dart';
import 'package:series_2d/utils/game_data_constant.dart';

import '../../../../params/user_results_params.dart';
import '../../../../provider/providers.dart';
import '../../../utils/constants.dart';
import '../../../utils/helper.dart';
import '../../my_lotteries/ticket_view_page.dart';
import '../../snackbar.dart';
import 'my_lotteries_game_type_2d.dart';
import 'package:pdf/widgets.dart' as pw;

class ToBeDrawnView2D extends ConsumerStatefulWidget {
  final int categoryId;
  final String? gameId;

  const ToBeDrawnView2D({Key? key, this.gameId, required this.categoryId})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _ToBeDrawnView2DState createState() => _ToBeDrawnView2DState();
}

class _ToBeDrawnView2DState extends ConsumerState<ToBeDrawnView2D> {
  late DateTime _startDate;
  late DateTime _endDate;

  TextEditingController barcodeCancelTicketController = TextEditingController();
  String searchedStartDate = "";
  String searchedEndDate = "";
  ScrollController? _parentScrollController;
  ScrollController? _childScrollController;

  int pageNo = 1;

  // List of items in our dropdown menu
  var items = [
    1,
  ];
  Printer? defaultPrinter;
  List<ur.Result> results = [];
  final preferenceService = PreferencesServices();
  var selectedPaperSize = PaperSelect.Size57;
  bool isLoading = false;
  bool showLoadingOverlay = false;
  List<Printer> printers = [];
  List<String> options = ['2 Inc', '3 Inc'];
  String optionPrintType = '2 Inc';

  @override
  void initState() {
    debugPrint("Calling to be drawn ====> ${widget.gameId}");
    super.initState();
    populateFileds();
    setupPrinter();
    initializeDates();
    _parentScrollController = ScrollController();
    _childScrollController = ScrollController()..addListener(_scrollListener);
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
    return SingleChildScrollView(
        controller: _parentScrollController,
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(color: Colors.white),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Type",
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                gameAsyncData.when(
                  data: (data) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      final selectedGameId =
                          ref.read(filterMyLotteriesProvider);

                      if (data.isNotEmpty && selectedGameId.isEmpty) {
                        // If widget.gameId is null → use first value
                        final matchedGame = widget.gameId != null
                            ? data.firstWhere(
                                (e) => e.gameId == widget.gameId,
                                orElse: () => data.first,
                              )
                            : data.first;

                        ref
                            .read(filterMyLotteriesProvider.notifier)
                            .setResultFilter(matchedGame.gameId ?? "-");
                        if (widget.gameId != null) searchResult();
                      }
                    });

                    return Wrap(
                      children: [
                        ...data.map(
                          (e) => MyLotteriesGameTypeWidget2D(
                            gameName: e.gameName ?? "-",
                            gameId: e.gameId ?? "-",
                          ),
                        ),
                      ],
                    );
                  },
                  error: (error, s) {
                    ExceptionHandler.showSnack(
                        errorCode: error.toString(), context: context);
                    return const Text("Something went wrong");
                  },
                  loading: () {
                    return const CircularProgressIndicator();
                  },
                )
              ],
            ),
          ),
          const SizedBox(
            height: 10.0,
          ),
          GestureDetector(
            onTap: () async {
              final lottoDateTime =
                  DateTime.fromMillisecondsSinceEpoch(lottoCurrentTimeServer);
              final adjustedLottoDateTime =
                  lottoDateTime.add(const Duration(days: 29));
              final picked = await showDateRangePicker(
                  context: context,
                  firstDate: lottoDateTime,
                  lastDate: adjustedLottoDateTime,
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
                    style:
                        TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
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
                        child:
                            Text(DateFormat('dd-MM-yyyy').format(_startDate)),
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
                        child: Text(DateFormat('dd-MM-yyyy').format(_endDate)),
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
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(8.0),
            decoration: const BoxDecoration(color: Colors.transparent),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisSize: MainAxisSize.min,
              children: [
                Column(
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
                        GameConstant.selectedGameId == "2d-series"
                            ? Container(
                                color: Colors.transparent,
                                width: 350,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    SizedBox(
                                        width: 200,
                                        child: TextFormField(
                                          controller:
                                              barcodeCancelTicketController,
                                          decoration: InputDecoration(
                                            prefixIcon: const Icon(Icons
                                                .barcode_reader), // Icon added to the left side
                                            hintText: 'Enter Barcode',
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10.0),
                                            ),
                                          ),
                                          onEditingComplete: () async {
                                            bool networkStatus = await Helper
                                                .checkNetworkConnection();

                                            if (networkStatus) {
                                              if (results.isNotEmpty) {
                                                showDialog(
                                                  // ignore: use_build_context_synchronously
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Confirmation"),
                                                      content: const Text(
                                                          "Are you sure you want to cancel the ticket?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                          child: const Text(
                                                              "Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          },
                                                          child:
                                                              const Text("Yes"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ).then((confirmed) async {
                                                  if (confirmed) {
                                                    await ref
                                                        .watch(
                                                            cancelTicketWithBarcodeProvider(
                                                      CancelTicketWithBarcodeParams(
                                                        categoryId: 2,
                                                        gameId: GameConstant
                                                            .selectedGameId,
                                                        barcode:
                                                            barcodeCancelTicketController
                                                                .text,
                                                      ),
                                                    ).future)
                                                        .then((value) {
                                                      if (value.errorCode ==
                                                          0) {
                                                        searchResult();
                                                        barcodeCancelTicketController
                                                            .clear();
                                                        showSnackBar(context,
                                                            "Successfully Cancelled Ticket With Barcode");
                                                        debugPrint(
                                                            "Success: ${value.errorCode}");
                                                      } else {
                                                        debugPrint(
                                                            "Error: ${value.errorCode}");
                                                        ExceptionHandler
                                                            .showSnack(
                                                          errorCode: value
                                                              .errorCode
                                                              .toString(),
                                                          context: context,
                                                        );
                                                      }
                                                    }).catchError((error) {
                                                      barcodeCancelTicketController
                                                          .clear();
                                                      ExceptionHandler
                                                          .showSnack(
                                                        errorCode:
                                                            error.toString(),
                                                        context: context,
                                                      );
                                                      debugPrint(
                                                          "Error during asynchronous operation: $error");
                                                    });
                                                  }
                                                });
                                              } else {
                                                // ignore: use_build_context_synchronously
                                                showSnackBar(context,
                                                    "No Tickets for Cancel");
                                              }
                                            } else {
                                              // ignore: use_build_context_synchronously
                                              showSnackBar(context,
                                                  "Check your internet connection");
                                            }
                                          },
                                        )),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink()
                      ],
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
                const SizedBox(
                  height: 10.0,
                ),
                results.isNotEmpty
                    ? Container(
                        color: Colors.transparent,
                        width: MediaQuery.of(context).size.width,
                        height: MediaQuery.of(context).size.height,
                        child: DataTable2(
                          scrollController: _childScrollController,
                          columnSpacing: 1,
                          horizontalMargin: 1,
                          dividerThickness: 0.1,
                          minWidth: MediaQuery.of(context).size.width * 0.90,
                          columns: [
                            const DataColumn2(
                                label: Center(child: Text("Draw ID"))),
                            const DataColumn2(
                                label: Center(child: Text("Barcode"))),
                            const DataColumn2(
                                size: ColumnSize.L,
                                label: Center(child: Text("Ticket Number"))),
                            const DataColumn2(
                                label: Center(child: Text("Draw Time"))),
                            if (GameConstant.selectedGameId != "2d")
                              const DataColumn2(
                                  label: Center(child: Text("Cancel Ticket"))),
                            const DataColumn2(
                                label: Center(child: Text("Re-Print"))),
                          ],
                          rows: List<DataRow>.generate(
                              results.length,
                              (index) => DataRow(cells: [
                                    DataCell(Center(
                                      child: Text(
                                          results[index].drawPlayGroupId ??
                                              "-"),
                                    )),
                                    DataCell(Center(
                                        child: Text(
                                            results[index].barCode ?? "-"))),
                                    DataCell(
                                      Center(
                                        child: ElevatedButton(
                                            onPressed: () async {
                                              bool networkStatus = await Helper
                                                  .checkNetworkConnection();
                                              if (networkStatus) {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        TicketViewPage(
                                                      showWinNoHeader: false,
                                                      playPoints: results[index]
                                                          .ticketPrice!,
                                                      winPrice: results[index]
                                                          .winPrice!,
                                                      jackpotPrice:
                                                          results[index]
                                                              .jackpotPrice!,
                                                      totalWinPrice:
                                                          results[index]
                                                              .totalWinPrice!,
                                                      gameId: results[index]
                                                          .gameId!,
                                                      resultShow: false,
                                                      barcode: results[index]
                                                          .barCode!,
                                                      purchaseTime:
                                                          results[index]
                                                              .purchaseTime!,
                                                      gameName: results[index]
                                                          .gameName!,
                                                      price:
                                                          results[index].price!,
                                                      ticketNo: results[index]
                                                          .ticketNo!,
                                                      drawTime:
                                                          results[index].time!,
                                                      drawPlayGroupId:
                                                          results[index]
                                                              .drawPlayGroupId!,
                                                      drawId: results[index]
                                                          .drawId!,
                                                      result: results,
                                                      selectionIndex: index,
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                // ignore: use_build_context_synchronously
                                                showSnackBar(context,
                                                    "Check your internet connection");
                                              }
                                            },
                                            child: const Text("View")),
                                      ),
                                    ),
                                    DataCell(
                                      Center(
                                        child: Text(results[index].time!),
                                      ),
                                    ),
                                    if (GameConstant.selectedGameId != "2d")
                                      DataCell(
                                        Center(
                                          child: IconButton(
                                            onPressed: () async {
                                              bool networkStatus = await Helper
                                                  .checkNetworkConnection();

                                              if (networkStatus) {
                                                showDialog(
                                                  // ignore: use_build_context_synchronously
                                                  context: context,
                                                  builder:
                                                      (BuildContext context) {
                                                    return AlertDialog(
                                                      title: const Text(
                                                          "Confirmation"),
                                                      content: const Text(
                                                          "Are you sure you want to cancel this ticket?"),
                                                      actions: [
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(false);
                                                          },
                                                          child: const Text(
                                                              "Cancel"),
                                                        ),
                                                        TextButton(
                                                          onPressed: () {
                                                            Navigator.of(
                                                                    context)
                                                                .pop(true);
                                                          },
                                                          child:
                                                              const Text("Yes"),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                ).then((confirmed) async {
                                                  if (confirmed) {
                                                    // Perform deletion logic here
                                                    await ref
                                                        .watch(cancelTicketProvider(
                                                            CancelTicketParams(
                                                      categoryId: 2,
                                                      gameId: results[index]
                                                          .gameId!,
                                                      drawId: results[index]
                                                          .drawId!,
                                                      ticketId: results[index]
                                                          .ticketId!,
                                                    )).future)
                                                        .then((value) {
                                                      if (value.errorCode ==
                                                          0) {
                                                        searchResult();
                                                        onCheckPrint(
                                                            gameID: gameId,
                                                            cancelTicket: true,
                                                            results: results,
                                                            share: false,
                                                            index: index);
                                                        showSnackBar(context,
                                                            "Successfully Cancelled the Ticket");
                                                      } else {
                                                        ExceptionHandler
                                                            .showSnack(
                                                          errorCode: value
                                                              .errorCode
                                                              .toString(),
                                                          context: context,
                                                        );
                                                      }
                                                    }).onError((error,
                                                                stackTrace) =>
                                                            ExceptionHandler
                                                                .showSnack(
                                                              errorCode: error
                                                                  .toString(),
                                                              context: context,
                                                            ));
                                                  }
                                                });
                                              } else {
                                                // ignore: use_build_context_synchronously
                                                showSnackBar(context,
                                                    "Check your internet connection");
                                              }
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              color: Colors.red,
                                            ),
                                          ),
                                        ),
                                      ),
                                    DataCell(
                                      Center(
                                        child: isPrintingList[index]
                                            ? CircularProgressIndicator()
                                            : IconButton(
                                                onPressed: () {
                                                  setState(() {
                                                    isPrintingList[index] =
                                                        true;
                                                  });
                                                  onCheckPrint(
                                                      gameID: gameId,
                                                      cancelTicket: false,
                                                      results: results,
                                                      share: false,
                                                      index: index);
                                                },
                                                icon: Icon(
                                                  Icons.print,
                                                  color: kPrimarySeedColor,
                                                )),
                                      ),
                                    ),
                                  ])),
                        ),
                      )
                    : isLoading
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : const SizedBox.shrink(),
              ],
            ),
          )
        ]));
  }

  void searchResult() async {
    bool networkStatus = await Helper.checkNetworkConnection();

    if (networkStatus) {
      results.clear();

      if (ref.watch(filterMyLotteriesProvider).isNotEmpty) {
        UserResultsParams userResultSearchParams = UserResultsParams(
          claimStatus: 0,
          categoryId: widget.categoryId,
          gameId: ref.watch(filterMyLotteriesProvider),
          fromDate: (_startDate.millisecondsSinceEpoch),
          toDate: (_endDate.millisecondsSinceEpoch),
          page: pageNo - 1,
          resultType: 1,
        );

        setState(() {
          isLoading = true;
          items = [];
        });

        await ref
            .watch(toBeDrawnProvider2d(userResultSearchParams).future)
            .then((value) {
          if (!mounted) {
            return;
          }
          setState(() {
            isPrintingList =
                List.generate(value.results!.length, (index) => false);
            if (value.totalPages != 0) {
              items = List<int>.generate(value.totalPages!, (i) => i + 1);
            }

            searchedStartDate = DateFormat('dd-MM-yyyy').format(_startDate);
            searchedEndDate = DateFormat('dd-MM-yyyy').format(_endDate);

            // Assign the results to the results list
            results = value.results!;
            DateTime lottoDateTime =
                DateTime.fromMillisecondsSinceEpoch(lottoCurrentTimeServer);

            // Get the current time
            final DateTime currentTime = lottoDateTime;

            // Filter and sort the results based on time
            results = results.where((ticket) {
              DateTime ticketTime =
                  DateFormat('yyyy-MM-dd hh:mm:ss a').parse(ticket.time!);
              return ticketTime
                  .isAfter(currentTime); // Keep only future tickets
            }).toList();

            // Sort by time, and for tickets with the same time, sort by purchase time
            results.sort((a, b) {
              DateTime timeA =
                  DateFormat('yyyy-MM-dd hh:mm:ss a').parse(a.time!);
              DateTime timeB =
                  DateFormat('yyyy-MM-dd hh:mm:ss a').parse(b.time!);
              int timeComparison = timeA.compareTo(timeB);

              // If times are equal, compare purchase times
              if (timeComparison == 0) {
                DateTime purchaseTimeA =
                    DateFormat('yyyy-MM-dd hh:mm:ss a').parse(a.purchaseTime!);
                DateTime purchaseTimeB =
                    DateFormat('yyyy-MM-dd hh:mm:ss a').parse(b.purchaseTime!);
                return purchaseTimeB.compareTo(
                    purchaseTimeA); // Sort purchaseTime in ascending order
              }

              return timeComparison;
            });

            isLoading = false;
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

  void onCheckPrint(
      {required List<ur.Result> results,
      required bool share,
      required int index,
      required String gameID,
      required bool cancelTicket}) async {
    const double globalFontSize = 8.0;
    final font = await PdfGoogleFonts.robotoFlexRegular();

    final pdf = pw.Document(version: PdfVersion.pdf_1_4);

    String userName = SharedPref.instance.getString("username") ?? "-";
    String address =
        'Retailer: $userName\r\nDraw Date: ${results[index].time!}';
    int totalTicketNo = 0;

    for (final ticket in results[index].ticketNo!) {
      if (ticket.betTypes != null) {
        for (final betTypes in ticket.betTypes!.values) {
          totalTicketNo += betTypes.values.fold(0, (sum, count) => sum + count);
        }
      }
    }

    pdf.addPage(pw.MultiPage(
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
            cancelTicket
                ? pw.Text('(CANCEL RECEIPT)',
                    style: pw.TextStyle(fontSize: globalFontSize, font: font))
                : pw.SizedBox.shrink(),
            pw.Text("Game name: ${results[index].gameName}",
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text(address,
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text('Draw Id: ${results[index].drawPlayGroupId}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text('Barcode Id: ${results[index].barCode}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text(
                'Total Qty: $totalTicketNo   Total Points: ${results[index].ticketPrice!.toStringAsFixed(0)}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
          ],
        ),
        pw.ListView.builder(
          itemCount: results.length > index ? 1 : 0,
          itemBuilder: (context, _) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              mainAxisAlignment: pw.MainAxisAlignment.start,
              children: [
                pw.ListView.builder(
                  itemCount: results[index].ticketNo?.length ?? 0,
                  itemBuilder: (context, i) {
                    final ticketNo = results[index].ticketNo![i];
                    int totalQuantitySeperated = 0;
                    num totalPriceSeperated = 0;

                    //Sort by betTypes by keys
                    final sortedBetTypes = ticketNo.betTypes?.map((key, value) {
                      final sortedEntries = Map.fromEntries(
                          value.entries.toList()
                            ..sort((a, b) => a.key.compareTo(b.key)));
                      return MapEntry(key, sortedEntries);
                    });
                    // Extract sorted numbers
                    final numbers = sortedBetTypes?.values
                            .expand((e) => e.entries)
                            .map((entry) {
                          final quantity =
                              int.tryParse(entry.value.toString()) ?? 0;
                          totalQuantitySeperated += quantity;
                          return '${entry.key}-$quantity';
                        }).toList() ??
                        [];

                    // final numbers = ticketNo.betTypes?.values
                    //         .expand((e) => e.entries)
                    //         .map((entry) {
                    //       final quantity =
                    //           int.tryParse(entry.value.toString()) ?? 0;
                    //       totalQuantitySeperated += quantity;
                    //       return '${entry.key}-$quantity';
                    //     }).toList() ??
                    //     [];

                    totalPriceSeperated =
                        (ticketNo.price ?? 0) * totalQuantitySeperated;

                    final List<List<String>> rows = [];
                    for (int j = 0;
                        j < numbers.length;
                        j += selectedPaperSize == PaperSelect.Size57 ? 3 : 5) {
                      int newNumber =
                          selectedPaperSize == PaperSelect.Size57 ? 3 : 5;
                      rows.add(numbers.sublist(
                          j, (j + newNumber).clamp(0, numbers.length)));
                    }

                    return pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Row(
                          children: [
                            gameId == "2d-super"
                                ? pw.Text(
                                    'Play(${ticketNo.price!.toStringAsFixed(0)})',
                                    style: pw.TextStyle(
                                        fontSize: globalFontSize, font: font),
                                  )
                                : pw.Text(
                                    '${ticketNo.typeName}',
                                    style: pw.TextStyle(
                                        fontSize: globalFontSize, font: font),
                                  ),
                            gameId == "2d-super"
                                ? pw.Text(
                                    ' Qty: $totalQuantitySeperated Points: ${totalPriceSeperated.toStringAsFixed(0)}',
                                    style: pw.TextStyle(
                                        fontSize: globalFontSize, font: font),
                                  )
                                : pw.Text(
                                    '(${ticketNo.price!.toStringAsFixed(0)})  Qty: $totalQuantitySeperated Points: ${totalPriceSeperated.toStringAsFixed(0)}',
                                    style: pw.TextStyle(
                                        fontSize: globalFontSize, font: font),
                                  ),
                          ],
                        ),
                        ...rows.map((row) {
                          return pw.Text(
                            row.join('  '),
                            style: pw.TextStyle(
                                fontSize: globalFontSize, font: font),
                          );
                        }),
                      ],
                    );
                  },
                ),
              ],
            );
          },
        ),
        isBarcode
            ? pw.SizedBox(
                width: 100,
                height: 40,
                child: pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(),
                    data: results[index].barCode!),
              )
            : pw.SizedBox.shrink(),
        pw.Text(
          '**Ticket not for sale**',
          style: pw.TextStyle(fontSize: globalFontSize, font: font),
        ),
        !cancelTicket
            ? pw.Text(
                '**Duplicate Ticket**',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
              )
            : pw.SizedBox.shrink()
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
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isPrintingList[index] = false; // Unlock after 2 seconds
      });
    });
  }

  void _scrollListener() {
    if (_childScrollController!.position.atEdge) {
      if (_childScrollController!.position.pixels == 0) {
        // At the top
        debugPrint("Scrolled to the top");
        if (_parentScrollController!.hasClients) {
          _parentScrollController!.jumpTo(0);
        }
      } else {
        // At the bottom
        debugPrint("Scrolled to the bottom");
      }
    }
  }

  @override
  void dispose() {
    _childScrollController!.removeListener(_scrollListener);
    _childScrollController!.dispose();
    _parentScrollController!.dispose(); // Dispose the outer scroll controller
    super.dispose();
  }
}
