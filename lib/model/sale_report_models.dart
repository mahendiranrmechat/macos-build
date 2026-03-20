class SaleReport {
  List<Result>? results;
  double? playPoints;
  double? winPoints;
  double? margin;
  double? net;
  int? from;
  int? to;
  int? page;
  int? totalPages;
  int? errorCode;
  int? currentTime; // ✅ Add currentTime here

  SaleReport({
    this.results,
    this.playPoints,
    this.winPoints,
    this.margin,
    this.net,
    this.from,
    this.to,
    this.page,
    this.totalPages,
    this.errorCode,
    this.currentTime, // ✅ Include in constructor
  });

  factory SaleReport.fromJson(Map<String, dynamic> json) => SaleReport(
        results: json["results"] == null
            ? []
            : List<Result>.from(json["results"].map((x) => Result.fromJson(x))),
        playPoints: json["playPoints"]?.toDouble(),
        winPoints: json["winPoints"]?.toDouble(),
        margin: json["margin"]?.toDouble(),
        net: json["net"]?.toDouble(),
        from: json["from"],
        to: json["to"],
        page: json["page"],
        totalPages: json["totalPages"],
        errorCode: json["errorCode"],
        currentTime: json["currentTime"], // ✅ Parse here
      );

  Map<String, dynamic> toJson() => {
        "results": results == null
            ? []
            : List<dynamic>.from(results!.map((x) => x.toJson())),
        "playPoints": playPoints,
        "winPoints": winPoints,
        "margin": margin,
        "net": net,
        "from": from,
        "to": to,
        "page": page,
        "totalPages": totalPages,
        "errorCode": errorCode,
        "currentTime": currentTime, // ✅ Include in serialization
      };
}

class Result {
  double? playPoints;
  double? margin;
  double? winPoints;
  String? name;
  double? net;

  Result({
    this.playPoints,
    this.margin,
    this.winPoints,
    this.name,
    this.net,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        playPoints: json["playPoints"]?.toDouble(),
        margin: json["margin"]?.toDouble(),
        winPoints: json["winPoints"]?.toDouble(),
        name: json["name"],
        net: json["net"]?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "playPoints": playPoints,
        "margin": margin,
        "winPoints": winPoints,
        "name": name,
        "net": net,
      };
}
