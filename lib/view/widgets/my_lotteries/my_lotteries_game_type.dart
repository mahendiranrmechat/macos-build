import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/provider/providers.dart';

import '../../utils/constants.dart';

class MyLotteriesGameTypeWidget extends ConsumerStatefulWidget {
  final String gameId;
  final String gameName;

  const MyLotteriesGameTypeWidget({
    required this.gameName,
    Key? key,
    required this.gameId,
  }) : super(key: key);

  @override
  ConsumerState<MyLotteriesGameTypeWidget> createState() =>
      _MyLotteriesGameTypeWidgetState();
}

class _MyLotteriesGameTypeWidgetState
    extends ConsumerState<MyLotteriesGameTypeWidget> {
  bool isSelected = false;

  @override
  Widget build(BuildContext context) {
    String filter = ref.watch(filterMyLotteriesProvider);
    return InkWell(
      onTap: () {
        if (filter == widget.gameId) {
          ref.read(filterMyLotteriesProvider.notifier).clear();
        } else {
          ref
              .read(filterMyLotteriesProvider.notifier)
              .setResultFilter(widget.gameId);
        }
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
