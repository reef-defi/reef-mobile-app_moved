import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/styles.dart';

class SelectLanguage extends StatefulWidget {
  const SelectLanguage({Key? key}) : super(key: key);
  @override
  State<SelectLanguage> createState() => _SelectLanguageState();
}

class _SelectLanguageState extends State<SelectLanguage> {
  String? _selectedLanguage = "English";
  final Map<String, String> _languageMap = {
    'English': 'en',
    'Hindi': 'hi',
    'Italian': 'it',
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 0, left: 24, bottom: 36, right: 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Gap(12),
        Builder(builder: (context) {
          return Text(
            AppLocalizations.of(context)!.select_language,
            style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Styles.textLightColor),
          );
        }),
        const Gap(8),
        DropdownButtonFormField<String>(
          decoration: InputDecoration(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0x20000000),
                width: 1,
              ),
            ),
          ),
          value: _selectedLanguage,
          items: _languageMap.keys
              .map((language) => DropdownMenuItem<String>(
                    value: language,
                    child: Text(
                      language,
                      style: const TextStyle(
                        fontSize: 16,
                      ),
                    ),
                  ))
              .toList(),
          onChanged: (String? value) {
            setState(() {
              _selectedLanguage = value;
            });
          },
        ),
        const Gap(30),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
          ),
          width: double.infinity,
          child: Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    splashFactory: NoSplash.splashFactory,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(40)),
                    shadowColor: const Color(0x559d6cff),
                    elevation: 5,
                    backgroundColor: const Color(0xff9d6cff),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () {
                    ReefAppState appState = ReefAppState.instance;
                    if (_selectedLanguage == 'English') {
                      appState.localeCtrl.changeSelectedLanguage('en');
                      SplashApp.setLocale(context, 'en');
                    } else if (_selectedLanguage == 'Hindi') {
                      appState.localeCtrl.changeSelectedLanguage('hi');
                      SplashApp.setLocale(context, 'hi');
                    } else if (_selectedLanguage == 'Italian') {
                      appState.localeCtrl.changeSelectedLanguage('it');
                      SplashApp.setLocale(context, 'it');
                    }
                    Navigator.pop(context);
                  },
                  child: Builder(builder: (context) {
                    return Text(
                      AppLocalizations.of(context)!.change_language,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
      ]),
    );
  }
}

void showSelectLanguageModal(String title, {BuildContext? context}) {
  showModal(context ?? navigatorKey.currentContext,
      child: const SelectLanguage(), headText: title);
}
