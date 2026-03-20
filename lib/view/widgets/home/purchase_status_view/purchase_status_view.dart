// ignore_for_file: must_be_immutable

import 'dart:async';
import 'dart:developer';
import 'dart:io' as pw;
import 'dart:io';
// import 'package:bluetooth_thermal_printer/bluetooth_thermal_printer.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:psglotto/model/buy_ticket.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/settings_services/shared_preferences.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:psglotto/view/widgets/purchase_status/purchased_ticket_chip.dart';
import 'package:series_2d/game_init_loader.dart';
// ignore: unused_import
//import 'package:esc_pos_utils/esc_pos_utils.dart';

class PurchaseStatusView extends ConsumerStatefulWidget {
  String gameName;
  String drawId;
  final BuyTicket data; //this is also yes-day work

  PurchaseStatusView(
      {required this.gameName,
      required this.drawId,
      required this.data,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<PurchaseStatusView> createState() => _PurchaseStatusViewState();
}

class _PurchaseStatusViewState extends ConsumerState<PurchaseStatusView> {
  bool connected = false; //bluetooth connect
  List availableBluetoothDevices = []; // availableBluetoothDevices for mobile
  final preferenceService = PreferencesServices();

  var isBarcode = false;
  // BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  // StreamSubscription<BluetoothAdapterState>? adapterStateStateSubscription;
  List<String> options = ['2 Inc', '3 Inc'];
  String optionPrintType = '2 Inc';

  // List<BluetoothInfo> items = [];
  bool progress = false;
  bool isPrinting = false;
  String msjProgress = '';
  String info = '';
  var selectedPaperSize = PaperSelect.Size57;
  Printer? defaultPrinter;
  String username = "-";
  @override
  void initState() {
    setState(() {
      username = SharedPref.instance.getString("username") ?? "-";
    });
    populateFileds();
    // adapterStateStateSubscription =
    //     FlutterBluePlus.adapterState.listen((state) {
    //   adapterState = state;
    // });
    initFile();
    setupPrinter();

    super.initState();
  }

  late File pdfFile;
  // late Printer defaultPrinter;
  late final pw.Directory directory;

  //settings field
  void populateFileds() async {
    final settings = await preferenceService.getSettings();
    setState(() {
      selectedPaperSize = settings.paperSelect;
      isBarcode = settings.isBarcode;
    });
  }

  void setupPrinter() async {
    List<Printer> printers = [];
    if (Platform.isWindows) {
      printers = await Printing.listPrinters();
      for (var element in printers) {
        if (element.isDefault == true) {
          defaultPrinter = element;
        }
      }
      onCheckPrint(purchaseData: widget.data, share: false);
    }
  }

  void initFile() async {
    directory = await getApplicationDocumentsDirectory();

    pdfFile =
        File('${directory.path}/$currentName ${widget.data.internalRefNo}.pdf');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 200,
        leading: Row(
          children: [
            const BackButton(),
            Text(username, style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
        centerTitle: true,
        title: const Text("Purchase Status"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Game Name: ${widget.gameName}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    Text("Draw ID: ${widget.drawId}",
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                CustomCloseButton(),
              ],
            ),
          )
        ],
      ),
      body: Stack(
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
                  height: 150.0,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              height: 200,
              width: 300,

              // color: Colors.orange,
              child: ListView.builder(
                  itemCount: availableBluetoothDevices.isNotEmpty
                      ? availableBluetoothDevices.length
                      : 0,
                  itemBuilder: (context, index) {
                    return ListTile(
                        onTap: () {
                          String select = availableBluetoothDevices[index];
                          List list =
                              select.split("#"); //this is for find mac address
                          if (kDebugMode) {
                            print(list[1]);
                          }
                          // String name = list[0];
                          String mac = list[1];
                          //  setConnect(mac);
                          // printGraphics();
                        },
                        title: connected == false
                            ? Text(
                                '${availableBluetoothDevices[index]}',
                                style: const TextStyle(color: Colors.red),
                              )
                            : Text(
                                '${availableBluetoothDevices[index]}',
                                style: const TextStyle(color: Colors.green),
                              ),
                        subtitle: connected == false
                            ? const Text(
                                "Click to connect",
                                style: TextStyle(color: Colors.black),
                              )
                            : const Text("Connected"));
                  }),
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
                          "Price: ${widget.data.ticketPrice!.toStringAsFixed(0)}",
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
                                if (Platform.isAndroid)
                                  IconButton(
                                    onPressed: () {
                                      // initprinter();
                                      if (connected == false) {
                                        //   getBluetooth();
                                      } else {
                                        //  printGraphics();
                                      }
                                    },
                                    icon: const Icon(Icons.share),
                                  ),
                              ],
                            ),
                          ],
                        ),
                        Container(
                          color: Colors.transparent,
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () async {
                                  if (progress) return; // Prevent multiple taps
                                  progress = true; // Lock processing

                                  try {
                                    onCheckPrint(
                                      purchaseData: widget.data,
                                      share: true,
                                    );
                                  } catch (error) {
                                    debugPrint("Error during sharing: $error");
                                  } finally {
                                    progress = false; // Unlock processing
                                  }
                                },
                                icon: const Icon(Icons.share),
                              ),
                              IconButton(
                                onPressed: isPrinting
                                    ? null // Disable button if printing is in progress
                                    : () async {
                                        setState(() {
                                          isPrinting = true; // Lock processing
                                        });

                                        try {
                                          if (Platform.isAndroid) {
                                            // if (adapterState == BluetoothAdapterState.on) {
                                            //   // Add your Bluetooth permission check logic here if needed.
                                            //   // getBluetoothDevices();
                                            // } else {
                                            //   showSnackBar(context, "Please Enable Bluetooth");
                                            // }
                                          } else {
                                            onCheckPrint(
                                              purchaseData: widget.data,
                                              share: false,
                                            );
                                          }
                                        } catch (error) {
                                          debugPrint(
                                              "Error during print: $error");
                                        }
                                      },
                                icon: const Icon(Icons.print),
                              ),
                            ],
                          ),
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
    );
  }

  // Future<void> getBluetoothDevices() async {
  //   setState(() {
  //     progress = true;
  //     msjProgress = "Searching...";
  //     items = <BluetoothInfo>[];
  //   });
  //   final List<BluetoothInfo> deviceList =
  //       await PrintBluetoothThermal.pairedBluetooths;

  //   setState(() {
  //     progress = false;
  //   });
  //   //check if empty
  //   if (deviceList.isEmpty) {
  //     setState(() {
  //       info =
  //           "No paired Bluetooth devices found. Please pair a printer in the settings.";
  //     });
  //   } else {
  //     setState(() {
  //       info = 'Select a device from the list to connect.';
  //     });
  //   }

  //   //set the device
  //   setState(() {
  //     items = deviceList;
  //     showBluetoothList(context, items);
  //   });
  // }

  // Future<Object?> showBluetoothList(
  //     BuildContext context, List<BluetoothInfo> items) {
  //   return showDialog(
  //     context: context,
  //     barrierDismissible: false,
  //     builder: (BuildContext context) {
  //       return StatefulBuilder(builder: (context, setState) {
  //         return Dialog(
  //           shape: RoundedRectangleBorder(
  //             borderRadius: BorderRadius.circular(20.0),
  //           ),
  //           child: Container(
  //             height: 450,
  //             decoration: BoxDecoration(
  //               borderRadius: BorderRadius.circular(10),
  //               border: Border.all(color: kPrimarySeedColor!, width: 2),
  //               color: Colors.white,
  //             ),
  //             child: Stack(
  //               children: [
  //                 Align(
  //                     alignment: Alignment.topRight,
  //                     child: Container(
  //                       height: 50,
  //                       width: 50,
  //                       decoration: BoxDecoration(
  //                           borderRadius: const BorderRadius.only(
  //                               bottomLeft: Radius.circular(20),
  //                               topRight: Radius.circular(2)),
  //                           color: Colors.grey[200]),
  //                       child: IconButton(
  //                           color: Colors.redAccent,
  //                           onPressed: () {
  //                             Navigator.of(context).pop();
  //                           },
  //                           icon: const Icon(Icons.close)),
  //                     )),
  //                 Column(
  //                   children: [
  //                     const Padding(
  //                       padding: EdgeInsets.all(12.0),
  //                       child: Text(
  //                         'Bluetooth Devices',
  //                         style: TextStyle(
  //                             fontSize: 18, fontWeight: FontWeight.bold),
  //                       ),
  //                     ),
  //                     Container(
  //                       height: 50,
  //                       color: Colors.transparent,
  //                       child: Row(
  //                         mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                         crossAxisAlignment: CrossAxisAlignment.center,
  //                         children: [
  //                           Row(
  //                             children: [
  //                               const Text("Barcode"),
  //                               SizedBox(
  //                                   width: 100,
  //                                   height: 45,
  //                                   child: SwitchListTile(
  //                                       activeColor: Colors.green,
  //                                       inactiveTrackColor: Colors.red,
  //                                       value: isBarcode,
  //                                       onChanged: (newValue) => setState(() {
  //                                             isBarcode = newValue;
  //                                             saveSettings();
  //                                           }))),
  //                             ],
  //                           ),
  //                           Row(
  //                             children: [
  //                               const Text("Size"),
  //                               const SizedBox(width: 10),
  //                               DropdownButton<String>(
  //                                 value: optionPrintType,
  //                                 items: options.map((String option) {
  //                                   return DropdownMenuItem<String>(
  //                                     value: option,
  //                                     child: Text(option),
  //                                   );
  //                                 }).toList(),
  //                                 onChanged: (String? newValue) {
  //                                   setState(() {
  //                                     optionPrintType = newValue!;
  //                                     if (optionPrintType == "2 Inc") {
  //                                       selectedPaperSize = PaperSelect.Size57;
  //                                     } else {
  //                                       selectedPaperSize = PaperSelect.Size80;
  //                                     }
  //                                     saveSettings();
  //                                   });
  //                                 },
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ),
  //                     const Divider(),
  //                     Expanded(
  //                       child: ListView.builder(
  //                         itemCount: items.length,
  //                         itemBuilder: (context, index) {
  //                           return progress
  //                               ? Center(
  //                                   child: CircularProgressIndicator(
  //                                   backgroundColor: kPrimarySeedColor!,
  //                                 ))
  //                               : Card(
  //                                   shape: RoundedRectangleBorder(
  //                                     borderRadius: BorderRadius.circular(10.0),
  //                                     side: const BorderSide(
  //                                         color: Colors.grey, width: 1),
  //                                   ),
  //                                   child: ListTile(
  //                                     leading: items[index].name == "RPP02N"
  //                                         ? Icon(Icons.print,
  //                                             color: connected
  //                                                 ? kPrimarySeedColor!
  //                                                 : Colors.red)
  //                                         : Icon(Icons.bluetooth,
  //                                             color: connected
  //                                                 ? kPrimarySeedColor!
  //                                                 : Colors.red),
  //                                     title: Text(items[index].name),
  //                                     subtitle: Text(items[index].macAdress),
  //                                     onTap: () async {
  //                                       setState(() {
  //                                         progress = true;
  //                                         msjProgress = 'Connecting...';
  //                                       });

  //                                       String mac = items[index].macAdress;
  //                                       bool connectionResult;
  //                                       try {
  //                                         if (!connected) {
  //                                           connectionResult =
  //                                               await PrintBluetoothThermal
  //                                                   .connect(
  //                                             macPrinterAddress: mac,
  //                                           );

  //                                           if (kDebugMode) {
  //                                             print(
  //                                                 'Connection Result: $connectionResult');
  //                                           }

  //                                           if (connectionResult) {
  //                                             setState(() {
  //                                               connected = true;
  //                                               msjProgress = 'Connected';
  //                                             });
  //                                           } else {
  //                                             setState(() {
  //                                               msjProgress =
  //                                                   'Connection failed';
  //                                               connected = false;
  //                                             });
  //                                           }
  //                                         } else {
  //                                           await PrintBluetoothThermal
  //                                               .disconnect;
  //                                           setState(() {
  //                                             connected = false;
  //                                             msjProgress = 'Disconnected';
  //                                           });
  //                                         }
  //                                       } catch (e) {
  //                                         setState(() {
  //                                           msjProgress = 'Connection error';
  //                                         });
  //                                       } finally {
  //                                         setState(() {
  //                                           progress = false;
  //                                         });
  //                                       }

  //                                       // Print message if necessary
  //                                     },
  //                                   ));
  //                         },
  //                       ),
  //                     ),
  //                     connected
  //                         ? Center(
  //                             child: Padding(
  //                               padding: const EdgeInsets.all(10.0),
  //                               child: SlideAction(
  //                                 outerColor: kPrimarySeedColor,
  //                                 borderRadius: 12,
  //                                 elevation: 5,
  //                                 height: 60,
  //                                 sliderButtonIcon:
  //                                     const Icon(Icons.print, size: 20),
  //                                 text: "Slide to Print",
  //                                 onSubmit: () {
  //                                   return connected ? printGraphics() : null;
  //                                 },
  //                               ),
  //                             ),
  //                           )
  //                         : const Center(
  //                             child: Padding(
  //                               padding: EdgeInsets.all(10.0),
  //                               child: SlideAction(
  //                                 outerColor: Colors.grey,
  //                                 borderRadius: 12,
  //                                 elevation: 5,
  //                                 height: 60,
  //                                 sliderButtonIcon: Icon(Icons.print, size: 20),
  //                                 text: "Slide to Print",
  //                               ),
  //                             ),
  //                           ),
  //                     // Row(
  //                     //   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                     //   children: [
  //                     //     ElevatedButton(
  //                     //         onPressed: connected ? printGraphics : null,
  //                     //         child: const Text("Print")),
  //                     //     ElevatedButton(
  //                     //         style: ElevatedButton.styleFrom(
  //                     //             backgroundColor: Colors.redAccent),
  //                     //         onPressed: () {
  //                     //           Navigator.of(context).pop();
  //                     //         },
  //                     //         child: const Text("Cancel")),
  //                     //   ],
  //                     // )
  //                   ],
  //                 ),
  //               ],
  //             ),
  //           ),
  //         );
  //       });
  //     },
  //   );
  // }

  void saveSettings() {
    final newSettings =
        Settings(paperSelect: selectedPaperSize, isBarcode: isBarcode);
    if (kDebugMode) {
      print(newSettings);
    }
    preferenceService.saveSettings(newSettings);
  }

  void onCheckPrint({
    required BuyTicket purchaseData,
    required bool share,
  }) async {
    double numberLines = 200 * PdfPageFormat.mm;
    double leftPadding = 10 * PdfPageFormat.mm;

    PdfPageFormat pageFormat;
    if (selectedPaperSize == PaperSelect.Size80) {
      pageFormat = PdfPageFormat(80 * PdfPageFormat.mm, numberLines);
      leftPadding = 10 * PdfPageFormat.mm;
    } else {
      pageFormat = PdfPageFormat(57 * PdfPageFormat.mm, numberLines);
      leftPadding = 0 * PdfPageFormat.mm;
    }

    final pdf = pw.Document(version: PdfVersion.pdf_1_4);
    String userName = SharedPref.instance.getString("username") ?? "-";

    String address =
        'Retailer: $userName\r\nTrans ID:${purchaseData.internalRefNo}\r\nDraw Date: ${Helper.epocToMMddYYYYhhMMaa(purchaseData.drawStartTime!).toString()}\r\nDraw ID: ${widget.data.drawPlayGroupId}\r\nTotal Points: ${purchaseData.ticketPrice!.floor()}';

    pdf.addPage(pw.MultiPage(
      pageFormat: pageFormat,
      margin:
          pw.EdgeInsets.only(left: leftPadding, top: 2, right: 5, bottom: 3),
      build: (context) => [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              currentName,
              style: const pw.TextStyle(fontSize: 12),
              textAlign: pw.TextAlign.center,
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(top: 5),
              child: pw.Text(
                '(For Amusement Purpose Only)',
                style: pw.TextStyle(
                  fontSize: selectedPaperSize == PaperSelect.Size80 ? 12 : 8,
                ),
              ),
            ),
            pw.Text(
              purchaseData.gameName!,
              style: const pw.TextStyle(fontSize: 14),
            ),
            pw.Text(
              address,
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              "Points: ${purchaseData.price!.floor()}       Qty: ${purchaseData.ticketCount}",
              style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
        pw.ListView.builder(
          itemCount: purchaseData.tickets!.length,
          itemBuilder: (context, index) {
            String ticketNumber = purchaseData.tickets![index];

            if (selectedPaperSize == PaperSelect.Size80) {
              // For 80mm paper, print tickets and barcodes in pairs (left and right)
              int evenIndex = index * 2;
              int oddIndex = evenIndex + 1;

              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  // Ticket and Barcode for Even Index
                  if (evenIndex < purchaseData.tickets!.length)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 20),
                            child: pw.Text(purchaseData.tickets![evenIndex]
                                .split('-')[0])),
                        pw.SizedBox(
                          width: 80,
                          height: 30,
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.code128(),
                            data: purchaseData.tickets![evenIndex]
                                .split('-')
                                .last,
                          ),
                        ),
                      ],
                    ),
                  pw.SizedBox(width: 10), // Adjust spacing between columns

                  // Ticket and Barcode for Odd Index
                  if (oddIndex < purchaseData.tickets!.length)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                            padding: const pw.EdgeInsets.only(left: 20),
                            child: pw.Text(
                                purchaseData.tickets![oddIndex].split('-')[0])),
                        pw.SizedBox(
                          width: 80,
                          height: 30,
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.code128(),
                            data:
                                purchaseData.tickets![oddIndex].split('-').last,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            } else {
              // For 57mm paper, print tickets and barcodes one by one (stacked vertically)
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(
                      padding: const pw.EdgeInsets.only(left: 20),
                      child: pw.Text(ticketNumber.split("-").first)),
                  pw.SizedBox(
                    width: 80,
                    height: 30,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: ticketNumber.split("-").last,
                    ),
                  ),
                  pw.SizedBox(height: 5), // Space between entries on 57mm paper
                ],
              );
            }
          },
        ),
        pw.SizedBox(height: 20),
        pw.Padding(
          padding: pw.EdgeInsets.only(left: leftPadding),
          child: pw.Text(
            '**Ticket not for sale**',
            style: const pw.TextStyle(fontSize: 12),
          ),
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

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isPrinting = false; // Unlock after 2 seconds
      });
    });
  }

  //This is for Mobile  Bluetooth  Printer

  // Future getBluetooth() async {
  //   List? bluetooths = await BluetoothThermalPrinter.getBluetooths;
  //   if (kDebugMode) {
  //     print("Print $bluetooths");
  //   }
  //   setState(() {
  //     availableBluetoothDevices = bluetooths!;
  //   });
  // }

  // Future<void> setConnect(String mac) async {
  //   String result = BluetoothThermalPrinter.connect(mac).toString();

  //   if (kDebugMode) {
  //     print("state conneected $result");
  //   }
  //   if (connected == false) {
  //     setState(() {
  //       connected = true;
  //       log("Reconnecting3");
  //     });
  //   } else {
  //     Exception("Somthing is wrong");
  //   }
  // }

  // Future<void> printGraphics() async {
  //   bool isConnected = await PrintBluetoothThermal.connectionStatus;
  //   if (isConnected == "true") {
  //     // List<int> bytes = await getGraphicsTicket(
  //     //     purchaseData: widget.data,
  //     //     paperSize: selectedPaperSize.toString() == 'PaperSelect.Size80'
  //     //         ? "mm80"
  //     //         : "mm57");

  //     // final result = await PrintBluetoothThermal.writeBytes(bytes);
  //     String txtText = "hello";
  //     String text = '$txtText\n';
  //     bool result = await PrintBluetoothThermal.writeString(
  //         printText: PrintTextSize(size: int.parse("58 mm"), text: text));
  //     if (kDebugMode) {
  //       print("Print $result");
  //     }
  //   } else {
  //     print("getting error");
  //     //Hadnle Not Connected Senario
  //   }
  // }
  // Future<void> printGraphics() async {
  //   bool isConnected = await PrintBluetoothThermal.connectionStatus;
  //   if (isConnected == true) {
  //     List<int> bytes = await getGraphicsTicket(
  //         purchaseData: widget.data,
  //         paperSize: selectedPaperSize.toString() == 'PaperSelect.Size80'
  //             ? "mm80"
  //             : "mm57");
  //     final result = await PrintBluetoothThermal.writeBytes(bytes);
  //     // ignore: use_build_context_synchronously
  //     Navigator.of(context).pop();
  //     if (kDebugMode) {
  //       print("Print $result");
  //     }
  //   }
  // }

  Future getGraphicsTicket(
      {required BuyTicket purchaseData, required String paperSize}) async {
    List<int> bytes = [];

    String userName = SharedPref.instance.getString("username") ?? "-";

    String address =
        'Retailer: $userName\r\nTrans ID: ${purchaseData.internalRefNo}\r\nDraw Date: ${Helper.epocToMMddYYYYhhMMaa(purchaseData.drawStartTime!).toString()}\r\n\r\n Draw ID: ${widget.data.drawPlayGroupId}\r\nTotal Points: ${purchaseData.ticketPrice}';
    String points = 'Points: ${purchaseData.price}\r\n\r\n';
    String qty = 'Qty: ${purchaseData.ticketCount}\r\n\r\n';

    CapabilityProfile profile = await CapabilityProfile.load();
    final generator = Generator(
        paperSize == 'mm58' ? PaperSize.mm58 : PaperSize.mm80, profile);

    // ignore: unused_local_variable
    String ticketList =
        purchaseData.tickets!.map((e) => e.substring(0, 6)).join('');

    bytes += generator.text(currentName,
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size2,
          width: PosTextSize.size2,
        ));
    bytes += generator.text("(For Amusement Purpose Only)",
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));

    bytes += generator.row([
      PosColumn(
          text: purchaseData.gameName!,
          width: 12,
          styles: const PosStyles(align: PosAlign.right)),
    ]);

    bytes += generator.text(address,
        styles: const PosStyles(height: PosTextSize.size1));

    bytes += generator.row([
      PosColumn(
        text: points,
        width: 4,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
      PosColumn(
        text: "",
        width: 5,
        styles: const PosStyles(
          align: PosAlign.left,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ),
      ),
      PosColumn(
          text: qty,
          width: 3,
          styles: const PosStyles(
            align: PosAlign.left,
            height: PosTextSize.size1,
            width: PosTextSize.size1,
          ))
    ]);

    for (var i = 0; i < purchaseData.tickets!.length; i++) {
      String ticketStrList =
          purchaseData.tickets![i].toString().split('-')[0].toString();
      // bytes += generator.text(ticketStrList,
      //     styles: const PosStyles(align: PosAlign.left));
      bytes += generator.row([
        PosColumn(
            text: ticketStrList,
            width: 12,
            styles: const PosStyles(
                align: PosAlign.center, height: PosTextSize.size1)),
      ]);
      List<String> barcodeStrList =
          purchaseData.tickets![i].toString().split("-")[2].split('');

      if (kDebugMode) {
        print("This is my barcode List: $barcodeStrList");
      }

      isBarcode == true
          ? bytes += generator.barcode(
              Barcode.code39(barcodeStrList),
              width: 2,
              height: 100,
              align: PosAlign.center,
            )
          : bytes += generator.text("");
    }
    bytes += generator.text("**Ticket not for sale**",
        styles: const PosStyles(
          align: PosAlign.center,
          height: PosTextSize.size1,
          width: PosTextSize.size1,
        ));
    bytes += generator.cut();

    return bytes;
  }
}
