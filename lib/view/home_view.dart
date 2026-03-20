// ignore_for_file: use_build_context_synchronously
import 'dart:async';
import 'dart:io';
import 'dart:ui';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:psglotto/model/Lobby.dart';
import 'package:psglotto/params/init_game_others_params.dart';
import 'package:psglotto/params/init_game_params.dart';
import 'package:psglotto/params/user_results_params.dart';
import 'package:psglotto/provider/lotto_clock_provider.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/services/api_service.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/settings_services/shared_preferences.dart';
import 'package:psglotto/utils/api_constants.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/info_page.dart';
import 'package:psglotto/view/my_lotteries_cancel_view.dart';
import 'package:psglotto/view/my_lotteries_view.dart';
import 'package:psglotto/view/result_view.dart';
import 'package:psglotto/view/saleReport.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:psglotto/view/utils/custom_log_out_pop.dart';
// import 'package:psglotto/view/utils/custom_layout.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/home/buy_ticket_view.dart';
import 'package:psglotto/view/widgets/home/game_pages_2d.dart/game_view.dart';
import 'package:psglotto/view/widgets/home/game_pages_2d.dart/game_view_mobile.dart';
import 'package:psglotto/view/widgets/home/lotto_card.dart';
import 'package:psglotto/view/widgets/home/lotto_card_2d.dart';
import 'package:psglotto/view/widgets/loading_overlay.dart';
import 'package:psglotto/view/widgets/snackbar.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:psglotto/model/user_result_2d.dart' as ur;
import 'package:psglotto/model/user_result_3d.dart' as ur3d;
import 'package:series_2d/presentation/logic_screen/three_d_series_logic.dart';
import 'package:series_2d/utils/game_data_constant.dart';
import 'dart:math' as math;
import 'login_view.dart';
import 'package:pdf/widgets.dart' as pw;

class HomeView extends ConsumerStatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _HomeViewState createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String username = "-";
  int userId = 0;
  String token = "";
  String balance = "-";
  Lobby lobby = Lobby();
  ScrollController scrollController = ScrollController();
  bool isButtonDisabled = false; // Flag to prevent multiple clicks
  bool showLoadingOverlay = false;
  String formattedDate = DateFormat('dd/MM/yyyy').format(DateTime.now());
  final preferenceService = PreferencesServices();
  bool isPrinting = false;
  //coin animation
  double coinImageSize = 40;
  int hoveredIndex =
      -1; // Initialize with a value that doesn't correspond to any valid index
  // List<double> prices = [];
  int selectedCoinIndex = 0;
  // int selectedCoinIndices = 0;
  List<int> selectedCoinIndices = [];
  List<Map<String, dynamic>> priceValueIndex = [];
  List<ur.Result> results = [];
  bool? isBarcode;
  var selectedPaperSize = PaperSelect.Size57;
  List<Printer> printers = [];
  List<String> options = ['2 Inc', '3 Inc'];
  String optionPrintType = '2 Inc';
  Printer? defaultPrinter;
  StreamSubscription<ConnectivityResult>? subscription;
  Stream<ConnectivityResult>? connectivityStream;
  @override
  void initState() {
    super.initState();
    populateFileds();
    onRefreshBalance();
    setupPrinter();
    setState(() {
      series2dSelection = false;
      username = SharedPref.instance.getString("username") ?? "-";
      token = SharedPref.instance.getString("token") ?? "-";
      userId = SharedPref.instance.getInt("userId") ?? 0;
    });
    subscription = Connectivity().onConnectivityChanged.listen((event) {
      if (event == ConnectivityResult.wifi ||
          event == ConnectivityResult.ethernet ||
          event == ConnectivityResult.mobile) {}
    });
    onRefresh();
  }

  void populateFileds() async {
    final settings = await preferenceService.getSettings();
    setState(() {
      isBarcode = settings.isBarcode;
      selectedPaperSize = settings.paperSelect;
    });
  }

  Future<void> onRefresh() async {
    // ref.refresh(lobbyProvider);
    // ignore: unused_result
    ref.refresh(lobbyProvider);
  }

  Future<void> onRefreshBalance() async {
    // ref.refresh(lobbyProvider);
    // ignore: unused_result
    ref.refresh(balanceProvider);
  }

  String getTime(int time) {
    DateTime date = DateTime.fromMillisecondsSinceEpoch(time);
    var format = DateFormat("hh-mm-ss");
    var dateString = format.format(date);

    return dateString;
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue lobbyAsyncData = ref.watch(lobbyProvider);
    final AsyncValue balance = ref.watch(balanceProvider);
    final serverTime =
        ref.read(lottoClockProvider); // Get the initial time from the provider
    return Scaffold(
      appBar: AppBar(
        title: Text(currentName),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(username),
                balance.when(
                  data: (balance) {
                    // return Text(" ${balance.toStringAsFixed(2)}");
                    return RichText(
                        text: TextSpan(children: [
                      buildCoinWidgetSpan(),
                      TextSpan(text: " ${balance.floor()}")
                    ]));
                  },
                  loading: () {
                    return const SizedBox(
                      width: 50.0,
                      child: LinearProgressIndicator(),
                    );
                  },
                  error: (e, s) {
                    return const Text("-");
                  },
                ),
              ],
            ),
          ),
          CustomCloseButton()
        ],
        leading: Transform.rotate(
            angle: 180 * math.pi / 180,
            child: IconButton(
              tooltip: "Log Out",
              icon: const Icon(Icons.logout),
              onPressed: showLoadingOverlay
                  ? null
                  : () async {
                      bool confirmLogout = await showLogoutConfirmationDialog(
                          context,
                          "Confirm Logout",
                          "Are you sure you want to logout?",
                          true);
                      if (confirmLogout) {
                        debugPrint("checking log out ");
                        bool networkStatus =
                            await Helper.checkNetworkConnection();
                        if (networkStatus) {
                          setState(() {
                            showLoadingOverlay = true;
                          });
                          ApiService.signOut().then((value) {
                            if (value == "Logged out") {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginView(),
                                  ),
                                  (route) => false);
                              showSnackBar(context, "Logged out");
                            } else {
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const LoginView(),
                                  ),
                                  (route) => false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(value.toString()),
                                ),
                              );
                            }
                            setState(() {
                              showLoadingOverlay = false;
                            });
                            //  SharedPref.instance.clear();
                          });
                        } else {
                          if (!mounted) return;
                          showSnackBar(
                              context, "Check your internet connection");
                        }
                      }
                    },
            )),
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () {
              return onRefresh();
            },
            child: lobbyAsyncData.when(
              data: <Lobby>(lobbyData) {
                return SizedBox(
                  height: MediaQuery.of(context).size.height,
                  child: ListView.builder(
                    itemCount: lobbyData.gameList.length,
                    itemBuilder: (context, index) {
                      selectedCoinIndices =
                          List.filled(lobbyData.gameList.length, 0);
                      List<CategoryGame>? categoryGames =
                          lobbyData.gameList[index].categoryGames;

                      if (categoryGames != null && categoryGames.isNotEmpty) {
                        // Separate prices list for each game list
                        List<double?> prices = [];

                        // Get the price values for the specific game list
                        for (var categoryGames in categoryGames) {
                          prices.addAll(categoryGames.games
                                  ?.map((game) => game.price)
                                  .toList() ??
                              []);
                        }

                        // Remove duplicated values
                        prices = prices.toSet().toList();
                        prices.sort();
                        int categoryId = lobbyData.gameList[index].categoryId;
                        if (priceValueIndex.length <= index) {
                          priceValueIndex.add({
                            'categoryId': categoryId,
                            'gameName': lobbyData.gameList[index].categoryName,
                            'selectedPriceIndex': 0,
                          });
                        }

                        // Inside categoryId == 1 Wrap
                        final now = DateTime.fromMillisecondsSinceEpoch(
                            lobbyData.currentTime);
                        final filteredGames = categoryGames
                            .where((category) =>
                                category.games != null &&
                                category.games!.isNotEmpty)
                            .expand((category) => category.games!)
                            .where((game) =>
                                game.price ==
                                prices[priceValueIndex[index]
                                    ["selectedPriceIndex"]])
                            .toList()
                          ..sort((a, b) {
                            final aTime = DateTime.fromMillisecondsSinceEpoch(
                                a.drawStartTime!);
                            final bTime = DateTime.fromMillisecondsSinceEpoch(
                                b.drawStartTime!);
                            return aTime
                                .difference(now)
                                .compareTo(bTime.difference(now));
                          });

                        // Sort games: 2d-super first, then by nearest drawStartTime
                        filteredGames.sort((a, b) {
                          if (a.gameId == "2d-super")
                            return -1; // a comes first
                          if (b.gameId == "2d-super") return 1; // b comes first
                          final aTime = DateTime.fromMillisecondsSinceEpoch(
                              a.drawStartTime!);
                          final bTime = DateTime.fromMillisecondsSinceEpoch(
                              b.drawStartTime!);
                          return aTime
                              .difference(now)
                              .compareTo(bTime.difference(now));
                        });
                        return Padding(
                          padding: const EdgeInsets.all(5.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                height: 50,
                                color: Colors.transparent,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Row(
                                    children: [
                                      Text(
                                        lobbyData.gameList[index].categoryName,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                        ),
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      categoryId == 1
                                          ? Expanded(
                                              child: ListView.builder(
                                                itemCount: prices.length,
                                                scrollDirection:
                                                    Axis.horizontal,
                                                itemBuilder: (context, i) {
                                                  String coinImage;
                                                  if (prices[i]! <= 5) {
                                                    coinImage =
                                                        'assets/images/coin_bronze.png';
                                                  } else if (prices[i]! <= 10) {
                                                    coinImage =
                                                        'assets/images/coin_gold.png';

                                                    //  'assets/images/coin_silver.png';
                                                  } else {
                                                    coinImage =
                                                        'assets/images/coin_gold.png';
                                                  }

                                                  return GestureDetector(
                                                    onTap: () {
                                                      setState(() {
                                                        priceValueIndex[index][
                                                            "selectedPriceIndex"] = i;

                                                        // selectedCoinIndices![index] =
                                                        //     index; // Use separate index for each game
                                                      });
                                                    },
                                                    child: MouseRegion(
                                                      onEnter: (event) {
                                                        setState(() {
                                                          if (priceValueIndex[
                                                                      index][
                                                                  "selectedPriceIndex"] ==
                                                              i) {
                                                            hoveredIndex = -1;
                                                          } else {
                                                            hoveredIndex = i;
                                                          }
                                                        });
                                                      },
                                                      onExit: (event) {
                                                        setState(() {
                                                          hoveredIndex = -1;
                                                        });
                                                      },
                                                      child: Container(
                                                        margin: const EdgeInsets
                                                            .all(8),
                                                        child: Stack(
                                                          alignment:
                                                              Alignment.center,
                                                          children: [
                                                            Opacity(
                                                              opacity: priceValueIndex[index]
                                                                              [
                                                                              "selectedPriceIndex"] ==
                                                                          i ||
                                                                      hoveredIndex ==
                                                                          i
                                                                  ? 1
                                                                  : 0.4,
                                                              child:
                                                                  Image.asset(
                                                                coinImage,
                                                                width: 30,
                                                                height: 30,
                                                              ),
                                                            ),
                                                            Text(
                                                              '${prices[i]!.toInt()}',
                                                              style:
                                                                  const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                          : const SizedBox.shrink(),
                                    ],
                                  ),
                                ),
                              ),
                              if (lobbyData.gameList[index].categoryId == 1)
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: filteredGames
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    int i = entry.key;
                                    var game = entry.value;
                                    if (lobbyData.gameList[index].categoryId ==
                                        1) {
                                      return InkWell(
                                        onTap: () async {
                                          if (isButtonDisabled) {
                                            return; // Prevent multiple clicks
                                          }
                                          isButtonDisabled =
                                              true; // Disable further clicks

                                          bool networkStatus = await Helper
                                              .checkNetworkConnection();
                                          if (networkStatus) {
                                            setState(() {
                                              showLoadingOverlay = true;
                                            });

                                            await ref
                                                .read(initGameProvider(
                                              InitGameParams(
                                                gameId: game.gameId!,
                                                categoryId: lobbyData
                                                    .gameList![index]
                                                    .categoryId!,
                                                drawPlayGroupId:
                                                    game.drawPlayGroupId!,
                                                drawId: game.drawId!,
                                              ),
                                            ).future)
                                                .then((value) {
                                              debugPrint(
                                                  "checking errror code  : ${value.errorCode}  : ${value.betCloseTime}   : ${value.drawStartTime}");
                                              if (value.status == 1) {
                                                if (mounted) {
                                                  setState(() {
                                                    showLoadingOverlay = false;
                                                    isButtonDisabled =
                                                        false; // Re-enable click after success
                                                  });
                                                }
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        BuyTicketView(
                                                      gameID: game.gameId!,
                                                      games: game,
                                                      categoryId: lobbyData
                                                          .gameList![index]
                                                          .categoryId!,
                                                      openDialogCallback:
                                                          (value) {
                                                        openScreen(
                                                            value,
                                                            game.gameId!,
                                                            lobbyData
                                                                .gameList![
                                                                    index]
                                                                .categoryId!);
                                                      },
                                                    ),
                                                  ),
                                                );
                                              } else {
                                                setState(() {
                                                  showLoadingOverlay = false;
                                                  isButtonDisabled =
                                                      false; // Re-enable click after failure
                                                });
                                                onRefresh();
                                                showSnackBar(
                                                  context,
                                                  "You cannot place a bet right now. Please try again after the draw",
                                                );
                                              }
                                            }).onError((error, stackTrace) {
                                              setState(() {
                                                showLoadingOverlay = false;
                                                isButtonDisabled =
                                                    false; // Re-enable click after error
                                              });
                                              ExceptionHandler.showSnack(
                                                errorCode: error.toString(),
                                                context: context,
                                              );
                                            });
                                          } else {
                                            setState(() {
                                              showLoadingOverlay = false;
                                              isButtonDisabled =
                                                  false; // Re-enable click after network check
                                            });
                                            if (!mounted) return;
                                            showSnackBar(
                                              context,
                                              "Check your internet connection",
                                            );
                                          }
                                        },
                                        child: LottoCard(
                                          type: game.gameId!,
                                          drawId: game.drawId!,
                                          drawPlayGroupId:
                                              game.drawPlayGroupId!,
                                          winPrice: game.winPrice!,
                                          time: game.drawStartTime!,
                                          timeDiff: DateTime
                                              .fromMillisecondsSinceEpoch(
                                            lobbyData.currentTime,
                                          ).difference(serverTime),
                                          isFirst: i == 0,
                                        ),
                                      );
                                    }

                                    return const SizedBox.shrink();
                                  }).toList(),
                                ),
                              if (lobbyData.gameList[index].categoryId == 2)
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: filteredGames.map<Widget>((game) {
                                    if (lobbyData.gameList[index].categoryId ==
                                        2) {
                                      return InkWell(
                                        onTap: () async {
                                          // String selectedGame = game.gameId!;
                                          bool networkStatus = await Helper
                                              .checkNetworkConnection();
                                          if (networkStatus) {
                                            setState(() {
                                              showLoadingOverlay = true;
                                            });

                                            await ref
                                                .read(initGameOthersProvider(
                                              InitGameOthersParams(
                                                gameId: game.gameId!,
                                                categoryId: lobbyData
                                                    .gameList![index]
                                                    .categoryId!,
                                                drawPlayGroupId:
                                                    game.drawPlayGroupId!,
                                                drawId: "",
                                              ),
                                            ).future)
                                                .then((value) {
                                              if (value.status == 1) {
                                                if (mounted) {
                                                  setState(() {
                                                    showLoadingOverlay = false;
                                                  });
                                                }
                                                if (Platform.isWindows ||
                                                    Platform.isMacOS) {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          GameView(
                                                        drawId: value.drawId!,
                                                        categoryId:
                                                            value.categoryId!,
                                                        betCloseTime:
                                                            value.betCloseTime,
                                                        drawStartTime:
                                                            value.drawStartTime,
                                                        gamName: value.gameName,
                                                        nextDrawList:
                                                            value.nextDrawList!,
                                                        results: value.results!,
                                                        types: value.types!,
                                                        userBalance:
                                                            value.balance,
                                                      ),
                                                    ),
                                                  );
                                                } else {
                                                  Navigator.push(
                                                    context,
                                                    MaterialPageRoute(
                                                      builder: (context) =>
                                                          GameViewMobile(
                                                        types: value.types!,
                                                        drawId: value.drawId!,
                                                        betCloseTime:
                                                            value.betCloseTime,
                                                        drawStartTime:
                                                            value.drawStartTime,
                                                      ),
                                                    ),
                                                  );
                                                }
                                              } else {
                                                setState(() {
                                                  showLoadingOverlay = false;
                                                });
                                                showSnackBar(
                                                  context,
                                                  "Sorry, the game isn't available. Please refresh",
                                                );
                                              }
                                            }).onError((error, stackTrace) {
                                              setState(() {
                                                showLoadingOverlay = false;
                                              });
                                              ExceptionHandler.showSnack(
                                                errorCode: error.toString(),
                                                context: context,
                                              );
                                            });
                                          } else {
                                            setState(() {
                                              showLoadingOverlay = false;
                                            });
                                            if (!mounted) return;
                                            showSnackBar(
                                              context,
                                              "Check your internet connection",
                                            );
                                          }
                                        },
                                        child: game.gameId == "2d"
                                            ? LottoCard2D(
                                                drawCount: game.drawCount!,
                                                formattedDate:
                                                    DateFormat('dd/MM/yyyy')
                                                        .format(serverTime),
                                              )
                                            // : Container()
                                            : Platform.isWindows ||
                                                    Platform.isMacOS
                                                ? GameInitLoader(
                                                    gameLowPrizeIsSelection:
                                                        gameLowPrizeIsSelection,
                                                    gameTypeSelection3dConfig:
                                                        gameTypeSelection3dConfig,
                                                    logo: logoPath,
                                                    kPrimarySeedColor:
                                                        kPrimarySeedColor!,
                                                    openDialogCallback:
                                                        (value, gameId) {
                                                      openScreen(
                                                          value,
                                                          gameId,
                                                          lobbyData
                                                              .gameList![index]
                                                              .categoryId!);
                                                    },
                                                    reprintCallBack: (value) {
                                                      searchResult(gameId, 2);
                                                    },
                                                    cancelTicketCallback:
                                                        (ticketId) {
                                                      debugPrint(
                                                          "Cancel ticket callback top  for ID: $ticketId");
                                                      cancelOpenScreen(
                                                          ticketId);
                                                    },
                                                    navigateToHome: () {
                                                      debugPrint(
                                                          "Working fine result call");
                                                      openScreen(
                                                          "Result",
                                                          gameId,
                                                          lobbyData
                                                              .gameList![index]
                                                              .categoryId!);
                                                    },
                                                    onSeries2DGameInit:
                                                        (value) {
                                                      setState(() {
                                                        series2dGameInitValue =
                                                            value;
                                                        series2dSelection =
                                                            true;
                                                      });
                                                      debugPrint(
                                                          "This is new call back method : ${value.gameName}");
                                                    },
                                                    formattedDate:
                                                        DateFormat('dd/MM/yyyy')
                                                            .format(serverTime),
                                                    paperSelect:
                                                        selectedPaperSize
                                                            .toString(),
                                                    balanceRefresh: () {
                                                      debugPrint(
                                                          "Working balance refresh");
                                                      onRefreshBalance();
                                                      setState(() {
                                                        series2dSelection =
                                                            false;
                                                        debugPrint(
                                                            "inside change the selection : $series2dSelection");
                                                      });
                                                    },
                                                    sessionCallback: () {
                                                      debugPrint(
                                                          "Working fine session callback");
                                                      SchedulerBinding.instance
                                                          .addPostFrameCallback(
                                                              (_) {
                                                        ExceptionHandler
                                                            .showSnack(
                                                                errorCode:
                                                                    "Exception",
                                                                context:
                                                                    context);
                                                      });
                                                    },
                                                    barcodeSettings:
                                                        isBarcode ?? false,
                                                    callback: () {
                                                      debugPrint(
                                                          "Working fine call back");
                                                      //! add call back for showLoadingOverlay
                                                      setState(() {
                                                        if (showLoadingOverlay) {
                                                          showLoadingOverlay =
                                                              false;
                                                        } else {
                                                          showLoadingOverlay =
                                                              true;
                                                        }
                                                      });
                                                    },
                                                    token: token,
                                                    userId: userId,
                                                    userName: username,
                                                    drawCount: game.drawCount!,
                                                    baseUrl:
                                                        ApiConstants.baseUrl,
                                                    gameId: game.gameId!,
                                                    categoryId: lobbyData
                                                        .gameList[index]
                                                        .categoryId,
                                                  )
                                                : const SizedBox.shrink(),
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }).toList(),
                                ),
                              if (lobbyData.gameList[index].categoryId == 3)
                                Wrap(
                                  spacing: 8.0,
                                  runSpacing: 8.0,
                                  children: categoryGames
                                      .where((category) =>
                                          category.games != null &&
                                          category.games!.isNotEmpty)
                                      .expand((category) => category.games!)
                                      .where((game) =>
                                          game.price ==
                                          prices[priceValueIndex[0]
                                              ["selectedPriceIndex"]])
                                      .map((game) {
                                    if (lobbyData.gameList[index].categoryId ==
                                        3) {
                                      return GameInitLoader(
                                        gameLowPrizeIsSelection:
                                            gameLowPrizeIsSelection,
                                        gameTypeSelection3dConfig:
                                            gameTypeSelection3dConfig,
                                        logo: logoPath,
                                        kPrimarySeedColor: kPrimarySeedColor!,
                                        openDialogCallback: (value, gameId) {
                                          openScreen(
                                              value,
                                              gameId,
                                              lobbyData
                                                  .gameList[index].categoryId);
                                        },
                                        reprintCallBack: (value) {
                                          searchResult("3d", 3);
                                        },
                                        navigateToHome: () {
                                          openScreen(
                                              "Result",
                                              gameId,
                                              lobbyData.gameList![index]
                                                  .categoryId!);
                                        },
                                        onSeries2DGameInit: (value) {
                                          setState(() {
                                            series2dGameInitValue = value;
                                            series2dSelection = true;
                                          });
                                        },
                                        cancelTicketCallback: (ticketId) {
                                          debugPrint(
                                              "Cancel ticket callback down for ID: $ticketId");
                                          cancelOpenScreen(ticketId);
                                        },
                                        formattedDate: DateFormat('dd/MM/yyyy')
                                            .format(serverTime),
                                        paperSelect:
                                            selectedPaperSize.toString(),
                                        balanceRefresh: () {
                                          onRefreshBalance();
                                          setState(() {
                                            series2dSelection = false;
                                          });
                                        },
                                        sessionCallback: () {
                                          SchedulerBinding.instance
                                              .addPostFrameCallback((_) {
                                            ExceptionHandler.showSnack(
                                                errorCode: "Exception",
                                                context: context);
                                          });
                                        },
                                        barcodeSettings: isBarcode ?? false,
                                        callback: () {
                                          setState(() {
                                            if (showLoadingOverlay) {
                                              showLoadingOverlay = false;
                                            } else {
                                              showLoadingOverlay = true;
                                            }
                                          });
                                        },
                                        token: token,
                                        userId: userId,
                                        userName: username,
                                        drawCount: game.drawCount!,
                                        baseUrl: ApiConstants.baseUrl,
                                        gameId: '3d',
                                        categoryId: lobbyData
                                            .gameList[index].categoryId,
                                      );
                                    }
                                    return const SizedBox.shrink();
                                  }).toList(),
                                ),
                              // if (lobbyData.gameList[index].categoryId == 3)
                              //   GameInitLoader(
                              //     openDialogCallback: (value) {
                              //       openScreen(value);
                              //     },
                              //     reprintCallBack: (value) {
                              //       searchResult("3d", 3);
                              //     },
                              //     navigateToHome: () {
                              //       openScreen("Result");
                              //     },
                              //     onSeries2DGameInit: (value) {
                              //       setState(() {
                              //         series2dGameInitValue = value;
                              //         series2dSelection = true;
                              //       });
                              //     },
                              //     formattedDate: DateFormat('dd/MM/yyyy')
                              //         .format(serverTime),
                              //     paperSelect: selectedPaperSize.toString(),
                              //     balanceRefresh: () {
                              //       onRefreshBalance();
                              //       setState(() {
                              //         series2dSelection = false;
                              //       });
                              //     },
                              //     sessionCallback: () {
                              //       SchedulerBinding.instance
                              //           .addPostFrameCallback((_) {
                              //         ExceptionHandler.showSnack(
                              //             errorCode: "Exception",
                              //             context: context);
                              //       });
                              //     },
                              //     barcodeSettings: isBarcode ?? false,
                              //     callback: () {
                              //       setState(() {
                              //         if (showLoadingOverlay) {
                              //           showLoadingOverlay = false;
                              //         } else {
                              //           showLoadingOverlay = true;
                              //         }
                              //       });
                              //     },
                              //     token: token,
                              //     userId: userId,
                              //     userName: username,
                              //     drawCount: 100,
                              //     baseUrl: ApiConstants.baseUrl,
                              //     gameId: '3d',
                              //     categoryId:
                              //         lobbyData.gameList[index].categoryId,
                              //   )
                            ],
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                );
              },
              error: (error, stackTrace) {
                SchedulerBinding.instance.addPostFrameCallback((_) {
                  ExceptionHandler.showSnack(
                      errorCode: error.toString(), context: context);
                });
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("No Internet connection"),
                      const SizedBox(
                        height: kDefaultPadding,
                      ),
                      ElevatedButton(
                        onPressed: () async {
                          bool networkStatus =
                              await Helper.checkNetworkConnection();
                          if (networkStatus) {
                            onRefresh();
                          } else {
                            if (!mounted) return;
                            showSnackBar(
                                context, "Check your internet connection");
                          }
                        },
                        child: const Text("Retry"),
                      ),
                    ],
                  ),
                );
              },
              loading: () => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
          ),
          if (showLoadingOverlay) const MyOverlay(),
        ],
      ),
    );
  }

  WidgetSpan buildCoinWidgetSpan() {
    return const WidgetSpan(
        child: Icon(
      Icons.stars_sharp,
      size: 16,
    ));
  }

  Future<void> getInitGameOthers(
      {int? categoryId, String? gameId, String? drawId}) async {
    ApiService().getInitGameOthers(
        categoryId: categoryId!, gameId: gameId!, drawId: drawId!);
  }

  void openScreen(String screenName, String gameId, int categoryId) {
    debugPrint(
        "Checking call back =======================>$gameId  $categoryId");
    Widget screen;
    switch (screenName) {
      case 'Info':
        screen = InfoPage();
        break;
      case 'Result':
        screen = const ResultView();
        break;
      case 'My History':
        screen = MyLotteriesView(
          categoryIdToShow: categoryId,
          gameId: gameId,
        );
        break;
      case 'Report':
        screen = const SaleReportScreen();
        break;
      default:
        screen =
            const SizedBox(); // Default screen if screenName is not recognized
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        const blur = 1.0; // 1.0 - very subtle, 9.0 - very strong blur
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: SizedBox(
              width: MediaQuery.of(context).size.width *
                  0.9, // 90% of screen width
              height: MediaQuery.of(context).size.height *
                  0.9, // 90% of screen height
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment
                        .spaceBetween, // Align the title to the center
                    children: [
                      const Spacer(),
                      screenName != "Report"
                          ? Text(
                              screenName,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            )
                          : const SizedBox(),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      // Pushes the title to the center
                    ],
                  ),
                  Expanded(child: screen),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void cancelOpenScreen(int categoryId) {
    Widget screen = MyLotteriesCancelView(
      categoryIdToShow: categoryId,
      gameId: gameId,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) {
        const blur = 1.0; // 1.0 - very subtle, 9.0 - very strong blur
        return AlertDialog(
          contentPadding: EdgeInsets.zero,
          content: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.9,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Spacer(),
                      const Text(
                        "Cancel Ticket",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                  Expanded(child: screen),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void setupPrinter() async {
    if (Platform.isWindows) {
      printers = await Printing.listPrinters();
      for (var element in printers) {
        if (element.isDefault == true) {
          defaultPrinter = element;
        }
      }
    }
  }

  //re -print result
  void searchResult(String gameID, int categoryId) async {
    bool networkStatus = await Helper.checkNetworkConnection();
    DateTime start =
        DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    DateTime end = DateTime(DateTime.now().year, DateTime.now().month,
        DateTime.now().day, 23, 59, 59);
    late DateTime startDate = start;
    late DateTime endDate = end;
    debugPrint(
        "dates :${startDate.millisecondsSinceEpoch},   ${endDate.millisecondsSinceEpoch} game id :$gameID");
    if (networkStatus) {
      results.clear();

      UserResultsParams userResultSearchParams = UserResultsParams(
        claimStatus: 0,
        categoryId: categoryId,
        gameId: gameID,
        fromDate: (startDate.millisecondsSinceEpoch),
        toDate: (endDate.millisecondsSinceEpoch),
        page: 0,
        resultType: 1,
      );

      //flutter: This is from date : 1719772200000 , 1719858599000
      if (gameID == "2d-jackpot" || gameID == "2d-super") {
        await ref
            .watch(toBeDrawnProvider2d(userResultSearchParams).future)
            .then((value) {
          if (!mounted) {
            return;
          }
          if (!isPrinting) {
            onCheckPrint(
                cancelTicket: false,
                context: context,
                id: 2,
                ticketSeriesOrResults: value.results,
                share: false,
                gameId: gameID,
                results: []);
          }
        }).onError((error, stackTrace) {
          if (!mounted) {
            return;
          }
          ExceptionHandler.showSnack(
              errorCode: error.toString(), context: context);
        });
      } else if (categoryId == 3) {
        await ref
            .watch(toBeDrawnProvider3d(userResultSearchParams).future)
            .then((value) {
          if (!mounted) {
            return;
          }
          if (!isPrinting) {
            onCheckPrint(
                gameId: gameID,
                cancelTicket: false,
                context: context,
                id: 3,
                ticketSeriesOrResults: value.results,
                share: false,
                results: value.results);
          }
        }).onError((error, stackTrace) {
          if (!mounted) {
            return;
          }
          ExceptionHandler.showSnack(
              errorCode: error.toString(), context: context);
        });
      } else {
        await ref
            .watch(toBeDrawnProvider2d(userResultSearchParams).future)
            .then((value) {
          if (!mounted) {
            return;
          }
          //create re print option
        }).onError((error, stackTrace) {
          if (!mounted) {
            return;
          }
          ExceptionHandler.showSnack(
              errorCode: error.toString(), context: context);
        });
      }

      //  else {
      //   if (!mounted) return;

      //   showSnackBar(context, "Please select a game type before searching");
      // }
    } else {
      if (!mounted) return;
      showSnackBar(context, "Check your internet connection");
    }
  }

  void onCheckPrint({
    required BuildContext context,
    required dynamic ticketSeriesOrResults,
    required bool share,
    required bool cancelTicket,
    required int id, // Added id to differentiate between the two cases
    required String gameId,
    required List<ur3d.Result> results,
  }) async {
    setState(() {
      isPrinting = true;
    });
    const double globalFontSize = 8.0;
    final font = await PdfGoogleFonts.robotoFlexRegular();

    final pdf = pw.Document(version: PdfVersion.pdf_1_4);
    String userName = SharedPref.instance.getString("username") ?? "-";

    String address =
        'Retailer: $userName\r\nDraw Date: ${results.isNotEmpty ? results.last.time : "N/A"}';

    if (id == 3) {
      debugPrint("checking 3d :${results.last}");

      num totalTicketNo = 0;

      if (results.last.ticketNo.isNotEmpty) {
        for (final ticket in results.last.ticketNo) {
          for (final betTypes in ticket.betTypes.values) {
            totalTicketNo +=
                betTypes.values.fold(0, (sum, count) => sum + count);
          }
        }
      }

      pdf.addPage(pw.MultiPage(
        margin: pw.EdgeInsets.only(
            left: selectedPaperSize == PaperSelect.Size57 ? 0 : 12),
        build: (final context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(currentName,
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text('(For Amusement Purpose Only)',
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              cancelTicket
                  ? pw.Text('(CANCEL RECEIPT)',
                      style: pw.TextStyle(fontSize: globalFontSize, font: font))
                  : pw.SizedBox.shrink(),
              pw.Text("Game name: ${results.last.gameName}",
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text(address,
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text('Draw Id: ${results.last.drawPlayGroupId}',
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text('Barcode Id: ${results.last.barCode}',
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text(
                  'Total Qty: $totalTicketNo   Total Points: ${results.last.ticketPrice.toStringAsFixed(0)}',
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            ],
          ),
          pw.ListView.builder(
            itemCount: results.last.ticketNo.length,
            itemBuilder: (context, i) {
              final ticketNo = results.last.ticketNo[i];
              int totalQuantitySeperated = 0;
              num totalPriceSeperated = 0;

              String middleValue = "";

              // Sort by betTypes by keys
              final sortedBetTypes = ticketNo.betTypes.map((key, value) {
                middleValue =
                    ThreeDSeriesLogic().getGameTypeByKey(int.parse(key));
                final sortedEntries = Map.fromEntries(
                  value.entries.toList()
                    ..sort((a, b) => a.key.compareTo(b.key)),
                );
                return MapEntry(key, sortedEntries);
              });

              // Extract sorted numbers using betTypes inside keys
              final numbers =
                  sortedBetTypes.values.expand((e) => e.entries).map((entry) {
                final quantity = int.tryParse(entry.value.toString()) ?? 0;
                totalQuantitySeperated += quantity;

                return '${entry.key}-$middleValue-${entry.value}';
              }).toList();

              totalPriceSeperated = (ticketNo.price) * totalQuantitySeperated;

              final List<List<String>> rows = [];
              for (int j = 0;
                  j < numbers.length;
                  j += selectedPaperSize == PaperSelect.Size57 ? 2 : 5) {
                int newNumber = selectedPaperSize == PaperSelect.Size57 ? 2 : 5;
                rows.add(numbers.sublist(
                    j, (j + newNumber).clamp(0, numbers.length)));
              }

              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Row(
                    children: [
                      pw.Text(
                        ticketNo.typeName,
                        style:
                            pw.TextStyle(fontSize: globalFontSize, font: font),
                      ),
                      pw.Text(
                        '(${ticketNo.price.toInt()})  Qty: $totalQuantitySeperated Points: ${totalPriceSeperated.toStringAsFixed(0)}',
                        style:
                            pw.TextStyle(fontSize: globalFontSize, font: font),
                      ),
                    ],
                  ),
                  ...rows.map((row) {
                    return pw.Text(
                      row.join('  '),
                      style: pw.TextStyle(fontSize: globalFontSize, font: font),
                    );
                  }),
                ],
              );
            },
          ),
          isBarcode!
              ? pw.SizedBox(
                  width: 100,
                  height: 40,
                  child: pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: results.last.barCode),
                )
              : pw.SizedBox.shrink(),
          pw.Text(
            '**Ticket not for sale**',
            style: pw.TextStyle(fontSize: globalFontSize, font: font),
          ),
          !cancelTicket
              ? pw.Text(
                  '**Duplicate Ticket**',
                  style: pw.TextStyle(fontSize: globalFontSize, font: font),
                )
              : pw.SizedBox.shrink()
        ],
      ));
    } else if (id == 2) {
      debugPrint("checking 2d");
      // Second Code (id == 2)
      final results = ticketSeriesOrResults as List<ur.Result>;

      address = 'Retailer: $userName\r\nDraw Date: ${results.last.time ?? '-'}';

      pdf.addPage(pw.MultiPage(
        margin: pw.EdgeInsets.only(
            left: selectedPaperSize == PaperSelect.Size57 ? 0 : 12),
        build: (final context) => [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(currentName,
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text('(For Amusement Purpose Only)',
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              if (cancelTicket)
                pw.Text('(CANCEL RECEIPT)',
                    style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text("Game name: ${results.last.gameName ?? '-'}",
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text(address,
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text('Draw Id: ${results.last.drawPlayGroupId}',
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text('Barcode Id: ${results.last.barCode}',
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
            ],
          ),
          pw.ListView.builder(
            itemCount: results.isNotEmpty ? 1 : 0,
            itemBuilder: (context, _) {
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  pw.ListView.builder(
                    itemCount: results.last.ticketNo?.length ?? 0,
                    itemBuilder: (context, i) {
                      final ticketNo = results.last.ticketNo![i];
                      int totalQuantitySeperated = 0;
                      num totalPriceSeperated = 0;

                      final numbers = ticketNo.betTypes?.values
                              .expand((e) => e.entries)
                              .map((entry) {
                            final quantity =
                                int.tryParse(entry.value.toString()) ?? 0;
                            totalQuantitySeperated += quantity;
                            return '${entry.key}-$quantity';
                          }).toList() ??
                          [];

                      totalPriceSeperated =
                          (ticketNo.price ?? 0) * totalQuantitySeperated;

                      final List<List<String>> rows = [];
                      for (int j = 0;
                          j < numbers.length;
                          j +=
                              selectedPaperSize == PaperSelect.Size57 ? 3 : 5) {
                        int newNumber =
                            selectedPaperSize == PaperSelect.Size57 ? 3 : 5;
                        rows.add(numbers.sublist(
                            j, (j + newNumber).clamp(0, numbers.length)));
                      }

                      return pw.Column(
                        crossAxisAlignment: pw.CrossAxisAlignment.start,
                        children: [
                          pw.Row(
                            children: [
                              pw.Text(
                                  gameId == "2d-super"
                                      ? "Play"
                                      : ticketNo.typeName ?? '-',
                                  style: pw.TextStyle(
                                      fontSize: globalFontSize, font: font)),
                              pw.Text(
                                  '(${ticketNo.price!.toInt()})  Qty: $totalQuantitySeperated Points: $totalPriceSeperated',
                                  style: pw.TextStyle(
                                      fontSize: globalFontSize, font: font)),
                            ],
                          ),
                          ...rows.map((row) {
                            return pw.Text(row.join('  '),
                                style: pw.TextStyle(
                                    fontSize: globalFontSize, font: font));
                          }),
                        ],
                      );
                    },
                  ),
                ],
              );
            },
          ),
          if (isBarcode!)
            pw.SizedBox(
              width: 100,
              height: 40,
              child: pw.BarcodeWidget(
                  barcode: pw.Barcode.code128(),
                  data: results.last.barCode ?? '-'),
            ),
          pw.Text('**Ticket not for sale**',
              style: pw.TextStyle(fontSize: globalFontSize, font: font)),
          if (!cancelTicket)
            pw.Text('**Duplicate Ticket**',
                style: pw.TextStyle(fontSize: globalFontSize, font: font)),
        ],
      ));
    }

    if (!share) {
      if (Platform.isAndroid) {
        Printing.layoutPdf(onLayout: (format) async => pdf.save());
      } else {
        await Printing.directPrintPdf(
            printer: defaultPrinter!, onLayout: (format) async => pdf.save());
      }
    } else {
      final bytes = await pdf.save();
      Printing.sharePdf(bytes: bytes);
    }
    setState(() {
      isPrinting = false;
    });
  }
}
