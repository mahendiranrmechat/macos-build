// To parse this JSON data, do
//
//     final userResults2D = userResults2DFromMap(jsonString);

import 'dart:convert';

UserResults2D userResults2DFromMap(String str) =>
    UserResults2D.fromMap(json.decode(str));

String userResults2DToMap(UserResults2D data) => json.encode(data.toMap());

class UserResults2D {
  UserResults2D({
    this.results,
    this.page,
    this.totalPages,
    this.unClaimedTickets,
    this.unClaimedPrice,
    this.errorCode,
  });

  List<Result>? results;
  int? page;
  int? totalPages;
  int? unClaimedTickets;
  num? unClaimedPrice;
  int? errorCode;

  factory UserResults2D.fromMap(Map<String, dynamic> json) => UserResults2D(
        results: json["results"] == null
            ? []
            : List<Result>.from(json["results"]!.map((x) => Result.fromMap(x))),
        page: json["page"],
        totalPages: json["totalPages"],
        unClaimedTickets: json["unClaimedTickets"],
        unClaimedPrice: json["unClaimedPrice"],
        errorCode: json["errorCode"],
      );

  Map<String, dynamic> toMap() => {
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toMap())),
        "page": page,
        "totalPages": totalPages,
        "unClaimedTickets": unClaimedTickets,
        "unClaimedPrice": unClaimedPrice,
        "errorCode": errorCode,
      };
}

class Result {
  Result({
    this.gameId,
    this.winName,
    this.gameName,
    this.ticketNo,
    this.winPrice,
    this.jackpotPrice,
    this.totalWinPrice,
    this.ticketPrice,
    this.price,
    this.drawId,
    this.claim,
    this.drawPlayGroupId,
    this.time,
    this.ticketId,
    this.barCode,
    this.purchaseTime,
    this.status,
  });

  String? gameId;
  List<dynamic>? winName;
  String? gameName;
  List<TicketNo>? ticketNo;
  double? winPrice;
  double? jackpotPrice;
  double? totalWinPrice;
  double? ticketPrice;
  double? price;
  String? drawId;
  int? claim;
  String? drawPlayGroupId;
  String? time;
  String? ticketId;
  String? barCode;
  String? purchaseTime;
  int? status;

  factory Result.fromMap(Map<String, dynamic> json) => Result(
        gameId: json["gameId"],
        winName: json["winName"] == null
            ? []
            : List<dynamic>.from(json["winName"]!.map((x) => x)),
        gameName: json["gameName"],
        ticketNo: json["ticketNo"] == null
            ? []
            : List<TicketNo>.from(
                json["ticketNo"]!.map((x) => TicketNo.fromMap(x))),
        winPrice: json["winPrice"],
        jackpotPrice: json["jackpotPrice"],
        totalWinPrice: json["totalWinPrice"],
        price: json["price"],
        drawId: json["drawId"],
        claim: json["claim"],
        drawPlayGroupId: json["drawPlayGroupId"],
        time: json["time"],
        ticketId: json["ticketId"],
        barCode: json["barCode"],
        ticketPrice: json["ticketPrice"],
        purchaseTime: json["purchaseTime"],
        status: json["status"],
      );

  Map<String, dynamic> toMap() => {
        "gameId": gameId,
        "winName":
            winName == null ? [] : List<dynamic>.from(winName!.map((x) => x)),
        "gameName": gameName,
        "ticketNo": ticketNo == null
            ? []
            : List<dynamic>.from(ticketNo!.map((x) => x.toMap())),
        "winPrice": winPrice,
        "jackpotPrice": jackpotPrice,
        "totalWinPrice": totalWinPrice,
        "ticketPrice": ticketPrice,
        "price": price,
        "drawId": drawId,
        "claim": claim,
        "drawPlayGroupId": drawPlayGroupId,
        "time": time,
        "ticketId": ticketId,
        "purchaseTime": purchaseTime,
        "barCode": barCode,
        "status": status,
      };
}

class TicketNo {
  TicketNo({
    this.typeName,
    this.typeId,
    this.price,
    this.betTypes,
    this.jackpotType, // New field
    this.jackpotPrice, // New field
  });

  String? typeName;
  int? typeId;
  num? price;
  Map<String, Map<String, int>>? betTypes;
  String? jackpotType; // New field
  int? jackpotPrice; // New field

  factory TicketNo.fromMap(Map<String, dynamic> json) => TicketNo(
        typeName: json["typeName"] as String?,
        typeId: json["typeId"] as int?,
        price: json["price"] as num?,
        betTypes: json["betTypes"] != null
            ? Map.from(json["betTypes"]).map((k, v) =>
                MapEntry<String, Map<String, int>>(
                    k, Map.from(v).map((k, v) => MapEntry<String, int>(k, v))))
            : null,
        jackpotType: json["jackpotType"] as String?, // Parse new field
        jackpotPrice: json["jackpotPrice"] as int?, // Parse new field
      );

  Map<String, dynamic> toMap() => {
        "typeName": typeName,
        "typeId": typeId,
        "price": price,
        "betTypes": betTypes != null
            ? Map.from(betTypes!).map((k, v) => MapEntry<String, dynamic>(
                k, Map.from(v).map((k, v) => MapEntry<String, dynamic>(k, v))))
            : null,
        "jackpotType": jackpotType, // Include new field
        "jackpotPrice": jackpotPrice, // Include new field
      };
}
