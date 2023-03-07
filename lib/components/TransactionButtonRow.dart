import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class TransactionButtonRow extends StatelessWidget {
  final bool biometricsIsAvailable;
  final Function authenticateWithBiometrics;
  final Function authenticateWithPassword;
  final bool isTransaction;
  final String password;
  final Function cancelCallback;

  const TransactionButtonRow({
    Key? key,
    required this.biometricsIsAvailable,
    required this.authenticateWithBiometrics,
    required this.authenticateWithPassword,
    required this.isTransaction,
    required this.password,
    required this.cancelCallback,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
            onPressed: () {
              if (biometricsIsAvailable) {
                authenticateWithBiometrics();
              } else {
                authenticateWithPassword(password);
              }
            },
            child: Text(
              isTransaction
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
            onPressed: () => cancelCallback(),
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
