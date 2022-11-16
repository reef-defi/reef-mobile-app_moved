import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class ActivityView extends StatefulWidget {
  const ActivityView({Key? key}) : super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}

class _ActivityViewState extends State<ActivityView> {
  Widget activityItem(
      {required String type,
      required BigInt? amount,
      required String tokenName,
      required DateTime timeStamp,
      required String? iconUrl,
      isFirstElement = false,
      isLastElement = false}) {
    final tsDate = timeStamp;
    String titleText = type.capitalize(),
        amountText = "",
        timeStampText =
            "${tsDate.day}-${tsDate.month}-${tsDate.year}, ${tsDate.hour}:${tsDate.minute}";
    IconData icon = CupertinoIcons.exclamationmark_circle_fill;
    Color? bgColor = Colors.transparent;
    Color? iconColor = Colors.transparent;
    bool isReceived = (type == "received");

    switch (type) {
      case "received":
        amountText =
            "+ ${amount != null ? toAmountDisplayBigInt(amount!, fractionDigits: 2) : 0}";
        icon = CupertinoIcons.arrow_down_left;
        bgColor = const Color(0x3335c57d);
        iconColor = const Color(0xff35c57d);
        break;
      case "sent":
        amountText =
            "- ${amount != null ? toAmountDisplayBigInt(amount!, fractionDigits: 2) : 0}";
        icon = CupertinoIcons.arrow_up_right;
        bgColor = const Color(0x8cd8dce6);
        iconColor = const Color(0xffb2b0c8);
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      // For debugging, remove later
      // decoration: BoxDecoration(
      //   border: Border.all(color: Colors.black12),
      // ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                        child: Icon(
                      icon,
                      color: iconColor,
                    )),
                  ),
                  const Gap(18),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "$titleText $tokenName",
                        style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 15,
                            color: Styles.textColor),
                      ),
                      const Gap(1),
                      Text(
                        timeStampText,
                        style: TextStyle(
                            fontSize: 10, color: Styles.textLightColor),
                      )
                    ],
                  ),
                ],
              ),
              Row(children: [
                Text(
                  amountText,
                  style: GoogleFonts.spaceGrotesk(
                      fontWeight: FontWeight.w700,
                      color: isReceived ? Color(0xff35c57d) : iconColor,
                      fontSize: 18),
                ),
                const SizedBox(width: 4),
                IconFromUrl(
                  iconUrl,
                  size: 18,
                )
              ]),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print(ReefAppState.instance.model.tokens.activity.map((item) => [
          item.token,
          item.isInbound,
          item.extrinsic,
          item.timestamp,
          item.tokenNFT,
          item.url,
          item.token?.iconUrl ?? "",
        ]));
    return ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(0),
        children: [
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 0.0),
              child: ViewBoxContainer(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: ReefAppState
                            .instance.model.tokens.activity.isNotEmpty
                        ? Observer(builder: (_) {
                            // return Column(
                            //     children: ReefAppState.instance.model.tokens.activity
                            //         .map((element) =>
                            //             Text(element.timestamp.toIso8601String()))
                            //         .toList());
                            return Column(
                              children: ReefAppState
                                  .instance.model.tokens.activity
                                  .map((item) => Column(
                                        children: [
                                          activityItem(
                                            tokenName: item.token?.name ?? "",
                                            type: item.isInbound
                                                ? 'received'
                                                : 'sent',
                                            timeStamp: item.timestamp,
                                            amount: item.token?.balance,
                                            iconUrl: item.token?.iconUrl,
                                          ),
                                          if (ReefAppState.instance.model.tokens
                                                  .activity.last !=
                                              item)
                                            const Divider(
                                              height: 32,
                                              color: Color(0x20000000),
                                              thickness: 0.5,
                                            ),
                                        ],
                                      ))
                                  .toList(),
                            );
                          })
                        : Center(
                            child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              "No activity yet",
                              style: TextStyle(
                                  color: Styles.textLightColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ))),
              ),
            ),
          )
        ]);
  }
}
