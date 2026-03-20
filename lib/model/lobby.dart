// To parse this JSON data, do
//
//     final lobby = lobbyFromJson(jsonString);

import 'dart:convert';

Lobby lobbyFromJson(String str) => Lobby.fromJson(json.decode(str));

String lobbyToJson(Lobby data) => json.encode(data.toJson());

class Lobby {
  List<GameList>? gameList;
  int? currentTime;
  int? errorCode;

  Lobby({
    this.gameList,
    this.currentTime,
    this.errorCode,
  });

  Lobby copyWith({
    List<GameList>? gameList,
    int? currentTime,
    int? errorCode,
  }) =>
      Lobby(
        gameList: gameList ?? this.gameList,
        currentTime: currentTime ?? this.currentTime,
        errorCode: errorCode ?? this.errorCode,
      );

  factory Lobby.fromJson(Map<String, dynamic> json) => Lobby(
        gameList: json["gameList"] == null
            ? []
            : List<GameList>.from(
                json["gameList"]!.map((x) => GameList.fromJson(x))),
        currentTime: json["currentTime"],
        errorCode: json["errorCode"],
      );

  Map<String, dynamic> toJson() => {
        "gameList": gameList == null
            ? []
            : List<dynamic>.from(gameList!.map((x) => x.toJson())),
        "currentTime": currentTime,
        "errorCode": errorCode,
      };
}

class GameList {
  int? categoryId;
  String? categoryName;
  int? categoryOrder;
  int? categoryStatus;
  List<CategoryGame>? categoryGames;

  GameList({
    this.categoryId,
    this.categoryName,
    this.categoryOrder,
    this.categoryStatus,
    this.categoryGames,
  });

  GameList copyWith({
    int? categoryId,
    String? categoryName,
    int? categoryOrder,
    int? categoryStatus,
    List<CategoryGame>? categoryGames,
  }) =>
      GameList(
        categoryId: categoryId ?? this.categoryId,
        categoryName: categoryName ?? this.categoryName,
        categoryOrder: categoryOrder ?? this.categoryOrder,
        categoryStatus: categoryStatus ?? this.categoryStatus,
        categoryGames: categoryGames ?? this.categoryGames,
      );

  factory GameList.fromJson(Map<String, dynamic> json) => GameList(
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
        categoryOrder: json["categoryOrder"],
        categoryStatus: json["categoryStatus"],
        categoryGames: json["categoryGames"] == null
            ? []
            : List<CategoryGame>.from(
                json["categoryGames"]!.map((x) => CategoryGame.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "categoryId": categoryId,
        "categoryName": categoryName,
        "categoryOrder": categoryOrder,
        "categoryStatus": categoryStatus,
        "categoryGames": categoryGames == null
            ? []
            : List<dynamic>.from(categoryGames!.map((x) => x.toJson())),
      };
}

class CategoryGame {
  double? price;
  List<Game>? games;

  CategoryGame({
    this.price,
    this.games,
  });

  CategoryGame copyWith({
    double? price,
    List<Game>? games,
  }) =>
      CategoryGame(
        price: price ?? this.price,
        games: games ?? this.games,
      );

  factory CategoryGame.fromJson(Map<String, dynamic> json) => CategoryGame(
        price: json["price"],
        games: json["games"] == null
            ? []
            : List<Game>.from(json["games"]!.map((x) => Game.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "games": games == null
            ? []
            : List<dynamic>.from(games!.map((x) => x.toJson())),
      };
}

class Game {
  String? gameId;
  String? gameName;
  double? price;
  double? winPrice;
  int? drawStartTime;
  String? drawId;
  int? betCloseTime;
  int? drawCount;
  int? digits;
  String? drawPlayGroupId;
  int? status;

  Game({
    this.gameId,
    this.gameName,
    this.price,
    this.winPrice,
    this.drawStartTime,
    this.drawId,
    this.betCloseTime,
    this.drawCount,
    this.digits,
    this.drawPlayGroupId,
    this.status,
  });

  Game copyWith({
    String? gameId,
    String? gameName,
    double? price,
    double? winPrice,
    int? drawStartTime,
    String? drawId,
    int? betCloseTime,
    int? drawCount,
    int? digits,
    String? drawPlayGroupId,
    int? status,
  }) =>
      Game(
        gameId: gameId ?? this.gameId,
        gameName: gameName ?? this.gameName,
        price: price ?? this.price,
        winPrice: winPrice ?? this.winPrice,
        drawStartTime: drawStartTime ?? this.drawStartTime,
        drawId: drawId ?? this.drawId,
        betCloseTime: betCloseTime ?? this.betCloseTime,
        drawCount: drawCount ?? this.drawCount,
        digits: digits ?? this.digits,
        drawPlayGroupId: drawPlayGroupId ?? this.drawPlayGroupId,
        status: status ?? this.status,
      );

  factory Game.fromJson(Map<String, dynamic> json) => Game(
        gameId: json["gameId"],
        gameName: json["gameName"],
        price: json["price"],
        winPrice: json["winPrice"],
        drawStartTime: json["drawStartTime"],
        drawId: json["drawId"],
        betCloseTime: json["betCloseTime"],
        drawCount: json["drawCount"],
        digits: json["digits"],
        drawPlayGroupId: json["drawPlayGroupId"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "gameId": gameId,
        "gameName": gameName,
        "price": price,
        "winPrice": winPrice,
        "drawStartTime": drawStartTime,
        "drawId": drawId,
        "betCloseTime": betCloseTime,
        "drawCount": drawCount,
        "digits": digits,
        "drawPlayGroupId": drawPlayGroupId,
        "status": status,
      };
}
