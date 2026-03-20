import 'package:flutter/material.dart';

class PurchasedTicketChip extends StatefulWidget {
  final String ticket;
  const PurchasedTicketChip({Key? key, required this.ticket}) : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _PurchasedTicketChipState createState() => _PurchasedTicketChipState();
}

class _PurchasedTicketChipState extends State<PurchasedTicketChip> {
  bool isAvailable() {
    if (widget.ticket.substring(6, 8) == "-1") {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: isAvailable() ? Colors.green : Colors.red,
        borderRadius: BorderRadius.circular(4.0),
      ),
      height: 20,
      width: 70,
      alignment: Alignment.center,
      child: Text(
        widget.ticket.substring(0, 6),
        style: TextStyle(
          fontSize: 12.0,
          color: isAvailable() ? Colors.white : Colors.white,
        ),
      ),
    );
  }
}
