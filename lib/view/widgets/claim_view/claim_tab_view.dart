import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/model/game.dart' as g;
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/view/utils/success_layout.dart';
import 'package:psglotto/view/widgets/my_lotteries/my_lotteries_game_type.dart';
import 'package:psglotto/view/widgets/snackbar.dart';
import 'package:series_2d/data/params/claim_with_barcode_params.dart';
import 'package:series_2d/data/provider/providers.dart' hide balanceProvider;

class BarcodeClaimTabView extends ConsumerStatefulWidget {
  final int categoryId;
  final VoidCallback? balanceRefresh;

  const BarcodeClaimTabView({
    Key? key,
    required this.categoryId,
    this.balanceRefresh,
  }) : super(key: key);

  @override
  ConsumerState<BarcodeClaimTabView> createState() =>
      _BarcodeClaimTabViewState();
}

class _BarcodeClaimTabViewState extends ConsumerState<BarcodeClaimTabView>
    with SingleTickerProviderStateMixin {
  late TabController _controller;
  bool isClaimWithBarcode = false;
  final TextEditingController claimWithBarcodeController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _controller.dispose();
    claimWithBarcodeController.dispose();
    super.dispose();
  }

  //! Claim with Barcode
  Future<void> claimWithBarcode(BuildContext context) async {
    setState(() {
      isClaimWithBarcode = true;
    });

    bool networkStatus = await Helper.checkNetworkConnection();
    if (!networkStatus) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Check your internet connection")),
      );
      setState(() => isClaimWithBarcode = false);
      return;
    }

    if (claimWithBarcodeController.text.isEmpty) {
      showSnackBar(context, "Please enter a valid Barcode");
      setState(() => isClaimWithBarcode = false);
      return;
    }

    await ref
        .read(claimWithBarcodeProvider(ClaimWithBarcodeParams(
                barcode: claimWithBarcodeController.text))
            .future)
        .then((value) {
      if (value.errorCode == 0) {
        claimWithBarcodeController.clear();
        ref.refresh(balanceProvider);
        if (!mounted) return;
        showSuccess(
          context,
          "Claim Success!",
          "Congratulations! You've won ${value.totalWinPrice!.toInt()} Points",
          "Your Updated Current Balance: ${value.balance!.floor()}",
          normalPoints: "Normal Win Points: ${value.winPrice!.toInt()}",
          jackpotPoints: "Jackpot Win Points: ${value.jackpotPrice!.toInt()}",
          showText: value.jackpotPrice != 0,
        );
      } else {
        showFailed(
          context,
          "Claim Failed",
          "We're sorry, your claim was unsuccessful.",
          "Reason: ${value.errorCode}",
        );
      }
    }).onError((error, stackTrace) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ExceptionHandler.showSnack(
            errorCode: error.toString(), context: context);
      });
    });

    setState(() {
      isClaimWithBarcode = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<List<g.GameList>> gameAsyncData =
        ref.watch(gameProvider(widget.categoryId));

    return DefaultTabController(
      length: 3,
      child: Column(
        children: [
          Expanded(
            child: TabBarView(
              controller: _controller,
              physics: const BouncingScrollPhysics(),
              children: [
                _buildClaimContent(gameAsyncData),
                _buildClaimContent(gameAsyncData),
                _buildClaimContent(gameAsyncData),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClaimContent(AsyncValue<List<g.GameList>> gameAsyncData) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type Selection
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 6,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Type",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                gameAsyncData.when(
                  data: (data) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (data.isNotEmpty &&
                          ref.read(filterMyLotteriesProvider).isEmpty) {
                        ref
                            .read(filterMyLotteriesProvider.notifier)
                            .setResultFilter(data.first.gameId ?? "-");
                      }
                    });

                    return Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: data
                          .map((e) => MyLotteriesGameTypeWidget(
                                gameName: e.gameName ?? "-",
                                gameId: e.gameId ?? "-",
                              ))
                          .toList(),
                    );
                  },
                  error: (error, s) {
                    ExceptionHandler.showSnack(
                        errorCode: error.toString(), context: context);
                    return const Text("Something went wrong");
                  },
                  loading: () => const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // Barcode Claim Input + Button
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.5,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                children: [
                  TextField(
                    controller: claimWithBarcodeController,
                    inputFormatters: [
                      widget.categoryId == 1
                          ? FilteringTextInputFormatter.allow(
                              RegExp(r'[a-zA-Z0-9]')) // alphanumeric
                          : FilteringTextInputFormatter
                              .digitsOnly, // numeric only
                    ],
                    decoration: const InputDecoration(
                      labelText: "Enter Barcode",
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: isClaimWithBarcode
                          ? null
                          : () => claimWithBarcode(context),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        textStyle: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: isClaimWithBarcode
                          ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                          : const Text("Claim"),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
