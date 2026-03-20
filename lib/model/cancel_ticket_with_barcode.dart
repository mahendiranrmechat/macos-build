// To parse this JSON data, do
//
//     final cancelTicketWithBarcode = cancelTicketWithBarcodeFromJson(jsonString);

import 'dart:convert';

CancelTicketWithBarcode cancelTicketWithBarcodeFromJson(String str) =>
    CancelTicketWithBarcode.fromJson(json.decode(str));

String cancelTicketWithBarcodeToJson(CancelTicketWithBarcode data) =>
    json.encode(data.toJson());

class CancelTicketWithBarcode {
  String? gameName;
  String? gameId;
  String? drawId;
  String? drawPlayGroupId;
  int? drawStartTime;
  double? price;
  int? ticketCount;
  double? ticketPrice;
  double? winPrice;
  String? internalRefNo;
  String? barCode;
  List<Type>? types;
  double? balance;
  int? errorCode;

  CancelTicketWithBarcode({
    this.gameName,
    this.gameId,
    this.drawId,
    this.drawPlayGroupId,
    this.drawStartTime,
    this.price,
    this.ticketCount,
    this.ticketPrice,
    this.winPrice,
    this.internalRefNo,
    this.barCode,
    this.types,
    this.balance,
    this.errorCode,
  });

  CancelTicketWithBarcode copyWith({
    String? gameName,
    String? gameId,
    String? drawId,
    String? drawPlayGroupId,
    int? drawStartTime,
    double? price,
    int? ticketCount,
    double? ticketPrice,
    double? winPrice,
    String? internalRefNo,
    String? barCode,
    List<Type>? types,
    double? balance,
    int? errorCode,
  }) =>
      CancelTicketWithBarcode(
        gameName: gameName ?? this.gameName,
        gameId: gameId ?? this.gameId,
        drawId: drawId ?? this.drawId,
        drawPlayGroupId: drawPlayGroupId ?? this.drawPlayGroupId,
        drawStartTime: drawStartTime ?? this.drawStartTime,
        price: price ?? this.price,
        ticketCount: ticketCount ?? this.ticketCount,
        ticketPrice: ticketPrice ?? this.ticketPrice,
        winPrice: winPrice ?? this.winPrice,
        internalRefNo: internalRefNo ?? this.internalRefNo,
        barCode: barCode ?? this.barCode,
        types: types ?? this.types,
        balance: balance ?? this.balance,
        errorCode: errorCode ?? this.errorCode,
      );

  factory CancelTicketWithBarcode.fromJson(Map<String, dynamic> json) =>
      CancelTicketWithBarcode(
        gameName: json["gameName"],
        gameId: json["gameId"],
        drawId: json["drawId"],
        drawPlayGroupId: json["drawPlayGroupId"],
        drawStartTime: json["drawStartTime"],
        price: json["price"],
        ticketCount: json["ticketCount"],
        ticketPrice: json["ticketPrice"],
        winPrice: json["winPrice"],
        internalRefNo: json["internalRefNo"],
        barCode: json["barCode"],
        types: json["types"] == null
            ? []
            : List<Type>.from(json["types"]!.map((x) => Type.fromJson(x))),
        balance: json["balance"],
        errorCode: json["errorCode"],
      );

  Map<String, dynamic> toJson() => {
        "gameName": gameName,
        "gameId": gameId,
        "drawId": drawId,
        "drawPlayGroupId": drawPlayGroupId,
        "drawStartTime": drawStartTime,
        "price": price,
        "ticketCount": ticketCount,
        "ticketPrice": ticketPrice,
        "winPrice": winPrice,
        "internalRefNo": internalRefNo,
        "barCode": barCode,
        "types": types == null
            ? []
            : List<dynamic>.from(types!.map((x) => x.toJson())),
        "balance": balance,
        "errorCode": errorCode,
      };
}

class Type {
  String? typeName;
  int? typeId;
  BetTypes? betTypes;

  Type({
    this.typeName,
    this.typeId,
    this.betTypes,
  });

  Type copyWith({
    String? typeName,
    int? typeId,
    BetTypes? betTypes,
  }) =>
      Type(
        typeName: typeName ?? this.typeName,
        typeId: typeId ?? this.typeId,
        betTypes: betTypes ?? this.betTypes,
      );

  factory Type.fromJson(Map<String, dynamic> json) => Type(
        typeName: json["typeName"],
        typeId: json["typeId"],
        betTypes: json["betTypes"] == null
            ? null
            : BetTypes.fromJson(json["betTypes"]),
      );

  Map<String, dynamic> toJson() => {
        "typeName": typeName,
        "typeId": typeId,
        "betTypes": betTypes?.toJson(),
      };
}

class BetTypes {
  String? the3;

  BetTypes({
    this.the3,
  });

  BetTypes copyWith({
    String? the3,
  }) =>
      BetTypes(
        the3: the3 ?? this.the3,
      );

  factory BetTypes.fromJson(Map<String, dynamic> json) => BetTypes(
        the3: json["3"],
      );

  Map<String, dynamic> toJson() => {
        "3": the3,
      };
}
