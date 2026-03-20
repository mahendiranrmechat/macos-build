// ignore_for_file: unused_local_variable

import 'dart:developer';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/model/buy_ticket.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/settings_services/shared_preferences.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/purchase_status/purchased_ticket_chip.dart';
import 'package:series_2d/game_init_loader.dart';

// import 'package:share_plus/share_plus.dart';
import 'package:universal_html/html.dart' as html;

class PurchaseStatusViewWeb extends ConsumerStatefulWidget {
  final BuyTicket data; //this is also yes-day work

  const PurchaseStatusViewWeb({required this.data, Key? key}) : super(key: key);

  @override
  ConsumerState<PurchaseStatusViewWeb> createState() =>
      _PurchaseStatusViewWebState();
}

class _PurchaseStatusViewWebState extends ConsumerState<PurchaseStatusViewWeb> {
  final preferenceService = PreferencesServices();
  var selectedPaperSize = PaperSelect.Size57;
  var isBarcode = false;
  @override
  void initState() {
    _populateFileds();
    super.initState();
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Purchase Status"),
      ),
      body: SizedBox(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: kDefaultPadding),
                    child: SingleChildScrollView(
                      child: Center(
                        child: Wrap(
                          spacing: kDefaultPadding,
                          runSpacing: kDefaultPadding,
                          children: [
                            ...widget.data.tickets!.map(
                              (e) => PurchasedTicketChip(
                                ticket: e,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 100.0,
                  ),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: FittedBox(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Tickets: ${widget.data.tickets!.length}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            "Price: ${widget.data.ticketPrice}",
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        ],
                      ),
                      const SizedBox(
                        height: kDefaultPadding / 2,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    height: 20,
                                    width: 70,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  const Text("Already sold"),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Row(
                                children: [
                                  Container(
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(4.0),
                                    ),
                                    height: 20,
                                    width: 70,
                                  ),
                                  const SizedBox(
                                    width: 10.0,
                                  ),
                                  const Text("Bought"),
                                  const SizedBox(
                                    width: 100.0,
                                  ),
                                ],
                              ),
                            ],
                          ),
                          IconButton(
                            onPressed: () async {
                              log("Clicked working");
                              await generatePDF(purchaseData: widget.data);
                            },
                            icon: const Icon(Icons.print),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  //add pdf
  Future<void> generatePDF({required BuyTicket purchaseData}) async {
    final pdf = pw.Document();
    const double pageWidth = 70 * PdfPageFormat.mm;
    const double pageHeight = 100 * PdfPageFormat.mm;
    const multiPageFormat = PdfPageFormat(pageWidth, pageHeight);
    // double numberLines = double.infinity * PdfPageFormat.mm;
    var printFormat = const PdfPageFormat(70 * PdfPageFormat.mm, pageWidth);

    //     //this is all data from
    // const String invoiceNumber = 'Invoice Number: 2058557939\r\n\r\nDate: ';
//     final Size contentSize = contentFont.measureString(invoiceNumber);
    String userName = SharedPref.instance.getString("username") ?? "-";

    //ticket List
    // String ticketList =
    //     purchaseData.tickets!.map((e) => e.substring(0, 6)).join(', ');

    String address =
        'Retailer: $userName\r\n\r\nTrans ID: ${purchaseData.internalRefNo}\r\n\r\nDraw Date: ${Helper.epocToMMddYYYYhhMMaa(purchaseData.drawStartTime!).toString()}\r\n\r\n Draw ID: ${widget.data.drawPlayGroupId}\r\n\r\nTotal Points: ${purchaseData.ticketPrice}';
    String points = 'Points: ${purchaseData.price}\r\n\r\n';
    String qty = 'Qty: ${purchaseData.ticketCount}\r\n\r\n';

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
                child: pw.Text(purchaseData.gameName!,
                    style: const pw.TextStyle(fontSize: 14))),
            // pw.Padding(
            //     padding: const pw.EdgeInsets.only(left: 140, top: -16),
            //     child: pw.Text(purchaseData.drawId!,
            //         style: const pw.TextStyle(fontSize: 14))),
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

    //this is multipage
    isBarcode == true
        ? pdf.addPage(pw.MultiPage(
            pageFormat: multiPageFormat,
            margin:
                const pw.EdgeInsets.only(left: 60, top: 2, right: 5, bottom: 3),
            build: (final context) => [
                  selectedPaperSize.toString() == 'PaperSelect.Size80'
                      ? pw.ListView.builder(
                          itemCount: purchaseData.tickets!.length,
                          itemBuilder: (context, index) {
                            if (index.isEven) {
                              if (purchaseData.tickets!.length == 1) {
                                return selectedPaperSize.toString() ==
                                        'PaperSelect.Size57'
                                    ? pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          left: -40,
                                        ),
                                        child: pw.Column(children: [
                                          pw.Text(purchaseData.tickets![index]
                                              .split('-')[0]),
                                          pw.SizedBox(
                                              width: 80,
                                              height: 30,
                                              child: pw.BarcodeWidget(
                                                  barcode: pw.Barcode.code128(),
                                                  data: purchaseData
                                                      .tickets![index]
                                                      .split('-')[2]))
                                        ]))
                                    : pw.Padding(
                                        padding: const pw.EdgeInsets.only(
                                          left: -40,
                                        ),
                                        child: pw.Column(children: [
                                          pw.Text(purchaseData.tickets![index]
                                              .split('-')[0]),
                                          pw.SizedBox(
                                              width: 80,
                                              height: 30,
                                              child: pw.BarcodeWidget(
                                                  barcode: pw.Barcode.code128(),
                                                  data: purchaseData
                                                      .tickets![index]
                                                      .split('-')[2]))
                                        ]));
                              } else {
                                return pw.Padding(
                                    padding: const pw.EdgeInsets.only(
                                      left: -140,
                                    ),
                                    child: pw.Column(children: [
                                      pw.Text(purchaseData.tickets![index]
                                          .split('-')[0]),
                                      pw.SizedBox(
                                          width: 80,
                                          height: 30,
                                          child: pw.BarcodeWidget(
                                              barcode: pw.Barcode.code128(),
                                              data: purchaseData.tickets![index]
                                                  .split('-')[2]))
                                    ]));
                              }
                            }
                            if (index.isOdd) {
                              return pw.Padding(
                                  padding: const pw.EdgeInsets.only(
                                      left: 60, top: -44),
                                  child: pw.Column(children: [
                                    pw.Text(purchaseData.tickets![index]
                                        .split('-')[0]),
                                    pw.SizedBox(
                                        width: 80,
                                        height: 30,
                                        child: pw.BarcodeWidget(
                                            barcode: pw.Barcode.code128(),
                                            data: purchaseData.tickets![index]
                                                .split('-')[2]))
                                  ]));
                            }
                            return pw.SizedBox();
                          })
                      : pw.ListView.builder(
                          itemCount: purchaseData.tickets!.length,
                          itemBuilder: (contex, index) {
                            return pw.SizedBox(
                                width: 80,
                                height: 30,
                                child: pw.BarcodeWidget(
                                    barcode: pw.Barcode.code128(),
                                    data: purchaseData.tickets![index]
                                        .split('-')[2]));
                          }),
                  pw.SizedBox(
                    height: 20,
                  ),
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(left: -10),
                      child: pw.Text('**Ticket not for sale**',
                          style: const pw.TextStyle(fontSize: 12)))
                ]))
        : pdf.addPage(pw.MultiPage(
            pageFormat: multiPageFormat,
            margin:
                const pw.EdgeInsets.only(left: 60, top: 2, right: 5, bottom: 3),
            // footer: (final pw.Context context) {
            //   return pw.Container(child: pw.Text("This i sfooter"));
            // },
            build: (final context) => [
                  pw.ListView.builder(
                      itemCount: purchaseData.tickets!.length,
                      itemBuilder: (context, index) {
                        if (index.isEven) {
                          if (purchaseData.tickets!.length == 1) {
                            return pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                  left: 20,
                                ),
                                child: pw.Column(children: [
                                  pw.Text(purchaseData.tickets![index]
                                      .split('-')[0]),
                                ]));
                          } else {
                            return pw.Padding(
                                padding: const pw.EdgeInsets.only(
                                  left: -100,
                                ),
                                child: pw.Column(children: [
                                  pw.Text(purchaseData.tickets![index]
                                      .split('-')[0]),
                                ]));
                          }
                        }
                        if (index.isOdd) {
                          return pw.Padding(
                              padding: const pw.EdgeInsets.only(
                                left: 80,
                                top: -13,
                              ),
                              child: pw.Column(children: [
                                pw.Text(
                                    purchaseData.tickets![index].split('-')[0]),
                              ]));
                        }
                        return pw.SizedBox();
                      }),
                  pw.SizedBox(
                    height: 20,
                  ),
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(left: -10),
                      child: pw.Text('**Ticket not for sale**',
                          style: const pw.TextStyle(fontSize: 12)))
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
