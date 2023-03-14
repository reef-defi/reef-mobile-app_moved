import 'package:reef_mobile_app/model/auth_url/auth_url.dart';
import 'package:reef_mobile_app/service/StorageService.dart';
import 'package:reef_mobile_app/model/metadata/metadata.dart';
import 'package:reef_mobile_app/model/account/stored_account.dart';



class StorageCtrl {
  final StorageService storage;

  StorageCtrl(this.storage);

  Future<dynamic> getValue(String key)=>storage.getValue(key);

  Future<dynamic> setValue(String key,dynamic value)=>storage.setValue(key,value);
  
  Future<dynamic> deleteValue(String key)=> storage.deleteValue(key);

  Future<dynamic> getMetadata(String genesisHash)=>storage.getMetadata(genesisHash);

  Future<dynamic> getAllMetadatas()=>storage.getAllMetadatas();

  Future<dynamic> saveMetadata(Metadata metadata)=>storage.saveMetadata(metadata);

  Future<dynamic> deleteMetadata(String genesisHash)=>storage.deleteMetadata(genesisHash);

  Future<dynamic> getAuthUrl(String url)=>storage.getAuthUrl(url);

  Future<dynamic> getAllAuthUrls()=>storage.getAllAuthUrls();

  Future<dynamic> saveAuthUrl(AuthUrl authUrl)=>storage.saveAuthUrl(authUrl);

  Future<dynamic> deleteAuthUrl(String url) =>storage.deleteAuthUrl(url);

  Future<dynamic> getAccount(String address) =>storage.getAccount(address);

  Future<dynamic> getAllAccounts() =>storage.getAllAccounts();

  Future<dynamic> saveAccount(StoredAccount account) => storage.saveAccount(account);

  Future<dynamic> deleteAccount(String address) => storage.deleteAccount(address);

  Future<dynamic> getJwt(String address) => storage.getJwt(address);

  Future<dynamic> saveJwt(String address, String jwt) => storage.saveJwt(address,jwt);

  Future<dynamic> deleteJwt(String address) => storage.deleteJwt(address);
}
