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
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../model/status-data-object/StatusDataObject.dart';
import '../BlurContent.dart';

class ActivityView extends StatefulWidget {
  const ActivityView({Key? key}) : super(key: key);

  @override
  State<ActivityView> createState() => _ActivityViewState();
}


Future<IconData> getIconData(String imageUrl) async {
  final response = await http.get(Uri.parse(imageUrl));
  final bytes = response.bodyBytes;
  final base64String = base64Encode(bytes);
  final IconData iconData = IconData(int.parse(base64String.substring(0, 10)), fontFamily: 'MaterialIcons');
  return iconData;
}

class _ActivityViewState extends State<ActivityView> {
  Widget activityItem(
      {required String type,
      required BigInt? amount,
      required String tokenName,
      required DateTime timeStamp,
      required String? iconUrl,
      required bool? isTokenNFT,
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
        if (amount != null) {
          amountText =
              "+ ${formatAmountToDisplayBigInt(amount, fractionDigits: 2)}";
        } else {
          if(isTokenNFT!){
            amountText = "";
          }else{
          amountText = "0";
          }
        }
        // amountText =
        //     "+ ${amount != null ? toAmountDisplayBigInt(amount!, fractionDigits: 2) : 0}";
        icon = CupertinoIcons.arrow_down_left;
        bgColor = const Color(0x3335c57d);
        iconColor = const Color(0xff35c57d);
        break;
      case "sent":
        if (amount != null) {
          amountText = "- ${formatAmountToDisplayBigInt(amount)}";
        } else {
          if(isTokenNFT!){
            amountText = "";
          }else{
          amountText = "0";
          }
        }
        // amountText =
        //     "- ${amount != null ? toAmountDisplayBigInt(amount!, fractionDigits: 2) : 0}";
        
        icon =  CupertinoIcons.arrow_up_right;
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
                Observer(builder: (context) {
                  return BlurableContent(
                      Text(
                        amountText,
                        style: GoogleFonts.spaceGrotesk(
                            fontWeight: FontWeight.w700,
                            color: isReceived ? Color(0xff35c57d) : iconColor,
                            fontSize: 18),
                      ),
                      ReefAppState.instance.model.appConfig.displayBalance);
                }),
                const SizedBox(width: 4),
                IconFromUrl(
                  iconUrl,
                  size:isTokenNFT!? 45:18,
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
    // print(ReefAppState.instance.model.tokens.txHistory.data.map((item) => [
    //       item.token,
    //       item.isInbound,
    //       item.extrinsic,
    //       item.timestamp,
    //       item.tokenNFT,
    //       item.url,
    //       item.token?.iconUrl ?? item.tokenNFT?.iconUrl,
    //     ]));
     
    return Observer(builder: (_) {
      String? message = getFdmListMessage(
          ReefAppState.instance.model.tokens.txHistory, AppLocalizations.of(context)!.activity, AppLocalizations.of(context)!.loading);

      return SliverList(
        delegate: SliverChildListDelegate([
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 12.0),
              child: ViewBoxContainer(
                child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: message == null
                        ? Column(
                            children: ReefAppState
                                .instance.model.tokens.txHistory.data
                                .map((item) => Column(
                                      children: [
                                        activityItem(
                                          tokenName: item.token?.name ?? (item.tokenNFT!.balance==BigInt.one? item.tokenNFT!.name: "${item.tokenNFT!.balance} ${item.tokenNFT!.name}s"),
                                          type: item.isInbound
                                              ? 'received'
                                              : 'sent',
                                          timeStamp: item.timestamp.toLocal(),
                                          amount: item.tokenNFT?.iconUrl==""?item.token?.balance:item.token?.balance,
                                          iconUrl: item.token?.iconUrl??item.tokenNFT?.iconUrl,
                                          isTokenNFT: item.tokenNFT==null?false:true,
                                        ),
                                        if (ReefAppState.instance.model.tokens
                                                .txHistory.data.last !=
                                            item)
                                          const Divider(
                                            height: 32,
                                            color: Color(0x20000000),
                                            thickness: 0.5,
                                          ),
                                      ],
                                    ))
                                .toList(),
                          )
                        : Center(
                            child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              message,
                              style: TextStyle(
                                  color: Styles.textLightColor,
                                  fontWeight: FontWeight.w500),
                            ),
                          ))),
              ),
            ),
          )
        ]),
      );
    });
  }
}
