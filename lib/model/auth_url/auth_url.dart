import 'package:hive/hive.dart';

part 'auth_url.g.dart';

@HiveType(typeId: 3)
class AuthUrl extends HiveObject {
  @HiveField(0)
  late String url;

  @HiveField(1)
  late bool isAllowed;

  AuthUrl(this.url, this.isAllowed);

  Map toJson() => {'url': url, 'isAllowed': isAllowed};
}
