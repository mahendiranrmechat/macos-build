import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/utils/exception_handler.dart';
import 'package:psglotto/view/utils/constants.dart';
import 'package:psglotto/view/utils/helper.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/view/utils/success_layout.dart';
import 'package:psglotto/view/widgets/snackbar.dart';
import 'package:series_2d/data/params/claim_with_barcode_params.dart';
import 'package:series_2d/data/provider/providers.dart' hide balanceProvider;

class ClaimView extends ConsumerStatefulWidget {
  const ClaimView({Key? key}) : super(key: key);

  @override
  ConsumerState<ClaimView> createState() => _ClaimViewState();
}

class _ClaimViewState extends ConsumerState<ClaimView> {
  final TextEditingController barcodeController = TextEditingController();
  final FocusNode barcodeFocusNode = FocusNode();
  bool isClaiming = false;

  final primary = const Color(0xff1C7D4A);

  // For detecting rapid scanner input
  DateTime? _lastInputTime;
  final Duration _scannerThreshold =
      const Duration(milliseconds: 50); // adjust if needed

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      barcodeFocusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    barcodeController.dispose();
    barcodeFocusNode.dispose();
    super.dispose();
  }

  /// 🔹 Auto Claim Function
  Future<void> claimWithBarcode(BuildContext context) async {
    if (isClaiming) return;

    FocusScope.of(context).unfocus();
    final code = barcodeController.text.trim();

    if (code.isEmpty) {
      showSnackBar(context, "Please enter a valid Barcode");
      return;
    }

    bool networkStatus = await Helper.checkNetworkConnection();
    if (!networkStatus) {
      showSnackBar(context, "Check your internet connection");
      return;
    }

    setState(() => isClaiming = true);

    await ref
        .read(
      claimWithBarcodeProvider(ClaimWithBarcodeParams(barcode: code)).future,
    )
        .then((value) {
      if (value.errorCode == 0) {
        barcodeController.clear();
        barcodeFocusNode.requestFocus();
        ref.refresh(balanceProvider);

        showSuccess(
          context,
          "Claim Successful 🎉",
          "You won ${value.totalWinPrice!.toInt()} Points!",
          "Updated Balance: ${value.balance!.floor()}",
          normalPoints: "Normal Win: ${value.winPrice!.toInt()}",
          jackpotPoints: "Jackpot Win: ${value.jackpotPrice!.toInt()}",
          showText: value.jackpotPrice != 0,
        );
      } else {
        showFailed(
          context,
          "Claim Failed ❌",
          "Your claim was not successful.",
          "Error Code: ${value.errorCode}",
        );
      }
    }).onError((error, stackTrace) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        ExceptionHandler.showSnack(
          errorCode: error.toString(),
          context: context,
        );
      });
    });

    setState(() => isClaiming = false);
  }

  /// Detect if input came from a barcode scanner
  void handleInput(String value) {
    final now = DateTime.now();

    if (_lastInputTime != null &&
        now.difference(_lastInputTime!) < _scannerThreshold) {
      // Rapid input detected → treat as scanner
      claimWithBarcode(context);
    }

    _lastInputTime = now;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //  backgroundColor: primary.withOpacity(0.08),
      appBar: AppBar(
        centerTitle: true,
        title: const Text("Barcode Claim"),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 400),
            width: MediaQuery.of(context).size.width * 0.48,
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: Colors.white.withOpacity(0.6),
              boxShadow: [
                BoxShadow(
                  blurRadius: 20,
                  color: Colors.black.withOpacity(0.1),
                )
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Claim Your Winning Ticket",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),

                    /// 🔹 TEXTFIELD
                    TextField(
                      focusNode: barcodeFocusNode,
                      controller: barcodeController,
                      autofocus: true,
                      textCapitalization: TextCapitalization.characters,
                      inputFormatters: [
                        FilteringTextInputFormatter.allow(
                            RegExp(r'[a-zA-Z0-9]')),
                      ],
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.9),
                        labelText: "Enter Barcode",
                        hintText: "Example: A1B22C33D44",
                        prefixIcon: Icon(Icons.qr_code, color: primary),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: primary, width: 2),
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onSubmitted: (_) => claimWithBarcode(
                          context), // ✅ Auto trigger when scanner sends Enter
                    ),

                    const SizedBox(height: 22),

                    /// BUTTON
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 300),
                      width: 150,
                      child: ElevatedButton(
                        onPressed:
                            isClaiming ? null : () => claimWithBarcode(context),
                        style: ElevatedButton.styleFrom(
                          elevation: 6,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: isClaiming
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.4,
                                  color: Colors.white,
                                ),
                              )
                            : const Text(
                                "Claim Now",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
