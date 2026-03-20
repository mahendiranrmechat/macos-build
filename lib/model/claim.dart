import 'dart:convert';

/// balance : 125600.00
/// errorCode : 0

Claim claimFromJson(String str) => Claim.fromJson(json.decode(str));
String claimToJson(Claim data) => json.encode(data.toJson());

class Claim {
  Claim({
    this.balance,
    this.errorCode,
  });

  Claim.fromJson(dynamic json) {
    balance = json['balance'];
    errorCode = json['errorCode'];
  }
  double? balance;
  int? errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['balance'] = balance;
    map['errorCode'] = errorCode;
    return map;
  }
}
