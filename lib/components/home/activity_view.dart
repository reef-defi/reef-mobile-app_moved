import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class ActivityView extends StatefulWidget {
  const ActivityView({Key? key}) : super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  static final List _activityMap = [
    {
      "key": 0,
      "type": "received",
      "amount": 4000.0,
      "tokenName": "REEF",
      "timeStamp": DateTime.now().millisecondsSinceEpoch,
    },
    {
      "key": 1,
      "type": "sent",
      "amount": 2000.0,
      "tokenName": "REEF",
      "timeStamp": DateTime.now()
          .subtract(const Duration(days: 1))
          .millisecondsSinceEpoch,
    },
    {
      "key": 2,
      "type": "received",
      "amount": 1000.0,
      "tokenName": "REEF",
      "timeStamp": DateTime.now()
          .subtract(const Duration(days: 2))
          .millisecondsSinceEpoch,
    },
    {
      "key": 3,
      "type": "sent",
      "amount": 500.0,
      "tokenName": "REEF",
      "timeStamp": DateTime.now()
          .subtract(const Duration(days: 3))
          .millisecondsSinceEpoch,
    },
    {
      "key": 4,
      "type": "received",
      "amount": 50000000.0,
      "tokenName": "REEF",
      "timeStamp": DateTime.now()
          .subtract(const Duration(days: 4))
          .millisecondsSinceEpoch,
    }
  ];

  Widget activityItem(
      {required String type,
      required double amount,
      required String tokenName,
      required int timeStamp,
      isFirstElement = false,
      isLastElement = false}) {
    final tsDate = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    String titleText = type.capitalize(),
        amountText = "",
        timeStampText = "${tsDate.day}-${tsDate.month}-${tsDate.year}";
    IconData icon = CupertinoIcons.exclamationmark_circle_fill;
    Color? bgColor = Colors.transparent;
    Color? iconColor = Colors.transparent;
    bool isGradientText = (type == "received");

    switch (type) {
      case "received":
        amountText = "+ $amount $tokenName";
        icon = CupertinoIcons.arrow_down_left;
        bgColor = const Color(0xFFD8F5D9);
        iconColor = Colors.green[400];
        break;
      case "sent":
        amountText = "- $amount $tokenName";
        icon = CupertinoIcons.arrow_up_right;
        bgColor = const Color(0xffe5e9eb);
        iconColor = Colors.grey[500];
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // For debugging, remove later
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.black12),
      // ),
      child: Column(
        children: [
          if (!isFirstElement) const Gap(8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(child: Icon(icon, color: iconColor)),
                  ),
                  const Gap(18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titleText,
                        style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 17,
                            color: Styles.textColor),
                      ),
                      const Gap(2),
                      Text(
                        timeStampText,
                        style: TextStyle(
                            fontSize: 12, color: Styles.textLightColor),
                      )
                    ],
                  ),
                ],
              ),
              if (isGradientText)
                GradientText(
                  amountText,
                  gradient: textGradient(),
                  style: GoogleFonts.spaceGrotesk(fontWeight: FontWeight.w700),
                )
              else
                Text(
                  amountText,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700, color: iconColor),
                )
            ],
          ),
          if (!isLastElement) const Gap(8),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: [
          SizedBox(
            // constraints: const BoxConstraints.expand(),
            width: double.infinity,
            // // replace later, just for debugging
            // decoration: BoxDecoration(
            //   border: Border.all(
            //     color: Colors.red,
            //   ),
            // ),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 24.0),
              child: ViewBoxContainer(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Column(
                    children: _activityMap
                        .map((item) => Column(
                              children: [
                                activityItem(
                                    type: item["type"],
                                    tokenName: item["tokenName"],
                                    timeStamp: item["timeStamp"],
                                    amount: item["amount"],
                                    isLastElement:
                                        item["key"] == _activityMap.length - 1,
                                    isFirstElement: item["key"] == 0),
                                if (item["key"] != _activityMap.length - 1)
                                  const Divider(
                                    color: Color(0x20000000),
                                    thickness: 0.5,
                                  ),
                              ],
                            ))
                        .toList(),
                  ),
                ),
              ),
            ),
          )
        ]);
  }
}
