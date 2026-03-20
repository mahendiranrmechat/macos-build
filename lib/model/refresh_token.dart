import 'dart:convert';

// Function to parse JSON string to RefreshToken object
RefreshToken refreshTokenFromJson(String str) =>
    RefreshToken.fromJson(json.decode(str));

// Function to convert RefreshToken object to JSON string
String refreshTokenToJson(RefreshToken data) => json.encode(data.toJson());

class RefreshToken {
  String? token;
  String? refreshToken;
  int? userId;
  String? userName;
  double? balance;
  int? status; // 0-inactive, 1-active, 2-suspended
  int? passwordChange; // 0-not needed, 1-change password
  List<Category>? gameList;
  List<Menu>? menuList;
  int? currentTime;
  int? errorCode;

  RefreshToken({
    this.token,
    this.refreshToken,
    this.userId,
    this.userName,
    this.balance,
    this.status,
    this.passwordChange,
    this.gameList,
    this.menuList,
    this.currentTime,
    this.errorCode,
  });

  factory RefreshToken.fromJson(Map<String, dynamic> json) => RefreshToken(
        token: json["token"],
        refreshToken: json["refreshToken"],
        userId: json["userId"],
        userName: json["userName"],
        balance: json["balance"],
        status: json["status"],
        passwordChange: json["passwordChange"],
        gameList: json["gameList"] != null
            ? List<Category>.from(
                json["gameList"].map((x) => Category.fromJson(x)))
            : null,
        menuList: json["menuList"] != null
            ? List<Menu>.from(json["menuList"].map((x) => Menu.fromJson(x)))
            : null,
        currentTime: json["currentTime"],
        errorCode: json["errorCode"],
      );

  Map<String, dynamic> toJson() => {
        "token": token,
        "refreshToken": refreshToken,
        "userId": userId,
        "userName": userName,
        "balance": balance,
        "status": status,
        "passwordChange": passwordChange,
        "gameList": gameList != null
            ? List<dynamic>.from(gameList!.map((x) => x.toJson()))
            : null,
        "menuList": menuList != null
            ? List<dynamic>.from(menuList!.map((x) => x.toJson()))
            : null,
        "currentTime": currentTime,
        "errorCode": errorCode,
      };
}

class Category {
  int? categoryId;
  String? categoryName;
  int? categoryOrder;
  int? categoryStatus;
  List<CategoryGame>? categoryGames;

  Category({
    this.categoryId,
    this.categoryName,
    this.categoryOrder,
    this.categoryStatus,
    this.categoryGames,
  });

  factory Category.fromJson(Map<String, dynamic> json) => Category(
        categoryId: json["categoryId"],
        categoryName: json["categoryName"],
        categoryOrder: json["categoryOrder"],
        categoryStatus: json["categoryStatus"],
        categoryGames: json["categoryGames"] != null
            ? List<CategoryGame>.from(
                json["categoryGames"].map((x) => CategoryGame.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "categoryId": categoryId,
        "categoryName": categoryName,
        "categoryOrder": categoryOrder,
        "categoryStatus": categoryStatus,
        "categoryGames": categoryGames != null
            ? List<dynamic>.from(categoryGames!.map((x) => x.toJson()))
            : null,
      };
}

class CategoryGame {
  double? price;
  List<Game>? games;

  CategoryGame({
    this.price,
    this.games,
  });

  factory CategoryGame.fromJson(Map<String, dynamic> json) => CategoryGame(
        price: json["price"],
        games: json["games"] != null
            ? List<Game>.from(json["games"].map((x) => Game.fromJson(x)))
            : null,
      );

  Map<String, dynamic> toJson() => {
        "price": price,
        "games": games != null
            ? List<dynamic>.from(games!.map((x) => x.toJson()))
            : null,
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
  bool? jackpotGame;

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
    this.jackpotGame,
  });

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
        jackpotGame: json["jackpotGame"],
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
        "jackpotGame": jackpotGame,
      };
}

class Menu {
  int? menuId;
  String? menuName;
  String? menuDisplayName;
  int? menuOrder;

  Menu({
    this.menuId,
    this.menuName,
    this.menuDisplayName,
    this.menuOrder,
  });

  factory Menu.fromJson(Map<String, dynamic> json) => Menu(
        menuId: json["menuId"],
        menuName: json["menuName"],
        menuDisplayName: json["menuDisplayName"],
        menuOrder: json["menuOrder"],
      );

  Map<String, dynamic> toJson() => {
        "menuId": menuId,
        "menuName": menuName,
        "menuDisplayName": menuDisplayName,
        "menuOrder": menuOrder,
      };
}
