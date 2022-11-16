import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class TokenView extends StatefulWidget {
  const TokenView({Key? key}) : super(key: key);

  @override
  State<TokenView> createState() => _TokenViewState();
}

class _TokenViewState extends State<TokenView> {
  Widget tokenCard(String name, String address,
      {String? iconURL,
      double balance = 0.0,
      double price = 0.0,
      String tokenName = ""}) {
    return ViewBoxContainer(
        child: Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 15.0),
            child: Column(
              children: [
                Row(
                  children: [
                    SizedBox(
                        height: 48, width: 48, child: IconFromUrl(iconURL)),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          constraints: BoxConstraints(maxWidth: 100),
                          child: Text(name,
                              overflow: TextOverflow.ellipsis,
                              style: GoogleFonts.poppins(
                                color: Styles.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                              )),
                        ),
                        Text(
                          // TODO allow conversionRate to be null for no data
                          price != 0
                              ? '\$${price.toStringAsFixed(4)}'
                              : 'No pool data',
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.normal,
                              color: Styles.textLightColor,
                              fontSize: 14),
                        )
                      ],
                    ),
                    const Spacer(),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        GradientText(
                            price != 0
                                ? "\$${getBalanceValue(balance, price).toStringAsFixed(2)}"
                                : "NA",
                            gradient: textGradient(),
                            style: GoogleFonts.poppins(
                              color: Styles.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            )),
                        Text(
                          "${balance != 0 ? balance.toStringAsFixed(0) : 0} ${tokenName != "" ? tokenName : name.toUpperCase()}",
                          style: GoogleFonts.poppins(
                            color: Styles.textColor,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /*Expanded(
                        child: ElevatedButton.icon(
                      icon: const Icon(
                        CupertinoIcons.repeat,
                        color: Color(0xffa93185),
                        size: 16.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Color(0xffe7def0),
                          shape: StadiumBorder(),
                          elevation: 0),
                      label: const Text(
                        'Swap',
                        style: TextStyle(
                            color: Color(0xffa93185),
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        ReefAppState.instance.navigation
                            .navigate(NavigationPage.swap);
                      },
                    )),*/
                    const SizedBox(width: 15),
                    Container(
                        child: Container(
                      decoration: BoxDecoration(
                          boxShadow: const [
                            BoxShadow(
                                color: Color(0xff742cb2),
                                spreadRadius: -10,
                                offset: Offset(0, 5),
                                blurRadius: 20),
                          ],
                          borderRadius: BorderRadius.circular(80),
                          gradient: const LinearGradient(
                            colors: [Color(0xffae27a5), Color(0xff742cb2)],
                            begin: Alignment(-1, -1),
                            end: Alignment(1, 1),
                          )),
                      child: ElevatedButton.icon(
                        icon: const Icon(
                          CupertinoIcons.paperplane_fill,
                          color: Colors.white,
                          size: 16.0,
                        ),
                        style: ElevatedButton.styleFrom(
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            backgroundColor: Colors.transparent,
                            shape: const StadiumBorder(),
                            elevation: 0),
                        label: const Text(
                          'Send',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {
                          ReefAppState.instance.navigation
                              .navigate(NavigationPage.send, data: address);
                        },
                      ),
                    )),
                  ],
                )
              ],
            )));
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
              padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 0),
              child: Observer(builder: (_) {
                return Wrap(
                  spacing: 24,
                  children: ReefAppState
                      .instance.model.tokens.selectedSignerTokens
                      .map((TokenWithAmount tkn) {
                    return Column(
                      children: [
                        tokenCard(tkn.name, tkn.address,
                            tokenName: tkn.symbol,
                            iconURL: tkn.iconUrl,
                            price: tkn.price?.toDouble() ?? 0,
                            balance: decimalsToDouble(tkn.balance)),
                        const SizedBox(height: 12),
                      ],
                    );
                  }).toList(),
                );
              }),
            ),
          )
        ]);
  }
}
