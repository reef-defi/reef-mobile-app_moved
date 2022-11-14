import 'package:flutter/material.dart';
import 'package:reef_mobile_app/components/modals/metadata_aproval_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/StorageKey.dart';
import 'package:reef_mobile_app/model/metadata/metadata.dart';

import '../components/SignatureContentToggle.dart';

class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  _checkMetadata() async {
    var metadataMap = await ReefAppState.instance.metadataCtrl.getMetadata();
    Metadata metadata = Metadata.fromMap(metadataMap);
    var chain =
        await ReefAppState.instance.storage.getMetadata(metadata.genesisHash);
    int currVersion = chain != null ? chain.specVersion : 0;
    var response = await showMetadataAprovalModal(
        metadata: metadata, currVersion: currVersion);
    if (response == true) {
      ReefAppState.instance.storage.saveMetadata(metadata);
    }
  }

  _deleteMetadata() async {
    var metadatas = await ReefAppState.instance.storage.getAllMetadatas();
    for (var metadata in metadatas) {
      metadata.delete();
    }
  }

  _signRaw(address) async {
    const message = "Hello World";
    var signTestRes =
        await ReefAppState.instance.signingCtrl.signRaw(address, message);
    print("SGN RAW TEST=$signTestRes");
  }

  _signPayload(address) async {
    // Sqwid auction transaction
    const payload = {
      "specVersion": "0x00000008",
      "transactionVersion": "0x00000002",
      "address": "5EnY9eFwEDcEJ62dJWrTXhTucJ4pzGym4WZ2xcDKiT3eJecP",
      "blockHash":
          "0xb4c87dc6df4fcf1b5b517e0f44510959770483df63cb24cee56e7826f5340264",
      "blockNumber": "0x003670cd",
      "era": "0xd500",
      "genesisHash":
          "0x0f89efd7bf650f2d521afef7456ed98dff138f54b5b7915cc9bce437ab728660",
      "method":
          "0x15000a3f2785dbbc5f022de511aab8846388b78009fd902e519f9000000000000000000000000000000000000000000000000000000000000000a4000064a7b3b6e00d0000000000000000d430230000000000d0070000",
      "nonce": "0x0000003b",
      "signedExtensions": [
        "CheckSpecVersion",
        "CheckTxVersion",
        "CheckGenesis",
        "CheckMortality",
        "CheckNonce",
        "CheckWeight",
        "ChargeTransactionPayment",
        "SetEvmOrigin"
      ],
      "tip": "0x00000000000000000000000000000000",
      "version": 4
    };
    var signTestRes =
        await ReefAppState.instance.signingCtrl.signPayload(address, payload);
    print("SGN PAYLOAD TEST=$signTestRes");
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Padding(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 48),
      child: Column(
        children: [
          Row(children: [
            ElevatedButton(
              child: const Text('check meta'),
              onPressed: () => _checkMetadata(),
            ),
            ElevatedButton(
              child: const Text('delete meta'),
              onPressed: () => _deleteMetadata(),
            ),
          ]),
          Row(children: [
            ElevatedButton(
              child: const Text('delete password'),
              onPressed: () {
                ReefAppState.instance.storage
                    .deleteValue(StorageKey.password.name);
              },
            ),
            ElevatedButton(
              child: const Text('delete jwts'),
              onPressed: () async => ReefAppState.instance.storage.deleteJwt(
                  await ReefAppState.instance.storage
                      .getValue(StorageKey.selected_address.name)),
            ),
          ]),
          Row(children: [
            ElevatedButton(
              child: const Text('sign raw'),
              onPressed: () {
                _signRaw(ReefAppState.instance.model.accounts.selectedAddress);
              },
            ),
            ElevatedButton(
              child: const Text('sign payload'),
              onPressed: () {
                _signPayload(
                    ReefAppState.instance.model.accounts.selectedAddress);
              },
            ),
          ]),
        ],
      ),
    ));
  }
}
