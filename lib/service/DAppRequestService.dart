import 'dart:convert';

import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/metadata/metadata.dart';

import 'JsApiService.dart';

class DAppRequestService {
  const DAppRequestService();

  void handleDAppMsgRequest(JsApiMessage message,
      void Function(String reqId, dynamic value) responseFn) async {
    if (message.msgType == 'pub(phishing.redirectIfDenied)') {
      responseFn(message.reqId, _redirectIfPhishing(message.value['url']));
    }

    if (message.msgType != 'pub(authorize.tab)' &&
        !_ensureUrlAuthorized(message.url)) {
      print('Domain not authorized= ${message.url}');
      // TODO display alert so user is aware domain is disabled
      return;
    }

    switch (message.msgType) {
      case 'pub(bytes.sign)':
        var signature = await ReefAppState.instance.signingCtrl
            .signRaw(message.value['address'], message.value['data']);
        responseFn(message.reqId, '${jsonEncode(signature)}');
        break;
      case 'pub(extrinsic.sign)':
        var signature = await ReefAppState.instance.signingCtrl
            .signPayload(message.value['address'], message.value);
        responseFn(message.reqId, '${jsonEncode(signature)}');
        break;
      case 'pub(authorize.tab)':
        responseFn(message.reqId,
            _authorizeDapp(message.value['origin'], message.url));
        break;
      case 'pub(accounts.list)':
        var accounts =
            await ReefAppState.instance.accountCtrl.getAccountsList();
        responseFn(message.reqId, jsonEncode(accounts));
        break;
      case 'pub(accounts.subscribe)':
        // TODO handle subscription
        ReefAppState.instance.accountCtrl
            .availableSignersStream()
            .listen((event) {
          print('accounts.subscribe event= $event');
        });
        responseFn(message.reqId, 'true');
        break;
      case 'pub(metadata.list)':
        responseFn(message.reqId, await _metadataList());
        break;
      case 'pub(metadata.provide)':
        responseFn(message.reqId, await _metadataProvide(message.value));
        break;
    }
  }

  bool _redirectIfPhishing(String url) {
    // TODO check against list
    return false;
  }

  bool _ensureUrlAuthorized(String? url) {
    if (url == null) {
      return false;
    }
    // TODO check against authorized domains
    return true;
  }

  _authorizeDapp(String dAppName, String? url) {
    if (url == null) {
      return false;
    }
    // TODO display modal and save url for _ensureUrlAuthorized
    return true;
  }

  Future<bool> _metadataProvide(Map metadataMap) async {
    Metadata metadata = Metadata.fromMap(metadataMap);
    // TODO confirmation modal
    var chain =
        await ReefAppState.instance.storage.getMetadata(metadata.genesisHash);
    print(
        "chain: ${metadata.chain}, icon: ${metadata.icon}, decimals: ${metadata.tokenDecimals}, symbol: ${metadata.tokenSymbol}, upgrade: ${chain != null ? chain.specVersion : '<unknown>'} -> ${metadata.specVersion}");
    print(
        "This approval will add the metadata to your mobile app, allowing future requests to be decoded using this metadata.");
    print("Yes, do this metadata update");
    print("Reject");
    await ReefAppState.instance.storage.saveMetadata(metadata);
    return true;
  }

  Future<String> _metadataList() async {
    var metadatas = await ReefAppState.instance.storage.getAllMetadatas();
    var injectedMetadataKnown = [];
    for (var metadata in metadatas) {
      injectedMetadataKnown.add(metadata.toInjectedMetadataKnownJson());
    }
    return jsonEncode(injectedMetadataKnown);
  }
}
