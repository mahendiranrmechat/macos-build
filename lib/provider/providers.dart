import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/file_for_claimwith_barcode/claim_with_barcode_model.dart';
import 'package:psglotto/file_for_claimwith_barcode/claim_with_params.dart';
import 'package:psglotto/model/Lobby.dart';
import 'package:psglotto/model/cancel_ticket.dart';
import 'package:psglotto/model/cancel_ticket_all.dart';
import 'package:psglotto/model/cancel_ticket_with_barcode.dart';
import 'package:psglotto/model/category.dart';
import 'package:psglotto/model/claim_2d.dart';
import 'package:psglotto/model/claim_all.dart';
import 'package:psglotto/model/customer_type_model.dart';
import 'package:psglotto/model/draw_result.dart' as d;
import 'package:psglotto/model/draw_result_2d.dart';
import 'package:psglotto/model/draw_result_3d.dart';
import 'package:psglotto/model/price_structure.dart';
import 'package:psglotto/model/reprint.dart';
import 'package:psglotto/model/sale_report_models.dart';
import 'package:psglotto/model/user_results.dart' as u;

import 'package:psglotto/model/init_game.dart';
import 'package:psglotto/model/lotto_results.dart';
import 'package:psglotto/model/search_params.dart';
import 'package:psglotto/params/cancel_ticket_all_params.dart';
import 'package:psglotto/params/cancel_ticket_params.dart';
import 'package:psglotto/params/cancel_ticket_with_barcode_params.dart';
import 'package:psglotto/params/claim_all_params.dart';
import 'package:psglotto/params/claim_params_2d.dart';
import 'package:psglotto/params/init_game_others_params.dart';
import 'package:psglotto/params/price_structure_params.dart';
import 'package:psglotto/params/reprint_params.dart';
import 'package:psglotto/params/sale_params.dart';
import 'package:psglotto/params/user_results_params.dart';
import 'package:psglotto/provider/cart_ticket_provider.dart';
import 'package:psglotto/provider/customize_ticker_provider.dart';
import '../model/buy_ticket.dart';
import '../model/buy_ticket_others.dart';
import '../model/claim.dart';
import '../model/game.dart' as g;
import '../model/init_game_others.dart';
import '../params/buy_ticket_others_params.dart';
import '../params/buy_ticket_params.dart';
import '../params/claim_params.dart';
import '../params/draw_result_params.dart';
import '../params/init_game_params.dart';
import '../params/result_search_params.dart';
import '../services/api_service.dart';
import '../update_value_2d_game.dart/init_game_others_notifier.dart';
import 'filter_my_lotteries_provider.dart';
import 'filter_result_provider.dart';
import 'package:psglotto/model/user_result_2d.dart' as ur;
import 'package:psglotto/model/user_result_3d.dart' as ur3d;

final customizeTicketProvider =
    StateNotifierProvider.autoDispose<CustomizeTicketNotifier, Set<String>>(
        (ref) => CustomizeTicketNotifier(customizeTickerData: <String>{}));

final cartTicketProvider =
    StateNotifierProvider.autoDispose<CartTicketNotifier, Set<String>>(
        (ref) => CartTicketNotifier(cartTickerData: <String>{}));

final apiProvider = Provider<ApiService>((ref) => ApiService());

final lobbyProvider = FutureProvider.autoDispose<Lobby>((ref) async {
  return ref.read(apiProvider).getLobby();
});
final game2dProvider =
    FutureProvider.autoDispose<InitGameOthersNew>((ref) async {
  return ref.read(apiProvider).getInitGameOthers(
        gameId: "2d",
        categoryId: 2,
        drawId: '',
      );
});

final balanceProvider = FutureProvider<double>((ref) async {
  return ref.read(apiProvider).getBalance();
});

final searchTicketProvider =
    FutureProvider.family<List<String>, SearchParams>((ref, params) async {
  return ref.read(apiProvider).searchTicket(
        gameID: params.gameID,
        drawID: params.drawID,
        ticketNo: params.ticketNo,
      );
});

final resultProvider = FutureProvider.family<List<Results>, ResultSearchParams>(
    (ref, params) async {
  return ref.read(apiProvider).getResult(
        gameId: params.gameId,
        categoryId: params.categoryId,
        fromDate: params.fromDate,
        toDate: params.toDate,
      );
});

final categoryProvider =
    FutureProvider.autoDispose<List<CategoryList>>((ref) async {
  return ref.read(apiProvider).getCategory();
});

final gameProvider = FutureProvider.family
    .autoDispose<List<g.GameList>, int>((ref, categoryId) async {
  return ref.read(apiProvider).getGames(categoryId: categoryId);
});

final buyTicketProvider =
    FutureProvider.family<BuyTicket, BuyParams>((ref, buyParams) async {
  return ref.read(apiProvider).buyTicket(
        gameId: buyParams.gameId,
        ticketNos: buyParams.ticketNos,
        drawId: buyParams.drawId,
        drawPlayGroupId: buyParams.drawPlayGroupId,
      );
});

final filterResultProvider =
    StateNotifierProvider.autoDispose<ResultFilterNotifier, String>(
        (ref) => ResultFilterNotifier(resultFilterData: ""));

final filterMyLotteriesProvider =
    StateNotifierProvider.autoDispose<MyLotteriesFilterNotifier, String>(
        (ref) => MyLotteriesFilterNotifier(myLotteriesFilterData: ""));

final initGameProvider = FutureProvider.family<InitGame, InitGameParams>(
    (ref, initGameParams) async {
  return ref.read(apiProvider).initGame(
        gameId: initGameParams.gameId,
        categoryId: initGameParams.categoryId,
        drawId: initGameParams.drawId,
      );
});

//initGameOthers Provider
final initGameOthersProvider =
    FutureProvider.family<InitGameOthersNew, InitGameOthersParams>(
        (ref, initGameOthersParams) async {
  return ref.read(apiProvider).getInitGameOthers(
        gameId: initGameOthersParams.gameId,
        categoryId: initGameOthersParams.categoryId,
        drawId: initGameOthersParams.drawId,
      );
});
//buyTicket others Provider Provider
final buyTicketOthersProvider =
    FutureProvider.family<BuyTicketOthers, BuyTicketOthersParams>(
        (ref, buyTicketOthersParams) async {
  return ref.read(apiProvider).getBuyticketOthers(
        gameId: buyTicketOthersParams.gameId,
        drawId: buyTicketOthersParams.drawId,
        types: buyTicketOthersParams.types,
      );
});

final drawResultProvider =
    FutureProvider.family<d.DrawResult, DrawResultParams>(
        (ref, drawResultParams) async {
  return ref.read(apiProvider).drawResult(
        gameId: drawResultParams.gameId,
        categoryId: drawResultParams.categoryId,
        drawId: drawResultParams.drawId,
      );
});
final drawResult2DProvider =
    FutureProvider.family<DrawResult2D, DrawResultParams>(
        (ref, drawResultParams) async {
  return ref.read(apiProvider).drawResult2D(
        gameId: drawResultParams.gameId,
        categoryId: drawResultParams.categoryId,
        drawId: drawResultParams.drawId,
      );
});

final toBeDrawnProvider =
    FutureProvider.family<u.UserResults, UserResultsParams>(
        (ref, params) async {
  return ref.read(apiProvider).getUserResults(
        gameId: params.gameId,
        categoryId: params.categoryId,
        fromDate: params.fromDate,
        claimStatus: params.claimStatus,
        page: params.page,
        toDate: params.toDate,
        resultType: 1,
      );
});

final drawnProvider = FutureProvider.family<u.UserResults, UserResultsParams>(
    (ref, params) async {
  return ref.read(apiProvider).getUserResults(
        gameId: params.gameId,
        categoryId: params.categoryId,
        claimStatus: params.claimStatus,
        fromDate: params.fromDate,
        toDate: params.toDate,
        resultType: 2,
        page: params.page,
      );
});

final wonProvider = FutureProvider.family<u.UserResults, UserResultsParams>(
    (ref, params) async {
  return ref.read(apiProvider).getUserResults(
        gameId: params.gameId,
        categoryId: params.categoryId,
        fromDate: params.fromDate,
        claimStatus: params.claimStatus,
        toDate: params.toDate,
        resultType: 3,
        page: params.page,
      );
});

final claimProvider =
    FutureProvider.family<Claim, ClaimParams>((ref, params) async {
  return ref.read(apiProvider).claim(
      gameId: params.gameId,
      categoryId: params.categoryId,
      ticketNo: params.ticketId,
      drawId: params.drawId,
      fromDate: params.fromDate,
      toDate: params.toDate);
});

//user DrawResult  ## for 2d Game
final toBeDrawnProvider2d =
    FutureProvider.family<ur.UserResults2D, UserResultsParams>(
        (ref, params) async {
  return ref.read(apiProvider).getUserResults2D(
        gameId: params.gameId,
        categoryId: params.categoryId,
        fromDate: params.fromDate,
        page: params.page,
        toDate: params.toDate,
        claimStatus: params.claimStatus,
        resultType: 1,
      );
});

final drawnProvider2d =
    FutureProvider.family<ur.UserResults2D, UserResultsParams>(
        (ref, params) async {
  return ref.read(apiProvider).getUserResults2D(
        gameId: params.gameId,
        categoryId: params.categoryId,
        claimStatus: params.claimStatus,
        fromDate: params.fromDate,
        toDate: params.toDate,
        resultType: 2,
        page: params.page,
      );
});

final wonProvider2d =
    FutureProvider.family<ur.UserResults2D, UserResultsParams>(
        (ref, params) async {
  return ref.read(apiProvider).getUserResults2D(
        gameId: params.gameId,
        claimStatus: params.claimStatus,
        categoryId: params.categoryId,
        fromDate: params.fromDate,
        toDate: params.toDate,
        resultType: 3,
        page: params.page,
      );
});

final claimProvider2d =
    FutureProvider.family<Claim2D, ClaimParams2D>((ref, params) async {
  return ref.read(apiProvider).claim2d(
      gameId: params.gameId,
      categoryId: params.categoryId,
      ticketId: params.ticketId,
      drawId: params.drawId,
      fromDate: params.fromDate,
      toDate: params.toDate);
});

//claim All
final claimProviderAll =
    FutureProvider.family<ClaimAll, ClaimParamsAll>((ref, params) async {
  return ref.read(apiProvider).claimAll(
        gameId: params.gameId,
        categoryId: params.categoryId,
        fromDate: params.fromDate,
        toDate: params.toDate,
      );
});

//3D
//user DrawResult  ## for 2d Game
final toBeDrawnProvider3d =
    FutureProvider.family<ur3d.UserResults3D, UserResultsParams>(
        (ref, params) async {
  return ref.read(apiProvider).getUserResults3D(
        gameId: params.gameId,
        categoryId: params.categoryId,
        fromDate: params.fromDate,
        page: params.page,
        toDate: params.toDate,
        claimStatus: params.claimStatus,
        resultType: 1,
      );
});
//user DrawResult  ## for 2d Game

final drawResult3DProvider =
    FutureProvider.family<DrawResult3D, DrawResultParams>(
        (ref, drawResultParams) async {
  return ref.read(apiProvider).drawResult3D(
        gameId: drawResultParams.gameId,
        categoryId: drawResultParams.categoryId,
        drawId: drawResultParams.drawId,
      );
});
final drawnProvider3d =
    FutureProvider.family<ur3d.UserResults3D, UserResultsParams>(
        (ref, params) async {
  return ref.read(apiProvider).getUserResults3D(
        gameId: params.gameId,
        categoryId: params.categoryId,
        fromDate: params.fromDate,
        page: params.page,
        toDate: params.toDate,
        claimStatus: params.claimStatus,
        resultType: 2,
      );
});

final wonProvider3d =
    FutureProvider.family<ur3d.UserResults3D, UserResultsParams>(
        (ref, params) async {
  return ref.read(apiProvider).getUserResults3D(
        gameId: params.gameId,
        categoryId: params.categoryId,
        fromDate: params.fromDate,
        page: params.page,
        toDate: params.toDate,
        claimStatus: params.claimStatus,
        resultType: 3,
      );
});

//Provide

final drawStartTimeNotifier =
    StateNotifierProvider<InitGameOthersNotifier, InitGameOthers>((ref) =>
        InitGameOthersNotifier(InitGameOthers(000, "", "", "", "", 000, 10, 000,
            000, 000, false, false, false, [], [])));

//saleReport
final saleReportProvider = FutureProvider.family<SaleReport, SaleReportParams>(
  (ref, params) async {
    final apiService = ref.watch(apiProvider);
    var result = await apiService.getSaleReport(
        from: params.from, to: params.to, page: params.page);
    return result;
  },
);

//customerTypeFunction
final customerTypeProvider =
    FutureProvider.autoDispose<CustomerType>((ref) async {
  return ref.read(apiProvider).getCustomerType();
});

//claim with barcode
final claimWithBarCode =
    FutureProvider.family<ClaimWithBarCode, ClaimWithBarCodeParams>(
        (ref, params) async {
  return ref.read(apiProvider).getClaimWithBarCode(
      from: params.fromDate, to: params.toDate, barCode: params.barCode);
});

//cancel ticket
final cancelTicketProvider =
    FutureProvider.family<CancelTicket, CancelTicketParams>(
        (ref, params) async {
  return ref.read(apiProvider).getCancelTicket(
      categoryId: params.categoryId,
      drawId: params.drawId,
      gameId: params.gameId,
      ticketId: params.ticketId);
});
final cancelTickeAlltProvider =
    FutureProvider.family<CancelTicketAll, CancelTicketAlltParams>(
        (ref, params) async {
  return ref.read(apiProvider).getCancelTicketAll(
      categoryId: params.categoryId,
      gameId: params.gameId,
      from: params.from,
      to: params.to);
});
final cancelTicketWithBarcodeProvider = FutureProvider.family<
    CancelTicketWithBarcode,
    CancelTicketWithBarcodeParams>((ref, params) async {
  return ref.read(apiProvider).getCancelTicketWithBarcode(
      categoryId: params.categoryId,
      gameId: params.gameId,
      barcode: params.barcode);
});

final reprintProvider =
    FutureProvider.family<Reprint, ReprintParams>((ref, params) async {
  return ref
      .read(apiProvider)
      .getReprint(gameId: params.gameId, internalRefNo: params.gameRefCode);
});

//!price structure
final priceStructureProvider =
    FutureProvider.family<PriceStructure, PriceStructureParams>(
        (ref, params) async {
  return ref.read(apiProvider).getPriceStructure(
        gameId: params.gameId,
      );
});
