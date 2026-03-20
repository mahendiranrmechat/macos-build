import 'dart:convert';

UserResults3D userResults3DFromMap(String str) =>
    UserResults3D.fromMap(json.decode(str));

String userResults3DToMap(UserResults3D data) => json.encode(data.toMap());

class UserResults3D {
  final List<Result> results;
  final int page;
  final int totalPages;
  final int unClaimedTickets;
  final double unClaimedPrice;
  final int errorCode;

  UserResults3D({
    required this.results,
    required this.page,
    required this.totalPages,
    required this.unClaimedTickets,
    required this.unClaimedPrice,
    required this.errorCode,
  });

  factory UserResults3D.fromMap(Map<String, dynamic> map) {
    return UserResults3D(
      results: List<Result>.from(
          map['results']?.map((x) => Result.fromMap(x)) ?? []),
      page: map['page'] ?? 0,
      totalPages: map['totalPages'] ?? 0,
      unClaimedTickets: map['unClaimedTickets'] ?? 0,
      unClaimedPrice: (map['unClaimedPrice'] ?? 0.0).toDouble(),
      errorCode: map['errorCode'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'results': List<dynamic>.from(results.map((x) => x.toMap())),
      'page': page,
      'totalPages': totalPages,
      'unClaimedTickets': unClaimedTickets,
      'unClaimedPrice': unClaimedPrice,
      'errorCode': errorCode,
    };
  }

  String toJson() => json.encode(toMap());

  static UserResults3D fromJson(String str) =>
      UserResults3D.fromMap(json.decode(str));
}

class Result {
  final String gameName;
  final String gameId;
  final String drawId;
  final String drawPlayGroupId;
  final String barCode;
  final String ticketId;
  final List<TicketNo> ticketNo;
  final String gameRefNo;
  final String time;
  final String purchaseTime;
  final int status;
  int claim;
  final List<WinName> winName;
  final double price;
  final double ticketPrice;
  final double winPrice;
  final double jackpotPrice;
  final double totalWinPrice;

  Result({
    required this.gameName,
    required this.gameId,
    required this.drawId,
    required this.drawPlayGroupId,
    required this.barCode,
    required this.ticketId,
    required this.ticketNo,
    required this.gameRefNo,
    required this.time,
    required this.purchaseTime,
    required this.status,
    required this.claim,
    required this.winName,
    required this.price,
    required this.ticketPrice,
    required this.winPrice,
    required this.jackpotPrice,
    required this.totalWinPrice,
  });

  factory Result.fromMap(Map<String, dynamic> map) {
    return Result(
      gameName: map['gameName'] ?? '',
      gameId: map['gameId'] ?? '',
      drawId: map['drawId'] ?? '',
      drawPlayGroupId: map['drawPlayGroupId'] ?? '',
      barCode: map['barCode'] ?? '',
      ticketId: map['ticketId'] ?? '',
      ticketNo: List<TicketNo>.from(
          map['ticketNo']?.map((x) => TicketNo.fromMap(x)) ?? []),
      gameRefNo: map['gameRefNo'] ?? '',
      time: map['time'] ?? '',
      purchaseTime: map['purchaseTime'] ?? '',
      status: map['status'] ?? 0,
      claim: map['claim'] ?? 0,
      winName: List<WinName>.from(
          map['winName']?.map((x) => WinName.fromMap(x)) ?? []),
      price: (map['price'] ?? 0.0).toDouble(),
      ticketPrice: (map['ticketPrice'] ?? 0.0).toDouble(),
      winPrice: (map['winPrice'] ?? 0.0).toDouble(),
      jackpotPrice: (map['jackpotPrice'] ?? 0.0).toDouble(),
      totalWinPrice: (map['totalWinPrice'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gameName': gameName,
      'gameId': gameId,
      'drawId': drawId,
      'drawPlayGroupId': drawPlayGroupId,
      'barCode': barCode,
      'ticketId': ticketId,
      'ticketNo': List<dynamic>.from(ticketNo.map((x) => x.toMap())),
      'gameRefNo': gameRefNo,
      'time': time,
      'purchaseTime': purchaseTime,
      'status': status,
      'claim': claim,
      'winName': List<dynamic>.from(winName.map((x) => x.toMap())),
      'price': price,
      'ticketPrice': ticketPrice,
      'winPrice': winPrice,
      'jackpotPrice': jackpotPrice,
      'totalWinPrice': totalWinPrice,
    };
  }
}

class TicketNo {
  final double price;
  final String typeName;
  final int typeId;
  final Map<String, Map<String, int>> betTypes;

  TicketNo({
    required this.price,
    required this.typeName,
    required this.typeId,
    required this.betTypes,
  });

  factory TicketNo.fromMap(Map<String, dynamic> map) {
    return TicketNo(
      price: (map['price'] ?? 0.0).toDouble(),
      typeName: map['typeName'] ?? '',
      typeId: map['typeId'] ?? 0,
      betTypes: Map.from(map['betTypes'] ?? {}).map(
        (k, v) => MapEntry(k, Map<String, int>.from(v ?? {})),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'price': price,
      'typeName': typeName,
      'typeId': typeId,
      'betTypes': Map.from(betTypes).map(
        (k, v) => MapEntry(k, Map<String, int>.from(v)),
      ),
    };
  }
}

class WinName {
  final String typeName;
  final int typeId;
  final double price;
  final Map<String, String> winTypes;
  final String jackpotType;
  final int jackpotPrice;

  WinName({
    required this.typeName,
    required this.typeId,
    required this.price,
    required this.winTypes,
    required this.jackpotType,
    required this.jackpotPrice,
  });

  factory WinName.fromMap(Map<String, dynamic> map) {
    return WinName(
      typeName: map['typeName'] ?? '',
      typeId: map['typeId'] ?? 0,
      price: (map['price'] ?? 0.0).toDouble(),
      winTypes: Map.from(map['winTypes'] ?? {}).map(
        (k, v) => MapEntry(k, v.toString()),
      ),
      jackpotType: map['jackpotType'] ?? '',
      jackpotPrice: map['jackpotPrice'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'typeName': typeName,
      'typeId': typeId,
      'price': price,
      'winTypes': Map.from(winTypes).map((k, v) => MapEntry(k, v)),
      'jackpotType': jackpotType,
      'jackpotPrice': jackpotPrice,
    };
  }
}
