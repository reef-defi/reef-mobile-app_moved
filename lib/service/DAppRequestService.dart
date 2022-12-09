import 'dart:convert';

import 'package:reef_mobile_app/components/modals/auth_url_aproval_modal.dart';
import 'package:reef_mobile_app/components/modals/metadata_aproval_modal.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/model/metadata/metadata.dart';

import 'JsApiService.dart';

enum AuthUrlStatus {
  authorized,
  notAuthorized,
  notFound,
}

class DAppRequestService {
  const DAppRequestService();

  void handleDAppMsgRequest(JsApiMessage message,
      void Function(String reqId, dynamic value) responseFn) async {
    if (message.msgType == 'pub(phishing.redirectIfDenied)') {
      responseFn(message.reqId, _redirectIfPhishing(message.value['url']));
    }

    if (message.msgType != 'pub(authorize.tab)' &&
        await _getAuthUrlStatus(message.url) != AuthUrlStatus.authorized) {
      print('Domain not authorized= ${message.url} - ${message.msgType}');
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
            await _authorizeDapp(message.value['origin'], message.url));
        break;
      case 'pub(accounts.list)':
        var accounts =
            await ReefAppState.instance.accountCtrl.getStorageAccountsList();
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

  Future<AuthUrlStatus> _getAuthUrlStatus(String? url) async {
    if (url == null) return AuthUrlStatus.notFound;

    var authUrl = await ReefAppState.instance.storage.getAuthUrl(url);
    if (authUrl == null) return AuthUrlStatus.notFound;

    return authUrl.isAllowed
        ? AuthUrlStatus.authorized
        : AuthUrlStatus.notAuthorized;
  }

  Future<bool> _authorizeDapp(String dAppName, String? url) async {
    switch (await _getAuthUrlStatus(url)) {
      case AuthUrlStatus.authorized:
        return true;
      case AuthUrlStatus.notFound:
        var response =
            await showAuthUrlAprovalModal(origin: dAppName, url: url);
        await ReefAppState.instance.storage
            .saveAuthUrl(AuthUrl(url!, response == true));
        return response == true;
      case AuthUrlStatus.notAuthorized:
      default:
        return false;
    }
  }

  Future<bool> _metadataProvide(Map metadataMap) async {
    Metadata metadata = Metadata.fromMap(metadataMap);
    var chain =
        await ReefAppState.instance.storage.getMetadata(metadata.genesisHash);
    var currVersion = chain != null ? chain.specVersion.toString() : 0;
    var response = await showMetadataAprovalModal(
      metadata: metadata,
      currVersion: currVersion,
    );
    if (response == true) {
      await ReefAppState.instance.storage.saveMetadata(metadata);
      return true;
    }
    return false;
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
