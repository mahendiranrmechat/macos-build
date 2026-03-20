import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:psglotto/settings_services/shared_preferences.dart';
import '../../settings_services/setting_class.dart';

class PrinterSettingsWeb extends StatefulWidget {
  const PrinterSettingsWeb({Key? key}) : super(key: key);

  @override
  State<PrinterSettingsWeb> createState() => _PrinterSettingsWebState();
}

class _PrinterSettingsWebState extends State<PrinterSettingsWeb> {
  final preferenceService = PreferencesServices();

  var selectedPaperSize = PaperSelect.Size57;
  var isBarcode = false;

  int select = 0;

  @override
  void initState() {
    super.initState();
    _populateFileds();
  }



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
        title: const Text("Printer Settings"),
        centerTitle: true,
      ),
      body: Column(children: [
        Container(
          width: MediaQuery.of(context).size.width,
          height: 300,
          color: Colors.grey.withOpacity(0.2),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(20.0),
                child: Text(
                  "Printer Settings",
                  style: TextStyle(
                      color: Colors.black, fontWeight: FontWeight.bold),
                ),
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  // Platform.isWindows
                  //     ? const Padding(
                  //         padding: EdgeInsets.only(top: 15),
                  //         child: Text(
                  //           "Paper Size",
                  //           style: TextStyle(
                  //               color: Colors.black,
                  //               fontWeight: FontWeight.w500),
                  //         ),
                  //       )
                  //     : const SizedBox(),
                  SizedBox(
                    width: 140,
                    height: 45,
                    child: RadioListTile(
                        title: const Text("2 inch"),
                        tileColor: Colors.grey.shade300,
                        value: PaperSelect.Size57,
                        activeColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        groupValue: selectedPaperSize,
                        onChanged: (value) => setState(() {
                              selectedPaperSize = value as PaperSelect;
                              if (kDebugMode) {
                                print(selectedPaperSize);
                              }
                            })),
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  SizedBox(
                    width: 140,
                    height: 45,
                    child: RadioListTile(
                        title: const Text("3 inch"),
                        tileColor: Colors.grey.shade300,
                        activeColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        value: PaperSelect.Size80,
                        groupValue: selectedPaperSize,
                        onChanged: (value) => setState(() {
                              selectedPaperSize = value as PaperSelect;
                              if (kDebugMode) {
                                print(selectedPaperSize);
                              }
                            })),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              SizedBox(
                // width: Platform.isWindows ? 505 : 450,
                height: 50,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    const SizedBox(
                      width: 140,
                      height: 45,
                      child: Center(
                        child: Text(
                          "Barcode ",
                          style: TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    SizedBox(
                        width: 140,
                        height: 45,
                        child: SwitchListTile(
                            activeColor: Colors.green,
                            inactiveTrackColor: Colors.red,
                            value: isBarcode,
                            onChanged: (newValue) => setState(() {
                                  isBarcode = newValue;
                                  if (kDebugMode) {
                                    print(isBarcode);
                                  }
                                }))),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
            onPressed: () {
              _saveSettings();
              ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text(" Changes Saved ")));
            },
            child: const Text("Save Settings")),
      ]),
    );
  }

  void _saveSettings() {
    final newSettings =
        Settings(paperSelect: selectedPaperSize, isBarcode: isBarcode);
    if (kDebugMode) {
      print(newSettings);
    }
    preferenceService.saveSettings(newSettings);
  }
}
