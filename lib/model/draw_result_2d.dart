class DrawResult2D {
  String drawId;
  String drawPlayGroupId;
  int drawStartTime;
  List<Result> results;
  int errorCode;

  DrawResult2D({
    required this.drawId,
    required this.drawPlayGroupId,
    required this.drawStartTime,
    required this.results,
    required this.errorCode,
  });

  factory DrawResult2D.fromJson(Map<String, dynamic> json) {
    return DrawResult2D(
      drawId: json['drawId'] ?? '',
      drawPlayGroupId: json['drawPlayGroupId'] ?? '',
      drawStartTime: json['drawStartTime'] ?? 0,
      results: (json['results'] as List<dynamic>?)
              ?.map((r) => Result.fromJson(r))
              .toList() ??
          [],
      errorCode: json['errorCode'] ?? 0,
    );
  }
}

class Result {
  List<TicketNo> ticketNos;
  double winPrice;
  String name;
  int id;
  int winTypeId;

  Result({
    required this.ticketNos,
    required this.winPrice,
    required this.name,
    required this.id,
    required this.winTypeId,
  });

  factory Result.fromJson(Map<String, dynamic> json) {
    return Result(
      ticketNos: (json['ticketNos'] as List<dynamic>?)
              ?.map((t) => TicketNo.fromJson(t))
              .toList() ??
          [],
      winPrice: json['winPrice'] ?? 0.0,
      name: json['name'] ?? '',
      id: json['id'] ?? 0,
      winTypeId: json['winTypeId'] ?? 0,
    );
  }
}

class TicketNo {
  final String winNo;
  final String typeName;
  final int typeId;
  final String jackpotType; // New field
  final int jackpotPrice; // New field

  TicketNo({
    required this.winNo,
    required this.typeName,
    required this.typeId,
    required this.jackpotType,
    required this.jackpotPrice,
  });

  factory TicketNo.fromJson(Map<String, dynamic> json) {
    return TicketNo(
      winNo: json['winNo'] as String? ?? '',
      typeName: json['typeName'] as String? ?? '',
      typeId: json['typeId'] as int? ?? 0,
      jackpotType: json['jackpotType'] as String? ?? '',
      jackpotPrice: json['jackpotPrice'] as int? ?? 0,
    );
  }
}
