import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:reef_mobile_app/components/modal.dart';
import 'package:reef_mobile_app/model/metadata/metadata.dart';
import 'package:reef_mobile_app/pages/SplashScreen.dart';
import 'package:reef_mobile_app/utils/elements.dart';
import 'package:reef_mobile_app/utils/gradient_text.dart';
import 'package:reef_mobile_app/utils/styles.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

List<TableRow> createTable({required keyTexts, required valueTexts}) {
  List<TableRow> rows = [];
  for (int i = 0; i < keyTexts.length; ++i) {
    rows.add(TableRow(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: GradientText(
          keyTexts[i],
          gradient: textGradient(),
          textAlign: TextAlign.right,
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
        ),
      ),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 4.0),
        child: Text(
          valueTexts[i],
          style: const TextStyle(fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]));
  }
  return rows;
}

class MetadataAproval extends StatefulWidget {
  final Metadata metadata;
  final int currVersion;
  const MetadataAproval(
      {Key? key, required this.metadata, required this.currVersion})
      : super(key: key);

  @override
  State<MetadataAproval> createState() => _MetadataAprovalState();
}

class _MetadataAprovalState extends State<MetadataAproval> {
  TextEditingController valueContainer = TextEditingController();
  bool value = false;

  @override
  Widget build(BuildContext context) {
    if (widget.currVersion == widget.metadata.specVersion) {
      return Padding(
          padding: EdgeInsets.fromLTRB(24, 0, 24, 32.0),
          child: Text(
            AppLocalizations.of(context)!.metadata_up_to_date,
            style: TextStyle(fontSize: 16),
            overflow: TextOverflow.ellipsis,
          ));
    }

    String currVersion =
        widget.currVersion == 0 ? "<unknown>" : widget.currVersion.toString();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 32.0),
      child: Column(
        children: [
          //Information Section
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(4),
              },
              children: createTable(keyTexts: [
                "Chain",
                "Decimals",
                "Symbol",
                "Upgrade"
              ], valueTexts: [
                widget.metadata.chain,
                widget.metadata.tokenDecimals.toString(),
                widget.metadata.tokenSymbol,
                "$currVersion -> ${widget.metadata.specVersion}"
              ]),
            ),
          ),
          //BoxContent
          ViewBoxContainer(
            color: Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 24.0, horizontal: 16.0),
              child: Column(children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      CupertinoIcons.exclamationmark_triangle_fill,
                      size: 16,
                      color: Styles.primaryAccentColorDark,
                    ),
                    const Gap(6),
                    Expanded(
                        flex: 1,
                        child: SizedBox(
                          width: 1,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                AppLocalizations.of(context)!.approve_metadata,
                                style: TextStyle(
                                    fontSize: 16, color: Styles.textColor),
                                textAlign: TextAlign.justify,
                              ),
                            ],
                          ),
                        )),
                  ],
                ),
                const Gap(12),
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
                    onPressed: () {
                      Navigator.pop(context, true);
                    },
                    child: const Text(
                      'Yes, do this metadata update',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    child: Text(AppLocalizations.of(context)!.reject,
                        style: TextStyle(
                          color: Styles.primaryAccentColorDark,
                          decoration: TextDecoration.underline,
                          fontSize: 16,
                        ))),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

Future<dynamic> showMetadataAprovalModal(
    {required metadata, required currVersion}) {
  return showModal(navigatorKey.currentContext,
      child: MetadataAproval(metadata: metadata, currVersion: currVersion),
      dismissible: false,
      headText: "Metadata");
}
