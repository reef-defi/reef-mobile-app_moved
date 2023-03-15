import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';

import '../../model/ReefAppState.dart';
import '../../model/signing/signature_request.dart';
import '../../utils/styles.dart';

class SignatureControls extends StatefulWidget {
  const SignatureControls(this._signatureReq, this._confirm, this._cancel, {Key? key}) : super(key: key);

  final SignatureRequest _signatureReq;
  final Future<bool> Function(String password) _confirm;
  final Function() _cancel;

  @override
  State<SignatureControls> createState() => _SignatureControlsState();
}

class _SignatureControlsState extends State<SignatureControls> {
  bool _passwordMatch=false;
  bool _biometricsIsAvailable = false;

  final TextEditingController _passwordController = TextEditingController();
  String password = "";

  @override
  void initState() {
    super.initState();

    _passwordController.addListener(() {
      setState(() {
        password = _passwordController.text;
      });
    });
    ReefAppState.instance.signingCtrl.checkBiometricsSupport().then((value) {
      setState(() {
        _biometricsIsAvailable = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(children: [
        if (!_biometricsIsAvailable) ...[
          const Divider(
            color: Styles.textLightColor,
            thickness: 1,
          ),
          const Gap(12),
          const Text(
            "PASSWORD FOR REEF APP",
            style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Styles.textLightColor),
          ),
          const Gap(8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            decoration: BoxDecoration(
              color: Styles.whiteColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0x20000000),
                width: 1,
              ),
            ),
            child: TextField(
              controller: _passwordController,
              obscureText: true,
              decoration: const InputDecoration.collapsed(hintText: ''),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
          ),
          const Gap(8),
          if (_passwordMatch==false&&password.isNotEmpty)
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  CupertinoIcons.exclamationmark_triangle_fill,
                  color: Styles.errorColor,
                  size: 16,
                ),
                const Gap(8),
                Flexible(
                  child: Text(
                    "Password is incorrect",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            )
        ],
        buildButtons(context)
      ],),
    );
  }

  Row buildButtons(BuildContext context) {
    return Row(
    children: [
      Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
        ),
        width: 240.0,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40)),
            shadowColor: const Color(0x559d6cff),
            elevation: 5,
            backgroundColor: Styles.secondaryAccentColor,
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          onPressed: ()  {
            setState(() async{
              _passwordMatch = await widget._confirm(password);
            });
          },
          child: Text(
            ReefAppState.instance.signingCtrl.isTransaction(widget._signatureReq)
                ? AppLocalizations.of(context)!.sign_transaction
                : AppLocalizations.of(context)!.sign_message,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
      Padding(
        padding: const EdgeInsets.all(2.0),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40)),
            shadowColor: const Color(0x559d6cff),
            elevation: 5,
            backgroundColor: Styles.primaryAccentColor,
            padding: const EdgeInsets.symmetric(
                vertical: 16, horizontal: 20),
          ),
          onPressed: widget._cancel,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.cancel, size: 18),
              const SizedBox(width: 8),
              Text(
                AppLocalizations.of(context)!.cancel,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
  }

}