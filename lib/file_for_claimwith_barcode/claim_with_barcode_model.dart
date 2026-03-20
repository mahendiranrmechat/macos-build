// To parse this JSON data, do
//
//     final claimWithBarCode = claimWithBarCodeFromJson(jsonString);

import 'dart:convert';

ClaimWithBarCode claimWithBarCodeFromJson(String str) =>
    ClaimWithBarCode.fromJson(json.decode(str));

String claimWithBarCodeToJson(ClaimWithBarCode data) =>
    json.encode(data.toJson());

class ClaimWithBarCode {
  double? balance;
  int? unClaimedTickets;
  num? unClaimedPrice;

  int? errorCode;

  ClaimWithBarCode({
    this.balance,
    this.unClaimedTickets,
    this.unClaimedPrice,
    this.errorCode,
  });

  ClaimWithBarCode copyWith({
    double? balance,
    num? unClaimedPrice,
    int? unClaimedTickets,
    int? errorCode,
  }) =>
      ClaimWithBarCode(
        balance: balance ?? this.balance,
        unClaimedPrice: unClaimedPrice ?? this.unClaimedPrice,
        unClaimedTickets: unClaimedTickets ?? this.unClaimedTickets,
        errorCode: errorCode ?? this.errorCode,
      );

  factory ClaimWithBarCode.fromJson(Map<String, dynamic> json) =>
      ClaimWithBarCode(
        balance: json["balance"],
        unClaimedPrice: json["unClaimedPrice"],
        unClaimedTickets: json["unClaimedTickets"],
        errorCode: json["errorCode"],
      );

  Map<String, dynamic> toJson() => {
        "balance": balance,
        "unClaimedPrice": unClaimedPrice,
        "unClaimedTickets": unClaimedTickets,
        "errorCode": errorCode,
      };
}
