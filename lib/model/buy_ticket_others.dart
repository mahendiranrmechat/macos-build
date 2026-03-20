// To parse this JSON data, do
//
//     final buyTicketOthers = buyTicketOthersFromJson(jsonString);

import 'dart:convert';

BuyTicketOthers buyTicketOthersFromJson(String str) =>
    BuyTicketOthers.fromJson(json.decode(str));

String buyTicketOthersToJson(BuyTicketOthers data) =>
    json.encode(data.toJson());

class BuyTicketOthers {
  List<Ticket>? tickets;
  double? balance;
  int? errorCode;

  BuyTicketOthers({
    this.tickets,
    this.balance,
    this.errorCode,
  });

  BuyTicketOthers copyWith({
    List<Ticket>? tickets,
    double? balance,
    int? errorCode,
  }) =>
      BuyTicketOthers(
        tickets: tickets ?? this.tickets,
        balance: balance ?? this.balance,
        errorCode: errorCode ?? this.errorCode,
      );

  factory BuyTicketOthers.fromJson(Map<String, dynamic> json) =>
      BuyTicketOthers(
        tickets: json["tickets"] == null
            ? []
            : List<Ticket>.from(
                json["tickets"]!.map((x) => Ticket.fromJson(x))),
        balance: json["balance"],
        errorCode: json["errorCode"],
      );

  Map<String, dynamic> toJson() => {
        "tickets": tickets == null
            ? []
            : List<dynamic>.from(tickets!.map((x) => x.toJson())),
        "balance": balance,
        "errorCode": errorCode,
      };
}

class Ticket {
  String? gameName;
  String? gameId;
  String? drawId;
  String? drawPlayGroupId;
  int? drawStartTime;
  double? price;
  int? ticketCount;
  int? ticketPrice;
  String? internalRefNo;
  String? barCode;
  List<Type>? types;
  int? errorCode;

  Ticket({
    this.gameName,
    this.gameId,
    this.drawId,
    this.drawPlayGroupId,
    this.drawStartTime,
    this.price,
    this.ticketCount,
    this.ticketPrice,
    this.internalRefNo,
    this.barCode,
    this.types,
    this.errorCode,
  });

  Ticket copyWith({
    String? gameName,
    String? gameId,
    String? drawId,
    String? drawPlayGroupId,
    int? drawStartTime,
    double? price,
    int? ticketCount,
    int? ticketPrice,
    String? internalRefNo,
    String? barCode,
    List<Type>? types,
    int? errorCode,
  }) =>
      Ticket(
        gameName: gameName ?? this.gameName,
        gameId: gameId ?? this.gameId,
        drawId: drawId ?? this.drawId,
        drawPlayGroupId: drawPlayGroupId ?? this.drawPlayGroupId,
        drawStartTime: drawStartTime ?? this.drawStartTime,
        price: price ?? this.price,
        ticketCount: ticketCount ?? this.ticketCount,
        ticketPrice: ticketPrice ?? this.ticketPrice,
        internalRefNo: internalRefNo ?? this.internalRefNo,
        barCode: barCode ?? this.barCode,
        types: types ?? this.types,
        errorCode: errorCode ?? this.errorCode,
      );

  factory Ticket.fromJson(Map<String, dynamic> json) => Ticket(
        gameName: json["gameName"],
        gameId: json["gameId"],
        drawId: json["drawId"],
        drawPlayGroupId: json["drawPlayGroupId"],
        drawStartTime: json["drawStartTime"],
        price: json["price"],
        ticketCount: json["ticketCount"],
        ticketPrice: json["ticketPrice"],
        internalRefNo: json["internalRefNo"],
        barCode: json["barCode"],
        types: json["types"] == null
            ? []
            : List<Type>.from(json["types"]!.map((x) => Type.fromJson(x))),
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
        "internalRefNo": internalRefNo,
        "barCode": barCode,
        "types": types == null
            ? []
            : List<dynamic>.from(types!.map((x) => x.toJson())),
        "errorCode": errorCode,
      };
}

class Type {
  int? typeId;
  String? typeName;
  Map<String, String>? betTypes;

  Type({
    this.typeId,
    this.typeName,
    this.betTypes,
  });

  Type copyWith({
    int? typeId,
    String? typeName,
    Map<String, String>? betTypes,
  }) =>
      Type(
        typeId: typeId ?? this.typeId,
        typeName: typeName ?? this.typeName,
        betTypes: betTypes ?? this.betTypes,
      );

  factory Type.fromJson(Map<String, dynamic> json) => Type(
        typeId: json["typeId"],
        typeName: json["typeName"],
        betTypes: Map.from(json["betTypes"]!)
            .map((k, v) => MapEntry<String, String>(k, v)),
      );

  Map<String, dynamic> toJson() => {
        "typeId": typeId,
        "typeName": typeName,
        "betTypes":
            Map.from(betTypes!).map((k, v) => MapEntry<String, dynamic>(k, v)),
      };
}
