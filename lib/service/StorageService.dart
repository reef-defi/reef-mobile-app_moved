import 'dart:async';
import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/model/metadata/metadata.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  Completer<Box<dynamic>> mainBox = Completer();
  Completer<Box<dynamic>> metadataBox = Completer();
  Completer<Box<dynamic>> authUrlsBox = Completer();
  Completer<Box<dynamic>> accountsBox = Completer();
  Completer<Box<dynamic>> jwtsBox = Completer();

  StorageService() {
    _initAsync();
  }

  Future<dynamic> getValue(String key) =>
      mainBox.future.then((Box<dynamic> box) => box.get(key));

  Future<dynamic> setValue(String key, dynamic value) =>
      mainBox.future.then((Box<dynamic> box) => box.put(key, value));

  Future<dynamic> deleteValue(String key) =>
      mainBox.future.then((Box<dynamic> box) => box.delete(key));

  Future<dynamic> getMetadata(String genesisHash) =>
      metadataBox.future.then((Box<dynamic> box) => box.get(genesisHash));

  Future<List<Metadata>> getAllMetadatas() => metadataBox.future
      .then((Box<dynamic> box) => box.values.toList().cast<Metadata>());

  Future<dynamic> saveMetadata(Metadata metadata) => metadataBox.future
      .then((Box<dynamic> box) => box.put(metadata.genesisHash, metadata));

  Future<dynamic> deleteMetadata(String genesisHash) =>
      metadataBox.future.then((Box<dynamic> box) => box.delete(genesisHash));

  Future<dynamic> getAuthUrl(String url) =>
      authUrlsBox.future.then((Box<dynamic> box) => box.get(url));

  Future<List<AuthUrl>> getAllAuthUrls() => authUrlsBox.future
      .then((Box<dynamic> box) => box.values.toList().cast<AuthUrl>());

  Future<dynamic> saveAuthUrl(AuthUrl authUrl) => authUrlsBox.future
      .then((Box<dynamic> box) => box.put(authUrl.url, authUrl));

  Future<dynamic> deleteAuthUrl(String url) =>
      authUrlsBox.future.then((Box<dynamic> box) => box.delete(url));

  Future<dynamic> getAccount(String address) =>
      accountsBox.future.then((Box<dynamic> box) => box.get(address));

  Future<List<StoredAccount>> getAllAccounts() => accountsBox.future
      .then((Box<dynamic> box) => box.values.toList().cast<StoredAccount>());

  Future<dynamic> saveAccount(StoredAccount account) => accountsBox.future
      .then((Box<dynamic> box) => box.put(account.address, account));

  Future<dynamic> deleteAccount(String address) =>
      accountsBox.future.then((Box<dynamic> box) => box.delete(address));

  Future<dynamic> getJwt(String address) =>
      jwtsBox.future.then((Box<dynamic> box) => box.get(address));

  Future<dynamic> saveJwt(String address, String jwt) =>
      jwtsBox.future.then((Box<dynamic> box) => box.put(address, jwt));

  Future<dynamic> deleteJwt(String address) =>
      jwtsBox.future.then((Box<dynamic> box) => box.delete(address));

  Future<void> _initAsync() async {
    if (await _checkPermission()) {
      _initHive();
    }
  }

  Future<void> _initHive() async {
    final prefs = await SharedPreferences.getInstance();
    var dir = await getApplicationDocumentsDirectory();
    var path = "${dir.path}/hive_store";
    Hive
      ..init(path)
      ..registerAdapter(StoredAccountAdapter())
      ..registerAdapter(MetadataAdapter())
      ..registerAdapter(AuthUrlAdapter());

    mainBox.complete(Hive.openBox('ReefChainBox'));
    metadataBox.complete(Hive.openBox('MetadataBox'));
    authUrlsBox.complete(Hive.openBox('AuthUrlsBox'));
    jwtsBox.complete(Hive.openBox('JwtsBox'));

    // Encryption
    const secureStorage = FlutterSecureStorage();
    if (prefs.getBool('first_run') ?? true) {
      await secureStorage.deleteAll();

      prefs.setBool('first_run', false);
    }
    var key = await secureStorage.read(key: 'encryptionKey');
    if (key == null) {
      var key = Hive.generateSecureKey();
      await secureStorage.write(
          key: 'encryptionKey', value: base64UrlEncode(key));
    }
    key = await secureStorage.read(key: 'encryptionKey');
    var encryptionKey = base64Url.decode(key!);

    accountsBox.complete(Hive.openBox('AccountsBox',
        encryptionCipher: HiveAesCipher(encryptionKey)));
  }

  Future<bool> _checkPermission() async {
    final status = await Permission.storage.status;
    print('PERMISSION STORAGE=$status');
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      if (await Permission.storage.request().isGranted) {
        print("PERMISSION GRANTED");
        return true;
      } else {
        print("PERMISSION DENIED");
        return true;
      }
    }
    return await Permission.storage.status.isGranted;
  }
}
