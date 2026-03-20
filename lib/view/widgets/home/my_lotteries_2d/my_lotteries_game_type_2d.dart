import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/provider/providers.dart';
import 'package:psglotto/utils/game_constant.dart';
import '../../../utils/constants.dart';

class MyLotteriesGameTypeWidget2D extends ConsumerStatefulWidget {
  final String gameId;
  final String gameName;

  const MyLotteriesGameTypeWidget2D({
    required this.gameName,
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  ConsumerState<MyLotteriesGameTypeWidget2D> createState() =>
      _MyLotteriesGameTypeWidget2DState();
}

class _MyLotteriesGameTypeWidget2DState
    extends ConsumerState<MyLotteriesGameTypeWidget2D> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    String filter = ref.watch(filterMyLotteriesProvider);
    return InkWell(
      onTap: () {
        setState(() {
          if (filter == widget.gameId) {
            ref.read(filterMyLotteriesProvider.notifier).clear();
            GameConstant.selectedGameId = "";
          } else {
            ref
                .read(filterMyLotteriesProvider.notifier)
                .setResultFilter(widget.gameId);
            GameConstant.selectedGameId = widget.gameId;
          }
        });
      },
      child: FittedBox(
        child: Container(
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
          decoration: BoxDecoration(
            color: filter == widget.gameId
                ? kPrimarySeedColor!
                : Colors.grey.withOpacity(0.40),
            borderRadius: BorderRadius.circular(4.0),
          ),
          height: 20,
          alignment: Alignment.center,
          child: Text(
            widget.gameName,
            style: TextStyle(
              fontSize: 12.0,
              color: filter == widget.gameId ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
