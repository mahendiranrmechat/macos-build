import 'package:flutter/material.dart';

import '../../utils/constants.dart';

class AddTicketChipWidget extends StatelessWidget {
  const AddTicketChipWidget({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      width: 105,
      padding: const EdgeInsets.symmetric(horizontal: 4.0),
      margin: const EdgeInsets.symmetric(horizontal: 4.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(
          4.0,
        ),
        border: Border.all(color: kPrimarySeedColor!),
        color: Colors.grey[200],
      ),
      alignment: Alignment.center,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_circle,
            color: kPrimarySeedColor!,
            size: 12.0,
          ),
          const SizedBox(
            width: 4.0,
          ),
          const Text(
            "Add one",
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}
