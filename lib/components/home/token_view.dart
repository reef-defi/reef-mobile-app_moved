import 'package:flutter/cupertino.dart';
import "package:flutter/material.dart";
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_mobx/flutter_mobx.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:reef_mobile_app/components/BlurableContent.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/status-data-object/StatusDataObject.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/icon_url.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:sliver_tools/sliver_tools.dart';

import '../modals/show_qr_code.dart';

class TokenView extends StatefulWidget {
  const TokenView({Key? key}) : super(key: key);

  @override
  State<TokenView> createState() => _TokenViewState();
}

class _TokenViewState extends State<TokenView> {
  Widget tokenCard(String name, String address,
      {String? iconURL,
      BigInt? balance,
      double price = 0.0,
      String tokenName = ""}) {
    return ViewBoxContainer(
      child: Padding(
        padding:
            const EdgeInsets.symmetric(vertical: 16.0, horizontal: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                GestureDetector(
                    onDoubleTap: () {
                      showQrCode(
                          '$name Contract \n(don\'t send funds here)',
                          address);
                    },
                    child: SizedBox(
                        height: 48,
                        width: 48,
                        child: IconFromUrl(iconURL))),
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      constraints: const BoxConstraints(maxWidth: 100),
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
                          ? NumberFormat.simpleCurrency(decimalDigits: 4)
                              .format(price)
                              .toString()
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
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Observer(builder: (context) {
                      return BlurableContent(
                          GradientText(
                              price != 0
                                  ? NumberFormat.compactLong()
                                      .format(
                                          getBalanceValueBI(balance, price))
                                      .toString()
                                  : "N/A",
                              gradient: textGradient(),
                              style: GoogleFonts.poppins(
                                color: Styles.textColor,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                              )),
                          ReefAppState.instance.model.appConfig
                              .displayBalance);
                    }),
                    Observer(builder: (context) {
                      return BlurableContent(
                          Text(
                            "${balance != null && balance > BigInt.zero ? NumberFormat.compact().format((balance) / BigInt.from(10).pow(18)).toString() : 0} ${tokenName != "" ? tokenName : name.toUpperCase()}",
                            style: GoogleFonts.poppins(
                              color: Styles.textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          ReefAppState.instance.model.appConfig
                              .displayBalance);
                    })
                  ],
                ),
              ],
            ),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                        /*ElevatedButton.icon(
                      icon: const Icon(
                        CupertinoIcons.repeat,
                        color: Color(0xffa93185),
                        size: 16.0,
                      ),
                      style: ElevatedButton.styleFrom(
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: const Color(0xffe7def0),
                          shape: const StadiumBorder(),
                          elevation: 0),
                      label: const Text(
                        'Swap',
                        style: TextStyle(
                            color: Color(0xffa93185),
                            fontWeight: FontWeight.w700),
                      ),
                      onPressed: () {
                        ReefAppState.instance.navigationCtrl
                            .navigateToSwapPage(context: context);
                      },
                    )),
                    const SizedBox(width: 15),*/
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
                            shape: const StadiumBorder(),
                            elevation: 0),
                        label: const Text(
                          'Send',
                          style: TextStyle(
                              color: Colors.white, fontWeight: FontWeight.w700),
                        ),
                        onPressed: () async{
                          ReefAppState.instance.navigationCtrl
                              .navigateToSendPage(
                                  context: context, preselected: address);
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
    return Observer(
      builder: (context) {
        final selectedERC20s =
            ReefAppState.instance.model.tokens.selectedErc20s;

        String? message = getFdmListMessage(
            selectedERC20s,
            AppLocalizations.of(context)!.balance,
            AppLocalizations.of(context)!.loading);

        return MultiSliver(
          pushPinnedChildren: false,
          children: [
            if (message != null)
              SliverToBoxAdapter(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
                  child: ViewBoxContainer(
                      child: Center(
                          child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 24.0, horizontal: 16),
                    child: Text(
                      message,
                      style: TextStyle(
                          color: Styles.textLightColor,
                          fontWeight: FontWeight.w500),
                    ),
                  ))),
                ),
              )
            else if (selectedERC20s.data.isNotEmpty || true)
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
                sliver: SliverGrid(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      final tkn = selectedERC20s.data[index];
                      return tokenCard(tkn.data.name, tkn.data.address,
                          tokenName: tkn.data.symbol,
                          iconURL: tkn.data.iconUrl,
                          price: tkn.data.price ?? 0,
                          balance: tkn.data.balance);
                    },
                    childCount: selectedERC20s.data.length,
                  ),
                  gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                      mainAxisSpacing: 24,
                      crossAxisSpacing: 24,
                      childAspectRatio: 2.5,
                      maxCrossAxisExtent: 400),
                ),
              ),
          ],
        );
      },
    );
  }
}
