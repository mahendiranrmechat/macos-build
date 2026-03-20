import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/model/game.dart' as g;
import 'package:psglotto/model/lotto_results.dart';
import 'package:psglotto/params/draw_result_params.dart';
import 'package:psglotto/provider/lotto_clock_provider.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/widgets/loading_overlay.dart';
import 'package:psglotto/view/widgets/result/draw_result_view.dart';
import 'package:intl/intl.dart';

import '../../../params/result_search_params.dart';
import '../../utils/helper.dart';
import '../snackbar.dart';
import 'result_game_type.dart';

class LottoTabView extends ConsumerStatefulWidget {
  final int categoryId;
  const LottoTabView({required this.categoryId, Key? key}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _LottoTabViewState createState() => _LottoTabViewState();
}

class _LottoTabViewState extends ConsumerState<LottoTabView> {
  late DateTime _startDate;
  late DateTime _endDate;

  String searchedStartDate = "";
  String searchedEndDate = "";

  List<Results> results = [];
  bool isLoading = false;
  bool showLoadingOverlay = false;

  @override
  void initState() {
    initializeDates();
    super.initState();
  }

  void initializeDates() {
    // Convert lottoCurrentTimeServer to DateTime
    DateTime lottoDateTime =
        DateTime.fromMillisecondsSinceEpoch(lottoCurrentTimeServer);

    // Initialize _startDate and _endDate
    _startDate =
        DateTime(lottoDateTime.year, lottoDateTime.month, lottoDateTime.day);
    _endDate = DateTime(
        lottoDateTime.year, lottoDateTime.month, lottoDateTime.day, 23, 59, 59);
    // Clear the filter on initialization
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   ref.read(filterMyLotteriesProvider.notifier).clear();
    // });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue lobbyAsyncData = ref.watch(lobbyProvider);
    AsyncValue<List<g.GameList>> gameAsyncData =
        ref.watch(gameProvider(widget.categoryId));

    return Scaffold(
      body: Stack(
        children: [
          Container(
              child: lobbyAsyncData.when(data: <Lobby>(lobbyData) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(8.0),
                  decoration: const BoxDecoration(color: Colors.white),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Type",
                        style: TextStyle(
                            fontSize: 16.0, fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(
                        height: 10.0,
                      ),
                      gameAsyncData.when(data: (data) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          Future.microtask(() {
                            if (data.isNotEmpty &&
                                ref.read(filterResultProvider).isEmpty) {
                              ref
                                  .read(filterResultProvider.notifier)
                                  .setResultFilter(data.first.gameId!);
                            }
                          });
                        });

                        return Wrap(
                          children: [
                            ...data.map(
                              (e) => ResultGameTypeWidget(
                                id: e.gameId ?? "",
                                name: e.gameName.toString(),
                              ),
                            ),
                          ],
                        );
                      }, error: (error, s) {
                        ExceptionHandler.showSnack(
                            errorCode: error.toString(), context: context);
                        return Text("Something went wrong");
                      }, loading: () {
                        return const CircularProgressIndicator();
                      }),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                GestureDetector(
                  onTap: () async {
                    final lottoDateTime = DateTime.fromMillisecondsSinceEpoch(
                        lottoCurrentTimeServer);
                    final adjustedLottoDateTime =
                        lottoDateTime.subtract(const Duration(days: 29));
                    final picked = await showDateRangePicker(
                        context: context,
                        lastDate: lottoDateTime,
                        firstDate: adjustedLottoDateTime,
                        currentDate: lottoDateTime);
                    if (picked != null) {
                      setState(() {
                        _startDate = picked.start;
                        _endDate = DateTime(picked.end.year, picked.end.month,
                            picked.end.day, 23, 59, 59);
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Draw date",
                          style: TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        Row(
                          children: [
                            const Text("From"),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: kScaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                  DateFormat('dd-MM-yyyy').format(_startDate)),
                            ),
                            const SizedBox(
                              width: 10.0,
                            ),
                            const Text("-"),
                            const SizedBox(
                              width: 10.0,
                            ),
                            Container(
                              padding: const EdgeInsets.all(4.0),
                              decoration: BoxDecoration(
                                color: kScaffoldBackgroundColor,
                                borderRadius: BorderRadius.circular(4.0),
                              ),
                              child: Text(
                                  DateFormat('dd-MM-yyyy').format(_endDate)),
                            ),
                          ],
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        ElevatedButton(
                          onPressed: () async {
                            bool networkStatus =
                                await Helper.checkNetworkConnection();
                            if (networkStatus) {
                              results = [];
                              if (ref.watch(filterResultProvider).isNotEmpty) {
                                ResultSearchParams resultSearchParams =
                                    ResultSearchParams(
                                  categoryId: widget.categoryId,
                                  gameId: ref.watch(filterResultProvider),
                                  fromDate: (_startDate.millisecondsSinceEpoch),
                                  toDate: (_endDate.millisecondsSinceEpoch),
                                );
                                setState(() {
                                  isLoading = true;
                                });
                                await ref
                                    .watch(resultProvider(resultSearchParams)
                                        .future)
                                    .then((value) {
                                  if (!mounted) {
                                    return;
                                  }
                                  setState(() {
                                    if (kDebugMode) {
                                      print(
                                          "Checking result current date : ${_startDate.millisecondsSinceEpoch} ${ref.watch(filterResultProvider)}");
                                    }
                                    results = value;
                                    isLoading = false;
                                    searchedStartDate = DateFormat('dd-MM-yyyy')
                                        .format(_startDate);
                                    searchedEndDate = DateFormat('dd-MM-yyyy')
                                        .format(_endDate);
                                    if (value.isEmpty) {
                                      showSnackBar(context, "No Results Found");
                                    }
                                  });
                                }).onError((error, stackTrace) {
                                  if (!mounted) {
                                    return;
                                  }
                                  ExceptionHandler.showSnack(
                                      errorCode: error.toString(),
                                      context: context);

                                  setState(() {
                                    isLoading = false;
                                  });
                                });
                              } else {
                                if (!mounted) return;

                                // ignore: use_build_context_synchronously
                                showSnackBar(context,
                                    "Please select a game type before searching");
                              }
                            } else {
                              if (!mounted) return;
                              showSnackBar(
                                  // ignore: use_build_context_synchronously
                                  context,
                                  "Check your internet connection");
                            }
                          },
                          child: const Text("Search"),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10.0,
                ),
                Expanded(
                  flex: 6,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(8.0),
                    decoration: const BoxDecoration(color: Colors.white),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Result for [$searchedStartDate - $searchedEndDate]",
                          style: const TextStyle(
                              fontSize: 16.0, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(
                          height: 10.0,
                        ),
                        results.isNotEmpty
                            ? Expanded(
                                // height: 500,
                                // color: Colors.transparent,
                                // width: MediaQuery.of(context).size.width,
                                child: DataTable2(
                                  dividerThickness: 0.1,
                                  columnSpacing: 1,
                                  horizontalMargin: 1,
                                  minWidth:
                                      MediaQuery.of(context).size.width * 0.90,
                                  columns: const [
                                    DataColumn2(
                                        size: ColumnSize.L,
                                        label:
                                            Center(child: Text("Game Name"))),
                                    DataColumn2(
                                        size: ColumnSize.L,
                                        label: Center(child: Text("Draw ID"))),
                                    DataColumn2(
                                        size: ColumnSize.L,
                                        label:
                                            Center(child: Text("Draw Time"))),
                                    DataColumn2(
                                        size: ColumnSize.L,
                                        label:
                                            Center(child: Text("View Result"))),
                                  ],
                                  rows: List<DataRow>.generate(
                                      results.length,
                                      (index) => DataRow(cells: [
                                            DataCell(Center(
                                                child: Text(
                                                    results[index].gameName!))),
                                            DataCell(Center(
                                              child: Text(results[index]
                                                      .drawPlayGroupId ??
                                                  "-"),
                                            )),
                                            DataCell(Center(
                                              child: Text(results[index]
                                                  .drawStartTime!),
                                            )),
                                            DataCell(
                                              Center(
                                                child: ElevatedButton(
                                                    onPressed: () async {
                                                      bool networkStatus =
                                                          await Helper
                                                              .checkNetworkConnection();

                                                      if (networkStatus) {
                                                        setState(() {
                                                          showLoadingOverlay =
                                                              true;
                                                        });
                                                        await ref
                                                            .read(
                                                          drawResultProvider(
                                                            DrawResultParams(
                                                              categoryId: 1,
                                                              gameId:
                                                                  results[index]
                                                                      .gameId!,
                                                              drawId:
                                                                  results[index]
                                                                      .drawId!,
                                                            ),
                                                          ).future,
                                                        )
                                                            .then((value) {
                                                          setState(() {
                                                            showLoadingOverlay =
                                                                false;
                                                          });

                                                          if (value.results !=
                                                              null) {
                                                            return Navigator
                                                                .push(
                                                              context,
                                                              MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        DrawResultView(
                                                                  drawTime: results[
                                                                          index]
                                                                      .drawStartTime!
                                                                      .toString(),
                                                                  gameName: results[
                                                                          index]
                                                                      .gameName!,
                                                                  drawId: results[
                                                                          index]
                                                                      .drawPlayGroupId!,
                                                                  results: value
                                                                      .results!,
                                                                ),
                                                              ),
                                                            );
                                                          }
                                                        }).onError((error,
                                                                stackTrace) {
                                                          if (!mounted) {
                                                            return;
                                                          }
                                                          ExceptionHandler
                                                              .showSnack(
                                                                  errorCode: error
                                                                      .toString(),
                                                                  context:
                                                                      context);
                                                          return null;
                                                        });
                                                      } else {
                                                        // ignore: use_build_context_synchronously
                                                        showSnackBar(context,
                                                            "Check your internet connection");
                                                      }
                                                    },
                                                    child: const Text("View")),
                                              ),
                                            ),
                                          ])),
                                ),
                              )
                            : isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(),
                                  )
                                : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }, error: (Object error, StackTrace? stackTrace) {
            return null;
          }, loading: () {
            return null;
          })),
          if (showLoadingOverlay) const MyOverlay(),
        ],
      ),
    );
  }
}
