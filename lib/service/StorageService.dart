import 'dart:async';
import 'dart:io';

import 'package:hive/hive.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';

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
    Hive..init(path);
    // ..registerAdapter(PersonAdapter());
    box.complete(Hive.openBox('ReefChainBox'));
  }

  Future<bool> _checkPermission() async {
    var status = await Permission.storage.status;
    print('PERMISSION STORAGE=$status');
    if (status.isDenied) {
      print('PERMISSION STORAGE=DENIED');
      // We didn't ask for permission yet or the permission has been denied before but not permanently.
      // TODO ask for permission
      await Permission.storage.request();
      if (await Permission.storage.request().isGranted) {
        print("PERMISSION GRANTED");
      } else {
        print("PERMISSION DENIED");
      }
    }
    return status.isGranted;
  }
}
