import 'dart:async';
import 'dart:io' as pw;
import 'dart:io';
//import 'package:esc_pos_utils/esc_pos_utils.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils.dart';
// import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pdf/pdf.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';
import 'package:printing/printing.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/home/game_time_helper_widgets/tab_color.dart';
import 'package:psglotto/model/buy_ticket_others.dart' as d;
import 'package:pdf/widgets.dart' as pw;
import 'package:psglotto/view/widgets/snackbar.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:slide_to_act/slide_to_act.dart';

import '../../../../settings_services/shared_preferences.dart';
import '../../../../update_value_2d_game.dart/init_game_others_notifier.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

// ignore: must_be_immutable
class PurchasedTicket2DGame extends ConsumerStatefulWidget {
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
  bool autoPrint;
  PurchasedTicket2DGame(
      {required this.autoPrint,
      required this.gameValue,
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
  ConsumerState<PurchasedTicket2DGame> createState() =>
      _PurchasedTicket2DGameState();
}

class _PurchasedTicket2DGameState extends ConsumerState<PurchasedTicket2DGame> {
  bool connected = false; //bluetooth connect
  List availableBluetoothDevices = []; // availableBluetoothDevices for mobile

  final preferenceService = PreferencesServices();
  var selectedPaperSize = PaperSelect.Size57;
  var isBarcode = false;
  bool isPrinting = false;
  late File pdfFile;
  // late Printer defaultPrinter;
  late final pw.Directory directory;

  Map<String, List<String>> betTypesValues = {};
  Map<String, List<String>> typedMap = {};
  List<Map<String, dynamic>> myList = [];
  Map<String, dynamic> typesMap = {};
  //last Updated
  List<Map<String, dynamic>> updatedTypes = [];
  //? Bluetooth device
  //Get Bluetooth devices
  //List<BluetoothInfo> items = [];
  bool progress = false;
  String msjProgress = '';
  String info = '';
  BluetoothAdapterState adapterState = BluetoothAdapterState.unknown;
  //check stream subscription
  StreamSubscription<BluetoothAdapterState>? adapterStateStateSubscription;
  List<String> options = ['2 Inc', '3 Inc'];
  String optionPrintType = '2 Inc';
  Printer? defaultPrinter;
  String username = "-";
  List<Printer> printers = [];
  bool autoPrintStatus = false;
  @override
  void initState() {
    setState(() {
      autoPrintStatus = widget.autoPrint;
      username = SharedPref.instance.getString("username") ?? "-";
    });

    super.initState();
    adapterStateStateSubscription =
        FlutterBluePlus.adapterState.listen((state) {
      adapterState = state;
    });

    setupPrinter();
    populateFileds();
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
      autoPrint();
      // Convert the input string to valid JSON by enclosing the keys and values in quotes
    });
  }

  void autoPrint() {
    Future.delayed(const Duration(seconds: 1), () {
      if (autoPrintStatus) {
        onCheckPrint(myList: myList, share: false);
      }
    });
  }

  @override
  void dispose() {
    adapterStateStateSubscription!.cancel();
    super.dispose();
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

  bool screenSizeChanger = false;

  @override
  Widget build(BuildContext context) {
    screenSizeChanger = MediaQuery.of(context).size.width < 1400 ? true : false;
    return Scaffold(
      appBar: AppBar(
        leadingWidth: 110,
        leading: Row(
          children: [
            const BackButton(),
            Text(username, style: const TextStyle(fontWeight: FontWeight.bold))
          ],
        ),
        centerTitle: true,
        title: Text(
          "Purchase Status",
          style: TextStyle(fontSize: Platform.isAndroid ? 17 : 20),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Game name: ${widget.gameName}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text("Draw id: ${widget.drawId}",
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          )
        ],
      ),

      // ignore: deprecated_member_use
      body: WillPopScope(
        onWillPop: () async {
          // ignore: unused_result
          ref.refresh(balanceProvider);
          return true;
        },
        child: Column(
          children: [
            Expanded(
              flex: 8,
              child: Container(
                color: Colors.white,
                child: ListView.builder(
                    itemCount: updatedTypes.length,
                    itemBuilder: (context, index) {
                      // int heightValue = updatedTypes[index]['betTypes']
                      //     .toString()
                      //     .split(",")
                      //     .length;
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
                              color: Colors.white,
                              child: Wrap(
                                spacing: 1.0,
                                runSpacing: 5,
                                children: myList[index]['betValue']
                                    .toString()
                                    .split(',')
                                    .map((betValue) {
                                  final values = betValue.split('-');
                                  return Container(
                                    width: 60,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(5),
                                      color: kPrimarySeedColor,
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          values[0].replaceAll('[', ''),
                                          style: const TextStyle(
                                              color: Colors.white),
                                        ),
                                        Container(
                                          width: double.infinity,
                                          height: 20,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.only(
                                              bottomLeft: Radius.circular(5),
                                              bottomRight: Radius.circular(5),
                                            ),
                                            color: getColorByType(
                                                updatedTypes[index]['typeId']),
                                          ),
                                          child: Center(
                                            child: Text(
                                              values[1].replaceAll(']', ''),
                                              style: const TextStyle(
                                                  color: Colors.white),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                }).toList(),
                              ),
                            )
                          ],
                        ),
                      );
                      // : Padding(
                      //     padding: const EdgeInsets.all(2.0),
                      //     child: Column(
                      //       mainAxisAlignment: MainAxisAlignment.start,
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Row(
                      //           children: [
                      //             Padding(
                      //               padding:
                      //                   const EdgeInsets.only(left: 10),
                      //               child: Text(
                      //                 updatedTypes[index]['typeName'],
                      //               ),
                      //             ),
                      //             Padding(
                      //               padding:
                      //                   const EdgeInsets.only(left: 10),
                      //               child: Text(
                      //                 "(${InitGameOthersProvider.getInitGameOthers()['types'][index]['price'].toString()})",
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         Container(
                      //             height: heightValue <= 5
                      //                 ? 60
                      //                 : heightValue >= 6 &&
                      //                         heightValue <= 10
                      //                     ? 120
                      //                     : heightValue >= 11 &&
                      //                             heightValue <= 15
                      //                         ? 180
                      //                         : heightValue >= 16 &&
                      //                                 heightValue <= 20
                      //                             ? 240
                      //                             : heightValue >= 21 &&
                      //                                     heightValue <= 25
                      //                                 ? 300
                      //                                 : heightValue >= 26 &&
                      //                                         heightValue <=
                      //                                             30
                      //                                     ? 360
                      //                                     : heightValue >=
                      //                                                 31 &&
                      //                                             heightValue <=
                      //                                                 35
                      //                                         ? 420
                      //                                         : heightValue >=
                      //                                                     36 &&
                      //                                                 heightValue <=
                      //                                                     40
                      //                                             ? 480
                      //                                             : heightValue >= 41 &&
                      //                                                     heightValue <= 45
                      //                                                 ? 500
                      //                                                 : heightValue >= 46 && heightValue <= 50
                      //                                                     ? 550
                      //                                                     : heightValue >= 51 && heightValue <= 55
                      //                                                         ? 640
                      //                                                         : heightValue >= 56 && heightValue <= 60
                      //                                                             ? 640
                      //                                                             : heightValue >= 61 && heightValue <= 65
                      //                                                                 ? 780
                      //                                                                 : heightValue >= 66 && heightValue <= 70
                      //                                                                     ? 800
                      //                                                                     : heightValue >= 71 && heightValue <= 75
                      //                                                                         ? 800
                      //                                                                         : heightValue >= 76 && heightValue <= 80
                      //                                                                             ? 960
                      //                                                                             : heightValue >= 81 && heightValue <= 85
                      //                                                                                 ? 1020
                      //                                                                                 : heightValue >= 86 && heightValue <= 90
                      //                                                                                     ? 1080
                      //                                                                                     : heightValue >= 91 && heightValue <= 95
                      //                                                                                         ? 1140
                      //                                                                                         : heightValue >= 96 && heightValue <= 100
                      //                                                                                             ? 1200
                      //                                                                                             : heightValue >= 101 && heightValue <= 105
                      //                                                                                                 ? 1260
                      //                                                                                                 : heightValue >= 106 && heightValue <= 110
                      //                                                                                                     ? 1320
                      //                                                                                                     : heightValue >= 111 && heightValue <= 115
                      //                                                                                                         ? 1380
                      //                                                                                                         : heightValue >= 116 && heightValue <= 120
                      //                                                                                                             ? 1440
                      //                                                                                                             : 0,
                      //             color: Colors.white,
                      //             child: GridView.builder(
                      //                 physics: const NeverScrollableScrollPhysics(),
                      //                 itemCount: myList[index]['betValue'].toString().split(',').length,
                      //                 gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      //                   childAspectRatio: 1.5,
                      //                   mainAxisSpacing: 0.5,
                      //                   crossAxisSpacing: 1.0,
                      //                   crossAxisCount: 5,
                      //                 ),
                      //                 itemBuilder: (context, i) {
                      //                   return Column(
                      //                     children: [
                      //                       Padding(
                      //                         padding:
                      //                             const EdgeInsets.only(
                      //                                 left: 1, right: 1),
                      //                         child: Container(
                      //                           width: 60,
                      //                           height: 20,
                      //                           decoration: BoxDecoration(
                      //                             borderRadius:
                      //                                 const BorderRadius
                      //                                     .only(
                      //                                     topLeft: Radius
                      //                                         .circular(5),
                      //                                     topRight: Radius
                      //                                         .circular(5)),
                      //                             color: kPrimarySeedColor,
                      //                           ),
                      //                           child: Center(
                      //                             //[[6-2,  B7-4,  18-1]]
                      //                             //[[6-1,  B7-1,  18-1, 31-1, 32-1, 34-1, 39-1, 46-1, 55-1, 60-1]]
                      //                             child: Text(
                      //                               myList[index]
                      //                                       ['betValue'][i]
                      //                                   .toString()
                      //                                   .split('-')[0]
                      //                                   .replaceAll(
                      //                                       '[', ''),
                      //                               style: const TextStyle(
                      //                                   color:
                      //                                       Colors.white),
                      //                             ),
                      //                           ),
                      //                         ),
                      //                       ),
                      //                       Container(
                      //                         width: 60,
                      //                         height: 20,
                      //                         decoration: BoxDecoration(
                      //                           borderRadius:
                      //                               const BorderRadius.only(
                      //                                   bottomLeft:
                      //                                       Radius.circular(
                      //                                           5),
                      //                                   bottomRight:
                      //                                       Radius.circular(
                      //                                           5)),
                      //                           color: getColorByType(
                      //                               updatedTypes[index]
                      //                                   ['typeId']),
                      //                         ),
                      //                         child: Center(
                      //                           child: Text(
                      //                             myList[index]['betValue']
                      //                                     [i]
                      //                                 .toString()
                      //                                 .split('-')[1]
                      //                                 .replaceAll(']', ''),
                      //                             style: const TextStyle(
                      //                                 color: Colors.white),
                      //                           ),
                      //                         ),
                      //                       )
                      //                     ],
                      //                   );
                      //                 }))
                      //       ],
                      //     ),
                      //   );
                    }),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                children: [
                  const SizedBox(
                    height: 16 / 2,
                  ),
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
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              onCheckPrint(myList: myList, share: true);
                            },
                            icon: const Icon(Icons.share),
                          ),
                          IconButton(
                            onPressed: isPrinting
                                ? null
                                : () async {
                                    setState(() {
                                      isPrinting = true; // Lock processing
                                    });
                                    if (Platform.isAndroid) {
                                      //first check bluetooth is on or off
                                      if (adapterState ==
                                          BluetoothAdapterState.on) {
                                        // //check app permission
                                        // PermissionStatus permission =
                                        //     await Permission.bluetooth.request();

                                        // if (permission.isGranted) {
                                        //   getBluetoothDevices();
                                        // } else {
                                        //   openAppSettings();
                                        // }
                                      } else {
                                        showSnackBar(
                                            context, "Please Enable Bluetooth");
                                      }
                                    } else {
                                      if (printers.isNotEmpty) {
                                        onCheckPrint(
                                            myList: myList, share: false);
                                      } else {
                                        showSnackBar(
                                            context, "No printers available!");
                                      }
                                    }
                                  },
                            icon: const Icon(Icons.print),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  //alret box for the device list show

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

  onCheckPrint({
    required myList,
    required bool share,
  }) async {
    final font = await PdfGoogleFonts.robotoFlexRegular();

    //double numberLines = double.infinity * PdfPageFormat.mm;
    // var printFormat = PdfPageFormat(57 * PdfPageFormat.mm, numberLines);

    // Define a global font size
    const double globalFontSize = 9.0;

    String userName = SharedPref.instance.getString("username") ?? "-";

    String address =
        'Retailer: $userName\r\nDraw Date: ${Helper.epocToMMddYYYYhhMMaa(widget.drawStartTime).toString()}\r\nDraw ID: ${widget.drawId}';
    String points = 'Points: ${widget.ticketPrice}';
    String qty = 'Qty: ${widget.ticketCount}';

    final pdf = pw.Document(version: PdfVersion.pdf_1_4);

    pdf.addPage(pw.MultiPage(
      //pageFormat: printFormat,
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
            pw.Text("Game name: ${widget.gameName}",
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text(address,
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text(points,
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            pw.Text(qty,
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
          ],
        ),
        pw.ListView.builder(
          itemCount: myList.length,
          itemBuilder: (context, index) {
            int currentValue = updatedTypes.length - 1;
            return pw.Container(
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.ListView.builder(
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
                            .skip(i *
                                (selectedPaperSize == PaperSelect.Size57
                                    ? 4
                                    : 6)) // Adjust the column count here
                            .take(selectedPaperSize == PaperSelect.Size57
                                ? 4
                                : 6) // Adjust the column count here
                            .toList(),
                      );

                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            mainAxisAlignment:
                                pw.MainAxisAlignment.spaceBetween,
                            children: [
                              pw.Row(children: [
                                pw.Text(
                                  '${widget.gameValue[index].typeName} (${InitGameOthersProvider.getInitGameOthers()['types'][index]['price'].toString()})  \n',
                                  style: pw.TextStyle(
                                      fontSize: globalFontSize, font: font),
                                ),
                                pw.Text(
                                  "Qty ${myList[index]['betValue'].toString().replaceAll("[", "").replaceAll(" ", "").trim().replaceAll("]", "").split(',').length}",
                                  style: pw.TextStyle(
                                      fontSize: globalFontSize, font: font),
                                ),
                              ])
                            ],
                          ),
                          pw.SizedBox(height: 2),
                          pw.Align(
                            // ignore: deprecated_member_use
                            child: pw.Table.fromTextArray(
                                cellAlignment: pw.Alignment.center,
                                defaultColumnWidth:
                                    const pw.IntrinsicColumnWidth(),
                                context: null,
                                data: rows,
                                headerStyle: pw.TextStyle(
                                    fontSize: globalFontSize, font: font),
                                cellStyle: pw.TextStyle(
                                    fontSize: globalFontSize, font: font),
                                headerAlignment: pw.Alignment.centerLeft,
                                border: pw.TableBorder.all(
                                    color: PdfColors.white, width: 0),
                                cellHeight: 1,
                                tableWidth: pw.TableWidth.min),
                          )
                        ],
                      );
                    },
                  ),
                ],
              ),
            );
          },
        ),
        isBarcode
            ? pw.SizedBox(
                width: 100,
                height: 40,
                child: pw.BarcodeWidget(
                    barcode: pw.Barcode.code128(), data: widget.barCode),
              )
            : pw.SizedBox.shrink(),
        //pw.SizedBox(height: 5), // Adjust this value to control bottom spacing
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
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isPrinting = false; // Unlock after 2 seconds
      });
    });
  }

  // Future<void> printGraphics() async {
  //   bool isConnected = await PrintBluetoothThermal.connectionStatus;
  //   if (isConnected == true) {
  //     List<int> bytes = await getGraphicsTicket(
  //         purchaseData: updatedTypes,
  //         paperSize: selectedPaperSize.toString() == 'PaperSelect.Size80'
  //             ? "mm80"
  //             : "mm57");
  //     final result = await PrintBluetoothThermal.writeBytes(bytes);
  //     // ignore: use_build_context_synchronously
  //     Navigator.of(context).pop();
  //     if (kDebugMode) {
  //       print("Print $result");
  //     }
  //   } else {
  //     //Hadnle Not Connected Senario
  //   }
  // }

  Future getGraphicsTicket(
      {required List<Map<String, dynamic>> purchaseData,
      required String paperSize}) async {
    List<int> bytes = [];

    String userName = SharedPref.instance.getString("username") ?? "-";

    String address =
        'Retailer: $userName\r\n\r\nTrans ID: ${widget.internalRefNo}\r\n\r\nDraw Date: ${Helper.epocToMMddYYYYhhMMaa(widget.drawStartTime).toString()}\r\n\r\nDraw ID: ${widget.drawId}\r\n\r\nTotal Points: ${widget.price} ';
    String points = 'Points: ${widget.ticketPrice}\r\n\r\n';
    String qty = 'Qty: ${widget.ticketCount}\r\n\r\n';
    final profile = await CapabilityProfile.load();

    final generator = Generator(
        paperSize == 'mm58' ? PaperSize.mm58 : PaperSize.mm80, profile);

    // // ignore: unused_local_variable
    // String ticketList =
    //     purchaseData.tickets!.map((e) => e.substring(0, 6)).join('');

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
          text: widget.gameName,
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
    List<String> ticketValues = [];
    for (int i = 0; i < updatedTypes.length; i++) {
      //Print Type Name
      Map<String, dynamic> type = updatedTypes[i];
      Map<String, String> betTypes = type['betTypes'];
      String betTypeName = type['typeName'];

      //new list to hold all values
      List<String> betTypeValuesList = [];

      // Populate the list with all the values
      for (var entry in betTypes.entries) {
        String betTypeValue = entry.value;
        if (betTypeValue.isNotEmpty) {
          betTypeValuesList.add(betTypeValue);
        }
      }

      // Split the betTypeValuesList into chunks of 5 values
      List<List<String>> betTypeValueChunks = [];
      int ticketSize = 5;
      for (int i = 0; i < betTypeValuesList.length; i += ticketSize) {
        int endIndex = i + ticketSize;
        if (endIndex > betTypeValuesList.length) {
          endIndex = betTypeValuesList.length;
        }
        List<String> chunk = betTypeValuesList.sublist(i, endIndex);
        betTypeValueChunks.add(chunk);
      }

      // Create a single string with chunks of 5 values each
      for (List<String> chunk in betTypeValueChunks) {
        String ticketStr = '$betTypeName\n${chunk.join(',')}\n';
        ticketValues.add(ticketStr);
      }
    }

    String ticketStrList = ticketValues.join();

    int chunkSize = 6;
    List<String> ticketStrChunks = [];
    for (int i = 0; i < ticketStrList.split(",").length; i += chunkSize) {
      int endIndex = i + chunkSize;
      if (endIndex > ticketStrList.split(",").length) {
        endIndex = ticketStrList.split(",").length;
      }
      List<String> chunk = ticketStrList.split(",").sublist(i, endIndex);
      ticketStrChunks.add(chunk.join(','));
    }

    String finalTicketStrList = ticketStrChunks.join('\n');

    if (kDebugMode) {
      print(finalTicketStrList);
    } // Print in groups of five values per line

    bytes += generator.text(finalTicketStrList,
        styles: const PosStyles(height: PosTextSize.size1));
    //parse and convert barcode data
    String barcodeValue = widget.barCode;
// Generate a barcode image
    final List<int> barData = barcodeValue.split('').map(int.parse).toList();
    isBarcode
        ? bytes += generator.barcode(Barcode.ean13(barData), width: 3)
        : null;

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
