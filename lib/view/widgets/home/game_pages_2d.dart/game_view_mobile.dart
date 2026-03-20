import 'dart:developer';
import 'package:animated_custom_dropdown/custom_dropdown.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:psglotto/params/buy_ticket_others_params.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/services/api_service.dart';
import 'package:psglotto/update_value_2d_game.dart/init_game_others_notifier.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/home/game_pages_2d.dart/game_value.dart';
import 'package:psglotto/view/widgets/home/game_time_helper_widgets/refresh_indicator.dart';
import 'package:psglotto/view/widgets/home/game_time_helper_widgets/tab_color.dart';
import 'package:psglotto/view/widgets/home/purchase_status_view/purchased_status_2dview.dart';
import 'package:psglotto/view/widgets/loading_overlay.dart';
import 'package:psglotto/view/widgets/loading_overlay_custome.dart';
import 'package:psglotto/view/widgets/snackbar.dart';

import '../game_time_helper_widgets/top_widget.dart';

class GameViewMobile extends ConsumerStatefulWidget {
  final String drawId;
  final List<dynamic> types;
  final int? drawStartTime;
  final int? betCloseTime;

  const GameViewMobile(
      {required this.types,
      required this.drawStartTime,
      required this.betCloseTime,
      required this.drawId,
      Key? key})
      : super(key: key);

  @override
  ConsumerState<GameViewMobile> createState() => _GameViewMobileState();
}

class _GameViewMobileState extends ConsumerState<GameViewMobile>
    with SingleTickerProviderStateMixin {
  AnimationController? _controller;
  int selectedIndex = 0;

  //textEditControllers
  TextEditingController andharOne = TextEditingController();
  TextEditingController andharTwo = TextEditingController();
  TextEditingController bharOne = TextEditingController();
  TextEditingController bharTwo = TextEditingController();
  TextEditingController numberOne = TextEditingController();
  TextEditingController numberTwo = TextEditingController();
  TextEditingController qtyOne = TextEditingController();
  TextEditingController qtyTwo = TextEditingController();
  TextEditingController qtyThree = TextEditingController();
  TextEditingController qtyFour = TextEditingController();
  TextEditingController randomController = TextEditingController();
  ScrollController scrollController = ScrollController();

  FocusNode qtyFocusNodeOne = FocusNode();
  FocusNode qtyFocusNodeTwo = FocusNode();
  FocusNode qtyFocusNodeThree = FocusNode();
  FocusNode qtyFocusNodeFour = FocusNode();

  List<dynamic> numberInputList = [];
  List<Map<String, dynamic>> buyticket = [];
  //randomSelector
  List<String> typeOne = [];
  List<String> typeTwo = [];
  List<String> typeThree = [];
  List<String> firstSeries = [];
  List<String> secondSeries = [];
  num totalPoint = 0;
  num totalQty = 0;
  int andharValue = 0;
  int baharValue = 0;
  int doubleValueOne = 0;
  int doubleValueTwo = 0;
  num totalCount = 0;
  bool showLoadingOverlay = false;
//selected color index
  int selectedColorIndex = 0;
  bool priceStructure = false;
  List<String> random = [
    "Odd",
    "Even",
    "Jodi",
    "Q5",
    "Q10",
    "Q25",
    "Q50",
    "Q75"
  ];
  String drawId = "";
  Animation<Offset>? animation;
  String selectedRandomValue = "";
  bool resultOverlay = false;
  int drawStartTime = 0;
  bool deleteAnimation = false;
  bool isRefreshing = false;

  @override
  void initState() {
    super.initState();
    getLastDrawResult();
    balanceProvider;
    drawId = widget.drawId;
    qtyOne.text = "1";
    qtyTwo.text = "1";
    qtyThree.text = "1";
    qtyFour.text = "1";
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  void getLastDrawResult() async {
    setState(() {
      resultOverlay = true;
    });

    await ApiService.getLastDrawResult(
      gameID: "2d",
      categoryID: 2,
    ).then((value) {
      setState(() {
        resultOverlay = false;
      });

      if (value != null) {
        setResults(value["results"]);
        setState(() {
          drawStartTime = value['drawStartTime'];
        });
      }
    }).onError((error, stackTrace) {
      if (!mounted) {
        return;
      }
      setState(() {
        resultOverlay = false;
      });
      ExceptionHandler.showSnack(errorCode: error.toString(), context: context);
    });
  }

  void setResults(List results) {
    ref.read(drawStartTimeNotifier.notifier).updatedResult(results);
  }

  void setReshresh(bool refresh) {
    ref.read(drawStartTimeNotifier.notifier).updateRefresh(refresh);
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  void _toggleSelectedIndex(int index) {
    setState(() {
      if (selectedIndex == index) {
        selectedIndex = 0;
      } else {
        selectedIndex = index;
      }
    });
  }

  Future<void> onRefresh() async {
    ref.refresh(game2dProvider);
  }

  int quantity = 1;
  @override
  Widget build(BuildContext context) {
    final initGameValue = ref.watch(drawStartTimeNotifier);
    final AsyncValue balance = ref.watch(balanceProvider);
    final AsyncValue gameAsyncData = ref.watch(game2dProvider);
    return SafeArea(
        child: gameAsyncData.when(data: <InitGameOthersNew>(game2dProvider) {
      return Scaffold(
        appBar: AppBar(actions: [
          Container(
            color: kPrimarySeedColor,
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height * 0.05,
            child: TopGameWidget(
              ref: ref,
            ),
          ),
        ]),
        body: Stack(
          children: [
            AbsorbPointer(
              absorbing: initGameValue.setBloack == true ? true : false,
              child: Column(
                children: [
                  Expanded(
                      flex: 1,
                      child: SingleChildScrollView(
                        child: Container(
                          color: Colors.transparent,
                          child: Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.08,
                                color: Colors.white,
                                child: GridView.builder(
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemCount: widget.types.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 5,
                                    childAspectRatio:
                                        2.5, // Adjust the aspect ratio to achieve the desired width-to-height ratio
                                  ),
                                  itemBuilder: (context, index) {
                                    return GestureDetector(
                                      onTap: () {
                                        if (selectedIndex != index) {
                                          _toggleSelectedIndex(index);
                                          selectedColorIndex = index;
                                          //clear input value
                                          clearInput();
                                        }
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Container(
                                          decoration: selectedIndex == index
                                              ? BoxDecoration(
                                                  border: Border.all(
                                                      color: Colors.black,
                                                      width: 1),
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  color: TabColor()
                                                      .tabColors[index],
                                                  boxShadow: const [
                                                      BoxShadow(
                                                          blurRadius: 2.0,
                                                          offset:
                                                              Offset(1.0, 2.0))
                                                    ])
                                              : BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(3),
                                                  border: Border.all(
                                                      color: Colors.white),
                                                  color: TabColor()
                                                      .tabColors[index]
                                                      .withOpacity(0.3)),
                                          child: Center(
                                            child: Text(
                                              InitGameOthersProvider
                                                          .getInitGameOthers()[
                                                      'types'][index]['typeName']
                                                  .toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.w500,
                                                  fontSize: 11,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              const Divider(
                                color: Colors.black,
                                height: 0.1,
                                thickness: 1,
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Container(
                                      color: Colors.transparent,
                                      child:
                                          const Center(child: Text("Result")),
                                    ),
                                  ),
                                  Expanded(
                                    flex: 13,
                                    child: isRefreshing
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Container(
                                            height: 30,
                                            color: Colors.transparent,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              physics:
                                                  const NeverScrollableScrollPhysics(),
                                              itemCount:
                                                  initGameValue.results.length,
                                              itemBuilder: (context, index) {
                                                return Padding(
                                                  padding:
                                                      const EdgeInsets.all(4.0),
                                                  child: Container(
                                                    height: 20,
                                                    width: 22,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              5),
                                                      color: TabColor()
                                                          .tabColors[index]
                                                          .withOpacity(0.5),
                                                    ),
                                                    child: Center(
                                                      child: Text(
                                                        initGameValue
                                                            .results[index]
                                                                ['winNo']
                                                            .toString(),
                                                      ),
                                                    ),
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                  ),
                                  Expanded(
                                      flex: 2,
                                      child: initGameValue.refreshBool
                                          ? RefreshButton(
                                              refreshFunction: () {
                                                setReshresh(false);
                                                getLastDrawResult();
                                              },
                                            )
                                          : IconButton(
                                              onPressed: () {
                                                setReshresh(false);
                                                getLastDrawResult();
                                              },
                                              icon: const Icon(
                                                Icons.refresh,
                                                size: 30,
                                                color: Colors.black,
                                              ))),
                                ],
                              ),
                              const Divider(
                                color: Colors.black,
                                height: 0.1,
                                thickness: 1,
                              ),
                            ],
                          ),
                        ),
                      )),
                  Expanded(
                      flex: 5,
                      child: SingleChildScrollView(
                        clipBehavior: Clip.antiAlias,
                        scrollDirection: Axis.vertical,
                        controller: scrollController,
                        child: SizedBox(
                          child: Column(
                            children: [
                              Container(
                                height:
                                    MediaQuery.of(context).size.height * 0.26,
                                color: Colors.transparent,
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: const Text(
                                                            "Random"),
                                                      )),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                          color: Colors
                                                              .transparent,
                                                          child: SizedBox(
                                                              height: 30,
                                                              child:
                                                                  CustomDropdown(
                                                                // controller:
                                                                //     randomController,
                                                                hintText:
                                                                    "Select Draw",
                                                                // borderSide: const BorderSide(
                                                                //     color: Colors
                                                                //         .black),
                                                                // borderRadius:
                                                                //     BorderRadius
                                                                //         .circular(
                                                                //             5),
                                                                items: random,
                                                                onChanged:
                                                                    (String?
                                                                        value) {
                                                                  setState(() {
                                                                    selectedRandomValue =
                                                                        value!;
                                                                    randomSelector();
                                                                  });
                                                                },
                                                              ))))
                                                ],
                                              ),
                                              //checking
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: const Text(
                                                            "Andhar"),
                                                      )),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                  child:
                                                                      Container(
                                                                    decoration:
                                                                        const BoxDecoration(
                                                                      borderRadius:
                                                                          BorderRadius.all(
                                                                              Radius.circular(5)),
                                                                      color: Colors
                                                                          .grey,
                                                                    ),
                                                                    height: 25,
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                  child:
                                                                      SizedBox(
                                                                    height: 25,
                                                                    child:
                                                                        TextFormField(
                                                                      readOnly:
                                                                          false,
                                                                      controller:
                                                                          andharTwo,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      inputFormatters: [
                                                                        LengthLimitingTextInputFormatter(
                                                                            1),
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp(r'[0-9]')),
                                                                      ],
                                                                      decoration: const InputDecoration(
                                                                          fillColor: Colors
                                                                              .white,
                                                                          filled:
                                                                              true,
                                                                          border:
                                                                              OutlineInputBorder(borderSide: BorderSide(color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child:
                                                            const Text("Bahar"),
                                                      )),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                  child:
                                                                      SizedBox(
                                                                    height: 25,
                                                                    child:
                                                                        TextFormField(
                                                                      readOnly:
                                                                          false,
                                                                      controller:
                                                                          bharOne,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      inputFormatters: [
                                                                        LengthLimitingTextInputFormatter(
                                                                            1),
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp(r'[0-9]')),
                                                                      ],
                                                                      decoration: const InputDecoration(
                                                                          filled:
                                                                              true,
                                                                          fillColor: Colors
                                                                              .white,
                                                                          border:
                                                                              OutlineInputBorder(borderSide: BorderSide(color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                  child:
                                                                      SizedBox(
                                                                    height: 25,
                                                                    child:
                                                                        Container(
                                                                      decoration:
                                                                          const BoxDecoration(
                                                                        borderRadius:
                                                                            BorderRadius.all(Radius.circular(5)),
                                                                        color: Colors
                                                                            .grey,
                                                                      ),
                                                                      height:
                                                                          25,
                                                                    ),
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                      flex: 1,
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: const Text(
                                                            "Double"),
                                                      )),
                                                  Expanded(
                                                      flex: 2,
                                                      child: Container(
                                                        color:
                                                            Colors.transparent,
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                  child:
                                                                      SizedBox(
                                                                    height: 25,
                                                                    child:
                                                                        TextFormField(
                                                                      readOnly:
                                                                          false,
                                                                      controller:
                                                                          numberOne,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      inputFormatters: [
                                                                        LengthLimitingTextInputFormatter(
                                                                            1),
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp(r'[0-9]')),
                                                                      ],
                                                                      decoration: const InputDecoration(
                                                                          fillColor: Colors
                                                                              .white,
                                                                          filled:
                                                                              true,
                                                                          border:
                                                                              OutlineInputBorder(borderSide: BorderSide(color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                )),
                                                            Expanded(
                                                                flex: 1,
                                                                child: Padding(
                                                                  padding:
                                                                      const EdgeInsets
                                                                          .all(
                                                                          1.0),
                                                                  child:
                                                                      SizedBox(
                                                                    height: 25,
                                                                    child:
                                                                        TextFormField(
                                                                      controller:
                                                                          numberTwo,
                                                                      keyboardType:
                                                                          TextInputType
                                                                              .number,
                                                                      inputFormatters: [
                                                                        LengthLimitingTextInputFormatter(
                                                                            1),
                                                                        FilteringTextInputFormatter.allow(
                                                                            RegExp(r'[0-9]')),
                                                                      ],
                                                                      decoration: const InputDecoration(
                                                                          fillColor: Colors
                                                                              .white,
                                                                          filled:
                                                                              true,
                                                                          border:
                                                                              OutlineInputBorder(borderSide: BorderSide(color: Colors.black))),
                                                                    ),
                                                                  ),
                                                                ))
                                                          ],
                                                        ),
                                                      ))
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        color: Colors.transparent,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            qtySelector(
                                                qtyOne, 1, qtyFocusNodeOne),
                                            qtySelector(
                                                qtyTwo, 2, qtyFocusNodeTwo),
                                            qtySelector(
                                                qtyThree, 3, qtyFocusNodeThree),
                                            qtySelector(
                                                qtyFour, 4, qtyFocusNodeFour),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.only(left: 10, bottom: 10),
                                child: Align(
                                  alignment: Alignment.centerLeft,
                                  child: Text(
                                    "Minimum One Number For Series Tickets",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 11),
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  height:
                                      MediaQuery.of(context).size.height * 0.6,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: TabColor()
                                        .tabColors[selectedColorIndex]
                                        .withOpacity(0.2),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                              flex: 4,
                                              child: Row(
                                                children: [
                                                  const SizedBox(
                                                    width: 5,
                                                  ),
                                                  const Icon(
                                                    Icons.shopping_cart,
                                                    size: 16.0,
                                                  ),
                                                  const SizedBox(
                                                    width: 10,
                                                  ),
                                                  Text(
                                                      "SHOPPING CART (${buyticket.length})"),
                                                ],
                                              )),
                                          deleteAnimation
                                              ? SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: Center(
                                                    child: Lottie.asset(
                                                      "assets/animations/delete.json",
                                                      height: 50,
                                                      width: 50,
                                                    ),
                                                  ),
                                                )
                                              : SizedBox(
                                                  width: 50,
                                                  height: 50,
                                                  child: Center(
                                                    child: IconButton(
                                                        onPressed: () {
                                                          if (buyticket
                                                              .isNotEmpty) {
                                                            setState(() {
                                                              deleteAnimation =
                                                                  true;
                                                              buyticket.clear();
                                                              clearValue();
                                                              Future.delayed(
                                                                  const Duration(
                                                                      seconds:
                                                                          1),
                                                                  () {
                                                                setState(() {
                                                                  deleteAnimation =
                                                                      false;
                                                                });
                                                              });
                                                            });
                                                          }
                                                        },
                                                        icon: const Icon(
                                                          Icons.delete_rounded,
                                                          size: 30,
                                                        )),
                                                  ),
                                                )
                                        ],
                                      ),
                                      Expanded(
                                        flex: 4,
                                        child: DataTable2(
                                          columnSpacing: 0.1,
                                          horizontalMargin: 10,
                                          headingRowColor:
                                              MaterialStateColor.resolveWith(
                                            (states) => TabColor()
                                                .tabColors[selectedColorIndex],
                                          ),
                                          fixedColumnsColor: Colors.transparent,
                                          dataRowColor:
                                              MaterialStateColor.resolveWith(
                                            (states) => Colors.transparent,
                                          ),
                                          dividerThickness: 0.2,
                                          border: TableBorder.all(),
                                          dataRowHeight: 40,
                                          headingRowHeight: 40,
                                          columns: const <DataColumn>[
                                            DataColumn2(
                                              size: ColumnSize.L,
                                              label: Center(
                                                child: Text(
                                                  'TYPE',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn2(
                                              size: ColumnSize.L,
                                              label: Center(
                                                child: Text(
                                                  'NUM',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn2(
                                              size: ColumnSize.L,
                                              label: Center(
                                                child: Text(
                                                  'QTY',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn2(
                                              size: ColumnSize.L,
                                              label: Center(
                                                child: Text(
                                                  'PRICE',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                            DataColumn2(
                                              size: ColumnSize.L,
                                              label: Center(
                                                child: Text(
                                                  'DELETE',
                                                  style: TextStyle(
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                          rows: buyticket
                                              .asMap()
                                              .entries
                                              .map((entry) {
                                                // final index = entry.key;
                                                final ticket = entry.value;
                                                final typeId = ticket['typeId'];
                                                final typeName =
                                                    ticket['typeName'];
                                                final typePrice =
                                                    ticket['price'];
                                                final betTypes =
                                                    ticket['betTypes'];
                                                final List<DataRow> rows = [];
                                                betTypes.forEach((key, value) {
                                                  if (value.isNotEmpty &&
                                                      typeId ==
                                                          selectedIndex + 1) {
                                                    // Exclude empty values
                                                    final numbers =
                                                        value.split(',');
                                                    numbers.forEach((number) {
                                                      final splitNumber =
                                                          number.split('-');
                                                      final extractedNumber =
                                                          splitNumber[0];
                                                      final qty =
                                                          splitNumber[1];
                                                      rows.add(
                                                        DataRow(cells: [
                                                          DataCell(Center(
                                                              child: Text(
                                                                  typeName))),
                                                          DataCell(Center(
                                                              child: Text(
                                                                  extractedNumber))),
                                                          DataCell(Center(
                                                              child: Text(qty
                                                                  .toString()
                                                                  .replaceAll(
                                                                      ",",
                                                                      "")))),
                                                          DataCell(Center(
                                                              child: Text(typePrice
                                                                  .toString()))),
                                                          DataCell(
                                                            Center(
                                                              child: IconButton(
                                                                onPressed: () {
                                                                  deleteValueInBetTypesByTypeId(
                                                                      buyticket,
                                                                      typeId,
                                                                      "$extractedNumber-$qty");
                                                                  buyticket.removeWhere((element) => element[
                                                                          "betTypes"]
                                                                      .values
                                                                      .every((value) => value
                                                                          .toString()
                                                                          .isEmpty));
                                                                  if (kDebugMode) {
                                                                    print(buyticket
                                                                        .toString());
                                                                  }
                                                                  ticketCounter();
                                                                },
                                                                icon: const Icon(
                                                                    Icons
                                                                        .delete),
                                                              ),
                                                            ),
                                                          ),
                                                        ]),
                                                      );
                                                    });
                                                  }
                                                });
                                                return rows;
                                              })
                                              .expand((element) => element)
                                              .toList(),
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                        topLeft: Radius.circular(10),
                                        topRight: Radius.circular(10)),
                                    color: Colors.grey.withOpacity(0.2),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Price Structure'),
                                        IconButton(
                                            onPressed: () {
                                              setState(() {
                                                if (!priceStructure) {
                                                  priceStructure = true;
                                                  scrollController.animateTo(
                                                    scrollController
                                                        .position.extentInside,
                                                    duration: const Duration(
                                                        milliseconds: 400),
                                                    curve: Curves.easeIn,
                                                  );
                                                } else {
                                                  priceStructure = false;
                                                  scrollController.animateTo(
                                                    scrollController
                                                        .position.extentAfter,
                                                    duration: const Duration(
                                                        milliseconds: 400),
                                                    curve: Curves.easeIn,
                                                  );
                                                }
                                              });
                                            },
                                            icon: priceStructure
                                                ? const Icon(
                                                    Icons.arrow_drop_up)
                                                : const Icon(
                                                    Icons.arrow_drop_down))
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              // AnimatedContainer to show/hide the second DataTable
                              AnimatedContainer(
                                duration: const Duration(milliseconds: 300),
                                child: priceStructure
                                    ? Padding(
                                        padding: const EdgeInsets.only(
                                            left: 4, right: 4),
                                        child: Column(
                                          children: [
                                            Container(
                                              height: 50,
                                              color: const Color.fromARGB(
                                                  255, 95, 187, 229),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 4),
                                                child: Row(
                                                  children: [
                                                    const Expanded(
                                                        flex: 3,
                                                        child:
                                                            Text("Game Name")),
                                                    const Expanded(
                                                        flex: 3,
                                                        child: Text(
                                                            "Play Points")),
                                                    Expanded(
                                                      flex: 4,
                                                      child: Container(
                                                        color: Colors
                                                            .transparent
                                                            .withOpacity(0.1),
                                                        child: Column(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceAround,
                                                          children: [
                                                            const Text(
                                                              "Win Points",
                                                              style: TextStyle(
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                            Row(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .spaceAround,
                                                              children: [
                                                                const Text(
                                                                    "Single"),
                                                                Container(
                                                                  height: 20,
                                                                  width: 2,
                                                                  color: Colors
                                                                      .white,
                                                                ),
                                                                const Text(
                                                                    "Double"),
                                                              ],
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ),
                                            SizedBox(
                                              height: 360,
                                              child: ListView.builder(
                                                itemCount: InitGameOthersProvider
                                                            .getInitGameOthers()[
                                                        'types']
                                                    .toList()
                                                    .length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(vertical: 2),
                                                    child: Container(
                                                      height: 30,
                                                      color: TabColor()
                                                          .tabColors[index]
                                                          .withOpacity(0.3),
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                              flex: 3,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            10),
                                                                child: Text(InitGameOthersProvider
                                                                            .getInitGameOthers()[
                                                                        'types'][index]
                                                                    [
                                                                    'typeName']),
                                                              )),
                                                          Expanded(
                                                              flex: 3,
                                                              child: Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        left:
                                                                            15),
                                                                child: Text(InitGameOthersProvider.getInitGameOthers()['types']
                                                                            [
                                                                            index]
                                                                        [
                                                                        'price']
                                                                    .toString()),
                                                              )),
                                                          const Expanded(
                                                              flex: 4,
                                                              child: Row(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .spaceAround,
                                                                children: [
                                                                  Text("90"),
                                                                  Text("900"),
                                                                ],
                                                              )),
                                                        ],
                                                      ),
                                                    ),
                                                  );
                                                },
                                              ),
                                            )
                                            // SizedBox(
                                            //   height: 360,
                                            //   child: DataTable2(
                                            //     dataRowHeight: 30,
                                            //     headingRowColor:
                                            //         MaterialStateColor
                                            //             .resolveWith(
                                            //       (states) =>
                                            //           TabColor().tabColors[
                                            //               selectedColorIndex],
                                            //     ),
                                            //     dataRowColor: MaterialStateColor
                                            //         .resolveWith(
                                            //       (states) => Colors.white,
                                            //     ),
                                            //     columns: const [
                                            //       DataColumn2(
                                            //         label: Text('Game Name'),
                                            //         size: ColumnSize.L,
                                            //       ),
                                            //       DataColumn2(
                                            //         label: Text('Price'),
                                            //         size: ColumnSize.S,
                                            //       ),
                                            //     ],
                                            //     rows: List<DataRow>.generate(
                                            //         InitGameOthersProvider
                                            //                     .getInitGameOthers()[
                                            //                 'types']
                                            //             .toList()
                                            //             .length, (index) {
                                            //       return DataRow(cells: [
                                            // DataCell(Text(
                                            //     InitGameOthersProvider
                                            //                 .getInitGameOthers()[
                                            //             'types'][index]
                                            //         ['typeName'])),
                                            // DataCell(Text(
                                            //     InitGameOthersProvider
                                            //                     .getInitGameOthers()[
                                            //                 'types']
                                            //             [index]['price']
                                            //         .toString()))
                                            //       ]);
                                            //     }),
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                              Container(
                                height: 70,
                              )
                            ],
                          ),
                        ),
                      )),
                ],
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: Container(
                height: 60,
                color: Colors.grey.shade200,
                child: Column(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const SizedBox(
                            width: 5,
                          ),
                          Expanded(flex: 5, child: Text("Ticket: ($totalQty)")),
                          Expanded(
                            flex: 1,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                const Icon(
                                  Icons.star,
                                  size: 15,
                                ),
                                Text(totalPoint.toString())
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 2,
                          ),
                        ],
                      ),
                    ),
                    const Divider(
                      color: Colors.black,
                      thickness: 0.2,
                      height: 0.1,
                    ),
                    Expanded(
                      flex: 2,
                      child: Center(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              flex: 1,
                              child: Row(
                                children: [
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  balance.when(data: (balance) {
                                    // return Text(" ${balance.toStringAsFixed(2)}");
                                    return Text(balance.toString());
                                  }, error: (e, s) {
                                    return const Text("-");
                                  }, loading: () {
                                    return const SizedBox(
                                      width: 50.0,
                                      child: LinearProgressIndicator(),
                                    );
                                  }),
                                  IconButton(
                                      onPressed: () =>
                                          ref.refresh(balanceProvider),
                                      icon: const Icon(
                                        Icons.refresh,
                                        size: 20,
                                      )),
                                ],
                              ),
                            ),
                            Expanded(
                                flex: 2,
                                child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Container(
                                    height: 50,
                                    color: kPrimarySeedColor,
                                    child: TextButton(
                                      child: const Text(
                                        "Quick Buy",
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ),
                                      onPressed: () async {
                                        setState(() {
                                          for (var ticket in buyticket) {
                                            Map<String, dynamic> betTypes =
                                                ticket['betTypes'];
                                            for (var key in betTypes.keys) {
                                              String value = betTypes[key];
                                              betTypes[key] = value.replaceAll(
                                                  RegExp('[AB]'), '');
                                            }
                                          }
                                          if (kDebugMode) {
                                            print(buyticket);
                                          }
                                        });
                                        bool networkStatus = await Helper
                                            .checkNetworkConnection();

                                        if (totalQty > 0) {
                                          if (networkStatus) {
                                            setState(() {
                                              showLoadingOverlay = true;
                                            });

                                            await ref
                                                .read(buyTicketOthersProvider(
                                                        BuyTicketOthersParams(
                                                            drawId:
                                                                initGameValue
                                                                    .drawId,
                                                            gameId: "2d",
                                                            types: buyticket))
                                                    .future)
                                                .then((value) {
                                              if (value.errorCode == 0) {
                                                if (mounted) {
                                                  setState(() {
                                                    showLoadingOverlay = false;
                                                  });
                                                }

                                                // ignore: unused_result
                                                ref.refresh(balanceProvider);

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        PurchasedTicket2DGame(
                                                      autoPrint: false,
                                                      gameValue: value
                                                          .tickets![0]
                                                          .types!, // Assuming types is a List<Type>
                                                      totalPoints: value
                                                          .tickets![0]
                                                          .ticketPrice!
                                                          .toDouble(),
                                                      totalQty: value
                                                          .tickets![0]
                                                          .ticketCount!,
                                                      ticketPrice: value
                                                          .tickets![0]
                                                          .ticketPrice!
                                                          .toDouble(),
                                                      gameName: value
                                                          .tickets![0]
                                                          .gameName!,
                                                      drawId: value
                                                          .tickets![0].drawId!,
                                                      barCode: value
                                                          .tickets![0].barCode!,
                                                      price: value
                                                          .tickets![0].price!
                                                          .toDouble(),
                                                      ticketCount: value
                                                          .tickets![0]
                                                          .ticketCount!,
                                                      drawStartTime: value
                                                          .tickets![0]
                                                          .drawStartTime!,
                                                      internalRefNo: value
                                                          .tickets![0]
                                                          .internalRefNo!,
                                                    ),
                                                  ),
                                                );

                                                //clear all value after navigate to ticket view page
                                                clearValue();
                                              } else {
                                                setState(() {
                                                  showLoadingOverlay = false;
                                                });

                                                showSnackBar(context,
                                                    "Please select ticket");
                                              }
                                            }).onError((error, stackTrace) {
                                              setState(() {
                                                showLoadingOverlay = false;
                                              });

                                              showSnackBar(
                                                  context, error.toString());

                                              ExceptionHandler.showSnack(
                                                  errorCode: error.toString(),
                                                  context: context);
                                            });
                                          } else {
                                            setState(() {
                                              showLoadingOverlay = false;
                                            });

                                            if (!mounted) return;
                                            showSnackBar(context,
                                                "Check your internet connection");
                                          }
                                        } else {
                                          // ignore: use_build_context_synchronously
                                          showSnackBar(context,
                                              "Please add a ticket to cart to buy");
                                        }
                                      },
                                    ),
                                  ),
                                )),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //23907
            if (initGameValue.setBloack)
              Center(child: CustomeBlocker(
                callbackClear: () {
                  clearValue();
                },
              )),
            if (showLoadingOverlay || initGameValue.setDrawBlocker)
              Center(child: MyOverlay(overlayFucntion: () {
                clearValue();
              })),
          ],
        ),
      );
    }, error: (Object error, e) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ExceptionHandler.showSnack(
            errorCode: error.toString(), context: context);
      });

      return const Center(
        child: Text("Something went wrong"),
      );
    }, loading: () {
      return Scaffold(
        appBar: AppBar(
          title: const Center(child: Text('2D Game')),
        ),
        body: const Center(
          child: MyOverlay(),
        ),
      );
    }));
  }

  //check outer select

  Row qtySelector(TextEditingController qtyController, int buttonIndex,
      FocusNode qtyFocusNode) {
    int quantity = int.parse(qtyController.text);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Expanded(flex: 1, child: Text("Qty")),
        Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    flex: 2,
                    child: Padding(
                      padding: const EdgeInsets.all(3.0),
                      child: SizedBox(
                        height: 30,
                        width: 60,
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          textAlignVertical: TextAlignVertical.center,
                          textAlign: TextAlign.center,
                          controller: qtyController,
                          focusNode: qtyFocusNode,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(3),
                          ],
                          onChanged: (value) {
                            int newValue = 1;
                            setState(() {
                              newValue = int.parse(value);
                              if (int.parse(value) > 100) {
                                quantity = 100;
                                qtyController.text = "100";
                                qtyController.selection =
                                    TextSelection.fromPosition(
                                  TextPosition(
                                      offset: qtyController.text.length),
                                );
                              } else if (newValue < 1) {
                                quantity = 1;
                                qtyController.text = "1";
                              } else {
                                quantity = int.parse(qtyController.text);
                              }
                            });
                          },
                          onEditingComplete: () {
                            if (qtyController.text.isEmpty) {
                              quantity = 1;
                              qtyController.text = "1";
                            }
                            qtyFocusNode.unfocus();
                          },
                          onTapOutside: (event) {
                            if (qtyController.text.isEmpty) {
                              quantity = 1;
                              qtyController.text = "1";
                            }
                            qtyFocusNode.unfocus();
                          },
                          onFieldSubmitted: (value) {
                            if (qtyController.text.isEmpty) {
                              quantity = 1;
                              qtyController.text = "1";
                            }
                            qtyFocusNode.unfocus();
                          },
                          decoration: const InputDecoration(
                            contentPadding: EdgeInsets.only(left: 5, bottom: 5),
                            border: OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(5))),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              // Add animation or other logic to increment the quantity
                              if (quantity < 100) {
                                quantity++;
                                qtyController.text = quantity.toString();
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                                height: 20,
                                width: 40,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      topRight: Radius.circular(5),
                                    ),
                                    color: Colors.green.shade300),
                                child: const Icon(
                                  Icons.add,
                                  size: 15,
                                )),
                          ),
                        ),
                        InkWell(
                          onTap: () {
                            setState(() {
                              if (quantity > 1) {
                                // Add animation or other logic to decrement the quantity
                                quantity--;
                                qtyController.text = quantity.toString();
                              }
                            });
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(1.0),
                            child: Container(
                                height: 20,
                                width: 40,
                                decoration: BoxDecoration(
                                    borderRadius: const BorderRadius.only(
                                      bottomRight: Radius.circular(5),
                                    ),
                                    color: Colors.red.shade300),
                                child: const Icon(
                                  Icons.remove,
                                  size: 15,
                                )),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )),
        const SizedBox(
          width: 5,
        ),
        Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(1.0),
              child: SizedBox(
                height: 40,
                child: TextButton(
                  style:
                      TextButton.styleFrom(backgroundColor: kPrimarySeedColor),
                  onPressed: () {
                    setState(() {
                      if (buttonIndex == 1) {
                        // Update buyticket based on buttonIndex 1 logic
                        //newly added random value for inc && dec qty value

                        if (randomController.text.isNotEmpty) {
                          randomSelector();
                          if (buyticket.isEmpty) {
                            buyticket.add({
                              "typeId": selectedIndex + 1,
                              "typeName":
                                  InitGameOthersProvider.getInitGameOthers()[
                                      'types'][selectedIndex]['typeName'],
                              "price":
                                  InitGameOthersProvider.getInitGameOthers()[
                                      'types'][selectedIndex]['price'],
                              "betTypes": {
                                "1": typeOne
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "")
                                    .replaceAll(RegExp(r'[\[\]\s]'),
                                        ""), //single - andar
                                "2": typeTwo
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "")
                                    .replaceAll(RegExp(r'[\[\]\s]'),
                                        ""), //single - bahar
                                "3": typeThree
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "")
                                    .replaceAll(
                                        RegExp(r'[\[\]\s]'), "") //double
                              }
                            });
                          } else {
                            for (int i = 0; i < buyticket.length; i++) {
                              if (buyticket[i]["typeId"] == selectedIndex + 1) {
                                buyticket[i]["betTypes"]['1'] = "";
                                buyticket[i]["betTypes"]['2'] = "";
                                buyticket[i]["betTypes"]['3'] = "";
                              }
                            }
                            bool found = false;
                            for (int type = 0;
                                type < buyticket.length;
                                type++) {
                              if (buyticket[type]['typeId'] ==
                                  selectedIndex + 1) {
                                buyticket[type]["betTypes"]["1"] = typeOne
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "")
                                    .trim()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "")
                                    .trim(); //single - andar
                                buyticket[type]["betTypes"]["2"] = typeTwo
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "")
                                    .trim()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "")
                                    .trim(); //single - bahar
                                buyticket[type]["betTypes"]["3"] = typeThree
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "")
                                    .trim()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "")
                                    .trim(); //double
                                found = true;
                                break;
                              }
                            }
                            if (!found) {
                              buyticket.add({
                                "typeId": selectedIndex + 1,
                                "typeName":
                                    InitGameOthersProvider.getInitGameOthers()[
                                        'types'][selectedIndex]['typeName'],
                                "price":
                                    InitGameOthersProvider.getInitGameOthers()[
                                        'types'][selectedIndex]['price'],
                                "betTypes": {
                                  "1": typeOne
                                      .toString()
                                      .replaceAll(RegExp(r'[\[\]\s]'), "")
                                      .replaceAll(RegExp(r'[\[\]\s]'),
                                          ""), //single - andar
                                  "2": typeTwo
                                      .toString()
                                      .replaceAll(RegExp(r'[\[\]\s]'), "")
                                      .replaceAll(RegExp(r'[\[\]\s]'),
                                          ""), //single - bahar
                                  "3": typeThree
                                      .toString()
                                      .replaceAll(RegExp(r'[\[\]\s]'), "")
                                      .replaceAll(
                                          RegExp(r'[\[\]\s]'), "") //double
                                }
                              });
                            }
                          }

                          log(buyticket.toString());
                        } else {
                          showSnackBar(context, "Please select Random");
                        }
                        ticketCounter();
                      } else if (buttonIndex == 2) {
                        bool found = false;
                        List<String> betTypes = [];
                        // Check if andharOne.text is empty
                        if (andharTwo.text.isNotEmpty) {
                          // Loop through buyticket list
                          for (int type = 0; type < buyticket.length; type++) {
                            // Check if the entry matches the desired typeId
                            if (buyticket[type]["typeId"] ==
                                selectedIndex + 1) {
                              // Get the current betTypes list
                              if (buyticket[type]["betTypes"]['1'] != null) {
                                betTypes = buyticket[type]["betTypes"]['1']
                                    .toString()
                                    .split(",")
                                    .map((value) => value.trim())
                                    .where((value) => value
                                        .isNotEmpty) // Remove any whitespace
                                    .toList();
                              }

                              // Loop through the betTypes list
                              for (int i = 0; i < betTypes.length; i++) {
                                // Extract the left side of the value
                                String leftSide = betTypes[i].split("-")[0];
                                if (leftSide == 'A${andharTwo.text}') {
                                  log("YES MATCH");
                                  int number =
                                      int.parse(betTypes[i].split("-")[1]);
                                  int addNumber = int.parse(qtyTwo.text);
                                  log("This is my index$i");
                                  int totalNumber = number + addNumber;
                                  betTypes[i] =
                                      "A${andharTwo.text}-${totalNumber > 100 ? 100 : totalNumber}"; // Update the value accordingly
                                  log(betTypes.toString());
                                  found = true;
                                  break;
                                }
                              }

                              if (!found) {
                                // If the left side is not found, add the new value
                                String newValue =
                                    'A${andharTwo.text}-${qtyTwo.text}'; // Create the new value
                                if (!betTypes.contains(newValue)) {
                                  betTypes.add(newValue);

                                  log(betTypes.toString());
                                  log("NOT MATCH");
                                }
                              }

                              // Update the buyticket with the updated betTypes list
                              buyticket[type]["betTypes"]['1'] = betTypes
                                  .toString()
                                  .replaceAll(RegExp(r'[\[\]\s]'), "");

                              // Set found to true to indicate successful processing
                              found = true;
                              break; // Exit the loop once the update is done
                            }
                          }

                          // If the left side is not found in any entry, you may need to decide what to do next
                          if (!found) {
                            buyticket.add({
                              "typeId": selectedIndex + 1,
                              "typeName":
                                  InitGameOthersProvider.getInitGameOthers()[
                                      'types'][selectedIndex]['typeName'],
                              "price":
                                  InitGameOthersProvider.getInitGameOthers()[
                                      'types'][selectedIndex]['price'],
                              "betTypes": {
                                "1":
                                    "A${andharTwo.text}-${qtyTwo.text}", //single - andar
                              }
                            });
                            log("NOT COMMING INSIDE");
                          }

                          if (kDebugMode) {
                            print(buyticket);
                          }
                        } else {
                          showSnackBar(context, "Please select Andhar");
                        }

                        ticketCounter();
                      } else if (buttonIndex == 3) {
                        bool found = false;
                        List<String> betTypes = [];
                        // Check if andharOne.text is empty
                        if (bharOne.text.isNotEmpty) {
                          // Loop through buyticket list
                          for (int type = 0; type < buyticket.length; type++) {
                            // Check if the entry matches the desired typeId
                            if (buyticket[type]["typeId"] ==
                                selectedIndex + 1) {
                              // Get the current betTypes list
                              if (buyticket[type]["betTypes"]['2'] != null) {
                                betTypes = buyticket[type]["betTypes"]['2']
                                    .toString()
                                    .split(",")
                                    .map((value) => value.trim())
                                    .where((value) => value
                                        .isNotEmpty) // Remove any whitespace
                                    .toList();
                              }

                              // Loop through the betTypes list
                              for (int i = 0; i < betTypes.length; i++) {
                                // Extract the left side of the value
                                String leftSide = betTypes[i].split("-")[0];

                                if (leftSide == 'B${bharOne.text}') {
                                  log("YES MATCH");
                                  int number =
                                      int.parse(betTypes[i].split("-")[1]);
                                  int addNumber = int.parse(qtyThree.text);
                                  int totalNumber = number + addNumber;
                                  betTypes[i] =
                                      "B${bharOne.text}-${totalNumber > 100 ? 100 : totalNumber}"; // Update the value accordingly
                                  log(betTypes.toString());
                                  found = true;
                                  break;
                                }
                              }

                              if (!found) {
                                // If the left side is not found, add the new value
                                String newValue =
                                    'B${bharOne.text}-${qtyThree.text}'; // Create the new value
                                if (!betTypes.contains(newValue)) {
                                  betTypes.add(newValue);

                                  log(betTypes.toString());
                                  log("NOT MATCH");
                                }
                              }

                              // Update the buyticket with the updated betTypes list
                              buyticket[type]["betTypes"]['2'] = betTypes
                                  .toString()
                                  .replaceAll(RegExp(r'[\[\]\s]'), "");

                              // Set found to true to indicate successful processing
                              found = true;
                              break; // Exit the loop once the update is done
                            }
                          }

                          // If the left side is not found in any entry, you may need to decide what to do next
                          if (!found) {
                            buyticket.add({
                              "typeId": selectedIndex + 1,
                              "typeName":
                                  InitGameOthersProvider.getInitGameOthers()[
                                      'types'][selectedIndex]['typeName'],
                              "price":
                                  InitGameOthersProvider.getInitGameOthers()[
                                      'types'][selectedIndex]['price'],
                              "betTypes": {
                                "2":
                                    "B${bharOne.text}-${qtyThree.text}", //single - andar
                              }
                            });
                            log("NOT COMMING INSIDE");
                          }

                          if (kDebugMode) {
                            print(buyticket);
                          }
                        } else {
                          showSnackBar(context, "Please select Bahar");
                        }

                        if (kDebugMode) {
                          print(buyticket);
                        }

                        ticketCounter();
                      } else {
                        //# number one and number two field check
                        //# if number one and number two are not empty, get the two field values
                        if (numberOne.text.isNotEmpty &&
                            numberTwo.text.isNotEmpty) {
                          String combination =
                              "${numberOne.text}${numberTwo.text}";
                          bool typeIdExists =
                              false; // Flag to check if typeId already exists in buyticket

                          for (int i = 0; i < buyticket.length; i++) {
                            if (buyticket[i]["typeId"] == selectedIndex + 1) {
                              typeIdExists = true; // Set the flag to true
                              break; // Exit the loop once you've found a matching "typeId"
                            }
                          }
                          if (typeIdExists) {
                            bool found =
                                false; // Variable to track if the combination is found in the list.
                            List<String> betTypes = [];
                            // Loop through buyticket list
                            for (int type = 0;
                                type < buyticket.length;
                                type++) {
                              if (buyticket[type]["betTypes"]
                                      .containsKey("3") &&
                                  buyticket[type]["typeId"] ==
                                      selectedIndex + 1) {
                                if (kDebugMode) {
                                  print(
                                      "Inside condition : ${buyticket[type]["typeId"]}");
                                }
                                // Get the current betTypes list
                                betTypes = buyticket[type]["betTypes"]['3']
                                    .toString()
                                    .split(",")
                                    .map((value) => value.trim())
                                    .where((value) => value
                                        .isNotEmpty) // Remove any whitespace
                                    .toList();
                                // Loop through the betTypes list
                                for (int i = 0; i < betTypes.length; i++) {
                                  // Extract the left side of the value
                                  String leftSide = betTypes[i].split("-")[0];
                                  // Check if the left side matches a certain value (e.g., 'B7')
                                  if (leftSide == combination) {
                                    log("YES MATCH");
                                    int number =
                                        int.parse(betTypes[i].split("-")[1]);
                                    log("This is my index$i");

                                    int addNumber = int.parse(qtyFour.text);
                                    int totalNumber = number + addNumber;
                                    betTypes[i] =
                                        "$combination-${totalNumber > 100 ? 100 : totalNumber}"; // Update the value accordingly
                                    log(betTypes.toString());
                                    found = true;
                                    break;
                                  }
                                }
                              }

                              if (!found) {
                                // If the left side is not found, add the new value
                                String newValue =
                                    '$combination-${qtyFour.text}'; // Create the new value
                                if (!betTypes.contains(newValue)) {
                                  betTypes.add(newValue);
                                  log(betTypes.toString());
                                  log("NOT MATCH");
                                }
                              }

                              // Update the buyticket with the updated betTypes list
                              if (buyticket[type]["typeId"] ==
                                  selectedIndex + 1) {
                                buyticket[type]["betTypes"]['3'] = betTypes
                                    .toString()
                                    .replaceAll(RegExp(r'[\[\]\s]'), "");
                                // Set found to true to indicate successful processing
                                found = true;
                                // break;
                              }
                            }
                          } else {
                            buyticket.add({
                              "typeId": selectedIndex + 1,
                              "typeName":
                                  InitGameOthersProvider.getInitGameOthers()[
                                      'types'][selectedIndex]['typeName'],
                              "price":
                                  InitGameOthersProvider.getInitGameOthers()[
                                      'types'][selectedIndex]['price'],
                              "betTypes": {"3": "$combination-${qtyFour.text}"},
                            });
                          }
                        } else {
                          if (numberOne.text.isNotEmpty ||
                              numberTwo.text.isNotEmpty) {
                            // At least one of the fields is empty

                            if (numberOne.text.isNotEmpty) {
                              // Generate series for number one
                              List<String> firstSeries = [];

                              // Loop through randomList and add matching values to firstSeries
                              for (int i = 0; i < randomList.length; i++) {
                                if (!randomList[i].toString().contains("A") &&
                                    !randomList[i].toString().contains("B") &&
                                    randomList[i]
                                        .toString()[0]
                                        .toString()
                                        .contains(numberOne.text)) {
                                  firstSeries
                                      .add("${randomList[i]}-${qtyFour.text}");
                                }
                              }

                              if (kDebugMode) {
                                print(firstSeries.toString());
                              }
                              firstSeries.sort();
                              secondSeries.sort();

                              // Add/update the ticket number for number one series

                              // check already have or not
                              bool typeIdExists =
                                  false; // Flag to check if typeId already exists in buyticket

                              for (int i = 0; i < buyticket.length; i++) {
                                if (buyticket[i]["typeId"] ==
                                    selectedIndex + 1) {
                                  typeIdExists = true; // Set the flag to true
                                  break; // Exit the loop once you've found a matching "typeId"
                                }
                              }

                              if (typeIdExists) {
                                // If typeId exists, update the "betTypes" for the specific item

                                for (int i = 0; i < buyticket.length; i++) {
                                  if (buyticket[i]["typeId"] ==
                                      selectedIndex + 1) {
                                    buyticket[i]["betTypes"]["1"] = "";
                                    buyticket[i]["betTypes"]["2"] = "";
                                    buyticket[i]["betTypes"]["3"] = firstSeries
                                        .toString()
                                        .replaceAll(RegExp(r'[\[\]\s]'), "")
                                        .replaceAll(RegExp(r'[\[\]\s]'), "");
                                    break; // Exit the loop after updating
                                  }
                                }
                              } else {
                                // If typeId doesn't exist, add a new item to buyticket
                                buyticket.add({
                                  "typeId": selectedIndex + 1,
                                  "typeName": InitGameOthersProvider
                                          .getInitGameOthers()['types']
                                      [selectedIndex]['typeName'],
                                  "price": InitGameOthersProvider
                                          .getInitGameOthers()['types']
                                      [selectedIndex]['price'],
                                  "betTypes": {
                                    "3": firstSeries
                                        .toString()
                                        .replaceAll(RegExp(r'[\[\]\s]'), "")
                                        .replaceAll(RegExp(r'[\[\]\s]'), ""),
                                  },
                                });
                              }
                            } else if (numberTwo.text.isNotEmpty) {
                              // Generate series for number two
                              List<String> secondSeries = [];

                              // Loop through randomList and add matching values to secondSeries
                              for (int i = 0; i < randomList.length; i++) {
                                if (!randomList[i].toString().contains("A") &&
                                    !randomList[i].toString().contains("B") &&
                                    randomList[i]
                                        .toString()[1]
                                        .toString()
                                        .contains(numberTwo.text)) {
                                  secondSeries
                                      .add("${randomList[i]}-${qtyFour.text}");
                                }
                              }

                              if (kDebugMode) {
                                print(numberTwo.toString());
                              }
                              firstSeries.sort();
                              secondSeries.sort();

                              bool typeIdExists =
                                  false; // Flag to check if typeId already exists in buyticket

                              for (int i = 0; i < buyticket.length; i++) {
                                if (buyticket[i]["typeId"] ==
                                    selectedIndex + 1) {
                                  typeIdExists = true; // Set the flag to true
                                  break; // Exit the loop once you've found a matching "typeId"
                                }
                              }

                              if (typeIdExists) {
                                // If typeId exists, update the "betTypes" for the specific item
                                for (int i = 0; i < buyticket.length; i++) {
                                  if (buyticket[i]["typeId"] ==
                                      selectedIndex + 1) {
                                    buyticket[i]["betTypes"]["1"] = "";
                                    buyticket[i]["betTypes"]["2"] = "";
                                    buyticket[i]["betTypes"]["3"] = secondSeries
                                        .toString()
                                        .replaceAll(RegExp(r'[\[\]\s]'), "")
                                        .replaceAll(RegExp(r'[\[\]\s]'), "");
                                    break; // Exit the loop after updating
                                  }
                                }
                              } else {
                                // If typeId doesn't exist, add a new item to buyticket
                                buyticket.add({
                                  "typeId": selectedIndex + 1,
                                  "typeName": InitGameOthersProvider
                                          .getInitGameOthers()['types']
                                      [selectedIndex]['typeName'],
                                  "price": InitGameOthersProvider
                                          .getInitGameOthers()['types']
                                      [selectedIndex]['price'],
                                  "betTypes": {
                                    "3": secondSeries
                                        .toString()
                                        .replaceAll(RegExp(r'[\[\]\s]'), "")
                                        .replaceAll(RegExp(r'[\[\]\s]'), ""),
                                  },
                                });
                              }
                            }
                          } else {
                            showSnackBar(context, "Please select Double");
                          }
                        }

                        ticketCounter();
                      }
                    });
                  },
                  child: const Text(
                    "Add",
                    style: TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ),
            ))
      ],
    );
  }

  void randomSelector() {
    setState(() {
      typeOne.clear();
      typeTwo.clear();
      typeThree.clear();
      numberInputList.clear();
      // Iterate through the 'buyticket' list
      if (selectedRandomValue == "Odd") {
        for (var i = 0; i < randomList.length; i++) {
          if (int.parse(randomList[i][1]).isOdd) {
            if (randomList[i].startsWith("A")) {
              typeOne.add("${randomList[i]}-${qtyOne.text}");
            } else if (randomList[i].startsWith("B")) {
              typeTwo.add("${randomList[i]}-${qtyOne.text}");
            } else {
              typeThree.add("${randomList[i]}-${qtyOne.text}");
            }
          }
        }
        sortRandomList();
      } else if (selectedRandomValue == "Even") {
        for (var i = 0; i < randomList.length; i++) {
          if (int.parse(randomList[i][1]).isEven) {
            if (randomList[i].startsWith("A")) {
              typeOne.add("${randomList[i]}-${qtyOne.text}");
            } else if (randomList[i].startsWith("B")) {
              typeTwo.add("${randomList[i]}-${qtyOne.text}");
            } else {
              typeThree.add("${randomList[i]}-${qtyOne.text}");
            }
          }
        }
        sortRandomList();
      } else if (selectedRandomValue == "Jodi") {
        // Jodi logic goes here
        for (var i = 0; i < randomList.length; i++) {
          if (randomList[i][0] == randomList[i][1]) {
            typeThree.add("${randomList[i]}-${qtyOne.text}");
          }
        }
        sortRandomList();
      } else {
        String value = selectedRandomValue.replaceAll(RegExp('[^0-9]'), '');
        randomList.shuffle();
        int count = int.parse(value);
        if (kDebugMode) {
          print(count);
          print("Working");
        }

        typeFiltter(randomList.sublist(0, count));
      }
    });
  }

  void sortRandomList() {
    typeOne.sort();
    typeTwo.sort();
    typeThree.sort();
  }

  void ticketCounter() {
    num totalTicket = 0;
    num totalPoints = 0; // Add this variable to store the total points.

    Map<int, num> typeIdTotalCounts = {};
    for (int i = 0; i < buyticket.length; i++) {
      Map<String, dynamic> ticket = buyticket[i];
      int typeId = ticket['typeId'];
      Map betTypesMap = ticket['betTypes'];

      num totalCount = 0;
      num totalPointsForTicket = 0;

      betTypesMap.forEach((key, value) {
        if (value.trim().isNotEmpty) {
          List<String> bets = value.split(",");
          totalCount += bets.length;

          // Calculate the  ticket's total points.
          for (String bet in bets) {
            List<String> parts = bet.split("-");
            if (parts.length == 2) {
              num points = int.tryParse(parts[1]) ?? 0;
              totalPointsForTicket += points;
            }
          }
        }
      });

      typeIdTotalCounts[typeId] = totalCount;
      totalTicket += totalPointsForTicket;
      totalPoints +=
          totalPointsForTicket * 10; // Accumulate total points for all tickets.
    }

    setState(() {
      totalQty = totalTicket;
      totalPoint = totalPoints; // Assign the total points to the variable.
    });
  }

  void typeFiltter(List selectedNumbers) {
    typeOne.clear();
    typeTwo.clear();
    typeThree.clear();
    setState(() {
      for (int i = 0; i < selectedNumbers.length; i++) {
        if (selectedNumbers[i].startsWith("A")) {
          typeOne.add("${selectedNumbers[i]}-${qtyOne.text}");
        } else if (selectedNumbers[i].startsWith("B")) {
          typeTwo.add("${selectedNumbers[i]}-${qtyOne.text}");
        } else {
          typeThree.add("${selectedNumbers[i]}-${qtyOne.text}");
        }
      }
      if (kDebugMode) {
        print(typeOne);
      }
      if (kDebugMode) {
        print(typeTwo);
      }
      if (kDebugMode) {
        print(typeThree);
      }
    });
  }

  void clearValue() {
    setState(() {
      buyticket.clear();
      totalCount = 0;
      totalPoint = 0;
      totalQty = 0;
    });
  }

  void clearInput() {
    setState(() {
      randomController.clear();
      andharOne.clear();
      andharTwo.clear();
      bharOne.clear();
      bharTwo.clear();
      numberOne.clear();
      numberTwo.clear();
    });
  }

  void deleteValueInBetTypesByTypeId(
      List<Map<String, dynamic>> ticketList, int typeId, String valueToDelete) {
    for (var ticket in ticketList) {
      if (ticket['typeId'] == typeId) {
        ticket['betTypes'].forEach((key, value) {
          List<String> values = value.split(',');
          values.removeWhere((val) => val == valueToDelete);
          ticket['betTypes'][key] = values.join(',');
        });
      }
      //betType value is empty delete the particular map value
    }
  }
}
