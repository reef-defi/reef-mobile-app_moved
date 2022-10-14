import 'package:flutter/material.dart';
import 'package:reef_mobile_app/model/ReefAppState.dart';
import 'package:reef_mobile_app/model/auth_url/auth_url.dart';

import '../components/SignatureContentToggle.dart';

// TODO Page for testing. Delete after testing is done.
class TestPage extends StatefulWidget {
  const TestPage({Key? key}) : super(key: key);

  @override
  State<TestPage> createState() => _TestPageState();
}

class _TestPageState extends State<TestPage> {
  var url = "mobile-dapp-test.web.app";

  void _set(bool isAllowed) {
    ReefAppState.instance.storage.saveAuthUrl(AuthUrl(url, isAllowed));
  }

  Future<List<AuthUrl>> _list() async {
    var authUrls = await ReefAppState.instance.storage.getAllAuthUrls();
    for (var authUrl in authUrls) {
      print('${authUrl.url} --> ${authUrl.isAllowed}');
    }
    return authUrls;
  }

  void _get() async {
    var authUrl = await ReefAppState.instance.storage.getAuthUrl(url);
    if (authUrl != null) {
      print('${authUrl.url} --> ${authUrl.isAllowed}');
    } else {
      print('not found');
    }
  }

  void _delete() {
    ReefAppState.instance.storage.deleteAuthUrl(url);
  }

  void _deleteAll() async {
    (await _list()).forEach((element) {
      ReefAppState.instance.storage.deleteAuthUrl(element.url);
    });
  }

  @override
  Widget build(BuildContext context) {
    return SignatureContentToggle(Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24),
      child: Column(
        children: [
          ElevatedButton(
              child: const Text('Set true'), onPressed: () => _set(true)),
          ElevatedButton(
              child: const Text('Set false'), onPressed: () => _set(false)),
          ElevatedButton(child: const Text('List'), onPressed: _list),
          ElevatedButton(child: const Text('Get'), onPressed: _get),
          ElevatedButton(child: const Text('Delete'), onPressed: _delete),
          ElevatedButton(
              child: const Text('Delete all'), onPressed: _deleteAll),
        ],
      ),
    ));
  }
}
