import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:psglotto/model/draw_result.dart' as d;
import 'package:psglotto/view/utils/custom_close_button.dart';

import '../../../model/draw_result.dart';
import '../../utils/constants.dart';
import '../common_chip.dart';

class DrawResultView extends StatefulWidget {
  final String gameName;
  final String drawId;
  final String drawTime;
  final List<d.Results> results;
  const DrawResultView(
      {Key? key,
      required this.results,
      required this.gameName,
      required this.drawTime,
      required this.drawId})
      : super(key: key);

  @override
  // ignore: library_private_types_in_public_api
  _DrawResultViewState createState() => _DrawResultViewState();
}

class _DrawResultViewState extends State<DrawResultView> {
  ScrollController controller = ScrollController();

  TextEditingController searchKey = TextEditingController();

  final itemkey = GlobalKey();

  Future scrollItem() async {
    final context = itemkey.currentContext!;
    await Scrollable.ensureVisible(context);
  }

  String searchedText = " ";
  String winSearch = "";
  String winSearchNumber = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Results"),
        centerTitle: true,
        actions: [
          Row(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Draw Time: ${widget.drawTime}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  Text("Draw ID: ${widget.drawId}",
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                ],
              ),
              CustomCloseButton()
            ],
          )
        ],
      ),
      body: SingleChildScrollView(
        // controller: controller,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text(
                            "Game Name: ",
                            style: TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                          Text(
                            widget.gameName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(
                    height: 16.0,
                  ),
                  TextFormField(
                    // controller: searchKey,
                    onChanged: (value) {
                      for (var result in widget.results) {
                        for (var ticket in (result.ticketNos ?? [])) {
                          if (highlight(ticket, value)) {
                            if (kDebugMode) {
                              print(result.name);
                            }
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                content: Text(result.name.toString())));
                          }
                        }
                      }

                      setState(() {
                        searchedText = value;
                      });
                    },
                    maxLength: 6,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.12),
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none,
                        borderRadius: BorderRadius.circular(8.0),
                      ),
                      hintText: "Ticket No",
                      hintStyle: const TextStyle(
                        fontSize: 14.0,
                        fontWeight: FontWeight.w600,
                      ),
                      suffixIcon: const Icon(Icons.search),
                    ),
                  ),
                  // Text()
                ],
              ),
            ),
            ListView.builder(
              // key: itemkey,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.results.length,
              itemBuilder: (context, index) {
                return Container(
                  margin: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                height: 25.0,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                decoration: BoxDecoration(
                                  color: kPrimarySeedColor!,
                                  borderRadius: const BorderRadius.only(
                                    topLeft: Radius.circular(12.0),
                                    bottomRight: Radius.circular(12.0),
                                  ),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  widget.results[index].name ?? "-",
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ),
                              const SizedBox(
                                height: 30.0,
                              ),
                              const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Icon(Icons.card_giftcard),
                              ),
                            ],
                          ),
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              children: [
                                Text(
                                  widget.results[index].winPrice!
                                      .toStringAsFixed(2),
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w600),
                                ),
                                const SizedBox(
                                  height: 10.0,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      if (widget.results[index].name != null)
                        Wrap(
                          children: [
                            ...widget.results[index].ticketNos!.map(
                              (e) => CommonChip(
                                ticketNo: e,
                                highlight:
                                    highlight(e, searchedText) ? true : null,
                              ),
                            )
                          ],
                        ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  String? searchTickets(String searchKey, List<Results> allList) {
    try {
      if (searchKey.isEmpty) {
        return null;
      } else {
        Results s = allList.firstWhere((element) {
          if (element.ticketNos == null || element.ticketNos!.isEmpty) {
            return false;
          }
          List<String> tickets = element.ticketNos!
              .where((e) => e.contains(searchKey))
              .map((e) => e)
              .toList();
          if (tickets.isNotEmpty) {
            return true;
          } else {
            return false;
          }
        });
        log("${s.winPrice}");
        log("${s.id}");
        log("${s.ticketNos}");
        log("${s.name}");

        return s.name;
      }
    } catch (e) {
      log("Not Valid");
      log("searchTickets : ${e.toString()}");
      return null;
    }
  }

  bool highlight(String text, String? query) {
    if (query != null) {
      if (query.length == 6) {
        return (query.substring(4, 6) == text) ||
            (query.substring(3, 6) == text) ||
            query == text;
      } else if (query.length == 3) {
        return query == text;
      } else if (query.length == 2) {
        return query == text;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
