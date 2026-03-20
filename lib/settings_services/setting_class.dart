// ignore: constant_identifier_names
enum PaperSelect { Size57, Size80 }

//create settings class
class Settings {
  final PaperSelect paperSelect;
  final bool isBarcode;

  Settings({required this.paperSelect, required this.isBarcode});
}
