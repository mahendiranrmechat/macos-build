import 'package:flutter/material.dart';
import 'package:psglotto/view/utils/constants.dart';

class LottoCard2D extends StatefulWidget {
  final String formattedDate;
  final int drawCount;

  const LottoCard2D(
      {required this.drawCount, required this.formattedDate, Key? key})
      : super(key: key);

  @override
  State<LottoCard2D> createState() => _LottoCard2DState();
}

class _LottoCard2DState extends State<LottoCard2D> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        image: const DecorationImage(
          image: AssetImage("assets/images/lottocard_bg_2d.png"),
          fit: BoxFit.cover,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
              color: kPrimarySeedColor!,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(8),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  widget.formattedDate,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  "DRAWS ${widget.drawCount}TIMES DAILY",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.all(kDefaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '',
                  style: TextStyle(
                    fontSize: 20.0,
                    color: Colors.white,
                  ),
                ),
                Text(
                  '',
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
