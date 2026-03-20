import 'dart:convert';

/// gameName : "WIN-WIN"
/// gameId : "winwin-mon"
/// drawId : "WW643223"
/// drawPlayGroupId : "WW23"
/// drawStartTime : "1650810092647"
/// price : 5.00
/// ticketCount : 3
/// ticketPrice : 15.00
/// balance : 23670.00
/// internalRefNo : "abfzs324"
/// tickets : ["123450-1-abfzs324f","123451-0-","123459-1-abfzs324g"]
/// errorCode : 0

BuyTicket buyTicketFromJson(String str) => BuyTicket.fromJson(json.decode(str));
String buyTicketToJson(BuyTicket data) => json.encode(data.toJson());

class BuyTicket {
  BuyTicket({
    this.gameName,
    this.gameId,
    this.drawId,
    this.drawPlayGroupId,
    this.drawStartTime,
    this.price,
    this.ticketCount,
    this.ticketPrice,
    this.balance,
    this.internalRefNo,
    this.tickets,
    this.errorCode,
  });

  BuyTicket.fromJson(dynamic json) {
    gameName = json['gameName'];
    gameId = json['gameId'];
    drawId = json['drawId'];
    drawPlayGroupId = json['drawPlayGroupId'];
    drawStartTime = json['drawStartTime'];
    price = json['price'];
    ticketCount = json['ticketCount'];
    ticketPrice = json['ticketPrice'];
    balance = json['balance'];
    internalRefNo = json['internalRefNo'];
    tickets = json['tickets'] != null ? json['tickets'].cast<String>() : [];
    errorCode = json['errorCode'];
  }
  String? gameName;
  String? gameId;
  String? drawId;
  String? drawPlayGroupId;
  int? drawStartTime;
  double? price;
  int? ticketCount;
  double? ticketPrice;
  double? balance;
  String? internalRefNo;
  List<String>? tickets;
  int? errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gameName'] = gameName;
    map['gameId'] = gameId;
    map['drawId'] = drawId;
    map['drawPlayGroupId'] = drawPlayGroupId;
    map['drawStartTime'] = drawStartTime;
    map['price'] = price;
    map['ticketCount'] = ticketCount;
    map['ticketPrice'] = ticketPrice;
    map['balance'] = balance;
    map['internalRefNo'] = internalRefNo;
    map['tickets'] = tickets;
    map['errorCode'] = errorCode;
    return map;
  }
}
