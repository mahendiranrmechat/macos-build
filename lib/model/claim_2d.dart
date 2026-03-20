import 'dart:convert';

Claim2D claim2DFromJson(String str) => Claim2D.fromJson(json.decode(str));
String claim2DToJson(Claim2D data) => json.encode(data.toJson());

class Claim2D {
  Claim2D(
      {this.balance,
      this.unClaimedTickets,
      this.unClaimedPrice,
      this.errorCode});

  Claim2D.fromJson(dynamic json) {
    balance = json['balance'];
    unClaimedTickets = json['unClaimedTickets'];
    unClaimedPrice = json['unClaimedPrice'];
    errorCode = json['errorCode'];
  }
  double? balance;
  int? errorCode;
  int? unClaimedTickets;
  num? unClaimedPrice;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['balance'] = balance;
    map['unClaimedTickets'] = unClaimedTickets;
    map['unClaimedPrice'] = unClaimedPrice;
    map['errorCode'] = errorCode;
    return map;
  }
}
