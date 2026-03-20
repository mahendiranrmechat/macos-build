import 'dart:convert';

/// gameList : [{"gameId":"winwin","gameName":"WIN WIN","gameOrder":1,"price":40.00,"digits":6,"id":1,"status":1}]
/// errorCode : 0

Game gameFromJson(String str) => Game.fromJson(json.decode(str));
String gameToJson(Game data) => json.encode(data.toJson());

class Game {
  Game({
    this.gameList,
    this.errorCode,
  });

  Game.fromJson(dynamic json) {
    if (json['gameList'] != null) {
      gameList = [];
      json['gameList'].forEach((v) {
        gameList?.add(GameList.fromJson(v));
      });
    }
    errorCode = json['errorCode'];
  }
  List<GameList>? gameList;
  int? errorCode;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (gameList != null) {
      map['gameList'] = gameList?.map((v) => v.toJson()).toList();
    }
    map['errorCode'] = errorCode;
    return map;
  }
}

/// gameId : "winwin"
/// gameName : "WIN WIN"
/// gameOrder : 1
/// price : 40.00
/// digits : 6
/// id : 1
/// status : 1

GameList gameListFromJson(String str) => GameList.fromJson(json.decode(str));
String gameListToJson(GameList data) => json.encode(data.toJson());

class GameList {
  GameList({
    this.gameId,
    this.gameName,
    this.gameOrder,
    this.price,
    this.digits,
    this.id,
    this.status,
  });

  GameList.fromJson(dynamic json) {
    gameId = json['gameId'];
    gameName = json['gameName'];
    gameOrder = json['gameOrder'];
    price = json['price'];
    digits = json['digits'];
    id = json['id'];
    status = json['status'];
  }
  String? gameId;
  String? gameName;
  int? gameOrder;
  double? price;
  int? digits;
  int? id;
  int? status;

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    map['gameId'] = gameId;
    map['gameName'] = gameName;
    map['gameOrder'] = gameOrder;
    map['price'] = price;
    map['digits'] = digits;
    map['id'] = id;
    map['status'] = status;
    return map;
  }
}
