import 'package:flutter/material.dart';
import 'package:series_2d/utils/constants.dart';
import 'package:series_2d/utils/game_data_constant.dart';

class InfoPage extends StatelessWidget {
  InfoPage({Key? key}) : super(key: key);

  final List<String> allowedKeys =
      gameTypeSelection3dConfig.keys.toList(); // Extract keys

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          children: [
            // Main content area
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Table(
                    border: TableBorder.all(
                      color: Colors.grey.shade300,
                      width: 1,
                    ),
                    defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                    columnWidths: const {
                      0: FlexColumnWidth(2),
                      1: FlexColumnWidth(1),
                      2: FlexColumnWidth(4),
                      3: FlexColumnWidth(2),
                    },
                    children: [
                      _buildTableHeader(),
                      if (allowedKeys.contains("1"))
                        _buildTableRow(
                            'Straight (STR)',
                            '123',
                            [
                              ['1', '2', '3']
                            ],
                            '900 x 10 = 9000',
                            extraString: '123 new lucky number'),
                      if (allowedKeys.contains("2"))
                        _buildTableRow(
                            'Box 3 Way (BOX3)',
                            '112',
                            [
                              ['1', '1', '2'],
                              ['1', '2', '1'],
                              ['2', '1', '1'],
                            ],
                            '300 x 10 = 3000'),
                      if (allowedKeys.contains("3"))
                        _buildTableRow(
                            'Box 6 Way (BOX6)',
                            '123',
                            [
                              ['1', '2', '3'],
                              ['1', '3', '2'],
                              ['2', '1', '3'],
                              ['2', '3', '1'],
                              ['3', '1', '2'],
                              ['3', '2', '1'],
                            ],
                            '150 x 10 = 1500',
                            isBox6Way: true),
                      if (allowedKeys.contains("4"))
                        _buildTableRow(
                            'Front Pair (FP)',
                            '12X',
                            [
                              ['1', '2', 'X']
                            ],
                            '90 x 10 = 900'),
                      if (allowedKeys.contains("5"))
                        _buildTableRow(
                            'Back Pair (BP)',
                            'X23',
                            [
                              ['X', '2', '3']
                            ],
                            '90 x 10 = 900'),
                      if (allowedKeys.contains("6"))
                        _buildTableRow(
                            'Split Pair (SP)',
                            '1X3',
                            [
                              ['1', 'X', '3']
                            ],
                            '90 x 10 = 900'),
                      if (allowedKeys.contains("7"))
                        _buildTableRow(
                            'Any Pair (AP)',
                            'X23',
                            [
                              ['X', '2', '3'],
                              ['2', 'X', '3'],
                              ['2', '3', 'X'],
                            ],
                            '30 x 10 = 300'),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  TableRow _buildTableHeader() {
    return TableRow(
      decoration: BoxDecoration(
        color: primaryColor,
      ),
      children: [
        _buildTableCell('Plays', isHeader: true),
        _buildTableCell('No', isHeader: true),
        _buildTableCell('If lucky coupon draws', isHeader: true),
        _buildTableCell('Win Points', isHeader: true),
      ],
    );
  }

  static TableCell _buildTableCell(String content, {bool isHeader = false}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0),
        child: Center(
          child: Text(
            content,
            style: TextStyle(
              fontWeight: FontWeight.bold, // Set text to bold
              color: isHeader ? Colors.white : Colors.black,
              fontSize: 16,
            ),
          ),
        ),
      ),
    );
  }

  TableRow _buildTableRow(String betType, String betValue,
      List<List<String>> numbers, String totalBet,
      {bool isBox6Way = false, String? extraString}) {
    return TableRow(
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      children: [
        _buildTableCell(betType),
        _buildTableCell(betValue),
        isBox6Way
            ? _buildBox6WayRow(numbers)
            : _buildNumberRow(numbers, extraString: extraString),
        _buildTableCell(totalBet),
      ],
    );
  }

  Widget _buildNumberRow(List<List<String>> numbers, {String? extraString}) {
    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: _groupNumbersInSetsOfThree(numbers).map((group) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: group.map((number) {
                          return _buildNumberCard(number);
                        }).toList(),
                      ),
                    );
                  }).toList(),
                ),
                if (extraString != null)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Text(
                      extraString,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold, // Bold text
                        color: Colors.black,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBox6WayRow(List<List<String>> numbers) {
    List<List<String>> groupedNumbers = _groupNumbersInSetsOfThree(numbers);

    return TableCell(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          children: [
            // First row of groups
            _buildNumberRowInTwoRows(groupedNumbers.take(3).toList()),
            const SizedBox(height: 10), // Space between rows
            // Second row of groups
            _buildNumberRowInTwoRows(groupedNumbers.skip(3).toList()),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberRowInTwoRows(List<List<String>> rowNumbers) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: rowNumbers.map((group) {
          return Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 8.0), // Space between groups of three numbers
            child: Row(
              children: group.map((number) {
                return _buildNumberCard(number);
              }).toList(),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildNumberCard(String number) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 16, 91, 211),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        number,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold, // Bold text
          fontSize: 16,
        ),
      ),
    );
  }

  List<List<String>> _groupNumbersInSetsOfThree(List<List<String>> numbers) {
    List<String> flatList = numbers.expand((e) => e).toList();
    List<List<String>> groupedNumbers = [];

    for (int i = 0; i < flatList.length; i += 3) {
      groupedNumbers.add(
        flatList.sublist(i, i + 3 > flatList.length ? flatList.length : i + 3),
      );
    }

    return groupedNumbers;
  }
}
