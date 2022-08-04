import 'JsApiService.dart';

class DAppRequestService {
  const DAppRequestService();

  void handleDAppMsgRequest(JsApiMessage message, void Function(String reqId, dynamic value) responseFn) {
    if (message.msgType == 'pub(phishing.redirectIfDenied)') {
      print('flutter DAPP req=${message.msgType} value= ${message.value}');
      responseFn(message.reqId, _redirectIfPhishing(message.value['url']));
    }
    print('DAPP MSG= ${message.msgType} val= ${message.url}');
    if (message.msgType != 'pub(authorize.tab)' && !_ensureUrlAuthorized(message.value['url'])) {
      print('Domain not authorized= ${message.value['url']}');
      return;
    }

    switch(message.msgType){
      case 'pub(bytes.sign)':
        print("TODO handle request");
        break;
      case 'pub(extrinsic.sign)':
        print("TODO handle request");
        break;
      case 'pub(authorize.tab)':
      // TODO display confirmation - message.value.origin is the app name
        responseFn(message.reqId, true);
        break;

      case 'pub(accounts.list)':
        print('dapp accountsLIST req');
      // TODO return this.accountsList(url, request as RequestAccountList);
        responseFn(message.reqId, ['account']);
        break;
    }
  }

  bool _redirectIfPhishing(String url) {
    // TODO check against list
    return false;
  }

  bool _ensureUrlAuthorized(String? url) {
    // TODO check against authorized domains
    return true;
  }
}
