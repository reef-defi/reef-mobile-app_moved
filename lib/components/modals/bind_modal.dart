import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefAccount.dart';
import 'package:reef_mobile_app/model/navigation/navigation_model.dart';
import 'package:reef_mobile_app/model/tokens/TokenWithAmount.dart';
import 'package:reef_mobile_app/utils/constants.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:reef_mobile_app/utils/functions.dart';

const MIN_BALANCE = 5;

class BindEvm extends StatefulWidget {
  final ReefAccount bindFor;

  const BindEvm({Key? key, required this.bindFor}) : super(key: key);

  @override
  State<BindEvm> createState() => _BindEvmState();
}

class _BindEvmState extends State<BindEvm> {
  bool selectAccount = false;
  dynamic transferBalanceFrom;
  List<ReefAccount> availableTxAccounts = [];

  @override
  void initState() {
    super.initState();

    if (hasBalanceForBinding(widget.bindFor)) return;

    availableTxAccounts = getSignersWithEnoughBalance(widget.bindFor);
    if (availableTxAccounts.isNotEmpty) {
      transferBalanceFrom = availableTxAccounts[0];
    }
  }

  bool hasBalanceForBinding(ReefAccount reefSigner) {
    return reefSigner.balance >= BigInt.from(MIN_BALANCE * 1e18);
  }

  bool hasBalanceForFunding(ReefAccount reefSigner) {
    return reefSigner.balance >= BigInt.from(MIN_BALANCE * 1e18 * 2);
  }

  List<ReefAccount> getSignersWithEnoughBalance(ReefAccount bindFor) {
    List<ReefAccount> _availableTxAccounts = ReefAppState
        .instance.model.accounts.accountsList
        .where((signer) =>
            signer.address != bindFor.address && hasBalanceForFunding(signer))
        .toList();
    _availableTxAccounts.sort((a, b) => b.balance.compareTo(a.balance));
    return _availableTxAccounts;
  }

  Future<void> transfer() async {
    TokenWithAmount reefToken = TokenWithAmount(
        name: 'Reef',
        address: Constants.REEF_TOKEN_ADDRESS,
        iconUrl: '',
        symbol: 'REEF',
        balance: BigInt.zero,
        decimals: 18,
        amount: BigInt.from(MIN_BALANCE * 1e18),
        price: null);
    await ReefAppState.instance.transferCtrl.transferTokens(
        transferBalanceFrom.address, widget.bindFor.address, reefToken);
  }

  Widget buildAccount(ReefAccount signer) {
    return ViewBoxContainer(
      color: Colors.white,
      child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
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
                      child: signer.iconSVG != null
                          ? SvgPicture.string(
                              signer.iconSVG!,
                              height: 48,
                              width: 48,
                            )
                          : const SizedBox(
                              width: 48,
                              height: 48,
                            ),
                    ),
                  ),
                  const Gap(12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        signer.name,
                        style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Styles.textColor),
                      ),
                      const Gap(4),
                      Row(
                        children: [
                          Text(
                            signer.address.shorten(),
                            style: const TextStyle(fontSize: 12),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ],
          )),
    );
  }

  Widget buildButton(Future<void> Function() func) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(40)),
          shadowColor: const Color(0x559d6cff),
          elevation: 5,
          backgroundColor: Styles.primaryAccentColorDark,
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        onPressed: () async {
          await func();
        },
        child: const Text(
          'Continue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  Widget buildSelectAccount() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Select account",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          )),
      const Gap(8),
      ...availableTxAccounts
          .map<Widget>((account) => Column(children: [
                InkWell(
                    onTap: () {
                      setState(() => {
                            transferBalanceFrom = account,
                            selectAccount = false
                          });
                    },
                    child: (buildAccount(account))),
                const Gap(8),
              ]))
          .toList(),
      const Gap(8),
    ]);
  }

  Widget buildBound() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text("Successfully connected to Ethereum VM address "),
      Text(widget.bindFor.evmAddress.shorten(),
          style: const TextStyle(fontWeight: FontWeight.bold)),
      const Gap(48),
    ]);
  }

  Widget buildBind() {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: const [
        Text("Start using Reef EVM smart contracts."),
        Gap(8),
        Text("First connect EVM address for:"),
        Gap(8)
      ]),
      // Bind for
      buildAccount(widget.bindFor),
      const Gap(16),
      if (hasBalanceForBinding(widget.bindFor)) ...[
        // Bind button
        buildButton(() async {
          final navigator = Navigator.of(context);
          ReefAppState.instance.accountCtrl
              .bindEvmAccount(widget.bindFor.address);
          navigator.pop();
        })
      ] else ...[
        // Insufficient balance
        if (transferBalanceFrom == null) ...[
          // No other accounts with enough balance
          const Text(
              "Not enough REEF in account for connect EVM address transaction fee."),
          const Gap(16),
        ] else ...[
          // Other accounts with enough balance
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: const [
              Text("~$MIN_BALANCE REEF ",
                  style: TextStyle(fontWeight: FontWeight.bold)),
              Text("is needed for transaction fee."),
            ]),
            const Gap(24),
            const Text("Coins will be transfered from account:"),
            const Gap(8)
          ]),
          // Transfer from
          InkWell(
              onTap: () {
                if (availableTxAccounts.length > 1) {
                  setState(() => selectAccount = true);
                }
              },
              child: (buildAccount(transferBalanceFrom))),
          const Gap(16),
          buildButton(() async {
            final navigator = Navigator.of(context);
            transfer();
            navigator.pop();
          }),
        ],
      ]
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectAccount)
            buildSelectAccount()
          else if (widget.bindFor.isEvmClaimed)
            buildBound()
          else
            buildBind(),
        ],
      ),
    );
  }
}

void showBindEvmModal(BuildContext context, {required bindFor}) {
  showModal(context,
      child: BindEvm(bindFor: bindFor),
      dismissible: true,
      headText: "Connect EVM");
}
