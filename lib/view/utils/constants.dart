import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:series_2d/data/models/series_2d_game_init_model.dart';
String lottoMaxCountTicketBuy="";
Color? kPrimarySeedColor;
const Color kPrimarySeedOrangeColor = Color(0xffED7014);
Color? kScaffoldBackgroundColor = Colors.grey[200];
// const kPrimarySeedColor = Color(0xff257a02);
bool series2dSelection = false;
Series2DGameInit? series2dGameInitValue;
const kDefaultPadding = 16.0;
var mySystemTheme =
    SystemUiOverlayStyle.light.copyWith(systemNavigationBarColor: Colors.white);
String currentName = "";
String logoPath = "";
String titile = "JACKPOT";

List<dynamic> gameName = [
  {"name": "PLAY SUPER JACKPOT", "color": const Color(0xff1c7d4a)},
  {"name": "PLAY LOTTO", "color": const Color(0xffED7014)},
 // {"name": "PLAY SUPER JACKPOT", "color": const Color.fromARGB(255, 236, 149, 90)},
];

List<dynamic> logoPathSet = [
  "assets/images/jackpot.png",
  "assets/images/logoPlay.png",
  "assets/images/jackpot.png"
];

//Text Design
Text appBarText(String titile) {
  return Text(
    titile,
    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
  );
}


// Map<String,dynamic> gameTypeSelection3dConfig = {};
// bool gameLowPrizeIsSelection = false; 