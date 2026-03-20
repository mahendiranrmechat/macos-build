import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/view/widgets/snackbar.dart';

import '../../../provider/providers.dart';

class TicketChipWidget extends StatelessWidget {
  final String ticketNo;
  final bool? fromCart;

  const TicketChipWidget({
    Key? key,
    required this.ticketNo,
    this.fromCart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer(builder: (context, ref, _) {
      return FittedBox(
        child: Container(
          height: 40,
          padding: const EdgeInsets.only(left: 6.0),
          margin: const EdgeInsets.symmetric(horizontal: 6.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(
              4.0,
            ),
            color:
                checkIfAvailable(ticketNo) ? Colors.grey[200] : Colors.red[100],
          ),
          alignment: Alignment.center,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: () {
                  if (checkIfAvailable(ticketNo) && fromCart == null) {
                    ref
                        .read(cartTicketProvider.notifier)
                        .addCartTicket({ticketNo.substring(0, 6)});
                    ref
                        .read(customizeTicketProvider.notifier)
                        .removeCustomizedTicket(ticketNo);
                  } else if (!checkIfAvailable(ticketNo)) {
                    showSnackBar(context, "Ticket is already sold");
                  }
                },
                child: Text(
                  ticketNo.substring(0, 6),
                  style: TextStyle(
                    fontSize: 25.0,
                    color:
                        checkIfAvailable(ticketNo) ? Colors.black : Colors.red,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  if (fromCart != null) {
                    ref
                        .read(cartTicketProvider.notifier)
                        .removeCartTicket(ticketNo.toString());
                  } else {
                    ref
                        .read(customizeTicketProvider.notifier)
                        .removeCustomizedTicket(ticketNo.toString());
                  }
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6.0,
                  ),
                  height: 25.0,
                  decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: const BorderRadius.horizontal(
                          right: Radius.circular(4.0))),
                  child: const Icon(
                    Icons.remove,
                    color: Colors.red,
                    size: 10.0,
                  ),
                ),
              )
            ],
          ),
        ),
      );
    });
  }
}

bool checkIfAvailable(String ticketNo) {
  // if (val.endsWith("-1")) {
  //   filteredList.add(
  //       val.substring(0, 6));
  // }

  if (ticketNo.endsWith("-0")) {
    return false;
  } else {
    return true;
  }
}
