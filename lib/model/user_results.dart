import 'dart:convert';

/// results : [{"gameName":"WIN-WIN","gameId":"winwin-mon","drawId":"WW643223","ticketNo":"165082","time":1650810092647,"status":1,"claim":0,"winName":"1st prize","winPrice":100000.00},{"gameName":"WIN-WIN","gameId":"winwin-mon","drawId":"WW643223","ticketNo":"165028","time":1650810092647,"status":1,"claim":0,"winName":"1st prize","winPrice":100000.00}]
/// page : 1
/// totalPages : 10
/// errorCode : 0

UserResults userResultsFromJson(String str) =>
    UserResults.fromJson(json.decode(str));
String userResultsToJson(UserResults data) => json.encode(data.toJson());

class UserResults {
  UserResults({
    this.results,
    this.page,
    this.totalPages,
    this.unClaimedPrice,
    this.unClaimedTickets,
    this.errorCode,
  });

  UserResults.fromJson(dynamic json) {
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(Results.fromJson(v));
      });
    }
    page = json['page'];
    totalPages = json['totalPages'];
    unClaimedTickets = json['unClaimedTickets'];
    unClaimedPrice = json['unClaimedPrice'];
    errorCode = json['errorCode'];
  }
  List<Results>? results;
  int? page;
  int? totalPages;
  int? errorCode;
  num? unClaimedTickets; // Added missing field
  num? unClaimedPrice; // Added missing field

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (results != null) {
      map['results'] = results?.map((v) => v.toJson()).toList();
    }
    map['page'] = page;
    map['totalPages'] = totalPages;
    map['unClaimedTickets'] = unClaimedTickets;
    map['unClaimedPrice'] = unClaimedPrice;
    map['errorCode'] = errorCode;
    return map;
  }
}

/// gameName : "WIN-WIN"
/// gameId : "winwin-mon"
/// drawId : "WW643223"
/// ticketNo : "165082"
/// time : 1650810092647
/// status : 1
/// claim : 0
/// winName : "1st prize"
/// winPrice : 100000.00

Results resultsFromJson(String str) => Results.fromJson(json.decode(str));
String resultsToJson(Results data) => json.encode(data.toJson());

class Results {
  Results(
      {this.gameName,
      this.gameId,
      this.drawPlayGroupId,
      this.ticketNo,
      this.time,
      this.purchaseTime,
      this.status,
      this.claim,
      this.ticketId,
      this.drawId,
      this.winName,
      this.winPrice,
      this.ticketPrice,
      this.barCode});

  Results.fromJson(dynamic json) {
    gameName = json['gameName'];
    gameId = json['gameId'];
    drawId = json['drawId'];
    drawPlayGroupId = json['drawPlayGroupId'];
    ticketNo = json['ticketNo'];
    time = json['time'];
    purchaseTime = json['purchaseTime'];
    status = json['status'];
    claim = json['claim'];
    barCode = json['barCode'];
    ticketId = json['ticketId'];
    winName = json['winName'];
    winPrice = json['winPrice'];
    ticketPrice = json['ticketPrice'];
  }
  String? gameName;
  String? gameId;
  String? drawId;
  String? drawPlayGroupId;
  String? ticketNo;
  String? barCode;
  String? time;
  String? purchaseTime;
  int? status;
  int? claim;
  String? ticketId;
  String? winName;
  num? winPrice;
  double? ticketPrice;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gameName'] = gameName;
    map['gameId'] = gameId;
    map['drawId'] = drawId;
    map['drawPlayGroupId'] = drawPlayGroupId;
    map['ticketNo'] = ticketNo;
    map['time'] = time;
    map['purchaseTime'] = purchaseTime;
    map['status'] = status;
    map['claim'] = claim;
    map['ticketId'] = ticketId;
    map['winName'] = winName;
    map['winPrice'] = winPrice;
    map['ticketPrice'] = ticketPrice;
    return map;
  }
}
