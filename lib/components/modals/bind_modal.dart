import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/account/ReefSigner.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:reef_mobile_app/utils/functions.dart';

const MIN_BALANCE = 5;

class BindEvm extends StatefulWidget {
  final ReefSigner bindFor;
  final Function() callback;
  const BindEvm({Key? key, required this.bindFor, required this.callback})
      : super(key: key);

  @override
  State<BindEvm> createState() => _BindEvmState();
}

class _BindEvmState extends State<BindEvm> {
  TextEditingController valueContainer = TextEditingController();
  bool value = false;

  hasBalanceForBinding(ReefSigner reefSigner) {
    return reefSigner.balance >= BigInt.from(MIN_BALANCE * 1e18);
  }

  getSignersWithEnoughBalance(ReefSigner bindFor) {
    List<ReefSigner> availableTxAccounts = ReefAppState
        .instance.model.accounts.signers
        .where((signer) =>
            signer.address != bindFor.address && hasBalanceForBinding(signer))
        .toList();
    availableTxAccounts.sort((a, b) => a.balance.compareTo(b.balance));
    return availableTxAccounts;
  }

  bind(String address) async {
    var response =
        await ReefAppState.instance.accountCtrl.bindEvmAccount(address);
    // TODO wait for tx to be included in block ?
    print(response);
  }

  Widget buildAccount(ReefSigner signer) {
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
                        style: TextStyle(
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

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!widget.bindFor.isEvmClaimed) ...[
            Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text("Start using Reef EVM smart contracts."),
                  Gap(8),
                  Text("First connect EVM address for:"),
                  Gap(8)
                ]),
            // Bind for
            buildAccount(widget.bindFor),
            const Gap(16),
            // Unsufficient balance
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
            buildAccount(widget.bindFor),
            const Gap(16),
          ] else ...[
            // Already bound
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text("Successfully connected to Ethereum VM address "),
              Text(widget.bindFor.evmAddress.shorten(),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const Gap(48),
            ]),
          ],
          // Continue button
          Container(
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
                backgroundColor: Styles.primaryAccentColorDark,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () async {
                await widget.callback();
                if (!mounted) return;
                Navigator.pop(context);
              },
              child: const Text(
                'Continue',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void showBindEvmModal(BuildContext context,
    {required bindFor, required callback}) {
  showModal(context,
      child: BindEvm(
        bindFor: bindFor,
        callback: callback,
      ),
      dismissible: true,
      headText: "Connect EVM");
}
