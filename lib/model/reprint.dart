class Reprint {
  final String gameName;
  final String gameId;
  final String drawId;
  final String drawPlayGroupId;
  final double price;
  final String drawStartTime;
  final int ticketCount;
  final double ticketPrice;
  final String internalRefNo;
  final String barCode;
  final List<String> tickets;
  final String purchaseTime;
  final int errorCode;

  Reprint({
    required this.gameName,
    required this.gameId,
    required this.drawId,
    required this.drawPlayGroupId,
    required this.price,
    required this.drawStartTime,
    required this.ticketCount,
    required this.ticketPrice,
    required this.internalRefNo,
    required this.barCode,
    required this.tickets,
    required this.purchaseTime,
    required this.errorCode,
  });

  factory Reprint.fromJson(Map<String, dynamic> json) {
    return Reprint(
      gameName: json['gameName'] ?? '',
      gameId: json['gameId'] ?? '',
      drawId: json['drawId'] ?? '',
      drawPlayGroupId: json['drawPlayGroupId'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? -1.0,
      drawStartTime: json['drawStartTime'] ?? '',
      ticketCount: json['ticketCount'] ?? -1,
      ticketPrice: (json['ticketPrice'] as num?)?.toDouble() ?? -1.0,
      internalRefNo: json['internalRefNo'] ?? '',
      barCode: json['barCode'] ?? '',
      tickets: List<String>.from(json['tickets'] ?? []),
      purchaseTime: json['purchaseTime'] ?? '',
      errorCode: json['errorCode'] ?? -1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'gameName': gameName,
      'gameId': gameId,
      'drawId': drawId,
      'drawPlayGroupId': drawPlayGroupId,
      'price': price,
      'drawStartTime': drawStartTime,
      'ticketCount': ticketCount,
      'ticketPrice': ticketPrice,
      'internalRefNo': internalRefNo,
      'barCode': barCode,
      'tickets': tickets,
      'purchaseTime': purchaseTime,
      'errorCode': errorCode,
    };
  }
}
