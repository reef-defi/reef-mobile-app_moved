import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:shimmer/shimmer.dart';

class TokenView extends StatefulWidget {
  const TokenView({Key? key}) : super(key: key);

  @override
  State<TokenView> createState() => _TokenViewState();
}

class _TokenViewState extends State<TokenView> {
  // Widget tokenCard(String name,
  //     {String? iconURL,
  //       double balance = 0.0,
  //     double price = 0.0,
  //     String tokenName = ""}) {
  //   return ViewBoxContainer(
  //       child: Padding(
  //           padding: const EdgeInsets.symmetric(vertical: 24.0),
  //           child: Column(
  //             children: [
  //               SizedBox(
  //                   height: 48,
  //                   width: 48,
  //                   child: /* TODO fix svg image base64
  //                   iconURL!=null ? CachedNetworkImage(
  //                     imageUrl: iconURL,
  //                     placeholder: (context, url) => Shimmer.fromColors(
  //                       baseColor: Colors.grey[300]!,
  //                       highlightColor: Colors.grey[350]!,
  //                       child: Container(
  //                         width: 48,
  //                         height: 48,
  //                         decoration: ShapeDecoration(
  //                           color: Colors.grey[350]!,
  //                           shape: const CircleBorder(),
  //                         ),
  //                       ),
  //                     ),
  //                     errorWidget: (context, url, error) => const Icon(
  //                       CupertinoIcons.exclamationmark_circle_fill,
  //                       color: Colors.black12,
  //                       size: 48,
  //                     ),
  //                   ):*/ const SizedBox.shrink()),
  //               const Gap(8),
  //               Text(
  //                 name,
  //                 style: TextStyle(
  //                   color: Styles.textColor,
  //                   fontSize: 20,
  //                   fontWeight: FontWeight.w700,
  //                 ),
  //               ),
  //               const Gap(2),
  //               Text(
  //                 // TODO allow conversionRate to be null for no data
  //                 "${balance != 0 ? balance : 0} ${tokenName != "" ? tokenName : name.toUpperCase()} - ${price != 0 ? price.toStringAsFixed(4) : 'No pool data'}",
  //                 style: TextStyle(color: Styles.textLightColor, fontSize: 16),
  //               ),
  //               const Gap(8),
  //               if (balance != 0)
  //                 GradientText(
  //                   "\$${getBalanceValue(balance, price).toStringAsFixed(2)}",
  //                   style: GoogleFonts.spaceGrotesk(
  //                       fontSize: 24, fontWeight: FontWeight.w700),
  //                   gradient: textGradient(),
  //                 ),
  //             ],
  //           )));
  // }

  Widget tokenCard(String name,
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
                        height: 48,
                        width: 48,
                        child: iconURL != null
                            ? CachedNetworkImage(
                                imageUrl: iconURL,
                                placeholder: (context, url) =>
                                    Shimmer.fromColors(
                                  baseColor: Colors.grey[300]!,
                                  highlightColor: Colors.grey[350]!,
                                  child: Container(
                                    width: 48,
                                    height: 48,
                                    decoration: ShapeDecoration(
                                      color: Colors.grey[350]!,
                                      shape: const CircleBorder(),
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) =>
                                    const Icon(
                                  CupertinoIcons.exclamationmark_circle_fill,
                                  color: Colors.black12,
                                  size: 48,
                                ),
                              )
                            : const SizedBox.shrink()),
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
                          "\$${price != 0 ? price.toStringAsFixed(4) : 'No pool data'}",
                          style: GoogleFonts.poppins(
                              fontWeight: FontWeight.w600,
                              color: Styles.textColor,
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
                            "US\$${getBalanceValue(balance, price).toStringAsFixed(2)}",
                            gradient: textGradient(),
                            style: GoogleFonts.poppins(
                              color: Styles.textColor,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                            )),
                        Text(
                          // TODO allow conversionRate to be null for no data
                          price != 0
                              ? "${balance != 0 ? balance.toStringAsFixed(4) : 0} ${tokenName != "" ? tokenName : name.toUpperCase()}"
                              : 'No pool data',
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
                  children: [
                    Expanded(
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
                      onPressed: () {},
                    )),
                    const SizedBox(width: 15),
                    Expanded(
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
                            shape: StadiumBorder(),
                            elevation: 0),
                        label: const Text(
                          'Send',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () {},
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
                        tokenCard(tkn.name,
                            tokenName: tkn.symbol,
                            iconURL: tkn.iconUrl,
                            price: tkn.price?.toDouble() ?? 0,
                            balance: decimalsToDouble(tkn.balance)),
                        SizedBox(height: 12),
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
