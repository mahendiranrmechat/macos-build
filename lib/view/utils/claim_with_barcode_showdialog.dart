import 'package:flutter/material.dart';
import 'package:psglotto/view/utils/constants.dart';

class ClaimDialogHelper {
  static void showClaimDialog(BuildContext context, bool screenSizeChanger) {
    // Implement your logic to show the claim dialog here
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.transparent,
            body: StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return Stack(
                children: [
                  Center(
                    child: Container(
                      width: screenSizeChanger
                          ? MediaQuery.of(context).size.width * 0.8
                          : MediaQuery.of(context).size.width * 0.5,
                      height: screenSizeChanger
                          ? MediaQuery.of(context).size.height * 0.8
                          : MediaQuery.of(context).size.height * 0.6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        border: Border.all(
                          color: kPrimarySeedColor!, // Golden border color
                          width: 2.0, // Border width
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.amber
                                .withOpacity(0.9), // Golden shadow color
                            spreadRadius: 5,
                            blurRadius: 5,
                            offset: const Offset(
                                0, 3), // Changes the position of the shadow
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              children: [
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        "Unclaimed Tickets : ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                      const Text("Unclaimed Price : ",
                                          style: TextStyle(
                                              fontWeight: FontWeight.bold)),
                                      ElevatedButton(
                                          onPressed: () {
                                            setState(() {});
                                          },
                                          child: Text(""))
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SizedBox(
                        width: screenSizeChanger
                            ? MediaQuery.of(context).size.width * 0.8
                            : MediaQuery.of(context).size.width * 0.5,
                        height: screenSizeChanger
                            ? MediaQuery.of(context).size.height * 0.8
                            : MediaQuery.of(context).size.height * 0.6,
                        child: Align(
                          alignment: Alignment.topRight,
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                //  pageNo = 1;
                              });
                              Navigator.pop(context);
                            },
                            icon: const Icon(Icons.close),
                            color: Colors.red,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        );
      },
    );
  }
}
