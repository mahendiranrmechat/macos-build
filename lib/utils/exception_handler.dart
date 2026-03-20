import 'package:flutter/material.dart';
import 'package:psglotto/view/utils/success_layout.dart';

import '../view/widgets/session_dialog.dart';
import '../view/widgets/snackbar.dart';

class ExceptionHandler {
  static showSnack({required String errorCode, required BuildContext context}) {
    switch (errorCode) {
      case "Exception":
        return sessionDialog(context);
      case "Exception: 1":
        return showSnackBar(context, "General Error");
      case "Exception: 2":
        return showSnackBar(context, "Game not found");
      case "Exception: 3":
        return showSnackBar(context, "Old password is wrong");
      case "Exception: 4":
        return showSnackBar(context, "Bet closed");
      case "Exception: 5":
        return showSnackBar(context, "Ticket not accepted");
      case "Exception: 6":
        return showSnackBar(context, "Ticket not found");
      case "Exception: 7":
        return showSnackBar(context, "Insufficient fund");
      case "Exception: 8":
        return showSnackBar(context, "Transaction not found");
      case "Exception: 9":
        return showSnackBar(context, "Draw result under in progress");
      case "Exception: 10":
        return showSnackBar(context, "Already claimed");
      case "Exception: 11":
        return showSnackBar(context, "Tickets not available for this range");
      case "Exception: 12":
        return showSnackBar(context, "Old password doesn't match our records");
      case "Exception: 13":
        return showSnackBar(context, "Draw is not started");
      case "Exception: 14":
        return showSnackBar(context, "Draw is already completed");
      case "Exception: 15":
        return showSnackBar(context,
            "No bets allowed for this draw due to bet time not started");
      case 'Exception: 16':
        return showSnackBar(
            context, "No bets allowed for this draw due to bet time is over");
      case 'Exception: 17':
        return showSnackBar(context, "Invalid ticket no");
      case 'Exception: 18':
        return showSnackBar(context, "Draw is not completed");
      case 'Exception: 19':
        return showSnackBar(context, "Better luck next time");
      case 'Exception: 20':
        return showSnackBar(
            context, "Claim not allowed due to bet cancelled already");
      case 'Exception: 21':
        return showSnackBar(context, "No Result found");
      case 'Exception: 25':
        return cancelTicket(context, "Limit Reached!", "Max 3 tickets per day");
    }
    return;
  }
}
