import 'package:dotted_border/dotted_border.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:reef_mobile_app/utils/functions.dart';
import 'package:intl/intl.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class StakingView extends StatefulWidget {
  const StakingView({Key? key}) : super(key: key);

  @override
  State<StakingView> createState() => _StakingViewState();
}

class _StakingViewState extends State<StakingView> {
  TextEditingController valueContainer = TextEditingController();
  bool _isInputEmpty = true;
  DateFormat dateFormat = DateFormat("yyyy-MM-dd HH:mm");

  @override
  void initState() {
    super.initState();
    // Start listening to changes.
    valueContainer.addListener(_changeState);
  }

  _changeState() {
    setState(() {
      _isInputEmpty = valueContainer.text.isEmpty;
    });
  }

  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final Map _stakeInfo = {
    "contract": "0x7D3596b724cEB02f2669b902E4F1EEDeEfad3be6",
    "staked": 0.00,
    "earned": 0.00,
    "stakingClosesIn": "8 months, 3 days, 11 hours, 45 minutes",
    "bondStartedOn":
        DateTime.now().subtract(const Duration(days: 5)).millisecondsSinceEpoch,
    "fundsUnlockOn":
        DateTime.now().subtract(const Duration(days: 6)).millisecondsSinceEpoch,
  };

  void _launchURL() async {
    Uri url =
        Uri.parse('https://reefscan.com/contract/${_stakeInfo["contract"]}');
    if (!await launchUrl(
      url,
      mode: LaunchMode.externalApplication,
    )) {
      throw 'Could not launch $url';
    }
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
                  const EdgeInsets.symmetric(vertical: 32, horizontal: 48.0),
              child: ViewBoxContainer(
                  child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 24.0, horizontal: 32.0),
                child: Column(
                  children: [
                    const Image(
                      image: AssetImage("assets/images/reef.png"),
                      height: 48,
                      width: 48,
                    ),
                    const Gap(16),
                    Center(
                      child: Text(
                        AppLocalizations.of(context)!.reef_community_bond,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    const Gap(16),
                    Center(
                      child: GradientText(
                        "Stake REEF to earn REEF validator rewards",
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                        gradient: textGradient(),
                      ),
                    ),
                    const Gap(28),
                    DottedBox(value: _stakeInfo["staked"], title: "Staked"),
                    const Gap(28),
                    DottedBox(
                        value: _stakeInfo["earned"],
                        title: "Earned",
                        color: Styles.greenColor),
                    const Gap(28),
                    Container(
                      color: const Color(0x08000000),
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: GestureDetector(
                        onTap: _launchURL,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(AppLocalizations.of(context)!.bond_contract),
                            const Gap(4),
                            Text(
                              _stakeInfo["contract"].toString().shorten(),
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                shadows: [
                                  Shadow(
                                      color: Styles.blueColor,
                                      offset: const Offset(0, -1))
                                ],
                                color: Colors.transparent,
                                decoration: TextDecoration.underline,
                                decorationColor: Styles.blueColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.staking_closes_in),
                          const Gap(4),
                          Text(
                            // TODO: add datetime and format it accordingly
                            _stakeInfo["stakingClosesIn"],
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      color: const Color(0x08000000),
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.bond_started_on),
                          const Gap(4),
                          Text(
                            dateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(int.parse(
                                    _stakeInfo["bondStartedOn"].toString()))),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(AppLocalizations.of(context)!.funds_unlock_on),
                          const Gap(4),
                          Text(
                            dateFormat.format(
                                DateTime.fromMillisecondsSinceEpoch(int.parse(
                                    _stakeInfo["fundsUnlockOn"].toString()))),
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Gap(24),
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          TextFormField(
                            controller: valueContainer,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly
                            ],
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 2),
                              border: const OutlineInputBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(color: Colors.grey),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(10)),
                                borderSide: BorderSide(
                                    color: Styles.secondaryAccentColor,
                                    width: 2),
                              ),
                              hintText: 'Enter amount to bond',
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Amount cannot be empty';
                              }
                              return null;
                            },
                          ),
                          const Gap(8),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(40)),
                                  shadowColor: const Color(0x559d6cff),
                                  elevation: 5,
                                  primary: _isInputEmpty
                                      ? const Color(0xff9d6cff)
                                      : Styles.secondaryAccentColor,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                ),
                                onPressed: () {
                                  if (_formKey.currentState!.validate()) {
                                    // Process data and do mobx stuff once integrated
                                  }
                                },
                                child: Text(
                                  _isInputEmpty
                                      ? 'Enter amount to stake'
                                      : 'Continue',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )),
            ),
          )
        ]);
  }
}
