import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/app_bar.dart';
import 'package:reef_mobile_app/components/top_bar.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SendNFT extends StatefulWidget {
  String? nftId;
  String? contractAddress;
  SendNFT(this.nftId,this.contractAddress,{Key? key}): super(key: key);

  @override
  State<SendNFT> createState() => _SendNFTState();
}

class _SendNFTState extends State<SendNFT> {
  FocusNode _focus = FocusNode();
  FocusNode _focusSecond = FocusNode();
  String address = "";
  TextEditingController valueController = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          color: Styles.primaryBackgroundColor,
        ),
        child: SingleChildScrollView(
          child: Column(children: [
            Stack(children: [
              const Image(
                image: AssetImage("./assets/images/reef-header.png"),
                fit: BoxFit.cover,
                height: 110,
              ),
              Container(
                  padding: const EdgeInsets.fromLTRB(14.0, 4.0, 14.0, 4.0),
                  child: topBar(context))
            ]),
            const Gap(4),
            Row(
              children: [
                Gap(8.0),
                Text(
                    "Send NFTs",
                    style: GoogleFonts.spaceGrotesk(
                        fontWeight: FontWeight.w500,
                        fontSize: 32,
                        color: Colors.grey[800]),
                  ),
              ],
            ),
            const Gap(3.0),
            ClipRRect(
              borderRadius: BorderRadius.circular(40.0),
              child: Image.asset(
                "./assets/images/nft.png",
                height: 250.0,
                width: 210.0,
              ),
            ),
            Text("Name Of NFT",
                style: GoogleFonts.poppins(
                    color: Colors.grey[800],
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1)),
            const Gap(4.0),
            Container(
              padding: const EdgeInsets.fromLTRB(30, 2, 15, 2),
              margin: const EdgeInsets.fromLTRB(15, 0, 15, 0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Styles.primaryAccentColor,
                              Styles.secondaryAccentColor
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: IconButton(
                          icon: const Icon(
                            Icons.remove,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                      Gap(12.0),
                      Container(
                        height: 40.0,
                        width: 200.0,
                        decoration: BoxDecoration(borderRadius: BorderRadius.circular(10.0)),
                        
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                "2",
                style: GoogleFonts.spaceGrotesk(
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                    color: Colors.grey[800]),
              ),
                          ],
                        ),
                      ),
                      const Gap(12.0),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Styles.primaryAccentColor,
                              Styles.secondaryAccentColor
                            ],
                          ),
                          borderRadius: BorderRadius.circular(30.0),
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.add,
                            color: Colors.white,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const Gap(20.0),
 Container(
  margin: EdgeInsets.fromLTRB(50, 0, 30, 0),
  padding: EdgeInsets.fromLTRB(10, 10, 10,10),
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(10.0),
  color: Styles.greyColor,
  ),
  
   child: Row(
                      children: [
                        SizedBox(
                          width: 48,
                          child: MaterialButton(
                            elevation: 0,
                            height: 48,
                            padding: EdgeInsets.zero,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            onPressed: () {
                            
                            },
                            color: const Color(0xffDFDAED),
                          ),
                        ),
                        Expanded(
                          child: TextFormField(
                            focusNode: _focus,
                            controller: valueController,
                            onChanged: (text) {
                              setState(() {
                                address = valueController.text;
                              });
                            },
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                            decoration: InputDecoration(
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 2),
                                border: InputBorder.none,
                                hintText: 'Send to address',
                                hintStyle:
                                    TextStyle(color: Styles.textLightColor)),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return 'Address cannot be empty';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
 ),
                    
            Gap(20.0),
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
                        borderRadius: BorderRadius.circular(12)),
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(240, 60),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(
                    "Send",
                    style: TextStyle(
                        color: Styles.whiteColor,
                        fontWeight: FontWeight.w600,
                        fontSize: 24),
                  )),
            ),
            Gap(120)
          ]),
        ),
      ),
    );
  }
}