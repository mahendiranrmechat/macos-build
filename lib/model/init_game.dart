import 'dart:convert';

/// categoryId : 1
/// gameId : "winwin"
/// drawId : "90"
/// gameName : null
/// digits : 6
/// price : 40.00
/// winPrice : 600000.00
/// status : 1
/// drawStartTime : 1687059000000
/// betCloseTime : 1687057200000
/// ticketNos : ["940435","755145","058827","456476","203857"]
/// balance : 10000.00
/// errorCode : 0

InitGame initGameFromJson(String str) => InitGame.fromJson(json.decode(str));
String initGameToJson(InitGame data) => json.encode(data.toJson());

class InitGame {
  InitGame({
    this.categoryId,
    this.gameId,
    this.drawId,
    this.gameName,
    this.drawPlayGroupId,
    this.digits,
    this.price,
    this.winPrice,
    this.status,
    this.drawStartTime,
    this.betCloseTime,
    this.ticketNos,
    this.balance,
    this.errorCode,
  });

  InitGame.fromJson(dynamic json) {
    categoryId = json['categoryId'];
    gameId = json['gameId'];
    drawId = json['drawId'];
    drawPlayGroupId = json['drawPlayGroupId'];
    gameName = json['gameName'];
    digits = json['digits'];
    price = json['price'];
    winPrice = json['winPrice'];
    status = json['status'];
    drawStartTime = json['drawStartTime'];
    betCloseTime = json['betCloseTime'];
    ticketNos =
        json['ticketNos'] != null ? json['ticketNos'].cast<String>() : [];
    balance = json['balance'];
    errorCode = json['errorCode'];
  }
  int? categoryId;
  String? gameId;
  String? drawId;
  String? drawPlayGroupId;
  dynamic gameName;
  int? digits;
  double? price;
  double? winPrice;
  int? status;
  int? drawStartTime;
  int? betCloseTime;
  List<String>? ticketNos;
  double? balance;
  int? errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['categoryId'] = categoryId;
    map['gameId'] = gameId;
    map['drawId'] = drawId;
    map['drawPlayGroupId'] = drawPlayGroupId;
    map['gameName'] = gameName;
    map['digits'] = digits;
    map['price'] = price;
    map['winPrice'] = winPrice;
    map['status'] = status;
    map['drawStartTime'] = drawStartTime;
    map['betCloseTime'] = betCloseTime;
    map['ticketNos'] = ticketNos;
    map['balance'] = balance;
    map['errorCode'] = errorCode;
    return map;
  }
}
