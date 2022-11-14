import 'package:reef_mobile_app/model/network/network_model.dart';
import 'package:reef_mobile_app/model/signing/signature_requests.dart';
import 'package:reef_mobile_app/model/tokens/token_model.dart';

import 'account/account_model.dart';

class ViewModel {
  final tokens = TokenModel();
  final accounts = AccountModel();
  final signatureRequests = SignatureRequests();
  final network = NetworkModel();
}
