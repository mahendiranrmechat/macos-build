import 'package:flutter/material.dart';
import 'package:psglotto/view/utils/constants.dart';

class CommonChip extends StatelessWidget {
  final String ticketNo;
  final bool? highlight;
  const CommonChip({Key? key, required this.ticketNo, this.highlight})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: highlight != null
            ? kPrimarySeedColor!
            : Colors.grey.withOpacity(0.40),
        borderRadius: BorderRadius.circular(4.0),
      ),
      height: 20,
      width: 70,
      alignment: Alignment.center,
      child: Text(
        ticketNo,
        style: TextStyle(
          fontSize: 12.0,
          color: (highlight != null) ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}
