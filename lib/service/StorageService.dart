import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';

class StorageService {
  Completer<Box<dynamic>> box = Completer();

  StorageService() {
    _checkPermission();
    _initAsync();
  }

  Future<dynamic> getValue(String key)=>box.future.then((Box<dynamic> box) => box.get(key));

  Future<dynamic> setValue(String key, dynamic value)=>box.future.then((Box<dynamic> box) => box.put(key, value));

  _initAsync() async {
    if(await _checkPermission() ){
      _initHive();
    }
  }

  _initHive() async {
    var dir = await getApplicationDocumentsDirectory();
    var path = dir.path+"/hive_store";
    Hive
      ..init(path)
      ..registerAdapter(StoredAccountAdapter());
    
    // Encryption
    const secureStorage = FlutterSecureStorage();
    var containsEncryptionKey = await secureStorage.containsKey(key: 'encryptionKey');
    if (!containsEncryptionKey) {
      var key = Hive.generateSecureKey();
      await secureStorage.write(key: 'encryptionKey', value: base64UrlEncode(key));
    }
    var key = await secureStorage.read(key: 'encryptionKey');
    var encryptionKey = base64Url.decode(key!);
    box.complete(Hive.openBox('ReefChainBoxEncrypted', encryptionCipher: HiveAesCipher(encryptionKey)));
  }

  Future<bool> _checkPermission() async {
    var status = await Permission.storage.status;
    print('PERMISSION STORAGE=$status');
    if (status.isDenied) {
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      if (await Permission.storage.request().isGranted) {
        print("PERMISSION GRANTED");
      } else {
        print("PERMISSION DENIED");
      }
    }
    return status.isGranted;
  }
}
