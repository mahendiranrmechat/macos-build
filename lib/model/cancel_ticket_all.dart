// To parse this JSON data, do
//
//     final cancelTicketAll = cancelTicketAllFromJson(jsonString);

import 'dart:convert';

CancelTicketAll cancelTicketAllFromJson(String str) =>
    CancelTicketAll.fromJson(json.decode(str));

String cancelTicketAllToJson(CancelTicketAll data) =>
    json.encode(data.toJson());

class CancelTicketAll {
  double? balance;
  List<int>? cancelledTicket;
  List<dynamic>? unCancelledTicket;
  int? errorCode;

  CancelTicketAll({
    this.balance,
    this.cancelledTicket,
    this.unCancelledTicket,
    this.errorCode,
  });

  CancelTicketAll copyWith({
    double? balance,
    List<int>? cancelledTicket,
    List<dynamic>? unCancelledTicket,
    int? errorCode,
  }) =>
      CancelTicketAll(
        balance: balance ?? this.balance,
        cancelledTicket: cancelledTicket ?? this.cancelledTicket,
        unCancelledTicket: unCancelledTicket ?? this.unCancelledTicket,
        errorCode: errorCode ?? this.errorCode,
      );

  factory CancelTicketAll.fromJson(Map<String, dynamic> json) =>
      CancelTicketAll(
        balance: json["balance"],
        cancelledTicket: json["cancelledTicket"] == null
            ? []
            : List<int>.from(json["cancelledTicket"]!.map((x) => x)),
        unCancelledTicket: json["unCancelledTicket"] == null
            ? []
            : List<dynamic>.from(json["unCancelledTicket"]!.map((x) => x)),
        errorCode: json["errorCode"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "cancelledTicket": cancelledTicket == null
            ? []
            : List<dynamic>.from(cancelledTicket!.map((x) => x)),
        "unCancelledTicket": unCancelledTicket == null
            ? []
            : List<dynamic>.from(unCancelledTicket!.map((x) => x)),
        "errorCode": errorCode,
      };
}
