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
          ]),
          Row(children: [
            ElevatedButton(
              child: const Text('delete meta'),
              onPressed: () => _deleteMetadata(),
            ),
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
        ],
      ),
    ));
  }
}
