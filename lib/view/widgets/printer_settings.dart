import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/settings_services/shared_preferences.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PrinterSettings extends StatefulWidget {
  const PrinterSettings({Key? key}) : super(key: key);

  @override
  State<PrinterSettings> createState() => _PrinterSettingsState();
}

class _PrinterSettingsState extends State<PrinterSettings> {
  final preferenceService = PreferencesServices();

  var selectedPaperSize = PaperSelect.Size57;
  var isBarcode = true;

  @override
  void initState() {
    super.initState();
    _populateFields();
    getCheckValue();
  }

  void _populateFields() async {
    final settings = await preferenceService.getSettings();
    setState(() {
      selectedPaperSize = settings.paperSelect;
      isBarcode = settings.isBarcode;
    });
  }

  // Function to save integer value
  Future<void> saveCheckValue(int value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt('check', value);
  }

// Function to retrieve integer value
  Future getCheckValue() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    debugPrint("Chcking value : ${prefs.getInt('check')}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Printer Settings"),
        centerTitle: true,
        actions: [CustomCloseButton()],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20.0),
            child: Text(
              "Paper Size",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Column(
              children: [
                _buildPaperSizeOption(PaperSelect.Size57, "2 inch"),
                const SizedBox(height: 10),
                _buildPaperSizeOption(PaperSelect.Size80, "3 inch"),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: Row(
              children: [
                const Text(
                  "Barcode",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Switch(
                  activeColor: Colors.green,
                  inactiveTrackColor: Colors.red,
                  value: isBarcode,
                  onChanged: (newValue) => setState(() {
                    isBarcode = newValue;
                    if (kDebugMode) {
                      print(isBarcode);
                    }
                  }),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Align(
              alignment: Alignment.bottomCenter,
              child: SizedBox(
                child: ElevatedButton(
                  onPressed: () {
                    _saveSettings();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Changes Saved")),
                    );
                  },
                  child: const Text("Save Settings"),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaperSizeOption(PaperSelect size, String label) {
    return SizedBox(
      width: double.infinity,
      child: RadioListTile(
        title: Text(label),
        tileColor: Colors.grey.shade300,
        value: size,
        activeColor: Colors.green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
        groupValue: selectedPaperSize,
        onChanged: (value) => setState(() {
          selectedPaperSize = value as PaperSelect;
          if (kDebugMode) {
            print(selectedPaperSize);
          }
        }),
      ),
    );
  }

  void _saveSettings() {
    saveCheckValue(1);
    final newSettings =
        Settings(paperSelect: selectedPaperSize, isBarcode: isBarcode);
    if (kDebugMode) {
      print(newSettings);
    }
    preferenceService.saveSettings(newSettings);
  }
}
