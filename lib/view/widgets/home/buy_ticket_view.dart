import 'dart:io';
import 'package:animated_flip_counter/animated_flip_counter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:psglotto/model/Lobby.dart';
import 'package:psglotto/model/price_structure.dart';
import 'package:psglotto/model/search_params.dart';
import 'package:psglotto/params/price_structure_params.dart';
import 'package:psglotto/params/reprint_params.dart';
import 'package:psglotto/params/user_results_params.dart';
import 'package:psglotto/services/api_service.dart';
import 'package:psglotto/settings_services/setting_class.dart';
import 'package:psglotto/settings_services/shared_preferences.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/utils/custom_close_button.dart';
import 'package:psglotto/view/widgets/home/purchase_status_view/purchase_status_view.dart';
import 'package:psglotto/view/widgets/home/quick_pick_custom.dart';
import 'package:psglotto/view/widgets/home/ticket_chip.dart';
import 'package:series_2d/game_init_loader.dart';
import 'package:series_2d/presentation/logic_screen/shortcut_key_intent.dart';
import 'package:psglotto/model/user_results.dart' as u;
import 'package:series_2d/utils/game_data_constant.dart';
import '../../../params/buy_ticket_params.dart';
import '../../../provider/providers.dart';
import '../../utils/constants.dart';
import '../../utils/helper.dart';
import '../loading_overlay.dart';
import '../snackbar.dart';
import 'add_one_ticket.dart';
import 'purchase_status_view/purchase_status_view_web.dart';
import 'quick_pick.dart';
import 'package:pdf/widgets.dart' as pw;

typedef OpenDialogCallback = void Function(String value);

class BuyTicketView extends ConsumerStatefulWidget {
  final Game games;
  final int categoryId;
  final String gameID;
  final OpenDialogCallback openDialogCallback;

  const BuyTicketView(
      {required this.games,
      required this.categoryId,
      required this.openDialogCallback,
      required this.gameID,
      Key? key})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _BuyTicketViewState createState() => _BuyTicketViewState();
}

class _BuyTicketViewState extends ConsumerState<BuyTicketView> {
  bool showCustomizeTicket = false;
  bool showPickYourTicker = false;
  TextEditingController customizeTicketController = TextEditingController();
  final customizeTicketKey = GlobalKey<FormState>();
  bool isSearching = false;
  double screenWidth = 0.0;
  double screenHeight = 0.0;
  double average = 0.0;
  bool isBuying = false;
  bool showLoadingOverlay = false;
  List<u.Results> results = [];
  bool isLoading = false;
  final preferenceService = PreferencesServices();
  bool? isBarcode;
  var selectedPaperSize = PaperSelect.Size57;
  List<Printer> printers = [];
  List<String> options = ['2 Inc', '3 Inc'];
  String optionPrintType = '2 Inc';
  Printer? defaultPrinter;
  bool userBalanceIsActive = false;
  final formatCurrency = NumberFormat("##,##,###");
  bool isProcessing = false;
  @override
  void initState() {
    populateFileds();
    setupPrinter();
    super.initState();
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

  //settings field
  void populateFileds() async {
    final settings = await preferenceService.getSettings();
    setState(() {
      selectedPaperSize = settings.paperSelect;
      isBarcode = settings.isBarcode;
    });
  }

  void quickPick(int count) async {
    setState(() {
      showLoadingOverlay = true;
    });
    await ApiService.getQuickPick(
            gameID: widget.games.gameId!,
            categoryId: widget.categoryId,
            count: count,
            drawID: widget.games.drawId!)
        .then((value) {
      setState(() {
        showLoadingOverlay = false;
      });
      if (value != null) {
        ref.read(cartTicketProvider.notifier).replaceCartItems(Set.from(value));
      }
    }).onError((error, stackTrace) {
      if (!mounted) {
        return;
      }

      setState(() {
        showLoadingOverlay = false;
      });
      ExceptionHandler.showSnack(errorCode: error.toString(), context: context);
    });
  }

  void addOne() async {
    setState(() {
      showLoadingOverlay = true;
    });

    await ApiService.getQuickPick(
      gameID: widget.games.gameId!,
      categoryId: widget.categoryId,
      count: 1,
      drawID: widget.games.drawId!,
    ).then((value) {
      setState(() {
        showLoadingOverlay = false;
      });

      if (value != null) {
        ref.read(cartTicketProvider.notifier).addCartTicket({value[0]});
      }
    }).onError((error, stackTrace) {
      if (!mounted) {
        return;
      }
      setState(() {
        showLoadingOverlay = false;
      });
      ExceptionHandler.showSnack(errorCode: error.toString(), context: context);
    });
  }

  PriceStructure? priceStructure;

  String? errorMessage;

  Future<void> fetchPriceStructure() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      debugPrint("calling method");
      priceStructure = await ref.read(priceStructureProvider(
        PriceStructureParams(gameId: widget.gameID),
      ).future);
      debugPrint("Price structure: ${priceStructure?.results}");
    } catch (error) {
      errorMessage = 'Error: $error';
      debugPrint("Error fetching price structure: $error");
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double totalPrice =
        widget.games.price! * ref.watch(cartTicketProvider).length;

    final Set<String> ticketNoSet = ref.watch(cartTicketProvider);
    final Set<String> customizeTicket = ref.watch(customizeTicketProvider);

    screenWidth = MediaQuery.of(context).size.width;
    screenHeight = MediaQuery.of(context).size.height;
    final AsyncValue balance = ref.watch(balanceProvider);
    average = screenWidth + screenHeight;
    return WillPopScope(
      onWillPop: () async {
        // ignore: unused_result
        ref.refresh(balanceProvider);
        // ignore: unused_result
        ref.refresh(lobbyProvider);
        return true;
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(widget.games.gameName!),
            ],
          ),
          actions: [
            GestureDetector(
              onTap: () {
                ApiService.signOut();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Row(
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              "Draw Time: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              Helper.epocToMMddYYYYhhMMaa(
                                  widget.games.drawStartTime!),
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            const Text(
                              "Draw ID: ",
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(
                              widget.games.drawPlayGroupId!,
                              style: const TextStyle(
                                  fontSize: 13, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Center(child: CustomCloseButton()),
                  ],
                ),
              ),
            ),
          ],
        ),
        body: Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.enter): CustomButton(),
            SingleActivator(LogicalKeyboardKey.f12): BarcodeIntent(),
            SingleActivator(LogicalKeyboardKey.f1): ResultIntent(),
            SingleActivator(LogicalKeyboardKey.f2): ReportIntent(),
            SingleActivator(LogicalKeyboardKey.f3): MyHistoryIntent(),
            SingleActivator(LogicalKeyboardKey.f4): ReprintIntent(),
          },
          child: Actions(
            actions: {
              CustomButton:
                  CallbackAction(onInvoke: (intent) => customeButtonSearch()),
              ResultIntent: CallbackAction<ResultIntent>(
                  onInvoke: (intent) => widget.openDialogCallback("Result")),
              ReportIntent: CallbackAction<ReportIntent>(
                  onInvoke: (intent) => widget.openDialogCallback("Report")),
              MyHistoryIntent: CallbackAction<MyHistoryIntent>(
                  onInvoke: (intent) =>
                      widget.openDialogCallback("My History")),
              ReprintIntent: CallbackAction<ReprintIntent>(
                  onInvoke: (intent) => searchResult()),
            },
            child: FocusScope(
              autofocus: true,
              child: AbsorbPointer(
                absorbing: showLoadingOverlay ? true : false,
                child: Stack(
                  children: [
                    Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              SizedBox(
                                width: MediaQuery.of(context).size.width,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        InkWell(
                                          onTap: showLoadingOverlay
                                              ? null
                                              : () async {
                                                  bool networkStatus = await Helper
                                                      .checkNetworkConnection();
                                                  if (networkStatus) {
                                                    quickPick(5);
                                                  } else {
                                                    if (!mounted) return;
                                                    // ignore: use_build_context_synchronously
                                                    showSnackBar(context,
                                                        "Check your internet connection");
                                                  }
                                                },
                                          child: QuickPicksWidget(
                                            title: '5 QuickPicks',
                                            onlytitile: 'only',
                                            icon: const Icon(
                                              Icons.stars_sharp,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                            //  const Image(
                                            //     image:
                                            //         AssetImage('assets/images/coin.png')),
                                            subtitle: (5 * widget.games.price!)
                                                .toStringAsFixed(0),
                                            iconData: Icons.shopping_cart,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: showLoadingOverlay
                                              ? null
                                              : () async {
                                                  bool networkStatus = await Helper
                                                      .checkNetworkConnection();
                                                  if (networkStatus) {
                                                    quickPick(25);
                                                  } else {
                                                    if (!mounted) return;
                                                    // ignore: use_build_context_synchronously
                                                    showSnackBar(context,
                                                        "Check your internet connection");
                                                  }
                                                },
                                          child: QuickPicksWidget(
                                            title: '25 QuickPicks',
                                            onlytitile: 'only',

                                            icon: const Icon(
                                              Icons.stars_sharp,
                                              size: 12,
                                              color: Colors.white,
                                            ),
                                            // const Image(
                                            //     image:
                                            //         AssetImage('assets/images/coin.png')),
                                            subtitle: (25 * widget.games.price!)
                                                .toStringAsFixed(0),
                                            iconData: Icons.shopping_cart,
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () {
                                            setState(() {
                                              showCustomizeTicket =
                                                  !showCustomizeTicket;
                                              customizeTicketController.clear();
                                            });
                                          },
                                          child: const QuickPicksWidget(
                                            title: 'Customize',
                                            subtitle: 'Your Tickets',
                                            onlytitile: '',
                                            icon: Text(''),
                                            iconData: Icons
                                                .dashboard_customize_outlined,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceAround,
                                      children: [
                                        QuickPicksWidgetCustom(
                                          text: "Result(F1)",
                                          icon: Icons.list,
                                          onPressed: () {
                                            widget.openDialogCallback("Result");
                                          },
                                          backgroundColor: kPrimarySeedColor!,
                                          iconSize: average / 100,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        QuickPicksWidgetCustom(
                                          text: "Report(F2)",
                                          icon: Icons.receipt_long_rounded,
                                          onPressed: () {
                                            widget.openDialogCallback("Report");
                                          },
                                          backgroundColor: kPrimarySeedColor!,
                                          iconSize: average / 100,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        QuickPicksWidgetCustom(
                                          text: "History(F3)",
                                          icon: Icons.file_copy,
                                          onPressed: () {
                                            widget.openDialogCallback(
                                                "My History");
                                          },
                                          backgroundColor: kPrimarySeedColor!,
                                          iconSize: average / 100,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        QuickPicksWidgetCustom(
                                          text: "Re-Print(F4)",
                                          icon: Icons.print_outlined,
                                          onPressed: () async {
                                            if (isProcessing) {
                                              return; // Prevent multiple taps
                                            }
                                            isProcessing =
                                                true; // Lock processing

                                            try {
                                              debugPrint(
                                                  "Checking game id : ${widget.gameID}");

                                              final value = await ref.read(
                                                reprintProvider(
                                                  ReprintParams(
                                                    gameRefCode: SharedPref
                                                            .instance
                                                            .getString(
                                                                "internalRefNo") ??
                                                        "",
                                                    gameId: SharedPref.instance
                                                            .getString(
                                                                "gameIdReprint") ??
                                                        "",
                                                  ),
                                                ).future,
                                              );

                                              onCheckPrint(
                                                userName: userName,
                                                barCode: value.barCode,
                                                cancelTicket: false,
                                                drawDate: value.drawStartTime,
                                                drawID: value.drawPlayGroupId,
                                                gameName: value.gameName,
                                                internalRefNo:
                                                    value.internalRefNo,
                                                ticketCount: value.ticketCount
                                                    .toString(),
                                                ticketPrice: value.ticketPrice,
                                                tickets: value.tickets,
                                                share: false,
                                                price: value.price,
                                                defaultPrinter: defaultPrinter,
                                              );
                                            } catch (error) {
                                              debugPrint(
                                                  "Error during reprint: $error");
                                            } finally {
                                              isProcessing =
                                                  false; // Unlock processing
                                            }
                                          },
                                          backgroundColor: kPrimarySeedColor!,
                                          iconSize: average / 100,
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              AnimatedSwitcher(
                                duration: const Duration(
                                  milliseconds: 300,
                                ),
                                child: showCustomizeTicket
                                    ? Column(
                                        children: [
                                          Container(
                                            height: 40.0,
                                            padding: const EdgeInsets.all(8.0),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            decoration: BoxDecoration(
                                              color: kPrimarySeedColor!
                                                  // ignore: deprecated_member_use
                                                  .withOpacity(
                                                0.17,
                                              ),
                                              borderRadius:
                                                  const BorderRadius.vertical(
                                                top: Radius.circular(8.0),
                                              ),
                                            ),
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                const Text(
                                                  "Customize your tickets",
                                                ),
                                                OutlinedButton(
                                                  style: OutlinedButton.styleFrom(
                                                      side: BorderSide(
                                                          color:
                                                              kPrimarySeedColor!)),
                                                  onPressed: () async {
                                                    bool networkStatus =
                                                        await Helper
                                                            .checkNetworkConnection();
                                                    if (networkStatus) {
                                                      setState(() {
                                                        showCustomizeTicket =
                                                            false;
                                                        showPickYourTicker =
                                                            false;
                                                        customizeTicketController
                                                            .clear();
                                                      });
                                                    } else {
                                                      if (!mounted) return;
                                                      showSnackBar(context,
                                                          "Check your internet connection");
                                                    }
                                                  },
                                                  child: const Text("Close"),
                                                )
                                              ],
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.all(8.0),
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 8.0),
                                            decoration: const BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                bottom: Radius.circular(8.0),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: Column(
                                              children: [
                                                Form(
                                                  key: customizeTicketKey,
                                                  child: SizedBox(
                                                    width: 250,
                                                    height: 60,
                                                    child: TextFormField(
                                                      controller:
                                                          customizeTicketController,
                                                      keyboardType:
                                                          TextInputType.number,
                                                      maxLength: 6,
                                                      onSaved: (value) async {
                                                        if (value != null) {
                                                          int multiplier =
                                                              6 - value.length;
                                                          if (value.length <
                                                              6) {
                                                            value = value +
                                                                "*" *
                                                                    multiplier;
                                                          }
                                                          setState(() {
                                                            isSearching = true;
                                                          });
                                                          SearchParams
                                                              searchParams =
                                                              SearchParams(
                                                            gameID: widget
                                                                .games.gameId!,
                                                            drawID: widget
                                                                .games.drawId!,
                                                            ticketNo: value,
                                                          );
                                                          await ref
                                                              .read(searchTicketProvider(
                                                                      searchParams)
                                                                  .future)
                                                              .then((value) {
                                                            setState(() {
                                                              isSearching =
                                                                  false;
                                                            });

                                                            Set<String>
                                                                filteredList =
                                                                {};
                                                            // for (String val in value) {
                                                            //   if (val.endsWith("-1")) {
                                                            filteredList
                                                                .addAll(value);
                                                            //   }
                                                            // }

                                                            if (filteredList
                                                                .isEmpty) {
                                                            } else {
                                                              ref
                                                                  .read(customizeTicketProvider
                                                                      .notifier)
                                                                  .addCustomizedTicket(
                                                                      filteredList);
                                                              setState(() {
                                                                showPickYourTicker =
                                                                    true;
                                                              });
                                                            }
                                                          }).onError((error,
                                                                  stackTrace) {
                                                            if (!mounted) {
                                                              return;
                                                            }
                                                            setState(() {
                                                              showLoadingOverlay =
                                                                  false;
                                                              isSearching =
                                                                  false;
                                                            });
                                                            ExceptionHandler.showSnack(
                                                                errorCode: error
                                                                    .toString(),
                                                                context:
                                                                    context);
                                                          });
                                                        }
                                                      },
                                                      inputFormatters: [
                                                        FilteringTextInputFormatter
                                                            .allow(
                                                          RegExp(r'[0-9]'),
                                                        ),
                                                      ],
                                                      autovalidateMode:
                                                          AutovalidateMode
                                                              .onUserInteraction,
                                                      validator: (value) {
                                                        if (value == null) {
                                                          return null;
                                                        } else if (value
                                                            .isEmpty) {
                                                          return "Ticket number cannot be empty";
                                                        } else if (value
                                                                .length <
                                                            4) {
                                                          return "Enter at least 4 digits";
                                                        }
                                                        return null;
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        filled: true,
                                                        fillColor: Colors.grey
                                                            .withOpacity(0.12),
                                                        border:
                                                            OutlineInputBorder(
                                                          borderSide:
                                                              BorderSide.none,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      8.0),
                                                        ),
                                                        hintText:
                                                            "Enter ticket no",
                                                        hintStyle:
                                                            const TextStyle(
                                                          fontSize: 12.0,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                        ),
                                                        contentPadding:
                                                            const EdgeInsetsDirectional
                                                                .fromSTEB(
                                                          kDefaultPadding * 2,
                                                          kDefaultPadding * 0.8,
                                                          0,
                                                          kDefaultPadding * 0.8,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                const SizedBox(
                                                  height: 10.0,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.center,
                                                  children: [
                                                    ElevatedButton(
                                                      onPressed: isSearching
                                                          ? null
                                                          : () async {
                                                              bool
                                                                  networkStatus =
                                                                  await Helper
                                                                      .checkNetworkConnection();
                                                              if (networkStatus) {
                                                                if (customizeTicketKey
                                                                    .currentState!
                                                                    .validate()) {
                                                                  setState(() {
                                                                    showPickYourTicker =
                                                                        false;
                                                                  });
                                                                  ref
                                                                      .read(
                                                                          customizeTicketProvider)
                                                                      .clear();
                                                                  customizeTicketKey
                                                                      .currentState!
                                                                      .save();
                                                                }
                                                              } else {
                                                                setState(() {
                                                                  showPickYourTicker =
                                                                      false;
                                                                });
                                                                if (!mounted)
                                                                  return;
                                                                showSnackBar(
                                                                    context,
                                                                    "Check your internet connection");
                                                              }
                                                            },
                                                      child: AnimatedCrossFade(
                                                        duration:
                                                            const Duration(
                                                                milliseconds:
                                                                    300),
                                                        firstChild: const Text(
                                                          "Search Your Tickets",
                                                        ),
                                                        secondChild:
                                                            const Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  4.0),
                                                          child: SizedBox(
                                                            height: 20.0,
                                                            width: 20.0,
                                                            child:
                                                                CircularProgressIndicator(
                                                              color:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                        ),
                                                        crossFadeState:
                                                            isSearching
                                                                ? CrossFadeState
                                                                    .showSecond
                                                                : CrossFadeState
                                                                    .showFirst,
                                                      ),
                                                    ),
                                                    const SizedBox(
                                                      width: 25.0,
                                                    ),
                                                    OutlinedButton(
                                                      onPressed: () {
                                                        customizeTicketKey
                                                            .currentState!
                                                            .reset();
                                                        customizeTicketController
                                                            .clear();
                                                        setState(() {
                                                          showPickYourTicker =
                                                              false;
                                                        });
                                                        ref.refresh(
                                                            customizeTicketProvider);
                                                      },
                                                      child: const Text(
                                                        "Reset",
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              Consumer(builder: (context, ref, _) {
                                return AnimatedCrossFade(
                                  firstChild: const SizedBox.shrink(),
                                  secondChild: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 16.0),
                                    child: Column(
                                      children: [
                                        Container(
                                          height: 40.0,
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2.0, horizontal: 8.0),
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: BoxDecoration(
                                            color:
                                                kPrimarySeedColor!.withOpacity(
                                              0.17,
                                            ),
                                            borderRadius:
                                                const BorderRadius.vertical(
                                              top: Radius.circular(8.0),
                                            ),
                                          ),
                                          child: Row(
                                            children: [
                                              const Text(
                                                "Pick Your Tickets",
                                              ),
                                              const Spacer(),
                                              SizedBox(
                                                height: 22.0,
                                                child: ElevatedButton(
                                                  onPressed: () {
                                                    final Set<String>
                                                        customizedTicketSet =
                                                        ref.read(
                                                            customizeTicketProvider);

                                                    Set<String> filteredList =
                                                        {};
                                                    for (String val
                                                        in customizedTicketSet) {
                                                      if (val.endsWith("-1")) {
                                                        filteredList.add(val
                                                            .substring(0, 6));
                                                      }
                                                    }

                                                    ref
                                                        .read(cartTicketProvider
                                                            .notifier)
                                                        .addCartTicket(
                                                            filteredList);
                                                    ref
                                                        .read(
                                                            customizeTicketProvider)
                                                        .clear();

                                                    setState(() {
                                                      showPickYourTicker =
                                                          false;
                                                    });
                                                  },
                                                  child: const Text(
                                                    "Pick All",
                                                    style: TextStyle(
                                                        fontSize: 12.0),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.all(8.0),
                                          width: double.infinity,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 8.0),
                                          decoration: const BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.vertical(
                                              bottom: Radius.circular(8.0),
                                            ),
                                          ),
                                          child: Wrap(
                                            runSpacing: 10.0,
                                            direction: Axis.horizontal,
                                            children: [
                                              ...customizeTicket
                                                  .map(
                                                    (e) => TicketChipWidget(
                                                      ticketNo: e,
                                                    ),
                                                  )
                                                  .toList(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  crossFadeState: showPickYourTicker
                                      ? CrossFadeState.showSecond
                                      : CrossFadeState.showFirst,
                                  duration: const Duration(milliseconds: 300),
                                );
                              }),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 16.0),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 40.0,
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 2.0, horizontal: 8.0),
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      decoration: BoxDecoration(
                                        color: kPrimarySeedColor!.withOpacity(
                                          0.17,
                                        ),
                                        borderRadius:
                                            const BorderRadius.vertical(
                                          top: Radius.circular(8.0),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.shopping_cart,
                                            size: 16.0,
                                          ),
                                          const SizedBox(
                                            width: 10.0,
                                          ),
                                          RichText(
                                            text: TextSpan(
                                              style: const TextStyle(
                                                  color: Colors.black),
                                              children: <TextSpan>[
                                                const TextSpan(
                                                    text: "Shopping Cart"),
                                                if (ref
                                                    .watch(cartTicketProvider
                                                        .notifier)
                                                    .cartTicketData
                                                    .isNotEmpty)
                                                  TextSpan(
                                                      text:
                                                          " (${ref.watch(cartTicketProvider.notifier).cartTicketLength.toString()})"),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () {
                                              ref
                                                  .read(cartTicketProvider
                                                      .notifier)
                                                  .clear();
                                              setState(() {
                                                showPickYourTicker = false;
                                              });
                                            },
                                            icon: const Icon(
                                              Icons.delete,
                                              size: 16.0,
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      width: double.infinity,
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 8.0),
                                      decoration: const BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.vertical(
                                          bottom: Radius.circular(8.0),
                                        ),
                                      ),
                                      child: Wrap(
                                        runSpacing: 10.0,
                                        direction: Axis.horizontal,
                                        children: [
                                          ...ticketNoSet
                                              .map(
                                                (e) => TicketChipWidget(
                                                  ticketNo: e,
                                                  fromCart: true,
                                                ),
                                              )
                                              .toList(),
                                          InkWell(
                                            onTap: showLoadingOverlay
                                                ? null
                                                : () async {
                                                    bool networkStatus =
                                                        await Helper
                                                            .checkNetworkConnection();
                                                    if (networkStatus) {
                                                      addOne();
                                                    } else {
                                                      if (!mounted) return;
                                                      showSnackBar(context,
                                                          "Check your internet connection");
                                                    }
                                                  },
                                            child: const AddTicketChipWidget(),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ExpansionTile(
                              //   backgroundColor: Colors.white,
                              //   title: const Text('Price Structure'),
                              //   controlAffinity:
                              //       ListTileControlAffinity.leading,
                              //   children: [
                              //     Padding(
                              //       padding: const EdgeInsets.all(8.0),
                              //       child: Table(
                              //         border: TableBorder.all(),
                              //         columnWidths: const <int,
                              //             TableColumnWidth>{
                              //           0: FlexColumnWidth(),
                              //           1: FlexColumnWidth(),
                              //           2: FlexColumnWidth(),
                              //         },
                              //         defaultVerticalAlignment:
                              //             TableCellVerticalAlignment.middle,
                              //         children: <TableRow>[
                              //           TableRow(
                              //             children: <Widget>[
                              //               CustomTableCell(
                              //                 text: "Prize Description",
                              //                 color:
                              //                     Colors.blue.withOpacity(0.20),
                              //               ),
                              //               CustomTableCell(
                              //                 text: "Prize",
                              //                 color:
                              //                     Colors.blue.withOpacity(0.20),
                              //               ),
                              //               CustomTableCell(
                              //                 text: "No. of Prize",
                              //                 color:
                              //                     Colors.blue.withOpacity(0.20),
                              //               ),
                              //               CustomTableCell(
                              //                 text: "Total Prize",
                              //                 color:
                              //                     Colors.blue.withOpacity(0.20),
                              //               ),
                              //             ],
                              //           ),
                              //           const TableRow(
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey,
                              //             ),
                              //             children: <Widget>[
                              //               CustomTableCell(
                              //                 text: "1st Price \n(6 digit)",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "6,00,000",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "1",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "6,00,000",
                              //               ),
                              //             ],
                              //           ),
                              //           const TableRow(
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey,
                              //             ),
                              //             children: <Widget>[
                              //               CustomTableCell(
                              //                 text: "Up/Down Price\n (6 digit)",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "1,00,000",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "2",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "2,00,000",
                              //               ),
                              //             ],
                              //           ),
                              //           const TableRow(
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey,
                              //             ),
                              //             children: <Widget>[
                              //               CustomTableCell(
                              //                 text: "2nd Price \n(6 digit)",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "50,000",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "5",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "2,50,000",
                              //               ),
                              //             ],
                              //           ),
                              //           const TableRow(
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey,
                              //             ),
                              //             children: <Widget>[
                              //               CustomTableCell(
                              //                 text: "3rd Price \n(6 digit)",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "10,000",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "10",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "1,00,000",
                              //               ),
                              //             ],
                              //           ),
                              //           const TableRow(
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey,
                              //             ),
                              //             children: <Widget>[
                              //               CustomTableCell(
                              //                 text: "4th Price \n (6 digit)",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "7,000",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "50",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "3,50,000",
                              //               ),
                              //             ],
                              //           ),
                              //           const TableRow(
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey,
                              //             ),
                              //             children: <Widget>[
                              //               CustomTableCell(
                              //                 text: "5th Price \n(6 digit)",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "5,000",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "100",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "5,00,000",
                              //               ),
                              //             ],
                              //           ),
                              //           const TableRow(
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey,
                              //             ),
                              //             children: <Widget>[
                              //               CustomTableCell(
                              //                 text: "Last 3 digit",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "250",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "4,000",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "10,00,000",
                              //               ),
                              //             ],
                              //           ),
                              //           const TableRow(
                              //             decoration: BoxDecoration(
                              //               color: Colors.grey,
                              //             ),
                              //             children: <Widget>[
                              //               CustomTableCell(
                              //                 text: "Last 2 digit",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "100",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "10,000",
                              //               ),
                              //               CustomTableCell(
                              //                 text: "10,00,000",
                              //               ),
                              //             ],
                              //           ),
                              //         ],
                              //       ),
                              //     ),
                              //   ],
                              // ),
                              ExpansionTile(
                                backgroundColor: Colors.white,
                                title: const Text('Price Structure'),
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                onExpansionChanged: (isExpanded) {
                                  if (isExpanded) fetchPriceStructure();
                                },
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8.0),
                                    child: Table(
                                      border: TableBorder.all(),
                                      columnWidths: const <int,
                                          TableColumnWidth>{
                                        0: FlexColumnWidth(),
                                        1: FlexColumnWidth(),
                                        2: FlexColumnWidth(),
                                        3: FlexColumnWidth(),
                                      },
                                      defaultVerticalAlignment:
                                          TableCellVerticalAlignment.middle,
                                      children: [
                                        // Header Row
                                        TableRow(
                                          children: [
                                            _buildHeaderCell(
                                                "Prize Description"),
                                            _buildHeaderCell("Prize"),
                                            _buildHeaderCell(
                                                "No. of Prize (Total Win No's)"),
                                            _buildHeaderCell("Total Prize"),
                                          ],
                                        ),
                                        // Dynamic Rows
                                        // Dynamic Rows
                                        ...(priceStructure?.results ?? [])
                                            .map((result) => TableRow(
                                                  decoration:
                                                      const BoxDecoration(
                                                          color: Colors.grey),
                                                  children: [
                                                    CustomTableCell(
                                                        text: result
                                                            .winDescription),
                                                    CustomTableCell(
                                                        text: result.winPrice
                                                            .toStringAsFixed(
                                                                0)),
                                                    CustomTableCell(
                                                        text:
                                                            "${result.totalNo.toString()} (${result.totalNoPrice}) "),
                                                    CustomTableCell(
                                                        text: formatCurrency
                                                            .format(result
                                                                    .totalNoPrice *
                                                                int.parse(result
                                                                    .winPrice
                                                                    .toStringAsFixed(
                                                                        0)))
                                                            .toString()),
                                                  ],
                                                )),
                                      ],
                                    ),
                                  )
                                ],
                              ),
                              const SizedBox(
                                height: 100,
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(4.0),
                                topRight: Radius.circular(4.0),
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                        "Tickets: ${ref.watch(cartTicketProvider).length}"),
                                    Row(
                                      children: [
                                        const Icon(
                                          Icons.stars_sharp,
                                          size: 16,
                                        ),
                                        // const SizedBox(
                                        //   width: 15,
                                        //   height: 18,
                                        //   child:   Image(
                                        //       image:
                                        //            AssetImage('assets/images/coin.png')),
                                        // ),
                                        const SizedBox(
                                          width: 4,
                                        ),
                                        Text(
                                            " ${totalPrice.toStringAsFixed(0)}"),
                                      ],
                                    ),
                                  ],
                                ),
                                Divider(
                                  color: Colors.grey[300],
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(SharedPref.instance
                                                .getString("username") ??
                                            "-"),
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Row(
                                          children: [
                                            const Text("Balance :"),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            const Icon(
                                              Icons.stars_sharp,
                                              size: 16,
                                            ),
                                            // const SizedBox(
                                            //   width: 15,
                                            //   height: 18,
                                            //   child:  Image(
                                            //       image:
                                            //           AssetImage('assets/images/coin.png')),
                                            // ),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            // Text((ref
                                            //         .watch(balanceProvider)
                                            //         .value!)
                                            //     .toStringAsFixed(0)),
                                            const SizedBox(
                                              width: 4,
                                            ),
                                            balance.when(
                                              data: (balance) {
                                                setState(() {
                                                  userBalance = balance;
                                                  userBalanceIsActive = false;
                                                });
                                                return Container(
                                                  padding:
                                                      const EdgeInsets.all(2),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                    color: Colors.white,
                                                  ),
                                                  child: AnimatedFlipCounter(
                                                    //  prefix: "Balance: ",
                                                    duration: const Duration(
                                                        milliseconds: 500),
                                                    textStyle: TextStyle(
                                                      fontSize: average / 200,

                                                      color: Colors.black,
                                                      // shadows: const [
                                                      //   BoxShadow(
                                                      //     color: Colors.grey,
                                                      //     offset: Offset(1, 5),
                                                      //     blurRadius: 4,
                                                      //   ),
                                                      // ],
                                                    ),
                                                    value: balance.floor(),
                                                  ),
                                                );
                                              },
                                              loading: () {
                                                return const SizedBox(
                                                  width: 50.0,
                                                  child:
                                                      LinearProgressIndicator(),
                                                );
                                              },
                                              error: (e, s) {
                                                //recently added this code for balance updated

                                                return const Text("-");
                                              },
                                            ),
                                            userBalanceIsActive
                                                ? const CircularProgressIndicator()
                                                : IconButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        userBalanceIsActive =
                                                            true;
                                                      });
                                                      // ignore: unused_result
                                                      ref.refresh(
                                                          balanceProvider);
                                                    },
                                                    icon: Icon(
                                                      Icons.refresh,
                                                      size: average / 120,
                                                      color: Colors.black,
                                                    ),
                                                  ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 32.0,
                                      width: 200.0,
                                      child: ElevatedButton(
                                        onPressed: isBuying
                                            ? null
                                            : () async {
                                                bool networkStatus = await Helper
                                                    .checkNetworkConnection();
                                                if (networkStatus) {
                                                  if (ref
                                                      .read(cartTicketProvider)
                                                      .isNotEmpty) {
                                                    if (ref
                                                            .read(
                                                                cartTicketProvider)
                                                            .length <=
                                                        int.parse(
                                                            lottoMaxCountTicketBuy)) {
                                                      if (totalPrice >
                                                          ref
                                                              .watch(
                                                                  balanceProvider)
                                                              .value!) {
                                                        if (!mounted) return;
                                                        ScaffoldMessenger.of(
                                                                context)
                                                            .showSnackBar(
                                                          const SnackBar(
                                                            content: Text(
                                                                "You don't have sufficient balance"),
                                                          ),
                                                        );
                                                        return;
                                                      }
                                                      setState(() {
                                                        isBuying = true;
                                                      });
                                                      await ref
                                                          .read(
                                                        buyTicketProvider(
                                                          BuyParams(
                                                            drawId: widget
                                                                .games.drawId!,
                                                            drawPlayGroupId: widget
                                                                .games
                                                                .drawPlayGroupId!,
                                                            gameId: widget
                                                                .games.gameId!,
                                                            ticketNos: ref
                                                                .read(
                                                                    cartTicketProvider)
                                                                .toList(),
                                                          ),
                                                        ).future,
                                                      )
                                                          .then((value) {
                                                        setState(() {
                                                          isBuying = false;
                                                          showLoadingOverlay =
                                                              false;
                                                        });
                                                        ref.refresh(
                                                            balanceProvider);
                                                        ref
                                                            .read(
                                                                cartTicketProvider)
                                                            .clear();
                                                        if (kIsWeb) {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PurchaseStatusViewWeb(
                                                                data: value,
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                              builder: (context) =>
                                                                  PurchaseStatusView(
                                                                drawId: value
                                                                    .drawPlayGroupId!,
                                                                gameName: value
                                                                    .gameName!,
                                                                data: value,
                                                              ),
                                                            ),
                                                          );
                                                        }
                                                      }).onError(
                                                              (Exception error,
                                                                  stackTrace) {
                                                        setState(() {
                                                          isBuying = false;
                                                          showLoadingOverlay =
                                                              false;
                                                        });
                                                        ExceptionHandler
                                                            .showSnack(
                                                                errorCode: error
                                                                    .toString(),
                                                                // ignore: use_build_context_synchronously
                                                                context:
                                                                    context);
                                                      });
                                                    } else {
                                                      if (!mounted) return;
                                                      // ignore: use_build_context_synchronously
                                                      showSnackBar(context,
                                                          "Ticket count should be less than or equal to $lottoMaxCountTicketBuy");
                                                    }
                                                  } else {
                                                    if (!mounted) return;
                                                    // ignore: use_build_context_synchronously
                                                    showSnackBar(context,
                                                        "Please add a ticket to cart to buy");
                                                  }
                                                } else {
                                                  if (!mounted) return;
                                                  // ignore: use_build_context_synchronously
                                                  showSnackBar(context,
                                                      "Check your internet connection");
                                                }
                                              },
                                        child: isBuying
                                            ? const CircularProgressIndicator()
                                            : const Text(
                                                "QUICK BUY",
                                                style: TextStyle(
                                                  fontSize: 14.0,
                                                ),
                                              ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (showLoadingOverlay || isBuying) const MyOverlay()
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void searchResult() async {
    bool networkStatus = await Helper.checkNetworkConnection();
    if (networkStatus) {
      results = [];
      DateTime now = DateTime.now();
      DateTime startOfDay = DateTime(now.year, now.month, now.day, 0, 0, 0);
      DateTime endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

      int fromDate = startOfDay.millisecondsSinceEpoch;
      int toDate = endOfDay.millisecondsSinceEpoch;

      UserResultsParams userResultSearchParams = UserResultsParams(
        claimStatus: 0,
        categoryId: widget.categoryId,
        gameId: widget.gameID,
        fromDate: fromDate,
        toDate: toDate,
        page: 0,
        resultType: 1,
      );
      setState(() {
        isLoading = true;
      });

      await ref
          .watch(toBeDrawnProvider(userResultSearchParams).future)
          .then((value) {
        if (!mounted) {
          return;
        }
        setState(() {
          results = value.results!;

          isLoading = false;
        });
      }).onError((error, stackTrace) {
        if (!mounted) {
          return;
        }
        ExceptionHandler.showSnack(
            errorCode: error.toString(), context: context);
        setState(() {
          isLoading = false;
        });
      });
    } else {
      if (!mounted) return;
      showSnackBar(context, "Check your internet connection");
    }
  }

  Widget _buildHeaderCell(String text) {
    return CustomTableCell(
      text: text,
      color: Colors.blue.withOpacity(0.20),
    );
  }

  void onCheckPrint({
    required String userName,
    required String gameName,
    required String drawDate,
    required String drawID,
    required double ticketPrice,
    required String ticketCount,
    required String internalRefNo,
    required String barCode,
    required List<String> tickets, // Added tickets list
    required bool share,
    required bool cancelTicket,
    required double price,
    Printer? defaultPrinter,
  }) async {
    const double globalFontSize = 8.0;
    final font = await PdfGoogleFonts.robotoFlexRegular();
    final pdf = pw.Document(version: PdfVersion.pdf_1_4);

    double numberLines = 200 * PdfPageFormat.mm;
    double leftPadding = 10 * PdfPageFormat.mm;

    PdfPageFormat pageFormat;
    if (selectedPaperSize == PaperSelect.Size80) {
      pageFormat = PdfPageFormat(80 * PdfPageFormat.mm, numberLines);
      leftPadding = 10 * PdfPageFormat.mm;
    } else {
      pageFormat = PdfPageFormat(57 * PdfPageFormat.mm, numberLines);
      leftPadding = 0 * PdfPageFormat.mm;
    }

    pdf.addPage(pw.MultiPage(
      pageFormat: pageFormat,
      margin:
          pw.EdgeInsets.only(left: leftPadding, top: 2, right: 5, bottom: 3),
      build: (context) => [
        // Centered header
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            pw.Text(
              currentName,
              style: pw.TextStyle(fontSize: 12, font: font),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(
              '(For Amusement Purpose Only)',
              style: pw.TextStyle(fontSize: 9.0, font: font),
              textAlign: pw.TextAlign.center,
            ),
            pw.Text(gameName, style: pw.TextStyle(fontSize: 14, font: font)),
          ],
        ),

        // Left-aligned details
        pw.Container(
          margin: const pw.EdgeInsets.only(bottom: 8),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Retailer: $userName",
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text("Trans ID:$internalRefNo",
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text("Draw Date: $drawDate",
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text("Draw ID: $drawID",
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text("Total Points: ${ticketPrice.toStringAsFixed(0)}",
                  style: pw.TextStyle(fontSize: globalFontSize, font: font)),
              pw.Text(
                "Points: ${price.toStringAsFixed(0)}       Qty: $ticketCount",
                style: pw.TextStyle(
                    fontSize: 10, fontWeight: pw.FontWeight.bold, font: font),
              ),
            ],
          ),
        ),
        // Display each ticket number and corresponding barcode
        pw.ListView.builder(
          itemCount: tickets.length,
          itemBuilder: (context, index) {
            String ticket = tickets[index];

            if (selectedPaperSize == PaperSelect.Size80) {
              // For 80mm paper, print tickets and barcodes in pairs (left and right)
              int evenIndex = index * 2;
              int oddIndex = evenIndex + 1;

              return pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.start,
                children: [
                  // Ticket and Barcode for Even Index
                  if (evenIndex < tickets.length)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 20),
                          child: pw.Text(
                            tickets[evenIndex].split('-')[0],
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                        pw.SizedBox(
                          width: 80,
                          height: 30,
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.code128(),
                            data: tickets[evenIndex].split('-').last,
                          ),
                        ),
                      ],
                    ),

                  pw.SizedBox(width: 10), // Adjust spacing between columns

                  // Ticket and Barcode for Odd Index
                  if (oddIndex < tickets.length)
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 20),
                          child: pw.Text(
                            tickets[oddIndex].split('-')[0],
                            style: pw.TextStyle(font: font),
                          ),
                        ),
                        pw.SizedBox(
                          width: 80,
                          height: 30,
                          child: pw.BarcodeWidget(
                            barcode: pw.Barcode.code128(),
                            data: tickets[oddIndex].split('-').last,
                          ),
                        ),
                      ],
                    ),
                ],
              );
            } else {
              // For other paper sizes, print tickets and barcodes vertically
              return pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Padding(
                    padding: const pw.EdgeInsets.only(left: 20),
                    child: pw.Text(ticket.split("-").first),
                  ),
                  pw.SizedBox(
                    width: 80,
                    height: 30,
                    child: pw.BarcodeWidget(
                      barcode: pw.Barcode.code128(),
                      data: ticket.split("-").last,
                    ),
                  ),
                  pw.SizedBox(height: 5), // Space between entries on 57mm paper
                ],
              );
            }
          },
        ),

        // Footer text
        pw.Padding(
          padding: const pw.EdgeInsets.only(left: 18),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.center,
            children: [
              pw.Text(
                '**Ticket not for sale**',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
                textAlign: pw.TextAlign.center,
              ),
              pw.Text(
                '**Duplicate Ticket**',
                style: pw.TextStyle(fontSize: globalFontSize, font: font),
                textAlign: pw.TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    ));

    // Print or share the PDF
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
  }

  void customeButtonSearch() async {
    bool networkStatus = await Helper.checkNetworkConnection();
    if (networkStatus) {
      if (customizeTicketKey.currentState!.validate()) {
        setState(() {
          showPickYourTicker = false;
        });
        ref.read(customizeTicketProvider).clear();
        customizeTicketKey.currentState!.save();
      }
    } else {
      setState(() {
        showPickYourTicker = false;
      });
      if (!mounted) return;
      showSnackBar(context, "Check your internet connection");
    }
  }
}

class CustomTableCell extends StatelessWidget {
  final String text;
  final Color? color;
  const CustomTableCell({
    Key? key,
    required this.text,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return TableCell(
      verticalAlignment: TableCellVerticalAlignment.top,
      child: Container(
        height: 50,
        width: 32,
        color: color ?? Colors.white,
        alignment: Alignment.center,
        child: Text(
          text,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

//! custonm button intent
class CustomButton extends Intent {
  const CustomButton();
}
