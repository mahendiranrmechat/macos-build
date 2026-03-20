import 'dart:convert';

/// results : [{"id":"12345","name":"1st prize","winPrice":100000.00,"ticketNos":["165082"]},{"id":"12347","name":"2nd prize","winPrice":50000.00,"ticketNos":["165082","165028"]}]
/// errorCode : 0

DrawResult drawResultFromJson(String str) =>
    DrawResult.fromJson(json.decode(str));
String drawResultToJson(DrawResult data) => json.encode(data.toJson());

class DrawResult {
  DrawResult({
    this.results,
    this.errorCode,
  });

  DrawResult.fromJson(dynamic json) {
    if (json['results'] != null) {
      results = [];
      json['results'].forEach((v) {
        results?.add(Results.fromJson(v));
      });
    }
    errorCode = json['errorCode'];
  }
  List<Results>? results;
  int? errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (results != null) {
      map['results'] = results?.map((v) => v.toJson()).toList();
    }
    map['errorCode'] = errorCode;
    return map;
  }
}

/// id : "12345"
/// name : "1st prize"
/// winPrice : 100000.00
/// ticketNos : ["165082"]

Results resultsFromJson(String str) => Results.fromJson(json.decode(str));
String resultsToJson(Results data) => json.encode(data.toJson());

class Results {
  Results({
    this.id,
    this.name,
    this.drawPlayGroupId,
    this.winPrice,
    this.ticketNos,
  });

  Results.fromJson(dynamic json) {
    id = json['id'];
    name = json['name'];
    drawPlayGroupId = json['drawPlayGroupId'];
    winPrice = json['winPrice'];
    ticketNos =
        json['ticketNos'] != null ? json['ticketNos'].cast<String>() : [];
  }
  int? id;
  String? name;
  String? drawPlayGroupId;
  double? winPrice;
  List<String>? ticketNos;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['id'] = id;
    map['name'] = name;
    map['drawPlayGroupId'] = drawPlayGroupId;
    map['winPrice'] = winPrice;
    map['ticketNos'] = ticketNos;
    return map;
  }
}
