import 'dart:convert';
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:psglotto/file_for_claimwith_barcode/claim_with_barcode_model.dart';
import 'package:psglotto/model/app_config.dart';
import 'package:psglotto/model/cancel_ticket.dart';
import 'package:psglotto/model/cancel_ticket_all.dart';
import 'package:psglotto/model/cancel_ticket_with_barcode.dart';
import 'package:psglotto/model/claim.dart';
import 'package:psglotto/model/buy_ticket.dart';
import 'package:psglotto/model/claim_2d.dart';
import 'package:psglotto/model/claim_all.dart';
import 'package:psglotto/model/customer_type_model.dart';
import 'package:psglotto/model/draw_result.dart' as d;
import 'package:psglotto/model/draw_result_3d.dart';
import 'package:psglotto/model/price_structure.dart';
import 'package:psglotto/model/refresh_token.dart';
import 'package:psglotto/model/reprint.dart';
import 'package:psglotto/model/sale_report_models.dart';
import 'package:psglotto/model/user_results.dart' as u;
import 'package:psglotto/model/init_game.dart';
import 'package:psglotto/model/search_ticket.dart';
import 'package:psglotto/model/user_result_2d.dart' as ur;
import 'package:psglotto/model/user_result_3d.dart' as ur3d;
import 'package:psglotto/provider/lotto_clock_provider.dart';
import 'package:psglotto/view/utils/url.dart';
import 'package:series_2d/game_init_loader.dart';

import '../model/Lobby.dart';
import '../model/buy_ticket_others.dart';
import '../model/category.dart';
import '../model/draw_result_2d.dart';
import '../model/game.dart' as g;
import '../model/init_game_others.dart';
import '../model/lotto_results.dart' as r;
import '../update_value_2d_game.dart/init_game_others_notifier.dart';
import '../utils/api_constants.dart';
import '../view/utils/helper.dart';
import 'package:psglotto/model/category.dart' as ct;

class ApiService {
  static List menuList = [];
  Future<String> signIn(String username, String password) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.signInEndpoint);

    // Step 1: Retrieve location data from SharedPref
    //String? locationData = SharedPref.instance.getString('locationData');

    // Log location data to debug
    // log("Location Data retrieved: $locationData");

    // if (locationData == null || locationData.isEmpty) {
    //   return "Location data is not available. Please try again.";
    // }
    // Fetch the local IP address
    String? localIp = await Helper.getDeviceIp();
    if (kDebugMode) {
      print(
          "All Req data = Login type : ${Helper.getDeviceType()}, macAddress : ${SharedPref.instance.getString("deviceId")}, location : , device reffrence: ${SharedPref.instance.getString("deviceReference")},  Ip = $localIp");
    }
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        "userName": username,
        "password": password,
        "appId": 1,
        "loginType": Helper.getDeviceType(),
        "macAddress": SharedPref.instance.getString("deviceId"),
        "ipAddress": localIp,
        "location": "No Data Found",
        "deviceReference": SharedPref.instance.getString("deviceReference")
      }),
    );
    Map<String, dynamic> data = json.decode(response.body);
    // if (kDebugMode) {
    //   print("THis is new data: $data");
    // }
    String? token = data["token"];
    int? userId = data["userId"];
    String? refreshToken = data["refreshToken"];
    if (data["status"] == 1 && token != null && refreshToken != null) {
      lottoCurrentTimeServer = data["currentTime"];
      debugPrint(
          "Checking current server time : ==============> : $lottoCurrentTimeServer");
      menuList = data["menuList"];
      SharedPref.instance.setString("username", username);
      SharedPref.instance.setString("token", token);
      SharedPref.instance.setString("refreshToken", refreshToken);
      SharedPref.instance.setInt("userId", userId!);
      return "Success";
    } else if (data["status"] == 401 || data["status"] == 500) {
      return data["error"];
    }
    return data["message"];
  }

  Future<double> getBalance() async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.balanceEndpoint);
    String? token = SharedPref.instance.getString("token");
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username")
      }),
    );
    Map<String, dynamic> data = json.decode(response.body);

    // log(data.toString());

    if (data["errorCode"] == 0) {
      return data["balance"];
    } else {
      throw Exception(data["errorCode"]);
    }
  }

  static Future<String> signOut() async {
    try {
      var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.signOutEndpoint);
      String? token = SharedPref.instance.getString("token");
      var response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode(<String, dynamic>{
          "userId": SharedPref.instance.getInt("userId")!,
          "userName": SharedPref.instance.getString("username")
        }),
      );
      Map<String, dynamic> data = json.decode(response.body);

      log(data.toString());

      if (data["errorCode"] == 0) {
        return "Logged out";
      }
    } catch (e) {
      log("Exception: $e");
    }
    return "Session Expired";
  }

  static Future<String> changePassword(
      String oldPassword, String newPassword) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.changePasswordEndpoint);
    String? token = SharedPref.instance.getString("token");
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "oldPassword": oldPassword,
        "newPassword": newPassword,
        "macAddress": SharedPref.instance.getString("deviceId"),
        "deviceReference": SharedPref.instance.getString("devicemodel")
      }),
    );
    Map<String, dynamic> data = json.decode(response.body);

    if (data["errorCode"] == 0) {
      return "Success";
    } else {
      throw Exception(data["errorCode"]);
    }
  }

  Future<Lobby> getLobby() async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.lobbyEndpoint);

    String? token = SharedPref.instance.getString("token");
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username")
      }),
    );

    // log("token is ${SharedPref.instance.get("token").toString()}");

    log("This is lobby response: ${response.body.toString()}");
    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      lottoCurrentTimeServer = data["currentTime"];
      InitGameOthersProvider.onSetLobbyDrawID(json.decode(response.body));
      return lobbyFromJson(response.body);
    } else {
      log(response.body);
      throw Exception(lobbyFromJson(response.body).errorCode);
    }
  }

  static Future getQuickPick(
      {required int categoryId,
      required String gameID,
      required String drawID,
      required int count}) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.quickPickEndpoint);
    String? token = SharedPref.instance.getString("token");
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameID,
        "drawId": drawID,
        "nos": count
      }),
    );
    Map<String, dynamic> data = await json.decode(response.body);

    if (data["errorCode"] == 0) {
      return data["ticketNos"];
    } else {
      throw Exception(data["errorCode"]);
    }
  }

  Future<List<String>> searchTicket(
      {required String gameID,
      required String drawID,
      required String ticketNo}) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.searchTicketEndpoint);
    String? token = SharedPref.instance.getString("token");
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "gameId": gameID,
        "drawId": drawID,
        "ticketNo": ticketNo
      }),
    );
    SearchTicket data = SearchTicket.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      return data.tickets!;
    } else {
      throw Exception(data.errorCode);
      // log(e.toString());
    }
  }

  Future<List<r.Results>> getResult({
    required int categoryId,
    required String gameId,
    required int fromDate,
    required int toDate,
  }) async {
    debugPrint("This is result : $gameId");
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.resultEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "from": fromDate,
        "to": toDate
      }),
    );
    log(response.body);
    r.Result data = r.Result.fromJson(jsonDecode(response.body));
    if (data.errorCode == 0) {
      log(response.body.toString());
      return data.results!;
    } else {
      throw Exception(data.errorCode);
      // log(e.toString());
    }
  }

  Future<List<CategoryList>> getCategory() async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.categoryEndpoint);

    String? token = SharedPref.instance.getString("token");
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username")
      }),
    );

    ct.Category data = ct.Category.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      log(response.body.toString());
      return data.categoryList!;
    } else {
      log(data.toJson().toString());

      throw Exception(data.errorCode);
    }
  }

  Future<List<g.GameList>> getGames({
    required int categoryId,
  }) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.gameEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
      }),
    );

    g.Game data = g.Game.fromJson(jsonDecode(response.body));

    log(response.toString());

    if (data.errorCode == 0) {
      return data.gameList!;
    } else if (response.statusCode == 500) {
      throw Exception();
    } else {
      throw Exception(data.errorCode);
    }
  }

  Future<BuyTicket> buyTicket({
    required String gameId,
    required String drawId,
    required String drawPlayGroupId,
    required List<String> ticketNos,
  }) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.buyTicketEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "gameId": gameId,
        "drawId": drawId,
        "drawPlayGroupId": drawPlayGroupId,
        "ticketNos": ticketNos
      }),
    );

    BuyTicket data = BuyTicket.fromJson(jsonDecode(response.body));
    log(data.toJson().toString());

    if (data.errorCode == 0) {
      SharedPref.instance.setString("internalRefNo", data.internalRefNo!);
      SharedPref.instance.setString("gameIdReprint", data.gameId!);
      return data;
    } else {
      throw Exception(data.errorCode);
    }
  }

  Future<InitGame> initGame({
    required int categoryId,
    required String gameId,
    required String drawId,
    // required String drawPlayGroupId,
  }) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.initGameEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "drawId": drawId,
        // "drawPlayGroupId": drawPlayGroupId,
      }),
    );

    InitGame data = InitGame.fromJson(jsonDecode(response.body));

    if (data.status == 1 || data.errorCode == 16) {
      return data;
    } else {
      throw Exception(data.errorCode);
    }
  }

  //initGameOthers service
  Future<InitGameOthersNew> getInitGameOthers(
      {required int categoryId,
      required String gameId,
      required String drawId,
      WidgetRef? ref
      // required String drawPlayGroupId,
      }) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.initGameOthersEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "drawId": drawId,
        // "drawPlayGroupId": drawPlayGroupId,
      }),
    );

    Map<String, dynamic> data = jsonDecode(response.body);

    if (data['status'] == 1 && data['errorCode'] == 0) {
      log(data.toString());
      InitGameOthersProvider.onSetInitGameOthers(data);
      //GameConstant.isFutureDrawInitRes = false;

      return InitGameOthersNew.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(data["errorCode"]);
    }
  }

  //result refress
  static Future getLastDrawResult({
    required int categoryID,
    required String gameID,
  }) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.lastdrawResultEndpoint);
    String? token = SharedPref.instance.getString("token");
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryID,
        "gameId": gameID,
      }),
    );
    Map<String, dynamic> data = await json.decode(response.body);

    if (data["errorCode"] == 0) {
      return data;
    } else {
      throw Exception(data["errorCode"]);
    }
  }

  //initGameOthers service
  Future<BuyTicketOthers> getBuyticketOthers({
    required String gameId,
    required String drawId,
    required List<Map<String, dynamic>> types,
    // required String drawPlayGroupId,
  }) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.buyTicketOthersEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "gameId": gameId,
        "drawId": drawId,
        "types": types,
        // "drawPlayGroupId": drawPlayGroupId,
      }),
    );

    debugPrint(response.body);
    BuyTicketOthers data = BuyTicketOthers.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      debugPrint(
          "This is type name: ${data.errorCode!} : ${data.balance}    : ${data.tickets}");
      return data;
    } else {
      throw Exception(data.errorCode);
    }
  }

  Future<d.DrawResult> drawResult({
    required int categoryId,
    required String gameId,
    required String drawId,
    // required String drawPlayGroupId,
  }) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.drawResultEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "drawId": drawId,
        // "drawPlayGroupId": drawPlayGroupId
      }),
    );

    d.DrawResult data = d.drawResultFromJson(response.body);

    if (data.errorCode == 0) {
      if (kDebugMode) {
        print("the the draw result is ${data.toJson()}");
      }

      return data;
    } else {
      log(jsonDecode(response.body.toString()));
      throw Exception(data.errorCode);
    }
  }

//Draw Result for 2D
  Future<DrawResult2D> drawResult2D({
    required int categoryId,
    required String gameId,
    required String drawId,
    // required String drawPlayGroupId,
  }) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.drawResult2DEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "drawId": drawId,
        // "drawPlayGroupId": drawPlayGroupId
      }),
    );
    log("This is drawResult 2d ${response.body}");
    DrawResult2D data = DrawResult2D.fromJson(jsonDecode(response.body));
    if (data.errorCode == 0) {
      return data;
    } else {
      log("This is drawResult 2d error ${data.errorCode}");
      throw Exception(data);
    }
  }

//Draw Result for 3D
  Future<DrawResult3D> drawResult3D({
    required int categoryId,
    required String gameId,
    required String drawId,
    // required String drawPlayGroupId,
  }) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.drawResult2DEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "drawId": drawId,
        // "drawPlayGroupId": drawPlayGroupId
      }),
    );
    log("This is drawResult 3d ${response.body}");
    DrawResult3D data = DrawResult3D.fromJson(jsonDecode(response.body));
    if (data.errorCode == 0) {
      return data;
    } else {
      log("This is drawResult 2d error ${data.errorCode}");
      throw Exception(data);
    }
  }

  Future<u.UserResults> getUserResults(
      {required int categoryId,
      required String gameId,
      required int resultType,
      required int page,
      required int fromDate,
      required int toDate,
      required int claimStatus}) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.userResultEndpoint);
    String? token = SharedPref.instance.getString("token");
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "resultType": resultType,
        "page": page,
        "claimStatus": claimStatus,
        "from": fromDate,
        "to": toDate
      }),
    );
    log("=====>:${response.body.toString()}");
    u.UserResults data = u.userResultsFromJson(response.body);
    if (kDebugMode) {
      print("user Result : ${jsonDecode(response.body.toString())}");
    }
    if (data.errorCode == 0) {
      return data;
    } else {
      log(data.toJson().toString());

      throw Exception(data.errorCode);
    }
  }

  //get User Result 2D
  Future<ur.UserResults2D> getUserResults2D({
    required int categoryId,
    required String gameId,
    required int resultType,
    required int page,
    required int fromDate,
    required int claimStatus,
    required int toDate,
  }) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.userResultEndpoint);
    String? token = SharedPref.instance.getString("token");
    if (kDebugMode) {
      print("This is from date : $fromDate , $toDate");
    }
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "resultType": resultType,
        "claimStatus": claimStatus,
        "page": page,
        "from": fromDate,
        "to": toDate
      }),
    );
    log("User  Result 2D: ${response.body.toString()}");

    ur.UserResults2D data = ur.userResults2DFromMap(response.body);

    if (data.errorCode == 0) {
      return data;
    } else {
      log(data.toString());
      if (kDebugMode) {
        print("user Error : ${data.toString()}");
      }

      throw Exception(data.errorCode);
    }
  }

  //get User Result 2D
  Future<ur3d.UserResults3D> getUserResults3D({
    required int categoryId,
    required String gameId,
    required int resultType,
    required int page,
    required int fromDate,
    required int claimStatus,
    required int toDate,
  }) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.userResultEndpoint);
    String? token = SharedPref.instance.getString("token");
    if (kDebugMode) {
      print("This is from date : $fromDate , $toDate");
    }
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "resultType": resultType,
        "claimStatus": claimStatus,
        "page": page,
        "from": fromDate,
        "to": toDate
      }),
    );
    log("User  Result 3D: ${response.body.toString()}");

    ur3d.UserResults3D data = ur3d.userResults3DFromMap(response.body);

    if (data.errorCode == 0) {
      return data;
    } else {
      log(data.toString());
      if (kDebugMode) {
        print("user Error : ${data.toString()}");
      }

      throw Exception(data.errorCode);
    }
  }

  Future<Claim> claim({
    required int categoryId,
    required String gameId,
    required String drawId,
    required String ticketNo,
    required int fromDate,
    required int toDate,
  }) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.claimEndpoint);
    String? token = SharedPref.instance.getString("token");
    if (kDebugMode) {
      print(" this $categoryId : $gameId : $drawId : $ticketNo");
    }
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "drawId": drawId,
        "ticketId": ticketNo,
        "from": fromDate,
        "to": toDate
      }),
    );

    Claim data = claimFromJson(response.body);
    if (kDebugMode) {
      print(jsonDecode(response.body).toString());
    }
    if (data.errorCode == 0) {
      return data;
    } else {
      throw Exception(data.errorCode);
      // log(e.toString());
    }
  }

  Future<Claim2D> claim2d({
    required int categoryId,
    required String gameId,
    required String drawId,
    required String ticketId,
    required int fromDate,
    required int toDate,
  }) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.claimEndpoint);
    String? token = SharedPref.instance.getString("token");
    if (kDebugMode) {
      print(" this $categoryId : $gameId : $drawId : $ticketId");
    }
    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": 2,
        "gameId": gameId,
        "drawId": drawId,
        "ticketId": ticketId,
        "from": fromDate,
        "to": toDate
      }),
    );
    log("This is 2d claim result: ${response.body}");
    Claim2D data = claim2DFromJson(response.body);

    if (data.errorCode == 0) {
      return data;
    } else {
      log("getting error becouse : ${data.errorCode}");
      throw Exception(data.errorCode);
    }
  }

  //claim all
  Future<ClaimAll> claimAll({
    required int categoryId,
    required String gameId,
    required int fromDate,
    required int toDate,
  }) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.claimAllEndpoint);
    String? token = SharedPref.instance.getString("token");

    Response response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "from": fromDate,
        "to": toDate
      }),
    );
    log("This is claim : ${response.body}");
    ClaimAll data = claimAllFromJson(response.body);

    if (data.errorCode == 0) {
      return data;
    } else {
      throw Exception(data.errorCode);
    }
  }

  //refresh token update
  Future<RefreshToken> getRefreshToken() async {
    try {
      var url =
          Uri.parse(ApiConstants.baseUrl + ApiConstants.refreshTokenEndpoint);

      // Make the POST request
      Response response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer ${SharedPref.instance.getString("token")}'
        },
        body: jsonEncode(<String, dynamic>{
          "refreshToken": SharedPref.instance.getString("refreshToken"),
        }),
      );

      debugPrint("Getting Refresh token  : ${response.body}");

      // Check if response is successful
      if (response.statusCode == 200) {
        RefreshToken data = refreshTokenFromJson(response.body);

        // Check error code in response data
        if (data.errorCode == 0) {
          debugPrint("Token updated");

          // Save the new token in shared preferences
          SharedPref.instance.setString("token", data.token!);

          return data;
        } else {
          // Throw an exception for any error code
          throw Exception("Error from server: ${data.errorCode}");
        }
      } else {
        // Handle non-200 responses
        throw Exception("Failed to refresh token: ${response.statusCode}");
      }
    } catch (e) {
      // Handle any kind of exception (network, parsing, etc.)
      debugPrint("Exception caught: $e");
      throw Exception("Unable to refresh token: $e");
    }
  }

//sale report
  Future<SaleReport> getSaleReport(
      {required from, required to, required page}) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.saleReportEndpoint);
    String? token = SharedPref.instance.getString("token");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "from": from,
        "to": to,
        "page": page
      }),
    );
    log("Report res : ${response.body}");
    SaleReport data = SaleReport.fromJson(jsonDecode(response.body));
    if (data.errorCode == 0) {
      return data;
    } else {
      throw Exception(data.errorCode);
    }
  }

  //get Customer Type
  Future<CustomerType> getCustomerType() async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.customerTypeEndpoint);
    String? token = SharedPref.instance.getString("token");
    String? loginCode = SharedPref.instance.getString("loginCode");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "menuId": '$loginCode' == "RT" ? 1 : 2
      }),
    );
    CustomerType data = CustomerType.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      return data;
    } else {
      throw Exception(data.errorCode);
    }
  }

  //!cancle ticket
  Future<CancelTicket> getCancelTicket(
      {required int categoryId,
      required String gameId,
      required String drawId,
      required String ticketId}) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.cancelTicketEndpoint);
    String? token = SharedPref.instance.getString("token");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "drawId": drawId,
        "ticketId": ticketId
      }),
    );

    debugPrint("Working fine : ${response.body}");

    CancelTicket data = CancelTicket.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      debugPrint("This is ticket cancel : ${data.errorCode}");
      return data;
    } else {
      throw Exception(data.errorCode.toString());
    }
  }

  //!cancle ticket All
  Future<CancelTicketAll> getCancelTicketAll({
    required int categoryId,
    required String gameId,
    required int from,
    required int to,
  }) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.cancelTicketAllEndpoint);
    String? token = SharedPref.instance.getString("token");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "from": from,
        "to": to
      }),
    );

    CancelTicketAll data = CancelTicketAll.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      return data;
    } else {
      throw Exception(data.errorCode.toString());
    }
  }

  //!cancle ticket with Barcode
  Future<CancelTicketWithBarcode> getCancelTicketWithBarcode({
    required int categoryId,
    required String gameId,
    required String barcode,
  }) async {
    var url = Uri.parse(
        ApiConstants.baseUrl + ApiConstants.cancelTicketWithBarcodeEndpoint);
    String? token = SharedPref.instance.getString("token");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "categoryId": categoryId,
        "gameId": gameId,
        "barCode": barcode,
      }),
    );

    CancelTicketWithBarcode data =
        CancelTicketWithBarcode.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      return data;
    } else {
      throw Exception(data.errorCode.toString());
    }
  }

  //!getPriceStructure
  Future<PriceStructure> getPriceStructure({
    required String gameId,
  }) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.priceStructureEndpoint);
    String? token = SharedPref.instance.getString("token");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "gameId": gameId,
      }),
    );
    log("getting price structure ${response.body}");

    PriceStructure data = PriceStructure.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      return data;
    } else {
      throw Exception(data.errorCode.toString());
    }
  }

  //get ClaimWithBarCode
  Future<ClaimWithBarCode> getClaimWithBarCode(
      {required String barCode, required from, required to}) async {
    var url =
        Uri.parse(ApiConstants.baseUrl + ApiConstants.claimWithBarCodeEndpoint);
    String? token = SharedPref.instance.getString("token");
    if (kDebugMode) {
      print("This is from date : $from , $to");
    }
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "barCode": barCode,
        "from": from,
        "to": to
      }),
    );

    //1703203015000
    //1703183399000000
    //1703097000000
    log("Claim all value : ${response.body} : $barCode");
    ClaimWithBarCode data =
        ClaimWithBarCode.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      return data;
    } else {
      throw Exception(data.errorCode);
    }
  }

  //get ClaimWithBarCode
  Future<Reprint> getReprint(
      {required String gameId, required String internalRefNo}) async {
    var url = Uri.parse(ApiConstants.baseUrl + ApiConstants.reprintEndpoint);
    String? token = SharedPref.instance.getString("token");

    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      },
      body: jsonEncode(<String, dynamic>{
        "userId": SharedPref.instance.getInt("userId")!,
        "userName": SharedPref.instance.getString("username"),
        "gameId": gameId,
        "internalRefNo": internalRefNo,
      }),
    );
    debugPrint("Re-print: ${response.body}   : $internalRefNo    $gameId");
    Reprint data = Reprint.fromJson(jsonDecode(response.body));

    if (data.errorCode == 0) {
      return data;
    } else {
      throw Exception(data.errorCode);
    }
  }

  Future<AppConfig?> fetchAppConfig() async {
    try {
      final response = await http.get(Uri.parse(UrlSet.configurl));

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonMap = jsonDecode(response.body);
        return AppConfig.fromJson(jsonMap);
      } else {
        debugPrint('Failed to load config: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Failed to fetch config: $e');
    }
    return null;
  }
}
