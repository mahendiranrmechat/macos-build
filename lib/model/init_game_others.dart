/*
{
"categoryId": 2,
"gameId": "2d",
"drawId": "2D643223",
"drawPlayGroupId": "2D1",
"gameName": "2D",
"digits": 2,
"price": 10.00,
"status": 1,
"drawStartTime": 1672889400000,
"betCloseTime": 1672889340000,
"nextDrawList": [
    {
        "drawStartTime": 1672889400000,
        "drawId": "196",
        "drawPlayGroupId": "2D1"
    }, {
        "drawStartTime": 1672890300000,
        "drawId": "197",
        "drawPlayGroupId": "2D2"
    }, {
        .....
}],
"results": [{
    "typeId": 1, 
    "typeName": "AMBER", 
    "winNo": "89"
}, {
    .....
}],
"types": [{
    "typeId": 1, 
    "typeName": "AMBER", 
    "price": 10.00
}, {
    .....
}],
"balance": 9200.00,
"currentTime":1650810092647,
"errorCode": 0
}

*/

import 'dart:convert';

//for upadate value
class InitGameOthers {
  final int categoryId;
  final String gameId;
  final String drawId;
  final String drawPlayGroupId;
  final String gameName;
  final int digits;
  final int price;
  final int status;
  final int drawStartTime;
  final int betCloseTime;
  final bool setBloack;
  final bool setDrawBlocker;
  final bool refreshBool;
  final List results;
  final List types;

  InitGameOthers(
    this.categoryId,
    this.gameId,
    this.drawId,
    this.drawPlayGroupId,
    this.gameName,
    this.digits,
    this.price,
    this.status,
    this.drawStartTime,
    this.betCloseTime,
    this.setBloack,
    this.setDrawBlocker,
    this.refreshBool,
    this.results,
    this.types,
  );

  get length => null;

  InitGameOthers copyWith({
    int? categoryId,
    String? gameId,
    String? drawId,
    String? drawPlayGroupId,
    String? gameName,
    int? digits,
    int? price,
    int? status,
    int? drawStartTime,
    int? betCloseTime,
    bool? setBloack,
    bool? setDrawBlocker,
    bool? refreshBool,
    List? results,
    List? types,
  }) {
    return InitGameOthers(
      categoryId ?? this.categoryId,
      gameId ?? this.gameId,
      drawId ?? this.drawId,
      drawPlayGroupId ?? this.drawPlayGroupId,
      gameName ?? this.gameName,
      digits ?? this.digits,
      price ?? this.price,
      status ?? this.status,
      drawStartTime ?? this.drawStartTime,
      betCloseTime ?? this.betCloseTime,
      setBloack ?? this.setBloack,
      setDrawBlocker ?? this.setDrawBlocker,
      refreshBool ?? this.refreshBool,
      results ?? this.results,
      types ?? this.types,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'categoryId': categoryId,
      'gameId': gameId,
      'drawId': drawId,
      'drawPlayGroupId': drawPlayGroupId,
      'gameName': gameName,
      'digits': digits,
      'price': price,
      'status': status,
      'drawStartTime': drawStartTime,
      'betCloseTime': betCloseTime,
      'setBloack': setBloack,
      'setDrawBlocker': setDrawBlocker,
      'refreshBool': refreshBool,
      'results': results,
      'types': types,
    };
  }

  factory InitGameOthers.fromMap(Map<String, dynamic> map) {
    return InitGameOthers(
      map['categoryId'] as int,
      map['gameId'] as String,
      map['drawId'] as String,
      map['drawPlayGroupId'] as String,
      map['gameName'] as String,
      map['digits'] as int,
      map['price'] as int,
      map['status'] as int,
      map['drawStartTime'] as int,
      map['betCloseTime'] as int,
      map['setBloack'] as bool,
      map['setDrawBlocker'] as bool,
      map['refreshBool'] as bool,
      map['results'] as List,
      map['types'] as List,
    );
  }

  String toJson() => json.encode(toMap());

  factory InitGameOthers.fromJson(String source) =>
      InitGameOthers.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'InitGameOthers(categoryId: $categoryId, gameId: $gameId, drawId: $drawId, drawPlayGroupId: $drawPlayGroupId, gameName: $gameName, digits: $digits, price: $price, status: $status, drawStartTime: $drawStartTime, betCloseTime: $betCloseTime, setBloack : $setBloack,results : $results,types $types )';
  }

  @override
  bool operator ==(covariant InitGameOthers other) {
    if (identical(this, other)) return true;

    return other.categoryId == categoryId &&
        other.gameId == gameId &&
        other.drawId == drawId &&
        other.drawPlayGroupId == drawPlayGroupId &&
        other.gameName == gameName &&
        other.digits == digits &&
        other.price == price &&
        other.status == status &&
        other.drawStartTime == drawStartTime &&
        other.betCloseTime == betCloseTime &&
        other.setBloack == setBloack &&
        other.results == results &&
        other.types == types;
  }

  @override
  int get hashCode {
    return categoryId.hashCode ^
        gameId.hashCode ^
        drawId.hashCode ^
        drawPlayGroupId.hashCode ^
        gameName.hashCode ^
        digits.hashCode ^
        price.hashCode ^
        status.hashCode ^
        drawStartTime.hashCode ^
        betCloseTime.hashCode ^
        setBloack.hashCode ^
        results.hashCode ^
        types.hashCode;
  }
}

InitGameOthersNew initGameOthersNewFromJson(String str) =>
    InitGameOthersNew.fromJson(json.decode(str));
String nitGameOthersNewToJson(InitGameOthersNew data) =>
    json.encode(data.toJson());

//for api
class InitGameOthersNew {
  InitGameOthersNew({
    this.categoryId,
    this.gameId,
    this.drawId,
    this.gameName,
    this.drawPlayGroupId,
    this.digits,
    this.price,
    this.winPrice,
    this.status,
    this.drawStartTime,
    this.betCloseTime,
    this.nextDrawList,
    this.results,
    this.types,
    this.balance,
    this.errorCode,
  });

  InitGameOthersNew.fromJson(dynamic json) {
    categoryId = json['categoryId'];
    gameId = json['gameId'];
    drawId = json['drawId'];
    drawPlayGroupId = json['drawPlayGroupId'];
    gameName = json['gameName'];
    digits = json['digits'];
    price = json['price'];
    winPrice = json['winPrice'];
    status = json['status'];
    drawStartTime = json['drawStartTime'];
    betCloseTime = json['betCloseTime'];
    nextDrawList =
        json['nextDrawList'] != null ? json['nextDrawList'].cast<String>() : [];
    results = json['results'] != null ? json['results'].cast<String>() : [];
    types = json['types'] != null ? json['types'].cast<String>() : [];
    balance = json['balance'];
    errorCode = json['errorCode'];
  }
  int? categoryId;
  String? gameId;
  String? drawId;
  String? drawPlayGroupId;
  dynamic gameName;
  int? digits;
  double? price;
  double? winPrice;
  int? status;
  int? drawStartTime;
  int? betCloseTime;
  List<String>? nextDrawList;
  List<String>? results;
  List<String>? types;
  double? balance;
  int? errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['categoryId'] = categoryId;
    map['gameId'] = gameId;
    map['drawId'] = drawId;
    map['drawPlayGroupId'] = drawPlayGroupId;
    map['gameName'] = gameName;
    map['digits'] = digits;
    map['price'] = price;
    map['winPrice'] = winPrice;
    map['status'] = status;
    map['drawStartTime'] = drawStartTime;
    map['betCloseTime'] = betCloseTime;
    map['nextDrawList'] = nextDrawList;
    map['results'] = results;
    map['types'] = types;
    map['balance'] = balance;
    map['errorCode'] = errorCode;
    return map;
  }
}
