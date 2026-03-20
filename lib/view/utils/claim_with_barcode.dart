import 'package:barcode_widget/barcode_widget.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/file_for_claimwith_barcode/claim_with_params.dart';
import 'package:psglotto/params/claim_params.dart';
import 'package:psglotto/params/claim_params_2d.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/view/widgets/snackbar.dart';
import '../../../../params/user_results_params.dart';
import '../../../../model/user_result_2d.dart';
import '../../model/user_results.dart' as u;

class ClaimWithBarcode extends ConsumerStatefulWidget {
  final int categoryId;
  final String gameName;
  const ClaimWithBarcode(
      {required this.categoryId, required this.gameName, Key? key})
      : super(key: key);

  @override
  ConsumerState<ClaimWithBarcode> createState() => _ClaimWithBarcodeState();
}

class _ClaimWithBarcodeState extends ConsumerState<ClaimWithBarcode> {
  TextEditingController barcodeController = TextEditingController();
  List<u.Results> results = [];
  List<Result> results_2d = [];
  int pageNo = 1;
  var items = [1];
  bool isLoading = false;
  bool isLoadingClaimButton = false;
  bool isShowLottieAnimation = false;
  bool isShowSuccessMsgText = false;
  String claimMsg = "";
  bool screenSizeChanger = false;
  int? unClaimedTicket;
  num? unClaimedPrice;

  DateTime now =
      DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
  late DateTime startDate = now;
  DateTime endDate = DateTime(DateTime.now().year, DateTime.now().month,
      DateTime.now().day, 23, 59, 59);

  @override
  Widget build(BuildContext context) {
    screenSizeChanger = MediaQuery.of(context).size.width < 1400 ? true : false;
    return isLoading
        ? const SizedBox(width: 100, child: LinearProgressIndicator())
        : Focus(
            autofocus: true,
            child: Container(
              height: 40.0,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter,
                  stops: [
                    0.0,
                    0.3,
                    0.8
                  ], // Adjust stops for a smooth transition
                  colors: [
                    Colors.yellow,
                    Colors.orange,
                    Colors.yellow,
                  ],
                ),
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: () {
                  if (widget.categoryId == 1) {
                    searchResult();
                  } else {
                    searchResult2d();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  textStyle: const TextStyle(fontSize: 18, color: Colors.black),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.shopping_cart,
                      color: Colors.black,
                      size: 24,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Claim',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
  }

  void showCustomDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: StatefulBuilder(
            builder: (BuildContext context, StateSetter setState) {
              return Stack(
                children: [
                  Center(
                    child: Container(
                      width: screenSizeChanger
                          ? MediaQuery.of(context).size.width * 0.8
                          : MediaQuery.of(context).size.width * 0.5,
                      height: screenSizeChanger
                          ? MediaQuery.of(context).size.height * 0.8
                          : MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        border: Border.all(
                          color: kPrimarySeedColor!, // Golden border color
                          width: 2.0, // Border width
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber
                                .withOpacity(0.9), // Golden shadow color
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // Changes the position of the shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Unclaimed Tickets :$unClaimedTicket ",
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      Text("Unclaimed Price : $unClaimedPrice",
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold))
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 16),
                                SizedBox(
                                  width: 200,
                                  child: TextFormField(
                                    controller: barcodeController,
                                    onChanged: (text) {
                                      setState(
                                          () {}); // This will trigger a rebuild when the text changes
                                    },
                                    decoration: InputDecoration(
                                      filled: true,
                                      fillColor: Colors.grey.withOpacity(0.12),
                                      border: OutlineInputBorder(
                                        borderSide: BorderSide(
                                            color: kPrimarySeedColor!),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      ),
                                      prefixIcon: const Icon(
                                        Icons.barcode_reader,
                                        size: 26.0,
                                      ),
                                      hintText: "Enter Barcode",
                                      hintStyle: const TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    inputFormatters: [
                                      // Allow only alphanumeric characters
                                      FilteringTextInputFormatter.allow(
                                          RegExp(r'^[a-zA-Z0-9]+')),
                                      // Limit the length to 15 characters
                                      LengthLimitingTextInputFormatter(15),
                                    ],
                                    autofocus: true,
                                    textInputAction: TextInputAction.next,
                                  ),
                                ),
                                const SizedBox(width: 16),
                                isLoading
                                    ? const SizedBox(
                                        width: 100,
                                        child: LinearProgressIndicator())
                                    : ElevatedButton(
                                        onPressed: barcodeController
                                                .text.isNotEmpty
                                            ? () {
                                                setState(() {
                                                  isLoading = true;
                                                });
                                                claimWithBarcode(
                                                    barcodeController.text,
                                                    context, () {
                                                  setState(() {
                                                    isLoading = false;
                                                    isShowSuccessMsgText = true;
                                                    isShowLottieAnimation =
                                                        true;
                                                    Future.delayed(
                                                        const Duration(
                                                            seconds: 2),
                                                        () => setState(() {
                                                              isShowLottieAnimation =
                                                                  false;
                                                              isShowSuccessMsgText =
                                                                  false;
                                                            }));
                                                  });
                                                });
                                              }
                                            : null,
                                        child: const Text("Claim"),
                                      ),
                                const SizedBox(width: 16),
                                items.length < 2
                                    ? const SizedBox.shrink()
                                    : DropdownButton(
                                        value: pageNo,
                                        items: items.map((int items) {
                                          return DropdownMenuItem(
                                            value: items,
                                            child: Text(items.toString()),
                                          );
                                        }).toList(),
                                        onChanged: (int? newValue) {
                                          setState(() {
                                            isLoading = true;
                                            pageNo = newValue!;
                                          });

                                          claimWithBarcodeCallFunction2d(
                                              context, () {
                                            setState(() {
                                              isLoading = false;
                                            });
                                          }, true);
                                        },
                                      ),
                              ],
                            ),
                          ),
                          isShowSuccessMsgText
                              ? Center(
                                  child: Text(
                                    claimMsg,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.bold),
                                  ),
                                )
                              : const SizedBox.shrink(),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Center(
                                child: isLoading
                                    ? const CircularProgressIndicator()
                                    : DataTable2(
                                        headingRowColor:
                                            MaterialStateProperty.all(
                                                kPrimarySeedColor!
                                                    .withOpacity(0.9)),
                                        dividerThickness: 0.1,
                                        columnSpacing: 1,
                                        horizontalMargin: 10,
                                        dataRowHeight: 80,
                                        columns: const [
                                          DataColumn(
                                              label: Center(
                                                  child: Text(
                                            'Barcode',
                                            style:
                                                TextStyle(color: Colors.white),
                                          ))),
                                          DataColumn(
                                              label: Center(
                                                  child: Text('Play price',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white)))),
                                          DataColumn(
                                              label: Center(
                                                  child: Text('Win price',
                                                      style: TextStyle(
                                                          color:
                                                              Colors.white)))),
                                          DataColumn(
                                            label: Center(
                                                child: Text('Claim',
                                                    style: TextStyle(
                                                        color: Colors.white))),
                                          ),
                                        ],
                                        rows: List<DataRow>.generate(
                                          widget.categoryId == 2
                                              ? results_2d.length
                                              : results.length,
                                          (index) => DataRow(cells: [
                                            widget.categoryId == 1
                                                ? DataCell(
                                                    Center(
                                                      child: BarcodeWidget(
                                                        data: results[index]
                                                                .barCode ??
                                                            "",
                                                        barcode:
                                                            Barcode.code128(),
                                                        width: 150,
                                                        height: 50,
                                                      ),
                                                    ),
                                                  )
                                                : DataCell(Center(
                                                    child: BarcodeWidget(
                                                      data: results_2d[index]
                                                              .barCode ??
                                                          "",
                                                      barcode:
                                                          Barcode.code128(),
                                                      width: 150,
                                                      height: 50,
                                                    ),
                                                  )),
                                            widget.categoryId == 1
                                                ? DataCell(
                                                    Center(
                                                      child: Text(results[index]
                                                          .ticketPrice
                                                          .toString()),
                                                    ),
                                                  )
                                                : DataCell(
                                                    Center(
                                                      child: Text(
                                                          results_2d[index]
                                                              .ticketPrice
                                                              .toString()),
                                                    ),
                                                  ),
                                            widget.categoryId == 1
                                                ? DataCell(
                                                    Center(
                                                      child: Text(results[index]
                                                          .winPrice
                                                          .toString()),
                                                    ),
                                                  )
                                                : DataCell(
                                                    Center(
                                                      child: Text(
                                                          results_2d[index]
                                                              .winPrice
                                                              .toString()),
                                                    ),
                                                  ),
                                            DataCell(Center(
                                              child: ElevatedButton(
                                                onPressed:
                                                    widget.categoryId == 1
                                                        ? results[index]
                                                                    .claim ==
                                                                0
                                                            ? () async {
                                                                bool
                                                                    networkStatus =
                                                                    await Helper
                                                                        .checkNetworkConnection();
                                                                if (networkStatus) {
                                                                  setState(() {
                                                                    isLoading =
                                                                        true;
                                                                    results[index]
                                                                        .claim = 1;
                                                                  });

                                                                  await ref
                                                                      .read(claimProvider(
                                                                          ClaimParams(
                                                                    gameId: results[
                                                                            index]
                                                                        .gameId!,
                                                                    categoryId:
                                                                        widget
                                                                            .categoryId,
                                                                    drawId: results[
                                                                            index]
                                                                        .drawId!,
                                                                    ticketId: results[
                                                                            index]
                                                                        .ticketId!,
                                                                    fromDate:
                                                                        (startDate
                                                                            .millisecondsSinceEpoch),
                                                                    toDate: (endDate
                                                                        .millisecondsSinceEpoch),
                                                                  )).future)
                                                                      .then(
                                                                          (value) {
                                                                    if (value
                                                                            .errorCode ==
                                                                        0) {
                                                                      if (mounted) {
                                                                        setState(
                                                                            () {
                                                                          claimMsg =
                                                                              handleErrorCode(value.errorCode!);
                                                                          isLoading =
                                                                              false;
                                                                        });
                                                                      }

                                                                      ref.refresh(
                                                                          balanceProvider);
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        claimMsg =
                                                                            handleErrorCode(value.errorCode!);
                                                                      });
                                                                    }
                                                                  }).onError((error,
                                                                          stackTrace) {
                                                                    setState(
                                                                        () {
                                                                      claimMsg = handleErrorCode(int.parse(error
                                                                          .toString()
                                                                          .split(
                                                                              ":")
                                                                          .last));
                                                                      isLoading =
                                                                          false;
                                                                    });

                                                                    ExceptionHandler.showSnack(
                                                                        errorCode:
                                                                            error
                                                                                .toString(),
                                                                        context:
                                                                            context);
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    isLoading =
                                                                        false;
                                                                  });

                                                                  if (!mounted) {
                                                                    return;
                                                                  }
                                                                  showSnackBar(
                                                                      context,
                                                                      "Check your internet connection");
                                                                }
                                                              }
                                                            : null
                                                        : results_2d[index]
                                                                    .claim ==
                                                                0
                                                            ? () async {
                                                                bool
                                                                    networkStatus =
                                                                    await Helper
                                                                        .checkNetworkConnection();
                                                                if (networkStatus) {
                                                                  disableClaimButtom(
                                                                      setState,
                                                                      index);

                                                                  await ref
                                                                      .read(claimProvider2d(
                                                                          ClaimParams2D(
                                                                    gameId: results_2d[
                                                                            index]
                                                                        .gameId!,
                                                                    categoryId:
                                                                        2,
                                                                    drawId: results_2d[
                                                                            index]
                                                                        .drawId!,
                                                                    ticketId: results_2d[
                                                                            index]
                                                                        .ticketId!,
                                                                    fromDate:
                                                                        (startDate
                                                                            .millisecondsSinceEpoch),
                                                                    toDate: (endDate
                                                                        .millisecondsSinceEpoch),
                                                                  )).future)
                                                                      .then(
                                                                          (value) {
                                                                    if (value
                                                                            .errorCode ==
                                                                        0) {
                                                                      if (mounted) {
                                                                        setState(
                                                                            () {
                                                                          unClaimedTicket =
                                                                              value.unClaimedTickets ?? 0;
                                                                          unClaimedPrice =
                                                                              value.unClaimedPrice ?? 0;
                                                                          isShowSuccessMsgText =
                                                                              true;
                                                                          claimMsg =
                                                                              handleErrorCode(value.errorCode!);
                                                                          isLoading =
                                                                              false;
                                                                          Future.delayed(
                                                                              const Duration(seconds: 2),
                                                                              () => isShowSuccessMsgText = false);
                                                                        });
                                                                      }

                                                                      ref.refresh(
                                                                          balanceProvider);
                                                                    } else {
                                                                      setState(
                                                                          () {
                                                                        claimMsg =
                                                                            handleErrorCode(value.errorCode!);
                                                                      });
                                                                    }
                                                                  }).onError((error,
                                                                          stackTrace) {
                                                                    setState(
                                                                        () {
                                                                      claimMsg = handleErrorCode(int.parse(error
                                                                          .toString()
                                                                          .split(
                                                                              ":")
                                                                          .last));
                                                                      isLoading =
                                                                          false;
                                                                    });

                                                                    ExceptionHandler.showSnack(
                                                                        errorCode:
                                                                            error
                                                                                .toString(),
                                                                        context:
                                                                            context);
                                                                  });
                                                                } else {
                                                                  setState(() {
                                                                    isLoading =
                                                                        false;
                                                                  });

                                                                  if (!mounted) {
                                                                    return;
                                                                  }
                                                                  showSnackBar(
                                                                      context,
                                                                      "Check your internet connection");
                                                                }
                                                              }
                                                            : null,
                                                child: const Text("Claim"),
                                              ),
                                            )),
                                          ]),
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: screenSizeChanger
                            ? MediaQuery.of(context).size.width * 0.8
                            : MediaQuery.of(context).size.width * 0.5,
                        height: screenSizeChanger
                            ? MediaQuery.of(context).size.height * 0.8
                            : MediaQuery.of(context).size.height * 0.6,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                pageNo = 1;
                              });
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        );
      },
    );
  }

  void searchResult() async {
    bool networkStatus = await Helper.checkNetworkConnection();
    if (networkStatus) {
      results = [];

      if (ref.watch(filterMyLotteriesProvider).isNotEmpty) {
        UserResultsParams userResultSearchParams = UserResultsParams(
          claimStatus: 2,
          categoryId: 1,
          gameId: widget.gameName,
          fromDate: (startDate.millisecondsSinceEpoch),
          toDate: (endDate.millisecondsSinceEpoch),
          resultType: 3,
          page: pageNo - 1,
        );

        setState(() {
          items = [];
          isLoading = true;
        });

        await ref
            .watch(wonProvider(userResultSearchParams).future)
            .then((value) {
          if (!mounted) {
            return;
          }

          setState(() {
            if (value.totalPages != 0) {
              items = List<int>.generate(value.totalPages!, (i) => i + 1);
            }

            results = value.results!;
            isLoading = false;
          });

          showCustomDialog();
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
        showSnackBar(context, "Please select a game type before searching");
      }
    } else {
      if (!mounted) return;
      showSnackBar(context, "Check your internet connection");
    }
  }

  void searchResult2d() async {
    bool networkStatus = await Helper.checkNetworkConnection();
    if (networkStatus) {
      results = [];
      UserResultsParams userResultSearchParams = UserResultsParams(
        claimStatus: 2,
        categoryId: 2,
        gameId: widget.gameName,
        fromDate: (startDate.millisecondsSinceEpoch),
        toDate: (endDate.millisecondsSinceEpoch),
        resultType: 3,
        page: pageNo - 1,
      );
      setState(() {
        items = [];
        isLoading = true;
      });
      await ref
          .watch(wonProvider2d(userResultSearchParams).future)
          .then((value) {
        if (!mounted) {
          return;
        }
        setState(() {
          if (value.totalPages != 0) {
            items = List<int>.generate(value.totalPages!, (i) => i + 1);

            isLoading = false;
            results_2d = value.results!;
          }
          unClaimedTicket = value.unClaimedTickets ?? 0;
          unClaimedPrice = value.unClaimedPrice ?? 0;

          showCustomDialog();
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
      showSnackBar(context, "Please select a game type before searching");
    }
  }

  Future<void> claimWithBarcode(
      String barcode, BuildContext context, Function callback) async {
    ClaimWithBarCodeParams claimWithBarCodeParams = ClaimWithBarCodeParams(
      barCode: barcode,
      fromDate: (startDate.millisecondsSinceEpoch),
      toDate: (endDate.millisecondsSinceEpoch),
    );

    try {
      await ref
          .watch(claimWithBarCode(claimWithBarCodeParams).future)
          .then((value) {
        if (value.errorCode == 0) {
          setState(() {
            unClaimedPrice = value.unClaimedPrice;
            unClaimedTicket = value.unClaimedTickets;
            claimMsg = handleErrorCode(value.errorCode!);
          });
          if (widget.categoryId == 1) {
            claimWithBarcodeCallFunction(context, () {
              callback();
            });
          } else {
            claimWithBarcodeCallFunction2d(context, () {
              callback();
            }, false);
          }
          setState(() {
            isLoading = false;
          });
        } else {
          callback();
          setState(() {
            claimMsg = handleErrorCode(value.errorCode!);
          });
          //handlie error
          ExceptionHandler.showSnack(
              errorCode: value.errorCode.toString(), context: context);
          callback();
        }
      });
    } catch (error) {
      //handlie error
      setState(() {
        print("This is a claimwithbarcode destailes: $error");
        isLoading = false;
        claimMsg = handleErrorCode(int.parse(error.toString().split(":").last));
      });

      callback();
    }
  }

  void claimWithBarcodeCallFunction(BuildContext context, Function callback) {
    UserResultsParams userResultSearchParams = UserResultsParams(
      claimStatus: 1,
      categoryId: widget.categoryId,
      gameId: widget.gameName,
      fromDate: (startDate.millisecondsSinceEpoch),
      toDate: (endDate.millisecondsSinceEpoch),
      resultType: 3,
      page: pageNo - 1,
    );

    ref
        .refresh(wonProvider(userResultSearchParams).future)
        .then((value) => setState(() {
              results = value.results!;
            }))
        .onError((error, stackTrace) {
      ExceptionHandler.showSnack(errorCode: error.toString(), context: context);
    });
  }

  void claimWithBarcodeCallFunction2d(
      BuildContext context, Function callback, bool? resetResultValue) {
    UserResultsParams userResultSearchParams = UserResultsParams(
      claimStatus: 2,
      categoryId: widget.categoryId,
      gameId: widget.gameName,
      fromDate: (startDate.millisecondsSinceEpoch),
      toDate: (endDate.millisecondsSinceEpoch),
      resultType: 3,
      page: pageNo - 1,
    );

    ref.refresh(wonProvider2d(userResultSearchParams).future).then((value) {
      if (value.errorCode == 0) {
        if (value.totalPages != 0) {
          items = List<int>.generate(value.totalPages!, (i) => i + 1);
        }
        if (mounted) {
          setState(() {
            claimMsg = handleErrorCode(value.errorCode!);
            isLoading = false;
            if (resetResultValue!) {
              results_2d = value.results!;
            }

            int index = results_2d.indexWhere(
              (element) {
                bool isMatch = element.barCode == barcodeController.text;
                return isMatch;
              },
            );

            results_2d[index].claim = 1;
            barcodeController.clear();
          });
        }

        callback();
      } else {
        //handlie error

        setState(() {
          claimMsg = handleErrorCode(value.errorCode!);
        });
        ExceptionHandler.showSnack(
            errorCode: value.errorCode.toString(), context: context);
        callback();
      }
    }).onError((error, stackTrace) {
      callback();

      claimMsg = handleErrorCode(int.parse(error.toString().split(":").last));
      setState(() {
        isLoading = false;
      });
      ExceptionHandler.showSnack(
        errorCode: error.toString(),
        context: context,
      );
    });
  }

  String handleErrorCode(int errorCode) {
    switch (errorCode) {
      case 0:
        return "Successfully claimed";
      case 6:
        return "Ticket not found";
      case 10:
        return "Already claimed";
      default:
        return "Something went wrong"; // Default case if the errorCode does not match any handled cases
    }
  }

  void disableClaimButtom(StateSetter setState, int index) {
    return setState(() {
      isLoading = true;
      results_2d[index].claim = 1;
    });
  }
}
