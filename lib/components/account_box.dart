
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/utils/functions.dart';

import '../utils/elements.dart';
import '../utils/gradient_text.dart';
import '../utils/styles.dart';

class AccountBox extends StatefulWidget {
  // TODO -- final ReefSigner props;
  final Map props;
  final VoidCallback callback;

  const AccountBox({Key? key, required this.props, required this.callback})
      : super(key: key);

  @override
  State<AccountBox> createState() => _AccountBoxState();
}

class _AccountBoxState extends State<AccountBox> {
  bool showBalance = true;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: widget.callback,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
            color: widget.props["selected"]
                ? const Color(0x25bf37a7)
                : Styles.boxBackgroundColor,
            border: Border.all(
              color: widget.props["selected"]
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
            if (widget.props["selected"])
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
                          child: SvgPicture.string(
                            widget.props["logo"],
                            height: 64,
                            width: 64,
                          ),
                        ),
                      ),
                      const Gap(12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.props["name"],
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
                                    ? double.parse(
                                    widget.props["balance"].toString())
                                    .toStringAsFixed(2)
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
                                "Native: ${widget.props["nativeAddress"].toString().shorten()}",
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
                          const Gap(2),
                          Row(
                            children: [
                              Text(
                                  "EVM: ${widget.props["evmAddress"].toString().shorten()}",
                                  style: const TextStyle(fontSize: 12)),
                              const Gap(2),
                              const Icon(
                                Icons.copy,
                                size: 12,
                                color: Colors.black45,
                              )
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      if (!widget.props["evmBound"])
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
                      IconButton(
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                          onPressed: () {},
                          icon: const Icon(
                            Icons.more_vert,
                            color: Colors.black45,
                          )),
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
