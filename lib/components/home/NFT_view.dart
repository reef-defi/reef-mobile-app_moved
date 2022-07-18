import 'package:flutter/material.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class NFTView extends StatefulWidget {
  const NFTView({Key? key}) : super(key: key);

  @override
  State<NFTView> createState() => _NFTViewState();
}

class _NFTViewState extends State<NFTView> {
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
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Column(
                  children: [
                    Text("No NFTs in your wallet",
                        style: TextStyle(
                            color: Styles.textLightColor, fontSize: 16)),
                  ],
                ),
              )),
            ),
          )
        ]);
  }
}
