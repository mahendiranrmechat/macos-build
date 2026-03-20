
class DrawResult3D {
  final String drawId;
  final String drawPlayGroupId;
  final int drawStartTime;
  final List<GameResult> results;
  final int errorCode;

  DrawResult3D({
    required this.drawId,
    required this.drawPlayGroupId,
    required this.drawStartTime,
    required this.results,
    required this.errorCode,
  });

  // Factory method to create an instance from JSON
  factory DrawResult3D.fromJson(Map<String, dynamic> json) {
    var list = json['results'] as List;
    List<GameResult> resultList = list.map((i) => GameResult.fromJson(i)).toList();

    return DrawResult3D(
      drawId: json['drawId'],
      drawPlayGroupId: json['drawPlayGroupId'],
      drawStartTime: json['drawStartTime'],
      results: resultList,
      errorCode: json['errorCode'],
    );
  }

  // Method to convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'drawId': drawId,
      'drawPlayGroupId': drawPlayGroupId,
      'drawStartTime': drawStartTime,
      'results': results.map((result) => result.toJson()).toList(),
      'errorCode': errorCode,
    };
  }

  // Method for creating a copy of the current object with modified values
  DrawResult3D copyWith({
    String? drawId,
    String? drawPlayGroupId,
    int? drawStartTime,
    List<GameResult>? results,
    int? errorCode,
  }) {
    return DrawResult3D(
      drawId: drawId ?? this.drawId,
      drawPlayGroupId: drawPlayGroupId ?? this.drawPlayGroupId,
      drawStartTime: drawStartTime ?? this.drawStartTime,
      results: results ?? this.results,
      errorCode: errorCode ?? this.errorCode,
    );
  }
}
class TicketNo {
  final int typeId;
  final String typeName;
  final String winNo;
  final String jackpotType;
  final double jackpotPrice;

  TicketNo({
    required this.typeId,
    required this.typeName,
    required this.winNo,
    required this.jackpotType,
    required this.jackpotPrice,
  });

  // Factory method to create an instance from JSON
  factory TicketNo.fromJson(Map<String, dynamic> json) {
    return TicketNo(
      typeId: json['typeId'],
      typeName: json['typeName'],
      winNo: json['winNo'],
      jackpotType: json['jackpotType'],
      jackpotPrice: json['jackpotPrice'].toDouble(),
    );
  }

  // Method to convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'typeId': typeId,
      'typeName': typeName,
      'winNo': winNo,
      'jackpotType': jackpotType,
      'jackpotPrice': jackpotPrice,
    };
  }

  // Method for creating a copy of the current object with modified values
  TicketNo copyWith({
    int? typeId,
    String? typeName,
    String? winNo,
    String? jackpotType,
    double? jackpotPrice,
  }) {
    return TicketNo(
      typeId: typeId ?? this.typeId,
      typeName: typeName ?? this.typeName,
      winNo: winNo ?? this.winNo,
      jackpotType: jackpotType ?? this.jackpotType,
      jackpotPrice: jackpotPrice ?? this.jackpotPrice,
    );
  }
}

class GameResult {
  final int id;
  final int winTypeId;
  final String name;
  final double winPrice;
  final List<TicketNo> ticketNos;

  GameResult({
    required this.id,
    required this.winTypeId,
    required this.name,
    required this.winPrice,
    required this.ticketNos,
  });

  // Factory method to create an instance from JSON
  factory GameResult.fromJson(Map<String, dynamic> json) {
    var list = json['ticketNos'] as List;
    List<TicketNo> ticketList = list.map((i) => TicketNo.fromJson(i)).toList();

    return GameResult(
      id: json['id'],
      winTypeId: json['winTypeId'],
      name: json['name'],
      winPrice: json['winPrice'].toDouble(),
      ticketNos: ticketList,
    );
  }

  // Method to convert the object to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'winTypeId': winTypeId,
      'name': name,
      'winPrice': winPrice,
      'ticketNos': ticketNos.map((ticket) => ticket.toJson()).toList(),
    };
  }

  // Method for creating a copy of the current object with modified values
  GameResult copyWith({
    int? id,
    int? winTypeId,
    String? name,
    double? winPrice,
    List<TicketNo>? ticketNos,
  }) {
    return GameResult(
      id: id ?? this.id,
      winTypeId: winTypeId ?? this.winTypeId,
      name: name ?? this.name,
      winPrice: winPrice ?? this.winPrice,
      ticketNos: ticketNos ?? this.ticketNos,
    );
  }
}
