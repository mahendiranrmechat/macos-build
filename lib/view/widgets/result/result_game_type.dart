import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:psglotto/provider/providers.dart';

import '../../utils/constants.dart';

class ResultGameTypeWidget extends ConsumerStatefulWidget {
  final String id;
  final String name;

  const ResultGameTypeWidget({
    Key? key,
    required this.id,
    required this.name,
  }) : super(key: key);

  @override
  ConsumerState<ResultGameTypeWidget> createState() => _CustomChipWidgetState();
}

class _CustomChipWidgetState extends ConsumerState<ResultGameTypeWidget> {
  bool isSelected = false;
  @override
  Widget build(BuildContext context) {
    String filter = ref.watch(filterResultProvider);
    return InkWell(
      onTap: () {
        if (filter == widget.id) {
          ref.read(filterResultProvider.notifier).clear();
        } else {
          ref.read(filterResultProvider.notifier).setResultFilter(widget.id);
        }
      },
      child: FittedBox(
        child: Container(
          margin: const EdgeInsets.all(4.0),
          padding: const EdgeInsets.symmetric(vertical: 0.0, horizontal: 4.0),
          decoration: BoxDecoration(
            color: filter == widget.id
                ? kPrimarySeedColor!
                // ignore: deprecated_member_use
                : Colors.grey.withOpacity(0.40),
            borderRadius: BorderRadius.circular(4.0),
          ),
          height: 20,
          alignment: Alignment.center,
          child: Text(
            widget.name,
            style: TextStyle(
              fontSize: 12.0,
              color: filter == widget.id ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
