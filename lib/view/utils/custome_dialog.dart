import 'package:flutter/material.dart';

Container customeDialog(BuildContext context) {
  return Container(
    width: 500,
    height: 100,
    decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
            topLeft: Radius.circular(10),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(10),
            bottomLeft: Radius.circular(20)),
        color: Color.fromARGB(215, 255, 82, 82)),
    child: const Column(children: [
      Center(
        child: Text(
          "Error",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      Text(
        "Must fill Ticket Qty",
        style: TextStyle(
          fontSize: 20,
        ),
      ),
    ]),
  );
}
