// ignore_for_file: file_names
import 'dart:io';
// import 'package:auto_size_text/auto_size_text.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:number_paginator/number_paginator.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:psglotto/params/sale_params.dart';
import 'package:psglotto/provider/lotto_clock_provider.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/settings_services/shared_preferences.dart';
import 'package:psglotto/utils/exception_handler.dart';
// import 'package:psglotto/utils/shared_preference.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/custom_layout.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/utils/network_check_helper.dart';
import 'package:psglotto/view/utils/over_lay.dart';
// import 'package:psglotto/view/utils/scroll_controller.dart';
// import 'package:psglotto/view/widgets/loading_overlay.dart';
import 'package:psglotto/view/widgets/snackbar.dart';
// import '../Utils/widget_helper.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
// import 'custom_layout.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:psglotto/model/sale_report_models.dart' as salereport;
import 'package:series_2d/utils/game_data_constant.dart';

class SaleReportScreen extends ConsumerStatefulWidget {
  const SaleReportScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<SaleReportScreen> createState() => _SaleReportScreenState();
}

class _SaleReportScreenState extends ConsumerState<SaleReportScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  String searchedStartDate = "";
  String searchedEndDate = "";
  final preferenceService = PreferencesServices();
  var selectedPaperSize = PaperSelect.Size57;
  TextEditingController dateinput1 = TextEditingController();
  TextEditingController dateinput2 = TextEditingController();
  ScrollController scrollController = ScrollController();

  String startData = '';
  String endDate = '';
  bool showLoadingOverlay = false;

  List<salereport.Result> saleReportResult = [];

  int page = 0;
  double? playPoints;
  double? winPoints;
  double? margin;
  double? net;
  String loginUserCode = '';
  int numberOfPage = 1;
  int currentTime = 0;
  int startPrintDate = 0;
  int endPrintDate = 0;
  //pagination
  List<int> pageNumbers = [];
  String selectedCustomerTypeName = "";

  Printer? defaultPrinter;
  List<Printer> printers = [];
  List<String> options = ['2 Inc', '3 Inc'];
  String optionPrintType = '2 Inc';
  final lottoDateTime =
      DateTime.fromMillisecondsSinceEpoch(lottoCurrentTimeServer);
  String startDate = DateTime.now().toString();
  @override
  void initState() {
    super.initState();

    setupPrinter();
    populateFileds();
    defaultDate();
    initializeDates();
  }

  void initializeDates() {
    setState(() {
      // Use current date for startDate and endDate
      DateTime now = DateTime.now();
      startDate = DateFormat('yyyy-MM-dd 00:00:00')
          .format(now); // Start date at midnight
      endDate = DateFormat('yyyy-MM-dd 23:59:59')
          .format(now); // End date at the last moment of the day

      // Update the _startDate and _endDate variables to reflect the selected date range
      _startDate =
          DateTime(now.year, now.month, now.day); // Current date at midnight
      _endDate = DateTime(
          now.year, now.month, now.day, 23, 59, 59); // Current date at 23:59:59
    });
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

  //Select date
  dynamic pickedDate;
  Future<void> _selectDate(TextEditingController control) async {
    pickedDate = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: lottoDateTime, // Ensure users can't pick future dates
      currentDate: lottoDateTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.light(primary: kPrimarySeedColor!),
          ),
          child: Align(
            alignment: Alignment.center,
            child: Container(
              // ignore: deprecated_member_use
              color: Colors.transparent,

              width: MediaQuery.of(context).size.width * 0.5,
              height:
                  MediaQuery.of(context).size.height * 0.8, // Limit max height
              child: Center(
                child: SingleChildScrollView(
                  // Enable scrolling if content overflows
                  physics: NeverScrollableScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _dateButton("Today", () {
                                _setDateRange(
                                    lottoDateTime, lottoDateTime, control);
                              }),
                              const SizedBox(height: 8),
                              _dateButton("Yesterday", () {
                                _setDateRange(
                                    lottoDateTime
                                        .subtract(const Duration(days: 1)),
                                    lottoDateTime
                                        .subtract(const Duration(days: 1)),
                                    control);
                              }),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _dateButton("This Week", () {
                                final now = lottoDateTime;
                                final startOfWeek = now
                                    .subtract(Duration(days: now.weekday - 1));
                                final endOfWeek =
                                    now.add(Duration(days: 7 - now.weekday));
                                _setDateRange(startOfWeek, endOfWeek, control);
                              }),
                              const SizedBox(height: 8),
                              _dateButton("Last Week", () {
                                final now = lottoDateTime;
                                final startOfLastWeek = now
                                    .subtract(Duration(days: now.weekday + 7));
                                final endOfLastWeek = now
                                    .subtract(Duration(days: now.weekday + 1));
                                _setDateRange(
                                    startOfLastWeek, endOfLastWeek, control);
                              }),
                            ],
                          ),
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _dateButton("This Month", () {
                                final now = lottoDateTime;
                                final startOfMonth =
                                    DateTime(now.year, now.month);
                                final endOfMonth =
                                    DateTime(now.year, now.month + 1, 0);
                                _setDateRange(
                                    startOfMonth, endOfMonth, control);
                              }),
                              const SizedBox(height: 8),
                              _dateButton("Last Month", () {
                                final now = lottoDateTime;
                                final lastMonth =
                                    DateTime(now.year, now.month - 1);
                                final startOfLastMonth =
                                    DateTime(lastMonth.year, lastMonth.month);
                                final endOfLastMonth = DateTime(
                                    lastMonth.year, lastMonth.month + 1, 0);
                                _setDateRange(
                                    startOfLastMonth, endOfLastMonth, control);
                              }),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (child != null) child, // Show the default date picker
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    if (pickedDate != null) {
      _updateDateSelection(control);
    }
  }

  Widget _dateButton(String text, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: kPrimarySeedColor),
        onPressed: onPressed,
        child: Text(text),
      ),
    );
  }

  void _setDateRange(
      DateTime start, DateTime end, TextEditingController control) {
    setState(() {
      control.text =
          '${DateFormat('yyyy-MM-dd').format(start)} to ${DateFormat('yyyy-MM-dd').format(end)}';
      dateinput1.text = DateFormat('yyyy-MM-dd').format(start);
      dateinput2.text = DateFormat('yyyy-MM-dd').format(end);
      startDate = DateFormat('yyyy-MM-dd 00:00:00').format(start);
      endDate = DateFormat('yyyy-MM-dd 23:59:59').format(end);
    });
    Navigator.pop(context);
  }

 void _updateDateSelection(TextEditingController control) {
  if (pickedDate is DateTimeRange) {
    final DateTimeRange range = pickedDate;
    final startDateFormatted = DateFormat('yyyy-MM-dd').format(range.start);
    final endDateFormatted = DateFormat('yyyy-MM-dd').format(range.end);
    
    setState(() {
      control.text = '$startDateFormatted to $endDateFormatted';
      dateinput1.text = startDateFormatted;
      dateinput2.text = endDateFormatted;
      startDate = "$startDateFormatted 00:00:00";
      endDate = "$endDateFormatted 23:59:59";
    });
  } else if (pickedDate is DateTime) {
    final formattedDate = DateFormat('yyyy-MM-dd').format(pickedDate);

    setState(() {
      control.text = formattedDate;
      if (control == dateinput1) {
        startDate = "$formattedDate 00:00:00";
      } else if (control == dateinput2) {
        endDate = "$formattedDate 23:59:59";
      }
    });
  }
}


  int? sortColumnIndex;
  bool sortAscending = true;

  void defaultDate() {
    return setState(() {
      final today = DateTime.now(); // Use current date and time
      dateinput1.text = DateFormat('yyyy-MM-dd').format(today);
      dateinput2.text = DateFormat('yyyy-MM-dd').format(today);
      startDate = DateFormat('yyyy-MM-dd 00:00:00').format(today);
      endDate = DateFormat('yyyy-MM-dd 23:59:59').format(today);
    });
  }

  @override
  Widget build(BuildContext context) {
    // ignore: deprecated_member_use
    return SafeArea(
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            centerTitle: true,
            title: const Text("My Sale Report"),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Center(
                    child: Text(
                  userName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )),
              )
            ],
          ),
          body: AbsorbPointer(
              absorbing: showLoadingOverlay ? true : false,
              child: Stack(children: [
                Responsive.isDesktop(context)
                    ? Row(
                        children: [
                          Container(
                            color: Colors.white24,
                            height: MediaQuery.of(context).size.height,
                            width: MediaQuery.of(context).size.width * 0.30,
                            child: Column(
                              children: [
                                selectDate(),
                                const SizedBox(
                                  height: 10,
                                ),
                                searchAndClearButton(context),
                                const SizedBox(height: 50),
                                saleReportResult.isNotEmpty
                                    ? totalUserWithPagination(context)
                                    : const SizedBox.shrink(),
                              ],
                            ),
                          ),
                          Expanded(
                            child: Column(children: [
                              Expanded(
                                flex: 8,
                                child: Container(
                                  color: Colors.transparent,
                                  height: MediaQuery.of(context).size.height,
                                  width:
                                      MediaQuery.of(context).size.width * 0.70,
                                  child: saleReportResult.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "No Data Available...",
                                            style:
                                                TextStyle(color: Colors.black),
                                          ),
                                        )
                                      : DataTable2(
                                          showBottomBorder: true,
                                          border: TableBorder.symmetric(
                                              outside: BorderSide(
                                                  color: kPrimarySeedColor!)),
                                          headingRowColor:
                                              WidgetStateColor.resolveWith(
                                                  (states) =>
                                                      kPrimarySeedColor!),
                                          columnSpacing: 10,
                                          sortColumnIndex: sortColumnIndex,
                                          sortAscending: sortAscending,
                                          horizontalMargin: 10,
                                          dividerThickness: 0.5,
                                          columns: [
                                            const DataColumn2(
                                              size: ColumnSize.S,
                                              label: Text("S.no",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                            DataColumn2(
                                                size: ColumnSize.L,
                                                onSort:
                                                    (columnIndex, ascending) {
                                                  setState(() {
                                                    if (sortColumnIndex ==
                                                        columnIndex) {
                                                      // If the same column is clicked again, reverse the sort order
                                                      sortAscending =
                                                          !sortAscending;
                                                    } else {
                                                      sortColumnIndex =
                                                          columnIndex;
                                                      sortAscending = ascending;
                                                    }
                                                    saleReportResult.sort((a,
                                                            b) =>
                                                        (a.playPoints ?? 0)
                                                            .compareTo(
                                                                b.playPoints ??
                                                                    0));
                                                    if (!sortAscending) {
                                                      saleReportResult =
                                                          saleReportResult
                                                              .reversed
                                                              .toList();
                                                    }
                                                  });
                                                },
                                                label: const Text('Play Points',
                                                    style: TextStyle(
                                                        color: Colors.white))),
                                            DataColumn2(
                                                size: ColumnSize.L,
                                                onSort:
                                                    (columnIndex, ascending) {
                                                  setState(() {
                                                    if (sortColumnIndex ==
                                                        columnIndex) {
                                                      // If the same column is clicked again, reverse the sort order
                                                      sortAscending =
                                                          !sortAscending;
                                                    } else {
                                                      sortColumnIndex =
                                                          columnIndex;
                                                      sortAscending = ascending;
                                                    }
                                                    saleReportResult.sort((a,
                                                            b) =>
                                                        (a.winPoints ?? 0)
                                                            .compareTo(
                                                                b.winPoints ??
                                                                    0));
                                                    if (!sortAscending) {
                                                      saleReportResult =
                                                          saleReportResult
                                                              .reversed
                                                              .toList();
                                                    }
                                                  });
                                                },
                                                label: const Text('Win Points',
                                                    style: TextStyle(
                                                        color: Colors.white))),
                                            DataColumn2(
                                                size: ColumnSize.L,
                                                onSort:
                                                    (columnIndex, ascending) {
                                                  setState(() {
                                                    if (sortColumnIndex ==
                                                        columnIndex) {
                                                      // If the same column is clicked again, reverse the sort order
                                                      sortAscending =
                                                          !sortAscending;
                                                    } else {
                                                      sortColumnIndex =
                                                          columnIndex;
                                                      sortAscending = ascending;
                                                    }
                                                    saleReportResult.sort((a,
                                                            b) =>
                                                        (a.margin ?? 0)
                                                            .compareTo(
                                                                b.margin ?? 0));
                                                    if (!sortAscending) {
                                                      saleReportResult =
                                                          saleReportResult
                                                              .reversed
                                                              .toList();
                                                    }
                                                  });
                                                },
                                                label: const Text('Margin',
                                                    style: TextStyle(
                                                        color: Colors.white))),
                                            DataColumn2(
                                                size: ColumnSize.L,
                                                onSort:
                                                    (columnIndex, ascending) {
                                                  setState(() {
                                                    if (sortColumnIndex ==
                                                        columnIndex) {
                                                      // If the same column is clicked again, reverse the sort order
                                                      sortAscending =
                                                          !sortAscending;
                                                    } else {
                                                      sortColumnIndex =
                                                          columnIndex;
                                                      sortAscending = ascending;
                                                    }
                                                    saleReportResult.sort(
                                                        (a, b) => (a.net ?? 0)
                                                            .compareTo(
                                                                b.net ?? 0));
                                                    if (!sortAscending) {
                                                      saleReportResult =
                                                          saleReportResult
                                                              .reversed
                                                              .toList();
                                                    }
                                                  });
                                                },
                                                label: const Text('Net',
                                                    style: TextStyle(
                                                        color: Colors.white))),
                                            const DataColumn2(
                                                label: Text('',
                                                    style: TextStyle(
                                                        color: Colors.white))),
                                          ],
                                          rows: List<DataRow>.generate(
                                            saleReportResult.length,
                                            (index) {
                                              final rowIndex =
                                                  index + 1 + page * 100;
                                              var result =
                                                  saleReportResult[index];
                                              if (result.name != null ||
                                                  result.playPoints != null ||
                                                  result.winPoints != null ||
                                                  result.margin != null ||
                                                  result.net != null) {
                                                return DataRow(cells: [
                                                  DataCell(Text(
                                                      rowIndex.toString())),
                                                  DataCell(Text(result
                                                      .playPoints!
                                                      .floor()
                                                      .toString())),
                                                  DataCell(Text(result
                                                      .winPoints!
                                                      .floor()
                                                      .toString())),
                                                  DataCell(Text(result.margin
                                                          ?.toString() ??
                                                      '')),
                                                  DataCell(Text(
                                                      result.net?.toString() ??
                                                          '')),
                                                  const DataCell(Text('')),
                                                ]);
                                              }
                                              return const DataRow(
                                                  cells: []); // Return an empty DataRow if the conditions are not met to exclude the row
                                            },
                                          ),
                                        ),
                                ),
                              ),
                              Expanded(
                                flex: 1,
                                child: Container(
                                  color: Colors.transparent,
                                  width: double.maxFinite,
                                  child: saleReportResult.isEmpty
                                      ? const Center(
                                          child: Text(
                                            "",
                                          ),
                                        )
                                      : Container(
                                          decoration: BoxDecoration(
                                              border: const Border(
                                                bottom: BorderSide(
                                                  color: Colors
                                                      .white, // White border color
                                                  width:
                                                      2.0, // Width of the border
                                                ),
                                              ),
                                              color: kPrimarySeedColor),
                                          child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceAround,
                                              children: [
                                                const Align(
                                                    alignment:
                                                        Alignment.topCenter,
                                                    child: Text("TOTAL",
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ))),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceAround,
                                                    children: [
                                                      Text(
                                                          "PLAY POINTS: ${playPoints!.floor()}",
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text(
                                                        "WIN POINTS: ${winPoints!.floor()}",
                                                        style: const TextStyle(
                                                            color: Colors.white,
                                                            fontWeight:
                                                                FontWeight
                                                                    .bold),
                                                      ),
                                                      Text(
                                                          "MARGIN: ${margin ?? ""}",
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      Text("NET: ${net ?? ""}",
                                                          style: const TextStyle(
                                                              color:
                                                                  Colors.white,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold)),
                                                      ElevatedButton.icon(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .white),
                                                        ),
                                                        onPressed: () {
                                                          //  debugPrint("checking format: ${Helper.epocToYYYYMMddhms(startPrintDate)}");
                                                          onCheckPrint(
                                                            share: true,
                                                            saleReportResult:
                                                                saleReportResult,
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.share,
                                                          color:
                                                              kPrimarySeedColor,
                                                        ),
                                                        label: Text(
                                                          "Share",
                                                          style: TextStyle(
                                                              color:
                                                                  kPrimarySeedColor),
                                                        ),
                                                      ),
                                                      ElevatedButton.icon(
                                                        style: ButtonStyle(
                                                          backgroundColor:
                                                              WidgetStateProperty
                                                                  .all<Color>(
                                                                      Colors
                                                                          .white),
                                                        ),
                                                        onPressed: () {
                                                          //  debugPrint("checking format: ${Helper.epocToYYYYMMddhms(startPrintDate)}");
                                                          onCheckPrint(
                                                            share: false,
                                                            saleReportResult:
                                                                saleReportResult,
                                                          );
                                                        },
                                                        icon: Icon(
                                                          Icons.print,
                                                          color:
                                                              kPrimarySeedColor,
                                                        ),
                                                        label: Text(
                                                          "Print",
                                                          style: TextStyle(
                                                              color:
                                                                  kPrimarySeedColor),
                                                        ),
                                                      ),
                                                    ])
                                              ]),
                                        ),
                                ),
                              )
                            ]),
                          )
                        ],
                      )

                    // ====================THis is for Mobile sreen===============================//
                    : Responsive.isTablet(context)
                        ? Column(
                            children: [
                              const SizedBox(
                                height: 10.0,
                              ),
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  "Search Date",
                                  style: TextStyle(
                                      fontSize: 16.0,
                                      fontWeight: FontWeight.w600),
                                ),
                              ),
                              const SizedBox(
                                height: 10.0,
                              ),
                              Expanded(flex: 1, child: selectDate()),
                              Expanded(
                                  flex: 1,
                                  child: Row(
                                    children: [
                                      searchAndClearButton(context),
                                      Padding(
                                        padding:
                                            const EdgeInsets.only(left: 25.0),
                                        child: saleReportResult.isNotEmpty
                                            ? totalUserWithPagination(context)
                                            : const SizedBox.shrink(),
                                      )
                                    ],
                                  )),
                              Expanded(
                                flex: 3,
                                child: saleReportResult.isNotEmpty
                                    ? dataTable2Mobile()
                                    : const SizedBox.shrink(),
                              ),
                              Expanded(flex: 1, child: totalContainer()),
                            ],
                          )
                        : SingleChildScrollView(
                            physics: const NeverScrollableScrollPhysics(),
                            child: Container(
                              height: MediaQuery.of(context).size.height,
                              width: MediaQuery.of(context).size.width,
                              color: kPrimarySeedColor,
                              child: Column(
                                children: [
                                  Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.70,
                                    width: MediaQuery.of(context).size.width,
                                    color: Colors.white,
                                    child: Column(
                                      children: [
                                        Expanded(
                                          flex: 3,
                                          child: Column(children: [
                                            const SizedBox(
                                              height: 10.0,
                                            ),
                                            const Align(
                                              alignment: Alignment.centerLeft,
                                              child: Text(
                                                "Search Date",
                                                style: TextStyle(
                                                    fontSize: 16.0,
                                                    fontWeight:
                                                        FontWeight.w600),
                                              ),
                                            ),
                                            Expanded(
                                                flex: 1, child: selectDate()),
                                            searchAndClearButton(context),
                                          ]),
                                        ),
                                        Expanded(
                                          flex: 1,
                                          child: saleReportResult.isNotEmpty
                                              ? totalUserWithPagination(context)
                                              : const SizedBox.shrink(),
                                        ),
                                        Expanded(
                                            flex: 5,
                                            child: saleReportResult.isEmpty
                                                ? const Center(
                                                    child: Text(
                                                      "No Data Available...",
                                                      // style:
                                                      //     TextStyle(color: Colors.black),
                                                    ),
                                                  )
                                                : dataTable2Mobile())
                                      ],
                                    ),
                                  ),
                                  totalContainer()
                                ],
                              ),
                            ),
                          ),
                if (showLoadingOverlay) const MyOverlay(),
              ]))),
    );
  }

  Row selectDate() {
    return Row(
      children: [
        SizedBox(
          height: 48,
          width: 130,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
            child: TextField(
              controller: dateinput1,
              style: TextStyle(color: kPrimarySeedColor!, fontSize: 14),
              autofocus: false,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.06),
                  hintText: "Start Date",
                  suffixIcon: Icon(
                    Icons.calendar_month,
                    color: kPrimarySeedColor!,
                  ),
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kPrimarySeedColor!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kPrimarySeedColor!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8))),
              readOnly:
                  true, //set it true, so that user will not able to edit text
              onTap: () {
                _selectDate(dateinput1);
              },
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        SizedBox(
          height: 48,
          width: 130,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: TextField(
              controller: dateinput2,
              style: TextStyle(color: kPrimarySeedColor!, fontSize: 14),
              autofocus: false,
              decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.grey.withOpacity(0.06),
                  hintText: "End Date",
                  suffixIcon: Icon(
                    Icons.calendar_month,
                    color: kPrimarySeedColor!,
                  ),
                  contentPadding:
                      const EdgeInsetsDirectional.fromSTEB(8, 0, 0, 0),
                  focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kPrimarySeedColor!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8)),
                  enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: kPrimarySeedColor!,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(8))),
              readOnly:
                  true, //set it true, so that user will not able to edit text
              onTap: () {
                _selectDate(dateinput2);
              },
            ),
          ),
        ),
      ],
    );
  }

  Padding dataTable2Mobile() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 1.5),
      child: DataTable2(
          showBottomBorder: true,
          // border: TableBorder.symmetric(outside: const BorderSide(color: kPrimarySeedColor)),
          headingRowColor:
              WidgetStateColor.resolveWith((states) => kPrimarySeedColor!),
          columnSpacing: 10,
          horizontalMargin: 10,
          dividerThickness: 0.5,
          minWidth: MediaQuery.of(context).size.width,
          // fixedLeftColumns: 1,
          // fixedColumnsColor: Colors.grey.shade200,
          sortColumnIndex: sortColumnIndex,
          sortAscending: sortAscending,
          columns: [
            DataColumn2(
              fixedWidth: MediaQuery.of(context).size.width * 0.11,
              label: const Text("S.no", style: TextStyle(color: Colors.white)),
            ),
            const DataColumn2(
                size: ColumnSize.M,
                label:
                    Text('Play Points', style: TextStyle(color: Colors.white))),
            const DataColumn2(
                size: ColumnSize.S,
                label: Text('Margin', style: TextStyle(color: Colors.white))),
            const DataColumn2(
                size: ColumnSize.M,
                label:
                    Text('Win Points', style: TextStyle(color: Colors.white))),
            const DataColumn2(
                size: ColumnSize.S,
                label: Text('Net', style: TextStyle(color: Colors.white))),
          ],
          rows: List<DataRow>.generate(
            saleReportResult.length,
            (index) {
              final rowIndex = index + 1 + page * 100;
              var result = saleReportResult[index];
              if (result.name != null ||
                  result.playPoints != null ||
                  result.winPoints != null ||
                  result.margin != null ||
                  result.net != null) {
                return DataRow(cells: [
                  DataCell(Text(rowIndex.toString())),
                  DataCell(Text(result.playPoints?.toString() ?? '')),
                  DataCell(Text(result.margin?.toString() ?? '')),
                  DataCell(Text(result.winPoints!.toString())),
                  DataCell(Text(result.net?.toString() ?? '')),
                ]);
              }
              return const DataRow(
                  cells: []); // Return an empty DataRow if the conditions are not met to exclude the row
            },
          )),
    );
  }

  Container totalContainer() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.10,
      width: MediaQuery.of(context).size.width,
      color: kPrimarySeedColor,
      child: Column(children: [
        const Align(
          alignment: Alignment.topCenter,
          child: Text(
            "TOTAL",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(
          height: 2,
        ),
        Padding(
            padding: const EdgeInsets.only(left: 2.0, right: 2.0),
            child: Row(children: [
              Expanded(
                  flex: 1,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        "PLAY POINTS: ${playPoints ?? ""}",
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      AutoSizeText(
                        "WIN POINTS: ${winPoints ?? ""}",
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ],
                  )),
              Expanded(
                  flex: 1,
                  child: Column(children: [
                    AutoSizeText(
                      "NET: ${net ?? ""}",
                      maxLines: 1,
                      style: const TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    AutoSizeText("MARGIN: ${margin ?? ""}",
                        maxLines: 1,
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))
                  ])),
              ElevatedButton.icon(
                style: ButtonStyle(
                  backgroundColor: WidgetStateProperty.all<Color>(Colors.white),
                ),
                onPressed: () {
                  onCheckPrint(
                    share: false,
                    saleReportResult: saleReportResult,
                  );
                },
                icon: Icon(
                  Icons.print,
                  color: kPrimarySeedColor,
                ),
                label: Text(
                  "Print",
                  style: TextStyle(color: kPrimarySeedColor),
                ),
              )
            ]))
      ]),
    );
  }

  Center totalUserWithPagination(BuildContext context) {
    String startDate = DateFormat('yyyy-MM-dd').format(_startDate);
    String endate = DateFormat('yyyy-MM-dd').format(_endDate);
    return Center(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Responsive.isMobile(context)
              ? Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Text("Start Date: $startDate"),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text("End Date: $endate"),
                      ),
                    ],
                  ),
                )
              : const SizedBox.shrink(),
          Align(
            alignment: Alignment.centerRight,
            child: pageNumbers.length < 2
                ? const SizedBox.shrink()
                : Padding(
                    padding: EdgeInsets.only(
                        top: Responsive.isDesktop(context) &&
                                Responsive.isTablet(context)
                            ? 50.0
                            : 0,
                        left: Responsive.isDesktop(context) &&
                                Responsive.isTablet(context)
                            ? 50.0
                            : 0),
                    child: SizedBox(
                      height: 40,
                      width: MediaQuery.of(context).size.width * 0.60,
                      child: NumberPaginator(
                        config: NumberPaginatorUIConfig(
                          height: 40,
                          buttonSelectedBackgroundColor: kPrimarySeedColor,
                        ),
                        numberPages: numberOfPage,
                        onPageChange: (int? newValue) async {
                          // print("Start Date $startData : endDate :$endDate");
                          bool networkStatus =
                              await NetworkCheckHelper.checkNetworkConnection();
                          // if (dateinput1.text.isNotEmpty &&
                          //     dateinput2.text.isNotEmpty) {
                          if (networkStatus) {
                            setState(() {
                              page = newValue!;
                              showLoadingOverlay = true;
                              //    showCreditValue = false;
                            });

                            await ref
                                .read(saleReportProvider(SaleReportParams(
                                        from: (DateTime.parse(startDate)
                                            .millisecondsSinceEpoch),
                                        to: (DateTime.parse(endDate)
                                            .millisecondsSinceEpoch),
                                        page: newValue!))
                                    .future)
                                .then((value) {
                              if (value.errorCode == 0) {
                                if (mounted) {
                                  setState(() {
                                    showLoadingOverlay = false;
                                    //   showCreditValue = true;
                                    saleReportResult = value.results!;
                                    playPoints = value.playPoints;
                                    winPoints = value.winPoints;
                                    net = value.net;
                                    margin = value.margin;
                                  });
                                  // scrollToTop(scrollController);
                                }
                              } else {
                                setState(() {
                                  showLoadingOverlay = false;
                                });

                                showSnackBar(context,
                                    "Sorry, the isn't available. Please refresh");
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
                            showSnackBar(
                                // ignore: use_build_context_synchronously
                                context,
                                "Check your internet connection");
                          }
                        },
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  //pagination
  Widget paginationButton(BuildContext context) {
    return pageNumbers.length < 2
        ? const SizedBox.shrink()
        : SizedBox(
            height: 30,
            child: DropdownButton(
                hint: Text("$page"),
                items: pageNumbers.asMap().entries.map((e) {
                  final index = e.key;
                  final value = e.value;
                  return DropdownMenuItem(
                      value: index, child: Text(value.toString()));
                }).toList(),
                onChanged: (int? newValue) async {
                  // print("Start Date $startData : endDate :$endDate");
                  bool networkStatus =
                      await NetworkCheckHelper.checkNetworkConnection();
                  // if (dateinput1.text.isNotEmpty &&
                  //     dateinput2.text.isNotEmpty) {
                  if (networkStatus) {
                    setState(() {
                      page = newValue!;
                      showLoadingOverlay = true;
                      //    showCreditValue = false;
                    });

                    await ref
                        .read(saleReportProvider(SaleReportParams(
                                from: (DateTime.parse(startDate)
                                    .millisecondsSinceEpoch),
                                to: (DateTime.parse(endDate)
                                    .millisecondsSinceEpoch),
                                page: newValue!))
                            .future)
                        .then((value) {
                      if (value.errorCode == 0) {
                        if (mounted) {
                          setState(() {
                            showLoadingOverlay = false;

                            saleReportResult = value.results!;
                            playPoints = value.playPoints;
                            winPoints = value.winPoints;
                            net = value.net;
                            margin = value.margin;
                          });
                          // scrollToTop(scrollController);
                        }
                      } else {
                        setState(() {
                          showLoadingOverlay = false;
                        });

                        showSnackBar(context,
                            "Sorry, the isn't available. Please refresh");
                      }
                    }).onError((error, stackTrace) {
                      setState(() {
                        showLoadingOverlay = false;
                      });

                      ExceptionHandler.showSnack(
                          errorCode: error.toString(), context: context);
                    });
                  } else {
                    setState(() {
                      showLoadingOverlay = false;
                    });

                    if (!mounted) return;
                    // ignore: use_build_context_synchronously
                    showSnackBar(context, "Check your internet connection");
                  }
                }),
          );
  }

  //BUttons
  Padding searchAndClearButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0, top: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Search button
          SizedBox(
            width: 80,
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: kPrimarySeedColor),
              onPressed: () async {
                //  initializeDates();
                setState(() {
                  pageNumbers.clear();
                });

                bool networkStatus =
                    await NetworkCheckHelper.checkNetworkConnection();

                if (networkStatus) {
                  setState(() {
                    showLoadingOverlay = true;
                    saleReportResult.clear();
                    //    showCreditValue = false;
                  });

                  await ref
                      .read(saleReportProvider(SaleReportParams(
                              from: (DateTime.parse(startDate)
                                  .millisecondsSinceEpoch),
                              to: (DateTime.parse(endDate)
                                  .millisecondsSinceEpoch),
                              page: page))
                          .future)
                      .then((value) {
                    if (value.errorCode == 0) {
                      if (mounted) {
                        setState(() {
                          showLoadingOverlay = false;
                          saleReportResult = value.results!;
                          net = value.net;
                          margin = value.margin;
                          playPoints = value.playPoints!;
                          winPoints = value.winPoints!;
                          numberOfPage = value.totalPages!;
                          page = value.page!;
                          int? pageNo = value.totalPages;
                          currentTime = value.currentTime!;
                          startPrintDate = value.from!;
                          endPrintDate = value.to!;
                          //store the value
                          for (int i = 0; i < pageNo!; i++) {
                            pageNumbers.add(i);
                          }
                        });
                      }
                    } else {
                      setState(() {
                        showLoadingOverlay = false;
                      });

                      showSnackBar(context,
                          "Sorry, the isn't available. Please refresh");
                    }
                  }).onError((error, stackTrace) {
                    setState(() {
                      showLoadingOverlay = false;
                    });

                    ExceptionHandler.showSnack(
                        errorCode: error.toString(), context: context);
                  });
                } else {
                  setState(() {
                    showLoadingOverlay = false;
                  });

                  if (!mounted) return;
                  // ignore: use_build_context_synchronously
                  showSnackBar(context, "Check your internet connection");
                }
              },
              child: const Text('Search'),
            ),
          ),
          SizedBox(
            width: Responsive.isDesktop(context) ? 50 : 100,
          ),
          // Clear button
          SizedBox(
            width: 80,
            child: ElevatedButton(
              style:
                  ElevatedButton.styleFrom(backgroundColor: kPrimarySeedColor),
              onPressed: () {
                setState(() {
                  saleReportResult.clear();
                  startData = "";
                  endDate = "";
                  dateinput1.clear();
                  dateinput2.clear();
                  playPoints = null;
                  winPoints = null;
                  net = null;
                  margin = null;
                  defaultDate();
                });
              },
              child: const Text('Clear'),
            ),
          ),
        ],
      ),
    );
  }

  onCheckPrint(
      {required bool share, List<salereport.Result>? saleReportResult}) async {
    final font = await PdfGoogleFonts.robotoFlexRegular();

    // Define a global font size
    const double globalFontSize = 8.0;

    final pdf = pw.Document(version: PdfVersion.pdf_1_4);

    pdf.addPage(pw.MultiPage(
      margin: pw.EdgeInsets.only(
        left: selectedPaperSize == PaperSelect.Size57 ? 0 : 12,
      ),
      build: (context) => [
        for (final result in saleReportResult ?? [])
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(currentName,
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text('(For Amusement Purpose Only)',
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text(
                'Retailer: ${result.name ?? "N/A"}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
              ),
              pw.Text(
                'Current Time:${Helper.epocToYYYYMMddhms(currentTime)}',
                style: pw.TextStyle(fontSize: 7.9, font: font),
              ),
              pw.Text(
                'Start Date:${Helper.epocToYYYYMMddhms(startPrintDate)}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
              ),
              pw.Text(
                'End Date: ${Helper.epocToYYYYMMddhms(endPrintDate)}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
              ),
              pw.Text(
                'Play Points: ${result.playPoints.floor() ?? "N/A"}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
              ),
              pw.Text(
                'Win Points: ${result.winPoints.floor() ?? "N/A"}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
              ),
              pw.Text(
                'Margin: ${result.margin ?? "N/A"}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
              ),
              pw.Text(
                'Net: ${result.net ?? "N/A"}',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
              ),
            ],
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
