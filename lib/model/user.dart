// To parse this JSON data, do
//
//     final user = userFromJson(jsonString);

import 'dart:convert';

User userFromJson(String str) => User.fromJson(json.decode(str));

String userToJson(User data) => json.encode(data.toJson());

class User {
  String? type;
  String? token;
  String? refreshToken;
  int? userId;
  String? userName;
  int? balance;
  int? status;
  int? passwordChange;
  List<GameList>? gameList;
  int? currentTime;

  User({
    this.type,
    this.token,
    this.refreshToken,
    this.userId,
    this.userName,
    this.balance,
    this.status,
    this.passwordChange,
    this.gameList,
    this.currentTime,
  });

  User copyWith({
    String? type,
    String? token,
    String? refreshToken,
    int? userId,
    String? userName,
    int? balance,
    int? status,
    int? passwordChange,
    List<GameList>? gameList,
    int? currentTime,
  }) =>
      User(
        type: type ?? this.type,
        token: token ?? this.token,
        refreshToken: refreshToken ?? this.refreshToken,
        userId: userId ?? this.userId,
        userName: userName ?? this.userName,
        balance: balance ?? this.balance,
        status: status ?? this.status,
        passwordChange: passwordChange ?? this.passwordChange,
        gameList: gameList ?? this.gameList,
        currentTime: currentTime ?? this.currentTime,
      );

  factory User.fromJson(Map<String, dynamic> json) => User(
        type: json["type"],
        token: json["token"],
        refreshToken: json["refreshToken"],
        userId: json["userId"],
        userName: json["userName"],
        balance: json["balance"],
        status: json["status"],
        passwordChange: json["passwordChange"],
        gameList: json["gameList"] == null
            ? []
            : List<GameList>.from(
                json["gameList"]!.map((x) => GameList.fromJson(x))),
        currentTime: json["currentTime"],
      );

  Map<String, dynamic> toJson() => {
        "type": type,
        "token": token,
        "refreshToken": refreshToken,
        "userId": userId,
        "userName": userName,
        "balance": balance,
        "status": status,
        "passwordChange": passwordChange,
        "gameList": gameList == null
            ? []
            : List<dynamic>.from(gameList!.map((x) => x.toJson())),
        "currentTime": currentTime,
      };
}

class GameList {
  int? categoryId;
  String? categoryName;
  int? categoryOrder;
  int? categoryStatus;
  List<CategoryGames>? categoryGames;

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
    List<CategoryGames>? categoryGames,
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
            : List<CategoryGames>.from(
                json["categoryGames"]!.map((x) => CategoryGames.fromJson(x))),
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

class CategoryGames {
  int? price;
  List<Game>? games;

  CategoryGames({
    this.price,
    this.games,
  });

  CategoryGames copyWith({
    int? price,
    List<Game>? games,
  }) =>
      CategoryGames(
        price: price ?? this.price,
        games: games ?? this.games,
      );

  factory CategoryGames.fromJson(Map<String, dynamic> json) => CategoryGames(
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
  int? price;
  int? winPrice;
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
    int? price,
    int? winPrice,
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
