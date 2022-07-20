import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/components/modals/account_modals.dart';
import 'package:reef_mobile_app/model/ReefState.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:reef_mobile_app/utils/functions.dart';

class AccountBox extends StatefulWidget {
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
                          child: Image(
                            image: NetworkImage(widget.props["logo"]),
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

class UserPage extends StatefulWidget {
  // const UserPage({Key? key}) : super(key: key);

  UserPage({Key? key}) : super(key: key);
  final ReefAppState reefState = ReefAppState.instance;
  final StorageService storageService = ReefAppState.instance.storage;

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  Future<List<StoredAccount>?> getAllAccounts() async {
    var accounts = await widget.storageService.getAllAccounts();
    if (accounts.isEmpty) {
      print("No accounts found.");
      return null;
    }
    print("Found ${accounts.length} accounts:");
    accounts.forEach((account) {
      print("  ${account.address}");
    });

    var account = await widget.storageService.getAccount(accounts[0].address);
    if (account == null) {
      print("Account not found.");
      return null;
    }
    print(account.toJson());

    return accounts;
  }

  @override
  void initState() {
    super.initState();
    getAllAccounts();
  }

  List accountMap = [
    {
      "key": 0,
      "name": "Reef",
      "balance": 327060,
      "nativeAddress": "5DiowuaekjasdasyrkwuebnrbcaqvsK",
      "evmAddress": "0x12318923718927317298379812390459",
      "evmBound": true,
      "selected": true,
      "logo":
          "https://source.unsplash.com/random/128x128?sig=2982348901892389746",
    },
    {
      "key": 1,
      "name": "Boidu",
      "balance": 98,
      "nativeAddress": "5DiowuaekjasdasyrkwuebnrbcaqvsK",
      "evmAddress": "0x12318923718927317298379812390459",
      "evmBound": true,
      "selected": false,
      "logo":
          "https://source.unsplash.com/random/128x128?sig=123984170237410289374",
    },
    {
      "key": 2,
      "name": "Test",
      "balance": 0.00,
      "nativeAddress": "5DiowuaekjasdasyrkwuebnrbcaqvsK",
      "evmAddress": "0x12318923718927317298379812390459",
      "evmBound": false,
      "selected": false,
      "logo":
          "https://source.unsplash.com/random/128x128?sig=8377364829387489232342",
    },
    {
      "key": 3,
      "name": "Dont use this one",
      "balance": 12.90,
      "nativeAddress": "5DiowuaekjasdasyrkwuebnrbcaqvsK",
      "evmAddress": "0x12318923718927317298379812390459",
      "evmBound": false,
      "selected": false,
      "logo":
          "https://source.unsplash.com/random/128x128?sig=6039816829381289309123",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Image(
                    image: AssetImage("./assets/images/reef.png"),
                    width: 24,
                    height: 24,
                  ),
                  const Gap(8),
                  Text(
                    "Accounts",
                    style: GoogleFonts.spaceGrotesk(
                        fontSize: 18,
                        color: Styles.textColor,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.search,
                      color: Styles.textLightColor,
                      size: 28,
                    ),
                  ),
                  const Gap(12),
                  MaterialButton(
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    onPressed: () {
                      showCreateAccountModal(context);
                    },
                    color: Styles.textLightColor,
                    minWidth: 0,
                    height: 0,
                    padding: const EdgeInsets.all(2),
                    shape: const CircleBorder(),
                    elevation: 0,
                    child: Icon(
                      Icons.add,
                      color: Styles.primaryBackgroundColor,
                      size: 20,
                    ),
                  )
                ],
              ),
            ],
          ),
        ),
        const Gap(16),
        Expanded(
          child: ListView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(0),
            children: accountMap
                .map<Widget>((item) => Column(children: [
                      AccountBox(
                          props: item,
                          callback: () {
                            List temp = accountMap;

                            for (var element in temp) {
                              element["selected"] = false;
                            }

                            temp[item["key"]]["selected"] = true;

                            setState(() {
                              accountMap = temp;
                            });
                          }),
                      if (item["key"] != accountMap.length) const Gap(12)
                    ]))
                .toList(),
          ),
        )
      ],
    );
  }
}
