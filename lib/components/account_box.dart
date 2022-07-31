
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/utils/functions.dart';

import '../utils/elements.dart';
import '../utils/gradient_text.dart';
import '../utils/styles.dart';

class AccountBox extends StatefulWidget {
  final ReefSigner reefSigner;
  final bool selected;
  final VoidCallback onSelected;

  const AccountBox({Key? key, required this.reefSigner, required this.selected, required this.onSelected})
      : super(key: key);

  @override
  State<AccountBox> createState() => _AccountBoxState();
}

class _AccountBoxState extends State<AccountBox> {
  bool showBalance = true;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.onSelected,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: widget.selected
                ? const Color(0x25bf37a7)
                : Styles.boxBackgroundColor,
            border: Border.all(
              color: widget.selected
                  ? Styles.primaryAccentColor
                  : Colors.grey[100]!,
              width: 2,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x16000000),
                blurRadius: 24,
              )
            ],
            borderRadius: BorderRadius.circular(15)),
        child: Stack(
          children: [
            if (widget.selected)
              Positioned(
                  top: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.only(
                        left: 12, bottom: 5, right: 10, top: 2),
                    decoration: BoxDecoration(
                        color: Styles.primaryAccentColor,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(15),
                            topRight: Radius.circular(12))),
                    child: Text(
                      "Selected",
                      style: TextStyle(
                          color: Styles.whiteColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  )),
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 16.0, vertical: 18.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.black12,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(64),
                          child: widget.reefSigner.iconSVG!=null ? SvgPicture.string(
                            widget.reefSigner.iconSVG!,
                            height: 64,
                            width: 64,
                          ): const SizedBox.shrink(),
                        ),
                      ),
                      const Gap(12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.reefSigner.name,
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Styles.textColor),
                          ),
                          const Gap(4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              IconButton(
                                  constraints: const BoxConstraints(),
                                  padding: EdgeInsets.zero,
                                  onPressed: () {
                                    setState(() {
                                      showBalance = !showBalance;
                                    });
                                  },
                                  icon: Icon(
                                    showBalance
                                        ? CupertinoIcons.eye
                                        : CupertinoIcons.eye_slash,
                                    size: 16,
                                    color: Styles.textLightColor,
                                  )),
                              const Image(
                                  image: AssetImage("./assets/images/reef.png"),
                                  width: 18,
                                  height: 18),
                              const Gap(4),
                              GradientText(
                                showBalance
                                    ? toBalanceDisplayBigInt(widget.reefSigner.balance)
                                    : "--",
                                style: GoogleFonts.spaceGrotesk(
                                    fontSize: 14, fontWeight: FontWeight.w700),
                                gradient: textGradient(),
                              ),
                            ],
                          ),
                          const Gap(2),
                          Row(
                            children: [
                              Text(
                                "Native: ${widget.reefSigner.address.shorten()}",
                                style: const TextStyle(fontSize: 12),
                              ),
                              const Gap(2),
                              const Icon(
                                Icons.copy,
                                size: 12,
                                color: Colors.black45,
                              )
                            ],
                          ),
                          /*const Gap(2),
                          widget.reefSigner.isEvmClaimed==true ? Row(
                            children: [
                              Text(
                                  "EVM: ${widget.reefSigner.evmAddress.toString().shorten()}",
                                  style: const TextStyle(fontSize: 12)),
                              const Gap(2),
                              const Icon(
                                Icons.copy,
                                size: 12,
                                color: Colors.black45,
                              )
                            ],
                          ):const SizedBox.shrink(),*/
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (widget.reefSigner.isEvmClaimed)
                        Row(
                          children: [
                            DecoratedBox(
                              decoration: BoxDecoration(
                                  color: Colors.black87,
                                  gradient: textGradient(),
                                  borderRadius: BorderRadius.circular(12)),
                              child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.black12,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(12)),
                                    padding: EdgeInsets.zero,
                                    minimumSize: const Size(75, 30),
                                    tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  child: Text(
                                    "Bind EVM",
                                    style: TextStyle(
                                        color: Styles.whiteColor,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  )),
                            ),
                            const Gap(6),
                          ],
                        ),
                      GestureDetector(
                        onDoubleTap: () {
                          ReefAppState.instance.accountCtrl.deleteAccount(widget.reefSigner.address);
                        },
                        child: IconButton(
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () {
                              // TODO show modal with option to delete account
                              // ReefAppState.instance.accountCtrl.deleteAccount(widget.reefSigner.address);
                            },
                            icon: const Icon(
                              Icons.more_vert,
                              color: Colors.black45,
                            ))
                      )

                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
