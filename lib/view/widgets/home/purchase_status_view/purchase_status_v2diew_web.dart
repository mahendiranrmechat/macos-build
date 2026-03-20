import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
import 'package:psglotto/model/buy_ticket_others.dart' as d;
import 'package:pdf/widgets.dart' as pw;
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/home/game_time_helper_widgets/tab_color.dart';
import 'package:series_2d/game_init_loader.dart';
//import 'package:share_plus/share_plus.dart';
import '../../../../settings_services/shared_preferences.dart';
import '../../../../update_value_2d_game.dart/init_game_others_notifier.dart';
import 'package:universal_html/html.dart' as html;

// ignore: must_be_immutable
class PurchasedTicket2DGameWeb extends ConsumerStatefulWidget {
  // ignore: non_constant_identifier_names
  List<d.Type> gameValue;
  int totalQty;
  double totalPoints;
  String internalRefNo;
  int drawStartTime;
  double price;
  int ticketCount;
  String barCode;
  String gameName;
  String drawId;
  double ticketPrice;
  PurchasedTicket2DGameWeb(
      {required this.gameValue,
      required this.totalPoints,
      required this.totalQty,
      required this.ticketPrice,
      required this.gameName,
      required this.drawId,
      required this.barCode,
      required this.price,
      required this.ticketCount,
      required this.drawStartTime,
      required this.internalRefNo,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<PurchasedTicket2DGameWeb> createState() =>
      _PurchasedTicket2DGameWebState();
}

class _PurchasedTicket2DGameWebState
    extends ConsumerState<PurchasedTicket2DGameWeb> {
  final preferenceService = PreferencesServices();
  var selectedPaperSize = PaperSelect.Size57;
  var isBarcode = false;

  Map<String, List<String>> betTypesValues = {};
  Map<String, List<String>> typedMap = {};
  List<Map<String, dynamic>> myList = [];
  Map<String, dynamic> typesMap = {};
  // late Printer defaultPrinter;
  //last Updated
  List<Map<String, dynamic>> updatedTypes = [];

  @override
  void initState() {
    _populateFileds();
    super.initState();
    for (var type in widget.gameValue) {
      Map<String, dynamic>? betTypes = type.betTypes;
      Map<String, String> updatedBetTypes = {};

      for (var key in betTypes!.keys) {
        if (key == "1") {
          List<String> values = betTypes[key].split(",");
          List<String> updatedValues = [];

          for (var value in values) {
            if (value.isNotEmpty) {
              updatedValues.add("A$value");
            }
          }

          updatedBetTypes[key] = updatedValues.join(",");
        } else if (key == "2") {
          List<String> values = betTypes[key].split(",");
          List<String> updatedValues = [];

          for (var value in values) {
            if (value.isNotEmpty) {
              updatedValues.add("B$value");
            }
          }

          updatedBetTypes[key] = updatedValues.join(",");
        } else {
          updatedBetTypes[key] = betTypes[key];
        }
      }

      updatedTypes.add({
        "typeId": type.typeId,
        "typeName": type.typeName,
        "betTypes": updatedBetTypes
      });
    }

    setState(() {
      updatedTypes;

      for (var type in updatedTypes) {
        //get the value from types
        String typeId = type['typeId'].toString();
        List<String> betTypes = type['betTypes'].values.toList();
        if (!betTypesValues.containsKey(typeId)) {
          betTypesValues[typeId] = [];
        }
        betTypesValues[typeId]!.addAll(betTypes);
      }

      betTypesValues.forEach((key, value) {
        value.removeWhere((e) => e.isEmpty);
      });

      typedMap = betTypesValues.map((key, value) => MapEntry(key, value));
      typedMap.forEach((key, value) {
        if (value.isNotEmpty) {
          Map<String, dynamic> item = {
            'betType': key,
            'betValue': value.toString().split(',')
          };

          item.removeWhere((key, value) => value.toString().isEmpty);

          myList.add(item);
          if (kDebugMode) {
            print(item.toString());
          }
        }
      });

      // Convert the input string to valid JSON by enclosing the keys and values in quotes
    });
  }

  //settings field
  void _populateFileds() async {
    final settings = await preferenceService.getSettings();
    setState(() {
      selectedPaperSize = settings.paperSelect;
      isBarcode = settings.isBarcode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // ref.refresh(game2dProvider);
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Purchase Status 2D Game"),
        ),
        body: WillPopScope(
          onWillPop: () async {
            ref.refresh(balanceProvider);
            return true;
          },
          child: Column(
            children: [
              Expanded(
                flex: 4,
                child: Container(
                  color: Colors.white,
                  child: ListView.builder(
                      itemCount: updatedTypes.length,
                      itemBuilder: (context, index) {
                        return Padding(
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
                                      updatedTypes[index]['typeName'],
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Text(
                                      "(${InitGameOthersProvider.getInitGameOthers()['types'][index]['price'].toString()})",
                                    ),
                                  ),
                                ],
                              ),
                              Container(
                                  height: myList[index]['betValue'].toString().split(',').length <=
                                          20
                                      ? 50
                                      : myList[index]['betValue'].toString().split(',').length >= 21 &&
                                              myList[index]['betValue']
                                                      .toString()
                                                      .split(',')
                                                      .length <=
                                                  40
                                          ? 100
                                          : myList[index]['betValue'].toString().split(',').length >= 41 &&
                                                  myList[index]['betValue']
                                                          .toString()
                                                          .split(',')
                                                          .length <=
                                                      60
                                              ? 150
                                              : myList[index]['betValue'].toString().split(',').length >= 61 &&
                                                      myList[index]['betValue']
                                                              .toString()
                                                              .split(',')
                                                              .length <=
                                                          80
                                                  ? 200
                                                  : myList[index]['betValue'].toString().split(',').length >= 81 &&
                                                          myList[index]
                                                                      ['betValue']
                                                                  .toString()
                                                                  .split(',')
                                                                  .length <=
                                                              100
                                                      ? 250
                                                      : myList[index]['betValue'].toString().split(',').length >= 101 && myList[index]['betValue'].toString().split(',').length <= 120
                                                          ? 300
                                                          : 400,
                                  color: Colors.white,
                                  child: GridView.builder(
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: myList[index]['betValue'].toString().split(',').length,
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        childAspectRatio: 1.5,
                                        mainAxisSpacing: 0.5,
                                        crossAxisSpacing: 1.0,
                                        crossAxisCount: 20,
                                      ),
                                      itemBuilder: (context, i) {
                                        return Column(
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
                                                          topLeft:
                                                              Radius.circular(
                                                                  5),
                                                          topRight:
                                                              Radius.circular(
                                                                  5)),
                                                  color: kPrimarySeedColor,
                                                ),
                                                child: Center(
                                                  //[[6-2,  B7-4,  18-1]]
                                                  //[[6-1,  B7-1,  18-1, 31-1, 32-1, 34-1, 39-1, 46-1, 55-1, 60-1]]
                                                  child: Text(
                                                    myList[index]['betValue'][i]
                                                        .toString()
                                                        .split('-')[0]
                                                        .replaceAll('[', ''),
                                                    style: const TextStyle(
                                                        color: Colors.white),
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
                                                        bottomLeft:
                                                            Radius.circular(5),
                                                        bottomRight:
                                                            Radius.circular(5)),
                                                color:
                                                    TabColor().tabColors[index],
                                              ),
                                              child: Center(
                                                child: Text(
                                                  myList[index]['betValue'][i]
                                                      .toString()
                                                      .split('-')[1]
                                                      .replaceAll(']', ''),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              ),
                                            )
                                          ],
                                        );
                                      }))
                            ],
                          ),
                        );
                      }),
                ),
              ),
              Container(
                height: MediaQuery.of(context).size.height * 0.110,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(color: Colors.grey.shade200),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Total Qty: ${widget.totalQty} ",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          "Price: ${widget.totalPoints}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                    const SizedBox(
                      height: 16 / 2,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                        IconButton(
                          onPressed: () async {
                            await generatePDF();
                          },
                          icon: const Icon(Icons.print),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> generatePDF() async {
    final pdf = pw.Document();
    const double pageWidth = 70 * PdfPageFormat.mm;
    const double pageHeight = 100 * PdfPageFormat.mm;
    const multiPageFormat = PdfPageFormat(pageWidth, pageHeight);
    // double numberLines = double.infinity * PdfPageFormat.mm;
    var printFormat = const PdfPageFormat(70 * PdfPageFormat.mm, pageWidth);
    String userName = SharedPref.instance.getString("username") ?? "-";
    String address =
        'Retailer: $userName\r\n\r\nTrans ID: ${widget.internalRefNo}\r\n\r\nDraw Date: ${Helper.epocToMMddYYYYhhMMaa(widget.drawStartTime).toString()}\r\n\r\nDraw ID: ${widget.drawId}\r\n\r\nTotal Points: ${widget.price} ';
    String points = 'Points: ${widget.ticketPrice}\r\n\r\n';
    String qty = 'Qty: ${widget.ticketCount}\r\n\r\n';

    pdf.addPage(pw.Page(
        pageFormat: printFormat,
        build: (final context) {
          return pw.Column(children: [
            pw.Padding(
                padding: const pw.EdgeInsets.only(left: 30),
                child: pw.Text('PLAY LOTTO',
                    style: const pw.TextStyle(fontSize: 18))),
            // ignore: unrelated_type_equality_checks
            selectedPaperSize.toString() == 'PaperSelect.Size80'
                ? pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 20, top: 10),
                    child: pw.Text('(For Amusement Purpose Only)',
                        style: const pw.TextStyle(fontSize: 12)))
                : pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 20, top: 10),
                    child: pw.Text('(For Amusement Purpose Only)',
                        style: const pw.TextStyle(fontSize: 10))),
            pw.Padding(
                padding: const pw.EdgeInsets.only(left: 0, top: 10),
                child: pw.Text(widget.gameName,
                    style: const pw.TextStyle(fontSize: 14))),

            pw.Padding(
                padding: const pw.EdgeInsets.only(left: 20, top: 10),
                child:
                    pw.Text(address, style: const pw.TextStyle(fontSize: 8))),
            selectedPaperSize.toString() ==
                    'PaperSelect.Size80' //This is for size80
                ? pw.Padding(
                    padding: const pw.EdgeInsets.only(left: -70, top: 10),
                    child: pw.Text(points,
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)))
                //This is for size57
                : pw.Padding(
                    padding: const pw.EdgeInsets.only(left: -60, top: 10),
                    child: pw.Text(points,
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold))),
            selectedPaperSize.toString() ==
                    'PaperSelect.Size80' //THis is qty Size for 80
                ? pw.Padding(
                    padding: const pw.EdgeInsets.only(top: -20, left: 160),
                    child: pw.Text(qty,
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold)))
                //THis is qty Size for 57
                : pw.Padding(
                    padding: const pw.EdgeInsets.only(top: -20, left: 150),
                    child: pw.Text(qty,
                        style: pw.TextStyle(
                            fontSize: 10, fontWeight: pw.FontWeight.bold))),
          ]);
        }));

    pw.SizedBox(height: 5);

    //this is multipage
    isBarcode != true
        ? pdf.addPage(pw.MultiPage(
            pageFormat: multiPageFormat,
            margin:
                const pw.EdgeInsets.only(left: 60, top: 2, right: 5, bottom: 3),
            build: (final context) => [
                  pw.ListView.builder(
                      itemCount: myList.length,
                      itemBuilder: (context, index) {
                        int currentValue = updatedTypes.length - 1;
                        //updated new length
                        return pw.Container(
                            child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.only(left: -45),
                                child: pw.ListView.builder(
                                  direction: pw.Axis.horizontal,
                                  itemCount: updatedTypes.length - currentValue,
                                  itemBuilder: (context, int i) {
                                    final rows = List.generate(
                                      (myList[index]['betValue']
                                          .toString()
                                          .replaceAll("[", "")
                                          .replaceAll(" ", "")
                                          .trim()
                                          .replaceAll("]", "")
                                          .split(',')
                                          .length),
                                      (i) => myList[index]['betValue']
                                          .toString()
                                          .replaceAll("[", "")
                                          .replaceAll("]", "")
                                          .replaceAll(" ", "")
                                          .trim()
                                          .split(',')
                                          .skip(i * 5)
                                          .take(5)
                                          .toList(),
                                    );

                                    return pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Row(
                                              mainAxisAlignment: pw
                                                  .MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                pw.Container(
                                                  width: 170,
                                                  child: pw.Text(
                                                      '${widget.gameValue[index].typeName} (${InitGameOthersProvider.getInitGameOthers()['types'][index]['price'].toString()})  \n',
                                                      style: const pw.TextStyle(
                                                          fontSize: 10)),
                                                ),
                                                pw.Container(
                                                  width: 100,
                                                  child: pw.Text(
                                                      "Qty ${myList[index]['betValue'].toString().replaceAll("[", "").replaceAll(" ", "").trim().replaceAll("]", "").split(',').length}",
                                                      style: const pw.TextStyle(
                                                          fontSize: 10)),
                                                ),
                                              ]),
                                          pw.SizedBox(
                                            height: 5,
                                          ),
                                          pw.Align(
                                            // ignore: deprecated_member_use
                                            child: pw.Table.fromTextArray(
                                              cellAlignment:
                                                  pw.Alignment.center,
                                              defaultColumnWidth: const pw
                                                  .IntrinsicColumnWidth(),
                                              context: null,
                                              data: rows,
                                              headerStyle: const pw.TextStyle(
                                                fontSize: 8,
                                              ),
                                              headers: null,
                                              // headerStyle: pw.TextStyle(
                                              //   // fontWeight: pw.FontWeight.bold,
                                              // ),
                                              cellStyle: const pw.TextStyle(
                                                fontSize: 8,
                                              ),
                                              headerAlignment:
                                                  pw.Alignment.centerLeft,
                                              // cellAlignment:
                                              //     pw.Alignment.centerLeft,
                                              border: pw.TableBorder.all(
                                                color: PdfColors.black,
                                                width: 0.01,
                                              ),
                                            ),
                                          )
                                        ]);
                                  },
                                ))
                          ],
                        ));
                      }),
                  pw.SizedBox(
                    height: 20,
                  ),
                  pw.Text('**Ticket not for sale**',
                      style: const pw.TextStyle(fontSize: 12))
                ]))
        : pdf.addPage(pw.MultiPage(
            pageFormat: multiPageFormat,
            margin:
                const pw.EdgeInsets.only(left: 60, top: 2, right: 5, bottom: 3),
            build: (final context) => [
                  pw.ListView.builder(
                      itemCount: myList.length,
                      itemBuilder: (context, index) {
                        int currentValue = updatedTypes.length - 1;
                        //updated new length

                        return pw.Container(
                            child: pw.Column(
                          mainAxisAlignment: pw.MainAxisAlignment.start,
                          children: [
                            pw.Padding(
                                padding: const pw.EdgeInsets.only(left: -45),
                                child: pw.ListView.builder(
                                  direction: pw.Axis.horizontal,
                                  itemCount: updatedTypes.length - currentValue,
                                  itemBuilder: (context, int i) {
                                    final rows = List.generate(
                                      (myList[index]['betValue']
                                          .toString()
                                          .replaceAll("[", "")
                                          .replaceAll(" ", "")
                                          .trim()
                                          .replaceAll("]", "")
                                          .split(',')
                                          .length),
                                      (i) => myList[index]['betValue']
                                          .toString()
                                          .replaceAll("[", "")
                                          .replaceAll("]", "")
                                          .replaceAll(" ", "")
                                          .trim()
                                          .split(',')
                                          .skip(i * 5)
                                          .take(5)
                                          .toList(),
                                    );

                                    return pw.Column(
                                        crossAxisAlignment:
                                            pw.CrossAxisAlignment.start,
                                        children: [
                                          pw.Row(
                                              mainAxisAlignment: pw
                                                  .MainAxisAlignment
                                                  .spaceBetween,
                                              children: [
                                                pw.Container(
                                                  width: 170,
                                                  child: pw.Text(
                                                      '${widget.gameValue[index].typeName} (${InitGameOthersProvider.getInitGameOthers()['types'][index]['price'].toString()})                            ${"Qty ${myList[index]['betValue'].toString().replaceAll("[", "").replaceAll(" ", "").trim().replaceAll("]", "").split(',').length}"}',
                                                      style: const pw.TextStyle(
                                                          fontSize: 10)),
                                                ),
                                              ]),
                                          pw.SizedBox(
                                            height: 5,
                                          ),
                                          pw.Align(
                                            // ignore: deprecated_member_use
                                            child: pw.Table.fromTextArray(
                                              cellAlignment:
                                                  pw.Alignment.center,
                                              defaultColumnWidth: const pw
                                                  .IntrinsicColumnWidth(),
                                              context: null,
                                              data: rows,
                                              headerStyle: const pw.TextStyle(
                                                fontSize: 8,
                                              ),
                                              headers: null,
                                              cellStyle: const pw.TextStyle(
                                                fontSize: 8,
                                              ),
                                              headerAlignment:
                                                  pw.Alignment.centerLeft,
                                              border: pw.TableBorder.all(
                                                color: PdfColors.black,
                                                width: 0.01,
                                              ),
                                            ),
                                          )
                                        ]);
                                  },
                                ))
                          ],
                        ));
                      }),
                  pw.SizedBox(
                    height: 5,
                  ),
                  pw.SizedBox(
                      width: 100,
                      height: 40,
                      child: pw.BarcodeWidget(
                          barcode: pw.Barcode.code128(), data: widget.barCode)),
                  pw.SizedBox(
                    height: 2,
                  ),
                  pw.Text('**Ticket not for sale**',
                      style: const pw.TextStyle(fontSize: 12))
                ]));

    // Generate PDF bytes
    final Uint8List pdfBytes = await pdf.save();

    // Convert bytes to Blob for compatibility with web
    final pdfBlob = html.Blob([pdfBytes], 'application/pdf');

    // Create an object URL from the Blob
    final pdfUrl = html.Url.createObjectUrlFromBlob(pdfBlob);

    // Open the PDF in a new browser tab
    html.window.open(pdfUrl, '_blank');

    // Save the PDF file
    // ignore: unused_local_variable
    const fileName = 'generated_pdf.pdf';
    final filePath = html.Url.createObjectUrl(pdfBlob);
    final fileData = html.Url.createObjectUrl(pdfBlob);

    html.AnchorElement(
      href: filePath,
    );
    // ..setAttribute('download', fileName)
    // ..click();

    // Share the PDF file
    // ignore: deprecated_member_use
    // Share.shareFiles([fileData], text: 'Sharing PDF');
  }
}
